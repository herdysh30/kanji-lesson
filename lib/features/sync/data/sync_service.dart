import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart' as drift;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:kanji_lesson/core/database/app_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Syncs drift progress tables to Cloud Firestore.
///
/// Layout: `users/{uid}/progress/{docId}`, `users/{uid}/daily/{date}`,
/// `users/{uid}/quiz/{contentKey}`. Doc IDs are URI-encoded (progress doc IDs
/// are kanji/vocab strings that may contain `/`).
///
/// Writes are delta-synced: only rows with `updatedAt` newer than the last
/// successful sync watermark are uploaded. Firestore batches are committed in
/// chunks of 450 ops to stay under the 500-op limit.
class SyncService {
  SyncService({required this.db, FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final AppDatabase db;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const _watermarkKeyPrefix = 'sync.watermark.';
  static const int _batchChunkSize = 450;

  Timer? _debounceTimer;
  bool _syncing = false;
  SharedPreferences? _prefs;

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _progressCol =>
      _firestore.collection('users').doc(_uid!).collection('progress');
  CollectionReference<Map<String, dynamic>> get _dailyCol =>
      _firestore.collection('users').doc(_uid!).collection('daily');
  CollectionReference<Map<String, dynamic>> get _quizCol =>
      _firestore.collection('users').doc(_uid!).collection('quiz');

  /// Debounced auto-sync; call after any local progress write.
  void scheduleSync() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      syncNow().catchError((Object e) {
        debugPrint('SyncService auto-sync failed:  $e');
      });
    });
  }

  /// Two-way sync (auto + manual). Throws on failure so callers can surface it.
  Future<void> syncNow() async {
    _debounceTimer?.cancel();
    final uid = _uid;
    if (uid == null || _syncing) return;
    _syncing = true;
    try {
      // Ensure parent doc exists so subcollections are visible in Console.
      await _firestore.collection('users').doc(uid).set(
            {'lastSyncAt': FieldValue.serverTimestamp()},
            SetOptions(merge: true),
          );
      await _downloadAll();
      await _uploadChanged();
      await _saveWatermark();
      await _firestore.collection('users').doc(uid).set(
            {'lastSyncAt': FieldValue.serverTimestamp()},
            SetOptions(merge: true),
          );
    } catch (e) {
      debugPrint('SyncService.syncNow failed: $e');
      rethrow;
    } finally {
      _syncing = false;
    }
  }

  Future<SharedPreferences> get _sharedPrefs async =>
      _prefs ??= await SharedPreferences.getInstance();

  /// Last successful sync instant, per user.
  Future<DateTime?> _readWatermark() async {
    final prefs = await _sharedPrefs;
    final ms = prefs.getInt('$_watermarkKeyPrefix$_uid');
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<void> _saveWatermark() async {
    final prefs = await _sharedPrefs;
    await prefs.setInt(
        '$_watermarkKeyPrefix$_uid', DateTime.now().millisecondsSinceEpoch);
  }

  /// Upload only rows changed since the last watermark.
  ///
  /// First-ever sync (no watermark) uploads everything — equivalent to the
  /// old full sync.
  Future<void> _uploadChanged() async {
    final watermark = await _readWatermark();
    final since = watermark ?? DateTime.fromMillisecondsSinceEpoch(0);

    // ponytail: 300 newest quiz per sync; watermark catches up rest next tick.
    final progress = await db.getProgressSince(since);
    final daily = await db.getDailyProgressSince(_dateKey(watermark ?? since));
    final minQuizId = watermark?.millisecondsSinceEpoch ?? 0;
    final quiz = await db.getQuizResultsSince(minQuizId);

    final ops = <List<Object?>>[];
    void op(String path, Map<String, dynamic> data) => ops.add([path, data]);

    for (final p in progress) {
      if (p.status == 'unseen') continue;
      op(
        _progressCol.doc(Uri.encodeComponent(p.kanjiCharacter)).path,
        {
          'kanjiCharacter': p.kanjiCharacter,
          'status': p.status,
          'correctCount': p.correctCount,
          'wrongCount': p.wrongCount,
          'ease': p.ease,
          'intervalDays': p.intervalDays,
          'repetitions': p.repetitions,
          'lastReviewedAt': p.lastReviewedAt?.toIso8601String(),
          'nextReviewAt': p.nextReviewAt?.toIso8601String(),
          'firstLearnedAt': p.firstLearnedAt?.toIso8601String(),
          'updatedAt': p.updatedAt.toIso8601String(),
          'isBookmarked': p.isBookmarked,
        },
      );
    }

    for (final d in daily) {
      op(
        _dailyCol.doc(Uri.encodeComponent(d.date)).path,
        {
          'date': d.date,
          'newKanjiCount': d.newKanjiCount,
          'reviewedKanjiCount': d.reviewedKanjiCount,
          'correctAnswers': d.correctAnswers,
          'wrongAnswers': d.wrongAnswers,
          'dailyGoal': d.dailyGoal,
          'goalCompleted': d.goalCompleted,
        },
      );
    }

    for (final q in quiz) {
      op(
        _quizCol.doc(_quizKey(q)).path,
        {
          'key': _quizKey(q),
          'date': q.date.toIso8601String(),
          'jlptLevel': q.jlptLevel,
          'quizType': q.quizType,
          'totalQuestions': q.totalQuestions,
          'correctAnswers': q.correctAnswers,
          'accuracy': q.accuracy,
          'questionsJson': q.questionsJson,
        },
      );
    }

    // Commit in chunks of <=450 ops (Firestore batch limit is 500).
    for (var i = 0; i < ops.length; i += _batchChunkSize) {
      final chunk =
          ops.sublist(i, (i + _batchChunkSize).clamp(0, ops.length));
      final batch = _firestore.batch();
      for (final entry in chunk) {
        batch.set(
          _firestore.doc(entry[0]! as String),
          entry[1]! as Map<String, dynamic>,
          SetOptions(merge: true),
        );
      }
      await batch.commit();
    }

    if (progress.isNotEmpty || daily.isNotEmpty || quiz.isNotEmpty) {
      debugPrint('SyncService: uploaded ${progress.length} progress, '
          '${daily.length} daily, ${quiz.length} quiz');
    }
  }

  String _dateKey(DateTime dt) {
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '${dt.year}-$m-$d';
  }

  /// Stable content key so re-uploads overwrite instead of duplicating.
  String _quizKey(QuizResultEntry q) {
    return Uri.encodeComponent(
        '${q.date.toIso8601String()}|${q.jlptLevel}|${q.quizType}|'
        '${q.totalQuestions}|${q.correctAnswers}');
  }

  Future<void> _downloadAll() async {
    // progress — last-write-wins on updatedAt
    final progressSnap = await _progressCol.get();
    for (final doc in progressSnap.docs) {
      final d = doc.data();
      final char = d['kanjiCharacter'] as String? ?? Uri.decodeComponent(doc.id);
      final cloudUpdated = DateTime.tryParse(d['updatedAt'] as String? ?? '');
      final local = await db.getProgress(char);
      // Skip cloud row if local is newer (last-write-wins).
      if (local != null && cloudUpdated != null) {
        if (!cloudUpdated.isAfter(local.updatedAt)) continue;
        await db.upsertProgress(UserKanjiProgressEntriesCompanion(
          kanjiCharacter: drift.Value(char),
          status: drift.Value(d['status'] as String? ?? 'learning'),
          correctCount: drift.Value((d['correctCount'] as num?)?.toInt() ?? 0),
          wrongCount: drift.Value((d['wrongCount'] as num?)?.toInt() ?? 0),
          ease: drift.Value((d['ease'] as num?)?.toDouble() ?? 2.5),
          intervalDays: drift.Value((d['intervalDays'] as num?)?.toInt() ?? 0),
          repetitions: drift.Value((d['repetitions'] as num?)?.toInt() ?? 0),
          lastReviewedAt:
              drift.Value(DateTime.tryParse(d['lastReviewedAt'] as String? ?? '')),
          nextReviewAt:
              drift.Value(DateTime.tryParse(d['nextReviewAt'] as String? ?? '')),
          firstLearnedAt:
              drift.Value(DateTime.tryParse(d['firstLearnedAt'] as String? ?? '')),
          updatedAt: drift.Value(cloudUpdated),
          isBookmarked: drift.Value(d['isBookmarked'] as bool? ?? false),
        ));
      } else {
        await db.upsertProgress(UserKanjiProgressEntriesCompanion(
          kanjiCharacter: drift.Value(char),
          status: drift.Value(d['status'] as String? ?? 'learning'),
          correctCount: drift.Value((d['correctCount'] as num?)?.toInt() ?? 0),
          wrongCount: drift.Value((d['wrongCount'] as num?)?.toInt() ?? 0),
          ease: drift.Value((d['ease'] as num?)?.toDouble() ?? 2.5),
          intervalDays: drift.Value((d['intervalDays'] as num?)?.toInt() ?? 0),
          repetitions: drift.Value((d['repetitions'] as num?)?.toInt() ?? 0),
          lastReviewedAt:
              drift.Value(DateTime.tryParse(d['lastReviewedAt'] as String? ?? '')),
          nextReviewAt:
              drift.Value(DateTime.tryParse(d['nextReviewAt'] as String? ?? '')),
          firstLearnedAt:
              drift.Value(DateTime.tryParse(d['firstLearnedAt'] as String? ?? '')),
          updatedAt: drift.Value(cloudUpdated ?? DateTime.now()),
          isBookmarked: drift.Value(d['isBookmarked'] as bool? ?? false),
        ));
      }
    }

    // daily — merge by date, cloud wins (additive counters)
    final dailySnap = await _dailyCol.get();
    for (final doc in dailySnap.docs) {
      final d = doc.data();
      await db.upsertDailyProgress(DailyProgressEntriesCompanion(
        date: drift.Value(d['date'] as String? ?? Uri.decodeComponent(doc.id)),
        newKanjiCount: drift.Value((d['newKanjiCount'] as num?)?.toInt() ?? 0),
        reviewedKanjiCount:
            drift.Value((d['reviewedKanjiCount'] as num?)?.toInt() ?? 0),
        correctAnswers: drift.Value((d['correctAnswers'] as num?)?.toInt() ?? 0),
        wrongAnswers: drift.Value((d['wrongAnswers'] as num?)?.toInt() ?? 0),
        dailyGoal: drift.Value((d['dailyGoal'] as num?)?.toInt() ?? 10),
        goalCompleted: drift.Value(d['goalCompleted'] as bool? ?? false),
      ));
    }

    // quiz (append-only) — skip rows already present locally via content key
    final existingKeys = (await db.getAllQuizResultKeys()).toSet();
    final quizSnap = await _quizCol.get();
    for (final doc in quizSnap.docs) {
      final d = doc.data();
      final date = DateTime.tryParse(d['date'] as String? ?? '');
      if (date == null) continue;
      final key = (d['key'] as String?) ?? doc.id;
      if (existingKeys.contains(key)) continue;
      await db.insertQuizResult(QuizResultEntriesCompanion.insert(
        date: drift.Value(date),
        jlptLevel: drift.Value((d['jlptLevel'] as num?)?.toInt()),
        quizType: d['quizType'] as String? ?? 'meaning',
        totalQuestions: (d['totalQuestions'] as num?)?.toInt() ?? 0,
        correctAnswers: (d['correctAnswers'] as num?)?.toInt() ?? 0,
        accuracy: (d['accuracy'] as num?)?.toDouble() ?? 0,
        questionsJson: drift.Value(d['questionsJson'] as String?),
      ));
    }
  }
}
