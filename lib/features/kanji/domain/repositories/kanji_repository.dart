import 'package:kanji_lesson/features/kanji/domain/entities/kanji.dart';
import 'package:kanji_lesson/features/kanji/domain/entities/vocabulary.dart';

/// Abstract repository interface for Kanji data
abstract class KanjiRepository {
  /// Get list of kanji characters for a JLPT level
  Future<List<String>> getKanjiListByJlpt(int level);

  /// Get detailed kanji information
  Future<Kanji> getKanjiDetail(String character);

  /// Get vocabulary/words for a kanji character
  Future<List<Vocabulary>> getVocabularyForKanji(String character);

  /// Search kanji by query (meaning, reading, or character)
  Future<List<Kanji>> searchKanji(String query, {int? jlptLevel});

  /// Check if kanji data is cached locally
  Future<bool> isKanjiCached(String character);

  /// Check if JLPT list is cached
  Future<bool> isJlptListCached(int level);

  /// Get total kanji count for a JLPT level
  Future<int> getKanjiCountByJlpt(int level);
}
