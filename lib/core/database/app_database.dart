import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:kanji_lesson/core/database/tables/jlpt_vocab_entries.dart';

part 'app_database.g.dart';

// ─── Constants ──────────────────────────────────────────────────

enum ReviewItemType { kanji, vocab, mixed }

// ─── Table Definitions ──────────────────────────────────────────

/// Cached kanji data from KanjiAPI
class KanjiEntries extends Table {
  TextColumn get character => text().withLength(min: 1, max: 4)();
  IntColumn get jlptLevel => integer().nullable()();
  TextColumn get meanings => text()(); // JSON encoded list
  TextColumn get meaningsId => text().nullable()(); // JSON encoded list of Indonesian meanings
  TextColumn get onyomi => text()(); // JSON encoded list
  TextColumn get kunyomi => text()(); // JSON encoded list
  TextColumn get nameReadings => text().withDefault(const Constant('[]'))();
  IntColumn get strokeCount => integer().withDefault(const Constant(0))();
  IntColumn get grade => integer().nullable()();
  TextColumn get heisigKeyword => text().nullable()();
  IntColumn get frequency => integer().nullable()();
  TextColumn get unicode => text().withDefault(const Constant(''))();
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {character};
}

/// Cached vocabulary/words from KanjiAPI
class VocabularyEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get kanjiCharacter => text()();
  TextColumn get word => text()();
  TextColumn get reading => text()();
  TextColumn get meanings => text()(); // JSON encoded list
  TextColumn get meaningsId => text().nullable()(); // JSON encoded list
  TextColumn get priorities => text().withDefault(const Constant('[]'))();
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();
}

/// User's learning progress per kanji
class UserKanjiProgressEntries extends Table {
  TextColumn get kanjiCharacter => text()();
  TextColumn get status => text().withDefault(const Constant('unseen'))(); // unseen, learning, reviewing, mastered
  IntColumn get correctCount => integer().withDefault(const Constant(0))();
  IntColumn get wrongCount => integer().withDefault(const Constant(0))();
  RealColumn get ease => real().withDefault(const Constant(2.5))();
  IntColumn get intervalDays => integer().withDefault(const Constant(0))();
  IntColumn get repetitions => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastReviewedAt => dateTime().nullable()();
  DateTimeColumn get nextReviewAt => dateTime().nullable()();
  DateTimeColumn get firstLearnedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isBookmarked => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {kanjiCharacter};
}

/// Daily progress tracking
class DailyProgressEntries extends Table {
  TextColumn get date => text()(); // yyyy-MM-dd format
  IntColumn get newKanjiCount => integer().withDefault(const Constant(0))();
  IntColumn get reviewedKanjiCount => integer().withDefault(const Constant(0))();
  IntColumn get correctAnswers => integer().withDefault(const Constant(0))();
  IntColumn get wrongAnswers => integer().withDefault(const Constant(0))();
  IntColumn get dailyGoal => integer().withDefault(const Constant(10))();
  BoolColumn get goalCompleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {date};
}

/// Quiz results history
class QuizResultEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
  IntColumn get jlptLevel => integer().nullable()();
  TextColumn get quizType => text()(); // meaning, reading, kanji, vocabulary, listening
  IntColumn get totalQuestions => integer()();
  IntColumn get correctAnswers => integer()();
  RealColumn get accuracy => real()();
  TextColumn get questionsJson => text().nullable()();
}

/// Similar kanji relationships (local data)
class SimilarKanjiEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get kanji1 => text()();
  TextColumn get kanji2 => text()();
  TextColumn get explanation => text().nullable()();
}

// ─── Database ───────────────────────────────────────────────────

@DriftDatabase(tables: [
  KanjiEntries,
  VocabularyEntries,
  UserKanjiProgressEntries,
  DailyProgressEntries,
  QuizResultEntries,
  SimilarKanjiEntries,
  JlptVocabEntries,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'kanji_lesson');
  }

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.addColumn(kanjiEntries, kanjiEntries.meaningsId);
          await m.addColumn(vocabularyEntries, vocabularyEntries.meaningsId);
        }
        if (from < 3) {
          await m.createTable(jlptVocabEntries);
        }
        if (from < 4) {
          await m.addColumn(jlptVocabEntries, jlptVocabEntries.meaningId);
        }
        if (from < 5) {
          await m.addColumn(quizResultEntries, quizResultEntries.questionsJson);
        }
        if (from < 6) {
          await m.addColumn(userKanjiProgressEntries, userKanjiProgressEntries.isBookmarked);
        }
      },
    );
  }

  // ─── Kanji Cache Operations ─────────────────────────────────

  Future<void> upsertKanji(KanjiEntriesCompanion entry) {
    return into(kanjiEntries).insertOnConflictUpdate(entry);
  }

  Future<List<KanjiEntry>> getKanjiByJlpt(int level) {
    return (select(kanjiEntries)..where((t) => t.jlptLevel.equals(level))).get();
  }

  Future<List<KanjiEntry>> getAllKanjiEntries() {
    return (select(kanjiEntries)..orderBy([(t) => OrderingTerm.asc(t.jlptLevel)])).get();
  }

  Future<KanjiEntry?> getKanjiByCharacter(String character) {
    return (select(kanjiEntries)..where((t) => t.character.equals(character)))
        .getSingleOrNull();
  }

  Future<List<KanjiEntry>> getKanjiByCharacters(List<String> characters) {
    return (select(kanjiEntries)..where((t) => t.character.isIn(characters)))
        .get();
  }

  Future<void> upsertManyKanji(List<KanjiEntriesCompanion> entries) async {
    await batch((batch) {
      for (final entry in entries) {
        batch.insert(kanjiEntries, entry, onConflict: DoUpdate((_) => entry));
      }
    });
  }

  // ─── Vocabulary Cache Operations ────────────────────────────

  Future<void> insertVocabulary(VocabularyEntriesCompanion entry) {
    return into(vocabularyEntries).insert(entry);
  }

  Future<List<VocabularyEntry>> getVocabularyForKanji(String character) {
    return (select(vocabularyEntries)
          ..where((t) => t.kanjiCharacter.equals(character)))
        .get();
  }

  Future<List<VocabularyEntry>> getVocabularyForCharacters(List<String> characters) {
    return (select(vocabularyEntries)
          ..where((t) => t.kanjiCharacter.isIn(characters)))
        .get();
  }

  Future<void> deleteVocabularyForKanji(String character) {
    return (delete(vocabularyEntries)
          ..where((t) => t.kanjiCharacter.equals(character)))
        .go();
  }

  Future<void> replaceVocabularyForKanji(
      String character, List<VocabularyEntriesCompanion> entries) async {
    await transaction(() async {
      await deleteVocabularyForKanji(character);
      await batch((batch) {
        batch.insertAll(vocabularyEntries, entries);
      });
    });
  }

  // ─── Progress Operations ────────────────────────────────────

  Future<void> upsertProgress(UserKanjiProgressEntriesCompanion entry) {
    return into(userKanjiProgressEntries).insertOnConflictUpdate(entry);
  }

  Future<void> updateProgress({
    required String kanjiCharacter,
    required String status,
    required double ease,
    required int intervalDays,
    required int repetitions,
    required DateTime nextReviewAt,
    required bool isCorrect,
  }) async {
    final existing = await getProgress(kanjiCharacter);
    
    await upsertProgress(
      UserKanjiProgressEntriesCompanion(
        kanjiCharacter: Value(kanjiCharacter),
        status: Value(status),
        ease: Value(ease),
        intervalDays: Value(intervalDays),
        repetitions: Value(repetitions),
        nextReviewAt: Value(nextReviewAt),
        correctCount: Value((existing?.correctCount ?? 0) + (isCorrect ? 1 : 0)),
        wrongCount: Value((existing?.wrongCount ?? 0) + (isCorrect ? 0 : 1)),
      ),
    );
  }

  Future<UserKanjiProgressEntry?> getProgress(String character) {
    return (select(userKanjiProgressEntries)
          ..where((t) => t.kanjiCharacter.equals(character)))
        .getSingleOrNull();
  }

  Future<void> toggleBookmark(String character, bool isBookmarked) async {
    await (update(userKanjiProgressEntries)
          ..where((t) => t.kanjiCharacter.equals(character)))
        .write(UserKanjiProgressEntriesCompanion(
          isBookmarked: Value(isBookmarked),
          updatedAt: Value(DateTime.now()),
        ));
  }

  Future<void> deleteProgress(String character) {
    return (delete(userKanjiProgressEntries)
          ..where((t) => t.kanjiCharacter.equals(character)))
        .go();
  }

  Future<void> setProgressStatus(String character, String newStatus) {
    return (update(userKanjiProgressEntries)
          ..where((t) => t.kanjiCharacter.equals(character)))
        .write(UserKanjiProgressEntriesCompanion(
          status: Value(newStatus),
          updatedAt: Value(DateTime.now()),
        ));
  }

  Future<List<UserKanjiProgressEntry>> getBookmarkedItems() {
    return (select(userKanjiProgressEntries)
          ..where((t) => t.isBookmarked.equals(true))
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();
  }

  Future<List<UserKanjiProgressEntry>> getAllProgress() {
    return select(userKanjiProgressEntries).get();
  }

  /// Rows changed since [since] — delta sync upload.
  Future<List<UserKanjiProgressEntry>> getProgressSince(DateTime since) {
    return (select(userKanjiProgressEntries)
          ..where((t) => t.updatedAt.isBiggerThanValue(since)))
        .get();
  }

  /// Aggregated progress counts/sums — avoids loading every row.
  Future<({int learned, int mastered, int reviewing, int totalCorrect, int totalWrong})>
      getProgressSummary() async {
    int learned = 0;
    int mastered = 0;
    int reviewing = 0;

    final rows = await (selectOnly(userKanjiProgressEntries)
          ..addColumns([
            userKanjiProgressEntries.status,
            userKanjiProgressEntries.status.count(),
          ])
          ..groupBy([userKanjiProgressEntries.status]))
        .get();

    for (final row in rows) {
      final status = row.read(userKanjiProgressEntries.status);
      final count = row.read(userKanjiProgressEntries.status.count()) ?? 0;
      if (status == 'mastered') {
        mastered += count;
        learned += count;
      } else if (status == 'reviewing' || status == 'learning') {
        reviewing += count;
        learned += count;
      }
    }

    final sums = await (selectOnly(userKanjiProgressEntries)
          ..addColumns([
            userKanjiProgressEntries.correctCount.sum(),
            userKanjiProgressEntries.wrongCount.sum(),
          ]))
        .getSingle();
    final totalCorrect =
        sums.read(userKanjiProgressEntries.correctCount.sum()) ?? 0;
    final totalWrong =
        sums.read(userKanjiProgressEntries.wrongCount.sum()) ?? 0;

    return (
      learned: learned,
      mastered: mastered,
      reviewing: reviewing,
      totalCorrect: totalCorrect,
      totalWrong: totalWrong,
    );
  }

  Future<List<UserKanjiProgressEntry>> getProgressByStatus(String status) {
    return (select(userKanjiProgressEntries)
          ..where((t) => t.status.equals(status)))
        .get();
  }

  Future<List<UserKanjiProgressEntry>> getDueReviews(DateTime now) {
    return (select(userKanjiProgressEntries)
          ..where((t) =>
              t.nextReviewAt.isSmallerOrEqualValue(now) &
              t.status.isNotIn(['unseen']))
          ..orderBy([(t) => OrderingTerm.asc(t.nextReviewAt)]))
        .get();
  }

  Future<List<UserKanjiProgressEntry>> startLearningNewItems(int limit, {int? jlptLevel, ReviewItemType type = ReviewItemType.kanji}) async {
    // 1. Get unseen items
    final unseenItems = <String>[];
    
    if (type == ReviewItemType.kanji || type == ReviewItemType.mixed) {
      final unseenKanji = await (select(kanjiEntries)
            ..where((k) {
              final subquery = selectOnly(userKanjiProgressEntries)
                ..addColumns([userKanjiProgressEntries.kanjiCharacter])
                ..where(userKanjiProgressEntries.status.isNotIn(['unseen']));
              
              var expr = k.character.isNotInQuery(subquery);
              if (jlptLevel != null) {
                expr = expr & k.jlptLevel.equals(jlptLevel);
              }
              return expr;
            })
            ..orderBy([(k) => OrderingTerm.desc(k.jlptLevel)]) // N5 first
            ..limit(limit))
          .map((row) => row.character)
          .get();
      unseenItems.addAll(unseenKanji);
    }

    if (type == ReviewItemType.vocab || type == ReviewItemType.mixed) {
      final unseenVocab = await (select(jlptVocabEntries)
            ..where((v) {
              final subquery = selectOnly(userKanjiProgressEntries)
                ..addColumns([userKanjiProgressEntries.kanjiCharacter])
                ..where(userKanjiProgressEntries.status.isNotIn(['unseen']));
              
              var expr = v.word.isNotInQuery(subquery);
              if (jlptLevel != null) {
                expr = expr & v.level.equals(jlptLevel);
              }
              return expr;
            })
            ..orderBy([(v) => OrderingTerm.desc(v.level)]) // N5 first
            ..limit(limit))
          .map((row) => row.word)
          .get();
      unseenItems.addAll(unseenVocab);
    }

    if (unseenItems.isEmpty) return [];

    if (type == ReviewItemType.mixed) {
      unseenItems.shuffle();
    }
    
    final selectedItems = unseenItems.take(limit).toList();

    // 2. Mark them as learning
    final now = DateTime.now();
    for (final item in selectedItems) {
      await upsertProgress(UserKanjiProgressEntriesCompanion(
        kanjiCharacter: Value(item),
        status: const Value('learning'),
        firstLearnedAt: Value(now),
        nextReviewAt: Value(now),
        updatedAt: Value(now),
      ));
    }

    // 3. Return their new progress entries
    return (select(userKanjiProgressEntries)
          ..where((t) => t.kanjiCharacter.isIn(selectedItems)))
        .get();
  }

  Future<List<UserKanjiProgressEntry>> getWeakKanji() {
    return (select(userKanjiProgressEntries)
          ..where((t) => t.status.isNotIn(['unseen']))
          ..orderBy([
            (t) => OrderingTerm.asc(
                // Sort by accuracy (correct / total)
                t.correctCount.caseMatch(
                  when: {
                    const Constant(0): const Constant(0.0),
                  },
                  orElse: t.correctCount /
                      (t.correctCount + t.wrongCount),
                )),
          ]))
        .get();
  }

  Future<int> getLearnedCount({int? jlptLevel}) async {
    final query = select(userKanjiProgressEntries)
      ..where((t) => t.status.isNotIn(['unseen']));

    if (jlptLevel != null) {
      final kanjiChars = await (select(kanjiEntries)
            ..where((t) => t.jlptLevel.equals(jlptLevel)))
          .map((row) => row.character)
          .get();

      query.where((t) => t.kanjiCharacter.isIn(kanjiChars));
    }

    final results = await query.get();
    return results.length;
  }

  Future<int> getMasteredCount({int? jlptLevel}) async {
    final query = select(userKanjiProgressEntries)
      ..where((t) => t.status.equals('mastered'));

    if (jlptLevel != null) {
      final kanjiChars = await (select(kanjiEntries)
            ..where((t) => t.jlptLevel.equals(jlptLevel)))
          .map((row) => row.character)
          .get();

      query.where((t) => t.kanjiCharacter.isIn(kanjiChars));
    }

    final results = await query.get();
    return results.length;
  }

  Future<int> getVocabLearnedCount({int? jlptLevel}) async {
    final query = select(userKanjiProgressEntries)
      ..where((t) => t.status.isNotIn(['unseen']));

    if (jlptLevel != null) {
      final vocabWords = await (select(jlptVocabEntries)
            ..where((t) => t.level.equals(jlptLevel)))
          .map((row) => row.word)
          .get();

      query.where((t) => t.kanjiCharacter.isIn(vocabWords));
    }

    final results = await query.get();
    return results.length;
  }

  Future<int> getVocabMasteredCount({int? jlptLevel}) async {
    final query = select(userKanjiProgressEntries)
      ..where((t) => t.status.equals('mastered'));

    if (jlptLevel != null) {
      final vocabWords = await (select(jlptVocabEntries)
            ..where((t) => t.level.equals(jlptLevel)))
          .map((row) => row.word)
          .get();

      query.where((t) => t.kanjiCharacter.isIn(vocabWords));
    }

    final results = await query.get();
    return results.length;
  }

  Future<int> getVocabTotalCount({int? jlptLevel}) async {
    final query = select(jlptVocabEntries);
    if (jlptLevel != null) {
      query.where((t) => t.level.equals(jlptLevel));
    }
    final results = await query.get();
    return results.length;
  }

  Future<List<JlptVocabEntry>> getAllJlptVocabEntries() {
    return (select(jlptVocabEntries)..orderBy([(t) => OrderingTerm.asc(t.level)])).get();
  }

  Future<List<JlptVocabEntry>> getJlptVocabByWords(List<String> words) {
    if (words.isEmpty) return Future.value([]);
    return (select(jlptVocabEntries)
          ..where((t) => t.word.isIn(words)))
        .get();
  }

  // ─── Daily Progress Operations ──────────────────────────────

  Future<void> upsertDailyProgress(DailyProgressEntriesCompanion entry) {
    return into(dailyProgressEntries).insertOnConflictUpdate(entry);
  }

  Future<void> incrementDailyReviewed(bool isCorrect) async {
    final today = DateTime.now();
    final dateStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    
    final existing = await getDailyProgress(dateStr);
    
    await upsertDailyProgress(
      DailyProgressEntriesCompanion(
        date: Value(dateStr),
        reviewedKanjiCount: Value((existing?.reviewedKanjiCount ?? 0) + 1),
        newKanjiCount: Value(existing?.newKanjiCount ?? 0),
        correctAnswers: Value((existing?.correctAnswers ?? 0) + (isCorrect ? 1 : 0)),
        wrongAnswers: Value((existing?.wrongAnswers ?? 0) + (isCorrect ? 0 : 1)),
      ),
    );
  }

  Future<DailyProgressEntry?> getDailyProgress(String date) {
    return (select(dailyProgressEntries)
          ..where((t) => t.date.equals(date)))
        .getSingleOrNull();
  }

  Future<List<DailyProgressEntry>> getRecentDailyProgress(int days) {
    return (select(dailyProgressEntries)
          ..orderBy([(t) => OrderingTerm.desc(t.date)])
          ..limit(days))
        .get();
  }

  /// Daily rows on/after [dateKey] (yyyy-MM-dd) — delta sync upload.
  Future<List<DailyProgressEntry>> getDailyProgressSince(String dateKey) {
    return (select(dailyProgressEntries)
          ..where((t) => t.date.isBiggerOrEqualValue(dateKey)))
        .get();
  }

  // ─── Quiz Result Operations ─────────────────────────────────

  Future<void> insertQuizResult(QuizResultEntriesCompanion entry) {
    return into(quizResultEntries).insert(entry);
  }

  Future<List<QuizResultEntry>> getRecentQuizResults(int count) {
    return (select(quizResultEntries)
          ..orderBy([(t) => OrderingTerm.desc(t.date)])
          ..limit(count))
        .get();
  }

  /// Quiz rows with id > [minId] — delta sync upload (capped at 300 newest).
  Future<List<QuizResultEntry>> getQuizResultsSince(int minId) {
    return (select(quizResultEntries)
          ..where((t) => t.id.isBiggerThanValue(minId))
          ..orderBy([(t) => OrderingTerm.desc(t.id)])
          ..limit(300))
        .get();
  }

  /// Content keys of all quiz rows — sync dedup for append-only downloads.
  Future<List<String>> getAllQuizResultKeys() async {
    final rows = await select(quizResultEntries).get();
    return [
      for (final r in rows)
        '${r.date.toIso8601String()}|${r.jlptLevel}|${r.quizType}|'
            '${r.totalQuestions}|${r.correctAnswers}',
    ];
  }

  // ─── Similar Kanji Operations ───────────────────────────────

  Future<List<SimilarKanjiEntry>> getSimilarKanji(String character) {
    return (select(similarKanjiEntries)
          ..where(
              (t) => t.kanji1.equals(character) | t.kanji2.equals(character)))
        .get();
  }

  // ─── Cleanup Operations ─────────────────────────────────────

  Future<void> clearAllCache() async {
    await delete(kanjiEntries).go();
    await delete(vocabularyEntries).go();
  }

  Future<void> resetAllProgress() async {
    await delete(userKanjiProgressEntries).go();
    await delete(dailyProgressEntries).go();
    await delete(quizResultEntries).go();
  }

  Future<void> resetJlptProgress(int jlptLevel) async {
    final kanjiChars = await (select(kanjiEntries)..where((k) => k.jlptLevel.equals(jlptLevel)))
        .map((k) => k.character)
        .get();

    final vocabWords = await (select(jlptVocabEntries)..where((v) => v.level.equals(jlptLevel)))
        .map((v) => v.word)
        .get();

    final allItems = [...kanjiChars, ...vocabWords];

    if (allItems.isNotEmpty) {
      await (delete(userKanjiProgressEntries)..where((t) => t.kanjiCharacter.isIn(allItems))).go();
    }
  }
}
