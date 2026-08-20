import 'dart:math';

import 'package:kanji_lesson/core/constants/app_constants.dart';
import 'package:kanji_lesson/features/kanji/domain/entities/kanji.dart';
import 'package:kanji_lesson/features/kanji/domain/entities/vocabulary.dart';

/// Types of quiz questions
enum QuizType {
  meaning, // Show kanji → pick meaning
  reading, // Show word → pick reading
  kanjiFromReading, // Show hiragana → pick kanji word
  vocabulary, // Show meaning → pick vocabulary
  listening, // TTS → pick answer
}

/// A single quiz question
class QuizQuestion {
  const QuizQuestion({
    required this.type,
    required this.prompt,
    required this.correctAnswer,
    required this.options,
    this.kanjiCharacter,
    this.audioText,
  });

  final QuizType type;
  final String prompt;
  final String correctAnswer;
  final List<String> options; // 4 options including correct
  final String? kanjiCharacter;
  final String? audioText; // For TTS

  int get correctIndex => options.indexOf(correctAnswer);
}

/// Quiz session result
class QuizSessionResult {
  const QuizSessionResult({
    required this.questions,
    required this.answers,
    required this.jlptLevel,
    required this.quizType,
  });

  final List<QuizQuestion> questions;
  final List<int> answers; // Selected option indices
  final int? jlptLevel;
  final QuizType quizType;

  int get totalQuestions => questions.length;

  int get correctCount {
    int count = 0;
    for (int i = 0; i < questions.length && i < answers.length; i++) {
      if (answers[i] == questions[i].correctIndex) count++;
    }
    return count;
  }

  int get incorrectCount => totalQuestions - correctCount;
  double get accuracy =>
      totalQuestions > 0 ? correctCount / totalQuestions : 0.0;
  String get accuracyPercent => '${(accuracy * 100).round()}%';

  /// Get list of incorrectly answered questions
  List<QuizQuestion> get incorrectQuestions {
    final result = <QuizQuestion>[];
    for (int i = 0; i < questions.length && i < answers.length; i++) {
      if (answers[i] != questions[i].correctIndex) {
        result.add(questions[i]);
      }
    }
    return result;
  }
}

/// Service to generate quiz questions
class QuizGenerator {
  QuizGenerator({Random? random}) : _random = random ?? Random();

  final Random _random;

  /// Generate meaning quiz questions
  /// "What does X mean?" → pick from 4 meanings
  List<QuizQuestion> generateMeaningQuiz(
    List<Kanji> kanjiPool, {
    int count = 10,
    bool isId = false,
  }) {
    if (kanjiPool.length < AppConstants.quizOptionsCount) return [];

    final questions = <QuizQuestion>[];
    final shuffled = List<Kanji>.from(kanjiPool)..shuffle(_random);
    final selected = shuffled.take(count).toList();

    for (final kanji in selected) {
      if (kanji.meanings.isEmpty) continue;

      final correctAnswer = kanji.primaryMeaning(isId);

      // Get distractors from other kanji
      final distractors = kanjiPool
          .where((k) => k.character != kanji.character && k.meanings.isNotEmpty)
          .map((k) => k.primaryMeaning(isId))
          .where((m) => m != correctAnswer)
          .toSet()
          .toList()
        ..shuffle(_random);

      if (distractors.length < 3) continue;

      final options = [correctAnswer, ...distractors.take(3)]..shuffle(_random);

      questions.add(QuizQuestion(
        type: QuizType.meaning,
        prompt: kanji.character,
        correctAnswer: correctAnswer,
        options: options,
        kanjiCharacter: kanji.character,
      ));
    }

    return questions.take(count).toList();
  }

  /// Generate reading quiz questions
  /// "How do you read X?" → pick from 4 readings
  List<QuizQuestion> generateReadingQuiz(
    List<Kanji> kanjiPool, {
    int count = 10,
  }) {
    if (kanjiPool.length < AppConstants.quizOptionsCount) return [];

    final questions = <QuizQuestion>[];
    final shuffled = List<Kanji>.from(kanjiPool)..shuffle(_random);
    final selected =
        shuffled.where((k) => k.allReadings.isNotEmpty).take(count).toList();

    for (final kanji in selected) {
      final correctAnswer = kanji.primaryReading;

      final distractors = kanjiPool
          .where((k) =>
              k.character != kanji.character && k.allReadings.isNotEmpty)
          .map((k) => k.primaryReading)
          .where((r) => r != correctAnswer)
          .toSet()
          .toList()
        ..shuffle(_random);

      if (distractors.length < 3) continue;

      final options = [correctAnswer, ...distractors.take(3)]..shuffle(_random);

      questions.add(QuizQuestion(
        type: QuizType.reading,
        prompt: kanji.character,
        correctAnswer: correctAnswer,
        options: options,
        kanjiCharacter: kanji.character,
      ));
    }

    return questions.take(count).toList();
  }

  /// Generate vocabulary quiz from vocabulary list
  List<QuizQuestion> generateVocabularyQuiz(
    List<Vocabulary> vocabPool, {
    int count = 10,
    bool isId = false,
  }) {
    if (vocabPool.length < AppConstants.quizOptionsCount) return [];

    final questions = <QuizQuestion>[];
    final shuffled = List<Vocabulary>.from(vocabPool)..shuffle(_random);
    final selected = shuffled.take(count).toList();

    for (final vocab in selected) {
      if (vocab.meanings.isEmpty) continue;

      final correctAnswer = vocab.primaryMeaning(isId);
      final prompt = vocab.word;

      // Get distractors from other vocabularies
      final distractors = vocabPool
          .where((v) => v.word != vocab.word && v.meanings.isNotEmpty)
          .map((v) => v.primaryMeaning(isId))
          .toSet()
          .toList()
        ..shuffle(_random);

      if (distractors.length < 3) continue;
      
      final options = [correctAnswer, ...distractors.take(3)]..shuffle(_random);

      questions.add(QuizQuestion(
        type: QuizType.vocabulary,
        prompt: prompt,
        correctAnswer: correctAnswer,
        options: options,
        audioText: vocab.reading,
      ));
    }

    return questions.take(count).toList();
  }

  /// Generate mixed quiz from kanji pool
  List<QuizQuestion> generateMixedQuiz(
    List<Kanji> kanjiPool, {
    int count = 10,
    bool isId = false,
  }) {
    final meaningQuestions = generateMeaningQuiz(kanjiPool, count: count, isId: isId);
    final readingQuestions = generateReadingQuiz(kanjiPool, count: count);

    final all = [...meaningQuestions, ...readingQuestions]..shuffle(_random);
    return all.take(count).toList();
  }
}
