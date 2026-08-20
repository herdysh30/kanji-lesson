import 'package:equatable/equatable.dart';

class JlptVocab extends Equatable {
  const JlptVocab({
    required this.word,
    required this.meaning,
    this.meaningId,
    required this.furigana,
    required this.romaji,
    required this.level,
  });

  final String word;
  final String meaning;
  final String? meaningId;
  final String furigana;
  final String romaji;
  final int level;

  @override
  List<Object?> get props => [word, meaning, meaningId, furigana, romaji, level];

  String primaryMeaning(bool isId) {
    if (isId && meaningId != null && meaningId!.isNotEmpty) {
      return meaningId!;
    }
    return meaning;
  }

  factory JlptVocab.fromJson(Map<String, dynamic> json) {
    return JlptVocab(
      word: json['word'] as String? ?? '',
      meaning: json['meaning'] as String? ?? '',
      meaningId: json['meaningId'] as String?,
      furigana: json['furigana'] as String? ?? '',
      romaji: json['romaji'] as String? ?? '',
      level: json['level'] as int? ?? 5,
    );
  }
}
