import 'package:drift/drift.dart';
import 'package:kanji_lesson/core/database/app_database.dart';
import 'package:kanji_lesson/core/utils/string_utils.dart';
import 'package:kanji_lesson/features/kanji/domain/entities/kanji.dart';
import 'package:kanji_lesson/features/kanji/domain/entities/vocabulary.dart';

/// Local data source using Drift database for caching
class KanjiLocalDataSource {
  KanjiLocalDataSource(this._db);

  final AppDatabase _db;

  // ─── Kanji Operations ─────────────────────────────────────────

  /// Cache a single kanji entry
  Future<void> cacheKanji(Kanji kanji) async {
    await _db.upsertKanji(KanjiEntriesCompanion(
      character: Value(kanji.character),
      jlptLevel: Value(kanji.jlptLevel),
      meanings: Value(StringUtils.encodeJsonList(kanji.meanings)),
      meaningsId: Value(StringUtils.encodeJsonList(kanji.meaningsId)),
      onyomi: Value(StringUtils.encodeJsonList(kanji.onyomi)),
      kunyomi: Value(StringUtils.encodeJsonList(kanji.kunyomi)),
      nameReadings: Value(StringUtils.encodeJsonList(kanji.nameReadings)),
      strokeCount: Value(kanji.strokeCount),
      grade: Value(kanji.grade),
      heisigKeyword: Value(kanji.heisigKeyword),
      frequency: Value(kanji.frequency),
      unicode: Value(kanji.unicode),
      cachedAt: Value(DateTime.now()),
    ));
  }

  /// Cache minimal kanji entries (character + JLPT level only)
  Future<void> cacheKanjiList(List<String> characters, int jlptLevel) async {
    final entries = characters.map((char) => KanjiEntriesCompanion(
          character: Value(char),
          jlptLevel: Value(jlptLevel),
          meanings: const Value('[]'),
          meaningsId: const Value('[]'),
          onyomi: const Value('[]'),
          kunyomi: const Value('[]'),
          cachedAt: Value(DateTime.now()),
        ));
    await _db.upsertManyKanji(entries.toList());
  }

  /// Get cached kanji by JLPT level
  Future<List<String>> getKanjiListByJlpt(int level) async {
    final entries = await _db.getKanjiByJlpt(level);
    return entries.map((e) => e.character).toList();
  }

  /// Get cached kanji detail
  Future<Kanji?> getKanjiDetail(String character) async {
    final entry = await _db.getKanjiByCharacter(character);
    if (entry == null) return null;
    return _mapEntryToKanji(entry);
  }

  /// Check if kanji is cached with full detail (has meanings)
  Future<bool> isKanjiDetailCached(String character) async {
    final entry = await _db.getKanjiByCharacter(character);
    if (entry == null) return false;
    final meanings = StringUtils.decodeJsonList(entry.meanings);
    return meanings.isNotEmpty;
  }

  /// Check if JLPT list is cached
  Future<bool> isJlptListCached(int level) async {
    final entries = await _db.getKanjiByJlpt(level);
    return entries.isNotEmpty;
  }

  /// Get total count for JLPT level
  Future<int> getKanjiCountByJlpt(int level) async {
    final entries = await _db.getKanjiByJlpt(level);
    return entries.length;
  }

  /// Get all cached kanji as domain entities (with full detail)
  Future<List<Kanji>> getCachedKanjiByJlpt(int level) async {
    final entries = await _db.getKanjiByJlpt(level);
    return entries
        .where((e) => StringUtils.decodeJsonList(e.meanings).isNotEmpty)
        .map(_mapEntryToKanji)
        .toList();
  }

  /// Search kanji locally
  Future<List<Kanji>> searchKanji(String query, {int? jlptLevel}) async {
    final allEntries = jlptLevel != null
        ? await _db.getKanjiByJlpt(jlptLevel)
        : await _db.select(_db.kanjiEntries).get();

    if (query.isEmpty) {
      return allEntries.map(_mapEntryToKanji).toList();
    }

    final lowerQuery = query.toLowerCase();

    return allEntries.where((entry) {
      // Match character
      if (entry.character == query) return true;

      // Match meanings
      final meanings = StringUtils.decodeJsonList(entry.meanings);
      if (meanings.any((m) => m.toLowerCase().contains(lowerQuery))) {
        return true;
      }

      // Match readings
      final onyomi = StringUtils.decodeJsonList(entry.onyomi);
      final kunyomi = StringUtils.decodeJsonList(entry.kunyomi);
      if (onyomi.any((r) => r.contains(query)) ||
          kunyomi.any((r) => r.contains(query))) {
        return true;
      }

      return false;
    }).map(_mapEntryToKanji).toList();
  }

  // ─── Vocabulary Operations ────────────────────────────────────

  /// Cache vocabulary for a kanji
  Future<void> cacheVocabulary(
      String character, List<Vocabulary> vocabularies) async {
    final entries = vocabularies
        .map((v) => VocabularyEntriesCompanion(
              kanjiCharacter: Value(character),
              word: Value(v.word),
              reading: Value(v.reading),
              meanings: Value(StringUtils.encodeJsonList(v.meanings)),
              meaningsId: Value(StringUtils.encodeJsonList(v.meaningsId)),
              priorities: Value(StringUtils.encodeJsonList(v.priorities)),
              cachedAt: Value(DateTime.now()),
            ))
        .toList();
    await _db.replaceVocabularyForKanji(character, entries);
  }

  /// Get cached vocabulary for a kanji
  Future<List<Vocabulary>> getVocabularyForKanji(String character) async {
    final entries = await _db.getVocabularyForKanji(character);
    return entries
        .map((e) => Vocabulary(
              word: e.word,
              reading: e.reading,
              meanings: StringUtils.decodeJsonList(e.meanings),
              meaningsId: e.meaningsId != null ? StringUtils.decodeJsonList(e.meaningsId!) : [],
              priorities: StringUtils.decodeJsonList(e.priorities),
            ))
        .toList();
  }

  /// Check if vocabulary is cached for a kanji
  Future<bool> isVocabularyCached(String character) async {
    final entries = await _db.getVocabularyForKanji(character);
    return entries.isNotEmpty;
  }

  // ─── Helper ───────────────────────────────────────────────────

  Kanji _mapEntryToKanji(KanjiEntry entry) {
    return Kanji(
      character: entry.character,
      jlptLevel: entry.jlptLevel,
      meanings: StringUtils.decodeJsonList(entry.meanings),
      meaningsId: entry.meaningsId != null ? StringUtils.decodeJsonList(entry.meaningsId!) : [],
      onyomi: StringUtils.decodeJsonList(entry.onyomi),
      kunyomi: StringUtils.decodeJsonList(entry.kunyomi),
      nameReadings: StringUtils.decodeJsonList(entry.nameReadings),
      strokeCount: entry.strokeCount,
      grade: entry.grade,
      heisigKeyword: entry.heisigKeyword,
      frequency: entry.frequency,
      unicode: entry.unicode,
    );
  }
}
