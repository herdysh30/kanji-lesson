import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart' as drift;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kanji_lesson/core/database/app_database.dart';

/// Syncs drift progress tables to Cloud Firestore.
///
/// Layout: `users/{uid}/progress/{kanjiCharacter}`, `users/{uid}/daily/{date}`,
/// `users/{uid}/quiz/{autoId}`.
///
/// Direction: local writes → cloud (debounced). On login/manual sync:
/// download cloud → merge into local → upload local-only rows.
class SyncService {
  SyncService({required this.db, FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final AppDatabase db;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Timer? _debounceTimer;
  bool _syncing = false;

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
    _debounceTimer = Timer(const Duration(milliseconds: 800), syncNow);
  }

  /// Full two-way sync (login / manual / after reconnect).
  Future<void> syncNow() async {
    _debounceTimer?.cancel();
    final uid = _uid;
    if (uid == null || _syncing) return;
    _syncing = true;
    try {
      await _downloadAll();
      await _uploadAll();
    } finally {
      _syncing = false;
    }
  }

  Future<void> _uploadAll() async {
    final batch = _firestore.batch();

    for (final p in await db.getAllProgress()) {
      if (p.status == 'unseen') continue;
      batch.set(_progressCol.doc(p.kanjiCharacter), {
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
      });
    }

    for (final d in await db.getRecentDailyProgress(365)) {
      batch.set(_dailyCol.doc(d.date), {
        'date': d.date,
        'newKanjiCount': d.newKanjiCount,
        'reviewedKanjiCount': d.reviewedKanjiCount,
        'correctAnswers': d.correctAnswers,
        'wrongAnswers': d.wrongAnswers,
        'dailyGoal': d.dailyGoal,
        'goalCompleted': d.goalCompleted,
      });
    }

    for (final q in await db.getRecentQuizResults(100)) {
      batch.set(_quizCol.doc('q${q.id}'), {
        'date': q.date.toIso8601String(),
        'jlptLevel': q.jlptLevel,
        'quizType': q.quizType,
        'totalQuestions': q.totalQuestions,
        'correctAnswers': q.correctAnswers,
        'accuracy': q.accuracy,
        'questionsJson': q.questionsJson,
      });
    }

    await batch.commit();
  }

  Future<void> _downloadAll() async {
    // progress
    final progressSnap = await _progressCol.get();
    for (final doc in progressSnap.docs) {
      final d = doc.data();
      await db.upsertProgress(UserKanjiProgressEntriesCompanion(
        kanjiCharacter: drift.Value(d['kanjiCharacter'] as String? ?? doc.id),
        status: drift.Value(d['status'] as String? ?? 'learning'),
        correctCount: drift.Value((d['correctCount'] as num?)?.toInt() ?? 0),
        wrongCount: drift.Value((d['wrongCount'] as num?)?.toInt() ?? 0),
        ease: drift.Value((d['ease'] as num?)?.toDouble() ?? 2.5),
        intervalDays: drift.Value((d['intervalDays'] as num?)?.toInt() ?? 0),
        repetitions: drift.Value((d['repetitions'] as num?)?.toInt() ?? 0),
        lastReviewedAt: drift.Value(DateTime.tryParse(d['lastReviewedAt'] as String? ?? '')),
        nextReviewAt: drift.Value(DateTime.tryParse(d['nextReviewAt'] as String? ?? '')),
        firstLearnedAt: drift.Value(DateTime.tryParse(d['firstLearnedAt'] as String? ?? '')),
        updatedAt: drift.Value(DateTime.tryParse(d['updatedAt'] as String? ?? '') ?? DateTime.now()),
        isBookmarked: drift.Value(d['isBookmarked'] as bool? ?? false),
      ));
    }

    // daily
    final dailySnap = await _dailyCol.get();
    for (final doc in dailySnap.docs) {
      final d = doc.data();
      await db.upsertDailyProgress(DailyProgressEntriesCompanion(
        date: drift.Value(d['date'] as String? ?? doc.id),
        newKanjiCount: drift.Value((d['newKanjiCount'] as num?)?.toInt() ?? 0),
        reviewedKanjiCount: drift.Value((d['reviewedKanjiCount'] as num?)?.toInt() ?? 0),
        correctAnswers: drift.Value((d['correctAnswers'] as num?)?.toInt() ?? 0),
        wrongAnswers: drift.Value((d['wrongAnswers'] as num?)?.toInt() ?? 0),
        dailyGoal: drift.Value((d['dailyGoal'] as num?)?.toInt() ?? 10),
        goalCompleted: drift.Value(d['goalCompleted'] as bool? ?? false),
      ));
    }

    // quiz (append-only, skip if exists to avoid dupes)
    final quizSnap = await _quizCol.get();
    for (final doc in quizSnap.docs) {
      final d = doc.data();
      final date = DateTime.tryParse(d['date'] as String? ?? '');
      if (date == null) continue;
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
