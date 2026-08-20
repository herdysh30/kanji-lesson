import 'package:drift/drift.dart';
import 'package:kanji_lesson/core/database/app_database.dart';
import 'package:kanji_lesson/features/kanji/domain/entities/jlpt_vocab.dart';

class JlptVocabLocalDataSource {
  const JlptVocabLocalDataSource(this._database);

  final AppDatabase _database;

  Future<void> cacheVocabList(List<JlptVocab> vocabList) async {
    await _database.batch((batch) {
      for (final vocab in vocabList) {
        batch.insert(
          _database.jlptVocabEntries,
          JlptVocabEntriesCompanion.insert(
            word: vocab.word,
            meaning: vocab.meaning,
            meaningId: Value(vocab.meaningId),
            furigana: vocab.furigana,
            romaji: vocab.romaji,
            level: vocab.level,
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<List<JlptVocab>> getVocabByLevel(int level) async {
    final entries = await (_database.select(_database.jlptVocabEntries)
          ..where((t) => t.level.equals(level)))
        .get();

    return entries
        .map((e) => JlptVocab(
              word: e.word,
              meaning: e.meaning,
              furigana: e.furigana,
              romaji: e.romaji,
              level: e.level,
            ))
        .toList();
  }

  Future<JlptVocab?> getVocabByWord(String word) async {
    final entry = await (_database.select(_database.jlptVocabEntries)
          ..where((t) => t.word.equals(word)))
        .getSingleOrNull();

    if (entry == null) return null;

    return JlptVocab(
      word: entry.word,
      meaning: entry.meaning,
      meaningId: entry.meaningId,
      furigana: entry.furigana,
      romaji: entry.romaji,
      level: entry.level,
    );
  }

  Future<List<JlptVocab>> getAllVocab() async {
    final entries = await _database.select(_database.jlptVocabEntries).get();
    return entries
        .map((e) => JlptVocab(
              word: e.word,
              meaning: e.meaning,
              meaningId: e.meaningId,
              furigana: e.furigana,
              romaji: e.romaji,
              level: e.level,
            ))
        .toList();
  }
}
