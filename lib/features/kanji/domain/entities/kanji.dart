import 'package:equatable/equatable.dart';

/// Domain entity representing a Kanji character
class Kanji extends Equatable {
  const Kanji({
    required this.character,
    this.jlptLevel,
    required this.meanings,
    this.meaningsId = const [],
    required this.onyomi,
    required this.kunyomi,
    this.nameReadings = const [],
    required this.strokeCount,
    this.grade,
    this.heisigKeyword,
    this.frequency,
    this.unicode = '',
  });

  final String character;
  final int? jlptLevel;
  final List<String> meanings;
  final List<String> meaningsId;
  final List<String> onyomi;
  final List<String> kunyomi;
  final List<String> nameReadings;
  final int strokeCount;
  final int? grade;
  final String? heisigKeyword;
  final int? frequency;
  final String unicode;

  /// Primary meaning (Indonesian or English fallback)
  String primaryMeaning(bool isId) {
    if (isId && meaningsId.isNotEmpty) return meaningsId.first;
    return meanings.isNotEmpty ? meanings.first : '';
  }

  /// Helper to convert Katakana to Hiragana
  String _toHiragana(String text) {
    return text.replaceAllMapped(RegExp(r'[\u30a1-\u30f6]'), (match) {
      return String.fromCharCode(match.group(0)!.codeUnitAt(0) - 0x60);
    });
  }

  /// Primary reading (combines both On'yomi and Kun'yomi if available)
  String get primaryReading {
    final List<String> readings = [];
    if (onyomi.isNotEmpty) {
      readings.add(_toHiragana(onyomi.first));
    }
    if (kunyomi.isNotEmpty) {
      readings.add(kunyomi.first);
    }
    return readings.join(' / ');
  }

  /// All readings combined
  List<String> get allReadings => [...kunyomi, ...onyomi];

  /// JLPT display name
  String get jlptDisplayName =>
      jlptLevel != null ? 'N$jlptLevel' : 'Unknown';

  @override
  List<Object?> get props => [character];

  @override
  String toString() => 'Kanji($character)';
}
