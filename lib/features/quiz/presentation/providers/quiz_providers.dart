import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kanji_lesson/features/kanji/presentation/providers/kanji_providers.dart';
import 'package:kanji_lesson/features/quiz/domain/services/quiz_generator.dart';
import 'package:kanji_lesson/features/kanji/domain/entities/kanji.dart';
import 'package:kanji_lesson/features/kanji/domain/entities/jlpt_vocab.dart';
import 'package:kanji_lesson/core/database/app_database.dart';
import 'package:kanji_lesson/features/kanji/presentation/providers/jlpt_vocab_providers.dart';
import 'package:kanji_lesson/features/settings/presentation/providers/settings_providers.dart';
import 'package:drift/drift.dart' as drift;

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
      final shuffledChars = List.of(chars)..shuffle();
      for (final char in shuffledChars) {
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

  final allKanji = await localDataSource.searchKanji('');
  final allVocab = await vocabRepo.getAllVocab();

  final List<QuizQuestion> allQuestions = [];
  
  if (setup.selectedQuizTypes.contains(QuizType.meaning)) {
    allQuestions.addAll(generator.generateMeaningQuiz(kanjiPool, vocabPool, kanjiDistractors: allKanji, vocabDistractors: allVocab, count: setup.questionCount, isId: isId));
  }
  if (setup.selectedQuizTypes.contains(QuizType.reading)) {
    allQuestions.addAll(generator.generateReadingQuiz(kanjiPool, vocabPool, kanjiDistractors: allKanji, vocabDistractors: allVocab, count: setup.questionCount));
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
  QuizSessionNotifier(this._db) 
      : super(const QuizSessionState(
          questions: [],
          currentIndex: 0,
          answers: [],
          isFinished: false,
        ));

  final AppDatabase _db;

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
    
    // Update progress in database
    final question = state.currentQuestion!;
    final isCorrect = selectedIndex == question.correctIndex;
    // Writing quiz overrides correctIndex to 0 if correct, 1 if wrong in UI logic, but `answerCurrent` receives it.
    // Actually, writing quiz passes 0 for correct, 1 for wrong. We can just rely on `isCorrect`.
    // Wait, let's just check if selectedIndex == correctIndex.
    final item = question.kanjiCharacter ?? question.correctAnswer;
    
    // Use the existing SRS method to update correct/wrong count
    // Quiz might not change interval/ease, but it should at least increment correct/wrong count.
    _updateProgress(item, isCorrect);
  }
  
  Future<void> _updateProgress(String item, bool isCorrect) async {
    final progress = await _db.getProgress(item);
    if (progress == null) {
      final now = DateTime.now();
      await _db.upsertProgress(UserKanjiProgressEntriesCompanion.insert(
        kanjiCharacter: item,
        status: const drift.Value('learning'),
        correctCount: drift.Value(isCorrect ? 1 : 0),
        wrongCount: drift.Value(isCorrect ? 0 : 1),
        firstLearnedAt: drift.Value(now),
        nextReviewAt: drift.Value(now),
      ));
    } else {
      final total = progress.correctCount + progress.wrongCount + 1;
      final correct = progress.correctCount + (isCorrect ? 1 : 0);
      final accuracy = correct / total;
      
      String newStatus = progress.status;
      if (progress.status != 'mastered' && total >= 5 && accuracy >= 0.8) {
        newStatus = 'mastered';
      } else if (progress.status == 'mastered' && accuracy < 0.8) {
        newStatus = 'reviewing';
      }

      await _db.upsertProgress(UserKanjiProgressEntriesCompanion(
        kanjiCharacter: drift.Value(progress.kanjiCharacter),
        status: drift.Value(newStatus),
        correctCount: drift.Value(progress.correctCount + (isCorrect ? 1 : 0)),
        wrongCount: drift.Value(progress.wrongCount + (isCorrect ? 0 : 1)),
        updatedAt: drift.Value(DateTime.now()),
      ));
    }
  }
  
  void nextQuestion() {
    if (state.isFinished) return;
    
    final nextIndex = state.currentIndex + 1;
    if (nextIndex >= state.questions.length) {
      state = state.copyWith(isFinished: true);
      _saveQuizResult();
    } else {
      state = state.copyWith(currentIndex: nextIndex);
    }
  }

  Future<void> _saveQuizResult() async {
    int correctCount = 0;
    for (int i = 0; i < state.questions.length; i++) {
      if (i < state.answers.length && state.answers[i] == state.questions[i].correctIndex) {
        correctCount++;
      }
    }
    final accuracy = state.questions.isEmpty ? 0.0 : correctCount / state.questions.length;
    
    await _db.insertQuizResult(QuizResultEntriesCompanion.insert(
      quizType: 'mixed', // Simplified, could get from setup
      totalQuestions: state.questions.length,
      correctAnswers: correctCount,
      accuracy: accuracy,
    ));
  }
}

final quizSessionProvider = StateNotifierProvider.autoDispose<QuizSessionNotifier, QuizSessionState>((ref) {
  final db = ref.watch(databaseProvider);
  return QuizSessionNotifier(db);
});
