import 'dart:math';

import 'package:kanji_lesson/features/kanji/domain/entities/kanji.dart';

import 'package:kanji_lesson/features/kanji/domain/entities/jlpt_vocab.dart';

enum QuizType {
  meaning,
  reading,
  writing,
}

/// A single quiz option with metadata for explanations
class QuizOption {
  const QuizOption({
    required this.text,
    this.kanjiCharacter,
    this.explanation,
  });

  final String text;           // The displayed answer text (meaning or reading)
  final String? kanjiCharacter; // The original kanji for this option
  final String? explanation;    // Extra info (e.g. meaning for reading quiz, reading for meaning quiz)
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
  final List<QuizOption> options; // 4 options including correct
  final String? kanjiCharacter;
  final String? audioText; // For TTS

  int get correctIndex => options.indexWhere((o) => o.text == correctAnswer);
}

/// Quiz session result
class QuizSessionResult {
  const QuizSessionResult({
    required this.questions,
    required this.answers,
    required this.jlptLevel,
    required this.selectedQuizTypes,
  });

  final List<QuizQuestion> questions;
  final List<int> answers; // Selected option indices
  final int? jlptLevel;
  final Set<QuizType> selectedQuizTypes;

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
    List<Kanji> kanjiPool,
    List<JlptVocab> vocabPool, {
    List<Kanji> kanjiDistractors = const [],
    List<JlptVocab> vocabDistractors = const [],
    int count = 10,
    bool isId = false,
  }) {
    final questions = <QuizQuestion>[];
    
    // Mix pools if both have items, otherwise just use one
    final kanjiQuestionsCount = kanjiPool.isEmpty ? 0 : 
        (vocabPool.isEmpty ? count : count ~/ 2);
    final vocabQuestionsCount = vocabPool.isEmpty ? 0 : 
        (count - kanjiQuestionsCount);
        
    // 1. Generate Kanji Questions
    if (kanjiQuestionsCount > 0) {
      final shuffled = List<Kanji>.from(kanjiPool)..shuffle(_random);
      final selected = shuffled.take(kanjiQuestionsCount).toList();

      for (final kanji in selected) {
        if (kanji.meanings.isEmpty) continue;
        final correctAnswer = kanji.primaryMeaning(isId);
        final correctOption = QuizOption(
          text: correctAnswer,
          kanjiCharacter: kanji.character,
          explanation: kanji.primaryReading,
        );

        final dKanjiPool = kanjiDistractors.isNotEmpty ? kanjiDistractors : kanjiPool;
        var distractorKanji = dKanjiPool
            .where((k) => k.character != kanji.character && k.meanings.isNotEmpty)
            .where((k) => k.primaryMeaning(isId) != correctAnswer)
            .toList()..shuffle(_random);
            
        final distractorOptions = distractorKanji.take(3).map((k) => QuizOption(
          text: k.primaryMeaning(isId),
          kanjiCharacter: k.character,
          explanation: k.primaryReading,
        )).toList();
        
        // Fallback dummy options if database is too small
        while (distractorOptions.length < 3) {
          final dummy = isId ? 'Salah ${distractorOptions.length + 1}' : 'Wrong ${distractorOptions.length + 1}';
          if (!distractorOptions.any((o) => o.text == dummy)) {
            distractorOptions.add(QuizOption(text: dummy));
          }
        }

        final options = [correctOption, ...distractorOptions]..shuffle(_random);
        questions.add(QuizQuestion(
          type: QuizType.meaning,
          prompt: kanji.character,
          correctAnswer: correctAnswer,
          options: options,
          kanjiCharacter: kanji.character,
        ));
      }
    }
    
    // 2. Generate Vocab Questions
    if (vocabQuestionsCount > 0) {
      final shuffled = List<JlptVocab>.from(vocabPool)..shuffle(_random);
      final selected = shuffled.take(vocabQuestionsCount).toList();

      for (final vocab in selected) {
        if (vocab.meaning.isEmpty) continue; // fallback check
        final correctAnswer = vocab.primaryMeaning(isId);
        final correctOption = QuizOption(
          text: correctAnswer,
          kanjiCharacter: vocab.word,
          explanation: vocab.furigana,
        );

        final dVocabPool = vocabDistractors.isNotEmpty ? vocabDistractors : vocabPool;
        var distractorVocab = dVocabPool
            .where((v) => v.word != vocab.word)
            .where((v) => v.primaryMeaning(isId) != correctAnswer)
            .toList()..shuffle(_random);
            
        final distractorOptions = distractorVocab.take(3).map((v) => QuizOption(
          text: v.primaryMeaning(isId),
          kanjiCharacter: v.word,
          explanation: v.furigana,
        )).toList();
        
        while (distractorOptions.length < 3) {
          final dummy = isId ? 'Salah ${distractorOptions.length + 1}' : 'Wrong ${distractorOptions.length + 1}';
          if (!distractorOptions.any((o) => o.text == dummy)) {
            distractorOptions.add(QuizOption(text: dummy));
          }
        }

        final options = [correctOption, ...distractorOptions]..shuffle(_random);
        questions.add(QuizQuestion(
          type: QuizType.meaning,
          prompt: vocab.word,
          correctAnswer: correctAnswer,
          options: options,
          kanjiCharacter: vocab.word,
        ));
      }
    }

    return (questions..shuffle(_random)).take(count).toList();
  }

  /// Generate reading quiz questions
  List<QuizQuestion> generateReadingQuiz(
    List<Kanji> kanjiPool,
    List<JlptVocab> vocabPool, {
    List<Kanji> kanjiDistractors = const [],
    List<JlptVocab> vocabDistractors = const [],
    int count = 10,
  }) {
    final questions = <QuizQuestion>[];
    
    final kanjiQuestionsCount = kanjiPool.isEmpty ? 0 : 
        (vocabPool.isEmpty ? count : count ~/ 2);
    final vocabQuestionsCount = vocabPool.isEmpty ? 0 : 
        (count - kanjiQuestionsCount);
        
    // 1. Kanji Readings
    if (kanjiQuestionsCount > 0) {
      final shuffled = List<Kanji>.from(kanjiPool)..shuffle(_random);
      final selected = shuffled.where((k) => k.allReadings.isNotEmpty).take(kanjiQuestionsCount).toList();

      for (final kanji in selected) {
        final correctAnswer = kanji.primaryReading;
        final correctOption = QuizOption(
          text: correctAnswer,
          kanjiCharacter: kanji.character,
          explanation: kanji.primaryMeaning(false),
        );

        final dKanjiPool = kanjiDistractors.isNotEmpty ? kanjiDistractors : kanjiPool;
        var distractorKanji = dKanjiPool
            .where((k) => k.character != kanji.character && k.allReadings.isNotEmpty)
            .where((k) => k.primaryReading != correctAnswer)
            .toList()..shuffle(_random);
            
        final distractorOptions = distractorKanji.take(3).map((k) => QuizOption(
          text: k.primaryReading,
          kanjiCharacter: k.character,
          explanation: k.primaryMeaning(false),
        )).toList();
        
        while (distractorOptions.length < 3) {
          final dummy = 'X ${distractorOptions.length + 1}';
          if (!distractorOptions.any((o) => o.text == dummy)) {
            distractorOptions.add(QuizOption(text: dummy));
          }
        }

        final options = [correctOption, ...distractorOptions]..shuffle(_random);
        questions.add(QuizQuestion(
          type: QuizType.reading,
          prompt: kanji.character,
          correctAnswer: correctAnswer,
          options: options,
          kanjiCharacter: kanji.character,
        ));
      }
    }
    
    // 2. Vocab Readings
    if (vocabQuestionsCount > 0) {
      final shuffled = List<JlptVocab>.from(vocabPool)..shuffle(_random);
      final selected = shuffled.take(vocabQuestionsCount).toList();

      for (final vocab in selected) {
        final correctAnswer = vocab.furigana;
        if (correctAnswer.isEmpty) continue;
        
        final correctOption = QuizOption(
          text: correctAnswer,
          kanjiCharacter: vocab.word,
          explanation: vocab.primaryMeaning(false),
        );

        final dVocabPool = vocabDistractors.isNotEmpty ? vocabDistractors : vocabPool;
        var distractorVocab = dVocabPool
            .where((v) => v.word != vocab.word && v.furigana.isNotEmpty)
            .where((v) => v.furigana != correctAnswer)
            .toList()..shuffle(_random);
            
        final distractorOptions = distractorVocab.take(3).map((v) => QuizOption(
          text: v.furigana,
          kanjiCharacter: v.word,
          explanation: v.primaryMeaning(false),
        )).toList();
        
        while (distractorOptions.length < 3) {
          final dummy = 'X ${distractorOptions.length + 1}';
          if (!distractorOptions.any((o) => o.text == dummy)) {
            distractorOptions.add(QuizOption(text: dummy));
          }
        }

        final options = [correctOption, ...distractorOptions]..shuffle(_random);
        questions.add(QuizQuestion(
          type: QuizType.reading,
          prompt: vocab.word,
          correctAnswer: correctAnswer,
          options: options,
          kanjiCharacter: vocab.word,
        ));
      }
    }

    return (questions..shuffle(_random)).take(count).toList();
  }

  /// Generate writing quiz
  List<QuizQuestion> generateWritingQuiz(
    List<Kanji> kanjiPool,
    List<JlptVocab> vocabPool, {
    int count = 10,
    bool isId = false,
  }) {
    final questions = <QuizQuestion>[];
    
    final kanjiQuestionsCount = kanjiPool.isEmpty ? 0 : 
        (vocabPool.isEmpty ? count : count ~/ 2);
    final vocabQuestionsCount = vocabPool.isEmpty ? 0 : 
        (count - kanjiQuestionsCount);
        
    // 1. Kanji Writing
    if (kanjiQuestionsCount > 0) {
      final shuffled = List<Kanji>.from(kanjiPool)..shuffle(_random);
      final selected = shuffled.take(kanjiQuestionsCount).toList();

      for (final kanji in selected) {
        if (kanji.meanings.isEmpty) continue;
        questions.add(QuizQuestion(
          type: QuizType.writing,
          prompt: kanji.primaryMeaning(isId), // User sees meaning, must draw kanji
          correctAnswer: kanji.character,
          options: [], // No options for writing
          kanjiCharacter: kanji.character,
        ));
      }
    }
    
    // 2. Vocab Writing
    if (vocabQuestionsCount > 0) {
      final shuffled = List<JlptVocab>.from(vocabPool)..shuffle(_random);
      final selected = shuffled.take(vocabQuestionsCount).toList();

      for (final vocab in selected) {
        if (vocab.meaning.isEmpty) continue;
        questions.add(QuizQuestion(
          type: QuizType.writing,
          prompt: vocab.primaryMeaning(isId),
          correctAnswer: vocab.word,
          options: [],
          kanjiCharacter: vocab.word,
        ));
      }
    }

    return (questions..shuffle(_random)).take(count).toList();
  }
}
