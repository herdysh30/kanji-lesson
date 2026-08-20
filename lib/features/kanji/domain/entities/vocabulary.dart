import 'package:equatable/equatable.dart';

/// Domain entity representing a vocabulary word
class Vocabulary extends Equatable {
  const Vocabulary({
    required this.word,
    required this.reading,
    required this.meanings,
    this.meaningsId = const [],
    this.priorities = const [],
    this.jlptLevel,
  });

  final String word;
  final String reading;
  final List<String> meanings;
  final List<String> meaningsId;
  final List<String> priorities;
  final int? jlptLevel;

  /// Primary meaning (Indonesian or English fallback)
  String primaryMeaning(bool isId) {
    if (isId && meaningsId.isNotEmpty) return meaningsId.first;
    return meanings.isNotEmpty ? meanings.first : '';
  }

  /// Check if this is a common word
  bool get isCommon =>
      priorities.any((p) => p.startsWith('ichi') || p.startsWith('news'));

  @override
  List<Object?> get props => [word, reading, jlptLevel];
}
