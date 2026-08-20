import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kanji_lesson/features/kanji/presentation/providers/kanji_providers.dart';
import 'package:kanji_lesson/features/quiz/domain/services/quiz_generator.dart';
import 'package:kanji_lesson/features/kanji/domain/entities/kanji.dart';
import 'package:kanji_lesson/features/kanji/domain/entities/jlpt_vocab.dart';
import 'package:kanji_lesson/core/database/app_database.dart';
import 'package:kanji_lesson/features/kanji/presentation/providers/jlpt_vocab_providers.dart';
import 'package:kanji_lesson/features/settings/presentation/providers/settings_providers.dart';

class QuizSetupState {
  const QuizSetupState({
    this.selectedJlptLevel, // null = all learned kanji
    this.selectedQuizTypes = const {QuizType.meaning, QuizType.reading},
    this.itemType = ReviewItemType.mixed,
    this.questionCount = 10,
    this.isCustomCount = false,
  });

  final int? selectedJlptLevel;
  final Set<QuizType> selectedQuizTypes;
  final ReviewItemType itemType;
  final int questionCount;
  final bool isCustomCount;

  QuizSetupState copyWith({
    int? selectedJlptLevel,
    bool clearJlptLevel = false,
    Set<QuizType>? selectedQuizTypes,
    ReviewItemType? itemType,
    int? questionCount,
    bool? isCustomCount,
  }) {
    return QuizSetupState(
      selectedJlptLevel: clearJlptLevel ? null : (selectedJlptLevel ?? this.selectedJlptLevel),
      selectedQuizTypes: selectedQuizTypes ?? this.selectedQuizTypes,
      itemType: itemType ?? this.itemType,
      questionCount: questionCount ?? this.questionCount,
      isCustomCount: isCustomCount ?? this.isCustomCount,
    );
  }
}

class QuizSetupNotifier extends StateNotifier<QuizSetupState> {
  QuizSetupNotifier() : super(const QuizSetupState());

  void setJlptLevel(int? level) {
    state = state.copyWith(selectedJlptLevel: level, clearJlptLevel: level == null);
  }

  void toggleQuizType(QuizType type) {
    final types = Set<QuizType>.from(state.selectedQuizTypes);
    if (types.contains(type) && types.length > 1) {
      types.remove(type);
    } else {
      types.add(type);
    }
    state = state.copyWith(selectedQuizTypes: types);
  }

  void setItemType(ReviewItemType type) {
    state = state.copyWith(itemType: type);
  }

  void setQuestionCount(int count, {bool isCustom = false}) {
    state = state.copyWith(questionCount: count, isCustomCount: isCustom);
  }
}

final quizSetupProvider = StateNotifierProvider.autoDispose<QuizSetupNotifier, QuizSetupState>((ref) {
  return QuizSetupNotifier();
});

final maxQuizItemsProvider = FutureProvider.autoDispose<int>((ref) async {
  final setup = ref.watch(quizSetupProvider);
  
  final db = ref.watch(databaseProvider);
  final vocabRepo = ref.watch(jlptVocabRepositoryProvider);
  final kanjiRepo = ref.watch(kanjiRepositoryProvider);

  int maxCount = 0;

  if (setup.selectedJlptLevel != null) {
    if (setup.itemType == ReviewItemType.kanji || setup.itemType == ReviewItemType.mixed) {
      final chars = await kanjiRepo.getKanjiListByJlpt(setup.selectedJlptLevel!);
      maxCount += chars.length;
    }
    if (setup.itemType == ReviewItemType.vocab || setup.itemType == ReviewItemType.mixed) {
      final vocabs = await vocabRepo.getVocabByLevel(setup.selectedJlptLevel!);
      maxCount += vocabs.length;
    }
  } else {
    final learned = await db.getAllProgress();
    final learnedKanji = learned.where((e) => e.kanjiCharacter.length == 1).toList();
    final learnedVocab = learned.where((e) => e.kanjiCharacter.length > 1).toList();

    if (setup.itemType == ReviewItemType.kanji || setup.itemType == ReviewItemType.mixed) {
      maxCount += learnedKanji.length;
    }
    if (setup.itemType == ReviewItemType.vocab || setup.itemType == ReviewItemType.mixed) {
      maxCount += learnedVocab.length;
    }
  }

  return maxCount == 0 ? 10 : maxCount; // Fallback so it doesn't break UI
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

  final db = ref.watch(databaseProvider);
  final localDataSource = ref.watch(kanjiLocalDataSourceProvider);
  final repo = ref.watch(kanjiRepositoryProvider);
  final vocabRepo = ref.watch(jlptVocabRepositoryProvider);

  List<Kanji> kanjiPool = [];
  List<JlptVocab> vocabPool = [];

  if (setup.selectedJlptLevel != null) {
    if (setup.itemType == ReviewItemType.kanji || setup.itemType == ReviewItemType.mixed) {
      final chars = await repo.getKanjiListByJlpt(setup.selectedJlptLevel!);
      final poolSize = (setup.questionCount + 5).clamp(10, chars.length);
      final selectedChars = (List.of(chars)..shuffle()).take(poolSize).toList();
      for (final char in selectedChars) {
        try {
          kanjiPool.add(await repo.getKanjiDetail(char));
        } catch (_) {}
        if (kanjiPool.length >= poolSize) break;
      }
    }
    if (setup.itemType == ReviewItemType.vocab || setup.itemType == ReviewItemType.mixed) {
      vocabPool = await vocabRepo.getVocabByLevel(setup.selectedJlptLevel!);
    }
  } else {
    final learned = await db.getAllProgress();
    final learnedChars = learned.map((e) => e.kanjiCharacter).toList();
    
    if (setup.itemType == ReviewItemType.kanji || setup.itemType == ReviewItemType.mixed) {
      final kanjiOnly = learnedChars.where((c) => c.length == 1).toList();
      final allKanji = await localDataSource.searchKanji('');
      kanjiPool = allKanji.where((k) => kanjiOnly.contains(k.character) && k.meanings.isNotEmpty).toList();
    }
    
    if (setup.itemType == ReviewItemType.vocab || setup.itemType == ReviewItemType.mixed) {
      final vocabOnly = learnedChars.where((c) => c.length > 1).toList();
      for (var word in vocabOnly) {
        final v = await vocabRepo.getVocabByWord(word);
        if (v != null) vocabPool.add(v);
      }
    }
  }

  final List<QuizQuestion> allQuestions = [];
  
  if (setup.selectedQuizTypes.contains(QuizType.meaning)) {
    allQuestions.addAll(generator.generateMeaningQuiz(kanjiPool, vocabPool, count: setup.questionCount, isId: isId));
  }
  if (setup.selectedQuizTypes.contains(QuizType.reading)) {
    allQuestions.addAll(generator.generateReadingQuiz(kanjiPool, vocabPool, count: setup.questionCount));
  }
  if (setup.selectedQuizTypes.contains(QuizType.writing)) {
    allQuestions.addAll(generator.generateWritingQuiz(kanjiPool, vocabPool, count: setup.questionCount, isId: isId));
  }

  allQuestions.shuffle();
  return allQuestions.take(setup.questionCount).toList();
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
