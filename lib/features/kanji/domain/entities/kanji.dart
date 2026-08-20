import 'package:equatable/equatable.dart';

/// Domain entity representing a Kanji character
class Kanji extends Equatable {
  const Kanji({
    required this.character,
    this.jlptLevel,
    required this.meanings,
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
  final List<String> onyomi;
  final List<String> kunyomi;
  final List<String> nameReadings;
  final int strokeCount;
  final int? grade;
  final String? heisigKeyword;
  final int? frequency;
  final String unicode;

  /// Primary meaning (first in list)
  String get primaryMeaning => meanings.isNotEmpty ? meanings.first : '';

  /// Primary reading (prefer kun'yomi)
  String get primaryReading {
    if (kunyomi.isNotEmpty) return kunyomi.first;
    if (onyomi.isNotEmpty) return onyomi.first;
    return '';
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
