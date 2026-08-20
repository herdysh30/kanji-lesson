import 'dart:convert';

/// String utility helpers for Japanese text processing
class StringUtils {
  StringUtils._();

  /// Check if a character is Hiragana (U+3040 – U+309F)
  static bool isHiragana(String char) {
    if (char.isEmpty) return false;
    final code = char.codeUnitAt(0);
    return code >= 0x3040 && code <= 0x309F;
  }

  /// Check if a character is Katakana (U+30A0 – U+30FF)
  static bool isKatakana(String char) {
    if (char.isEmpty) return false;
    final code = char.codeUnitAt(0);
    return code >= 0x30A0 && code <= 0x30FF;
  }

  /// Check if a character is Kanji (CJK Unified Ideographs U+4E00 – U+9FAF)
  static bool isKanji(String char) {
    if (char.isEmpty) return false;
    final code = char.codeUnitAt(0);
    return code >= 0x4E00 && code <= 0x9FAF;
  }

  /// Check if a string contains Japanese characters
  static bool containsJapanese(String text) {
    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      if (isHiragana(char) || isKatakana(char) || isKanji(char)) {
        return true;
      }
    }
    return false;
  }

  /// Convert kanji character to Unicode hex string (for KanjiVG lookup)
  static String toUnicodeHex(String character) {
    if (character.isEmpty) return '';
    return character.codeUnitAt(0).toRadixString(16).padLeft(5, '0');
  }

  /// Safe JSON list decode
  static List<String> decodeJsonList(String jsonString) {
    try {
      final decoded = json.decode(jsonString);
      if (decoded is List) {
        return decoded.cast<String>();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Safe JSON list encode
  static String encodeJsonList(List<String> list) {
    return json.encode(list);
  }

  /// Truncate string with ellipsis
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Join meanings with comma
  static String joinMeanings(List<String> meanings, {int maxCount = 3}) {
    if (meanings.isEmpty) return '';
    final limited = meanings.take(maxCount).toList();
    return limited.join(', ');
  }

  /// Get primary meaning
  static String primaryMeaning(List<String> meanings) {
    return meanings.isNotEmpty ? meanings.first : '';
  }

  /// Get primary reading (prefer kun'yomi for standalone kanji)
  static String primaryReading(List<String> kunyomi, List<String> onyomi) {
    if (kunyomi.isNotEmpty) return kunyomi.first;
    if (onyomi.isNotEmpty) return onyomi.first;
    return '';
  }

  /// Calculate accuracy percentage
  static double accuracy(int correct, int wrong) {
    final total = correct + wrong;
    if (total == 0) return 0.0;
    return correct / total;
  }

  /// Format accuracy as percentage string
  static String accuracyPercent(int correct, int wrong) {
    final acc = accuracy(correct, wrong);
    return '${(acc * 100).round()}%';
  }
}
