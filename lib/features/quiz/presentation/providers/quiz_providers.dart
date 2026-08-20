import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kanji_lesson/features/kanji/presentation/providers/kanji_providers.dart';
import 'package:kanji_lesson/features/quiz/domain/services/quiz_generator.dart';
import 'package:kanji_lesson/features/kanji/domain/entities/kanji.dart';
import 'package:kanji_lesson/features/settings/presentation/providers/settings_providers.dart';

class QuizSetupState {
  const QuizSetupState({
    this.selectedJlptLevel, // null = all learned kanji
    this.quizType = QuizType.meaning,
    this.questionCount = 10,
  });

  final int? selectedJlptLevel;
  final QuizType quizType;
  final int questionCount;

  QuizSetupState copyWith({
    int? selectedJlptLevel,
    bool clearJlptLevel = false,
    QuizType? quizType,
    int? questionCount,
  }) {
    return QuizSetupState(
      selectedJlptLevel: clearJlptLevel ? null : (selectedJlptLevel ?? this.selectedJlptLevel),
      quizType: quizType ?? this.quizType,
      questionCount: questionCount ?? this.questionCount,
    );
  }
}

class QuizSetupNotifier extends StateNotifier<QuizSetupState> {
  QuizSetupNotifier() : super(const QuizSetupState());

  void setJlptLevel(int? level) {
    state = state.copyWith(selectedJlptLevel: level, clearJlptLevel: level == null);
  }

  void setQuizType(QuizType type) {
    state = state.copyWith(quizType: type);
  }

  void setQuestionCount(int count) {
    state = state.copyWith(questionCount: count);
  }
}

final quizSetupProvider = StateNotifierProvider.autoDispose<QuizSetupNotifier, QuizSetupState>((ref) {
  return QuizSetupNotifier();
});

// ─── Generator & Question Provider ─────────────────────────────────

final quizGeneratorProvider = Provider<QuizGenerator>((ref) {
  return QuizGenerator();
});

/// A future provider that actually fetches/generates the quiz questions based on the setup
final quizQuestionsProvider = FutureProvider.autoDispose<List<QuizQuestion>>((ref) async {
  final setup = ref.watch(quizSetupProvider);
  final generator = ref.watch(quizGeneratorProvider);
  final isId = ref.watch(localeProvider).languageCode == 'id';

  // Get kanji pool
  final db = ref.watch(databaseProvider);
  final localDataSource = ref.watch(kanjiLocalDataSourceProvider);
  
  final repo = ref.watch(kanjiRepositoryProvider);
  
  if (setup.selectedJlptLevel != null) {
    // Get list of all characters in this JLPT level
    final chars = await repo.getKanjiListByJlpt(setup.selectedJlptLevel!);
    if (chars.isEmpty) return [];
    
    // We only need enough kanji for the questions + a few extra for distractors
    // This avoids hitting API rate limits or taking too long for 40+ sequential requests
    final poolSize = (setup.questionCount + 5).clamp(10, chars.length);
    final selectedChars = (List.of(chars)..shuffle()).take(poolSize).toList();
    
    // Fetch full details for the selected characters sequentially to avoid API rate limits (HTTP 429)
    final entries = <Kanji>[];
    for (final char in selectedChars) {
      try {
        final detail = await repo.getKanjiDetail(char);
        entries.add(detail);
      } catch (_) {
        // Skip on error
      }
      // Stop early if we have enough kanji for the quiz
      if (entries.length >= poolSize) break;
    }
    
    if (entries.isEmpty) return [];
    switch (setup.quizType) {
      case QuizType.meaning:
        return generator.generateMeaningQuiz(entries, count: setup.questionCount, isId: isId);
      case QuizType.reading:
        return generator.generateReadingQuiz(entries, count: setup.questionCount);
      case QuizType.writing:
        return generator.generateWritingQuiz(entries, count: setup.questionCount, isId: isId);
      default:
        return generator.generateMixedQuiz(entries, count: setup.questionCount, isId: isId);
    }
  } else {
    // Learned kanji
    final learned = await db.getAllProgress();
    final learnedChars = learned.map((e) => e.kanjiCharacter).toList();
    if (learnedChars.isEmpty) return [];
    
    // Fetch their full details from localDataSource
    final allKanji = await localDataSource.searchKanji(''); // get all locally
    final pool = allKanji.where((k) => learnedChars.contains(k.character) && k.meanings.isNotEmpty).toList();
    
    switch (setup.quizType) {
      case QuizType.meaning:
        return generator.generateMeaningQuiz(pool, count: setup.questionCount, isId: isId);
      case QuizType.reading:
        return generator.generateReadingQuiz(pool, count: setup.questionCount);
      case QuizType.writing:
        return generator.generateWritingQuiz(pool, count: setup.questionCount, isId: isId);
      default:
        return generator.generateMixedQuiz(pool, count: setup.questionCount, isId: isId);
    }
  }
});

// ─── Active Quiz Session ──────────────────────────────────────────

class QuizSessionState {
  const QuizSessionState({
    required this.questions,
    required this.currentIndex,
    required this.answers,
    required this.isFinished,
  });

  final List<QuizQuestion> questions;
  final int currentIndex;
  final List<int> answers; // Stores the selected option index for each question
  final bool isFinished;

  QuizQuestion? get currentQuestion => 
      currentIndex < questions.length ? questions[currentIndex] : null;

  QuizSessionState copyWith({
    List<QuizQuestion>? questions,
    int? currentIndex,
    List<int>? answers,
    bool? isFinished,
  }) {
    return QuizSessionState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      isFinished: isFinished ?? this.isFinished,
    );
  }
}

class QuizSessionNotifier extends StateNotifier<QuizSessionState> {
  QuizSessionNotifier() 
      : super(const QuizSessionState(
          questions: [],
          currentIndex: 0,
          answers: [],
          isFinished: false,
        ));

  void initialize(List<QuizQuestion> questions) {
    if (state.questions.isNotEmpty) return; // already initialized
    state = state.copyWith(
      questions: questions,
      isFinished: questions.isEmpty,
    );
  }

  void answerCurrent(int selectedIndex) {
    if (state.isFinished || state.currentQuestion == null) return;
    if (state.answers.length > state.currentIndex) return; // already answered
    
    final newAnswers = List<int>.from(state.answers)..add(selectedIndex);
    state = state.copyWith(answers: newAnswers);
  }
  
  void nextQuestion() {
    if (state.isFinished) return;
    
    final nextIndex = state.currentIndex + 1;
    if (nextIndex >= state.questions.length) {
      state = state.copyWith(isFinished: true);
    } else {
      state = state.copyWith(currentIndex: nextIndex);
    }
  }
}

final quizSessionProvider = StateNotifierProvider.autoDispose<QuizSessionNotifier, QuizSessionState>((ref) {
  return QuizSessionNotifier();
});
