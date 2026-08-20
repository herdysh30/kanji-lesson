import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kanji_lesson/features/kanji/presentation/providers/kanji_providers.dart';
import 'package:kanji_lesson/features/quiz/domain/services/quiz_generator.dart';
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
  
  if (setup.selectedJlptLevel != null) {
    final entries = await localDataSource.getCachedKanjiByJlpt(setup.selectedJlptLevel!);
    if (entries.isEmpty) return [];
    
    switch (setup.quizType) {
      case QuizType.meaning:
        return generator.generateMeaningQuiz(entries, count: setup.questionCount, isId: isId);
      case QuizType.reading:
        return generator.generateReadingQuiz(entries, count: setup.questionCount);
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
