import 'package:kanji_lesson/features/quiz/domain/services/quiz_generator.dart';
import 'package:kanji_lesson/features/kanji/domain/entities/sentence.dart';

class QuizAttemptRecord {
  const QuizAttemptRecord({
    required this.question,
    required this.userAnswer,
    required this.isCorrect,
  });

  final QuizQuestion question;
  final String userAnswer;
  final bool isCorrect;

  Map<String, dynamic> toJson() {
    return {
      'question': _questionToJson(question),
      'userAnswer': userAnswer,
      'isCorrect': isCorrect,
    };
  }

  static QuizAttemptRecord fromJson(Map<String, dynamic> json) {
    return QuizAttemptRecord(
      question: _questionFromJson(json['question']),
      userAnswer: json['userAnswer'],
      isCorrect: json['isCorrect'],
    );
  }
}

Map<String, dynamic> _questionToJson(QuizQuestion q) {
  return {
    'type': q.type.name,
    'prompt': q.prompt,
    'correctAnswer': q.correctAnswer,
    'options': q.options.map((o) => _optionToJson(o)).toList(),
    'kanjiCharacter': q.kanjiCharacter,
    'audioText': q.audioText,
    'sentenceObj': q.sentenceObj != null ? _sentenceToJson(q.sentenceObj!) : null,
  };
}

QuizQuestion _questionFromJson(Map<String, dynamic> json) {
  return QuizQuestion(
    type: QuizType.values.firstWhere((e) => e.name == json['type']),
    prompt: json['prompt'],
    correctAnswer: json['correctAnswer'],
    options: (json['options'] as List).map((o) => _optionFromJson(o)).toList(),
    kanjiCharacter: json['kanjiCharacter'],
    audioText: json['audioText'],
    sentenceObj: json['sentenceObj'] != null ? _sentenceFromJson(json['sentenceObj']) : null,
  );
}

Map<String, dynamic> _optionToJson(QuizOption o) {
  return {
    'text': o.text,
    'kanjiCharacter': o.kanjiCharacter,
    'explanation': o.explanation,
  };
}

QuizOption _optionFromJson(Map<String, dynamic> json) {
  return QuizOption(
    text: json['text'],
    kanjiCharacter: json['kanjiCharacter'],
    explanation: json['explanation'],
  );
}

Map<String, dynamic> _sentenceToJson(Sentence s) {
  return {
    'japanese': s.japanese,
    'english': s.english,
    'indonesian': s.indonesian,
    'romaji': s.romaji,
  };
}

Sentence _sentenceFromJson(Map<String, dynamic> json) {
  return Sentence(
    japanese: json['japanese'],
    english: json['english'],
    indonesian: json['indonesian'],
    romaji: json['romaji'] ?? '',
  );
}
