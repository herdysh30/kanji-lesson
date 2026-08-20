/// API endpoint constants for KanjiAPI.dev
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://kanjiapi.dev/v1';

  /// Get list of kanji characters by JLPT level (1-5)
  /// Returns: `List<String>`
  static String kanjiByJlpt(int level) => '/kanji/jlpt-$level';

  /// Get detailed kanji information
  /// Returns: `KanjiApiModel`
  static String kanjiDetail(String character) => '/kanji/$character';

  /// Get words/vocabulary for a kanji character
  /// Returns: `List<WordApiModel>`
  static String wordsForKanji(String character) => '/words/$character';

  /// Get kanji by reading
  /// Returns: `List<String>`
  static String kanjiByReading(String reading) => '/reading/$reading';

  /// Get kanji by grade level
  /// Returns: `List<String>`
  static String kanjiByGrade(int grade) => '/kanji/grade-$grade';

  /// KanjiVG SVG stroke order URL
  static String kanjiVgSvgUrl(String unicodeHex) =>
      'https://raw.githubusercontent.com/KanjiVG/kanjivg/master/kanji/$unicodeHex.svg';

  /// Timeout durations
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);

  /// Cache TTL
  static const Duration cacheTtl = Duration(hours: 24);
}
