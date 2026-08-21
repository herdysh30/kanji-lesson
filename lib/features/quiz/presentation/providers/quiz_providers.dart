import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kanji_lesson/features/kanji/presentation/providers/kanji_providers.dart';
import 'package:kanji_lesson/features/quiz/domain/services/quiz_generator.dart';
import 'package:kanji_lesson/features/kanji/domain/entities/kanji.dart';
import 'package:kanji_lesson/features/kanji/domain/entities/jlpt_vocab.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'package:kanji_lesson/core/database/app_database.dart';
import 'package:kanji_lesson/features/kanji/presentation/providers/jlpt_vocab_providers.dart';
import 'package:kanji_lesson/features/settings/presentation/providers/settings_providers.dart';
import 'package:drift/drift.dart' as drift;
import 'package:equatable/equatable.dart';
import 'package:kanji_lesson/features/quiz/domain/models/quiz_attempt.dart';

enum QuizItemType {
  kanji,
  vocab,
  sentence,
}

class QuizSetupState extends Equatable {
  const QuizSetupState({
    this.selectedJlptLevel,
    this.questionCount = 10,
    this.isCustomCount = false,
    this.selectedQuizTypes = const {QuizType.meaning, QuizType.reading},
    this.selectedItemTypes = const {QuizItemType.kanji, QuizItemType.vocab},
  });

  final int? selectedJlptLevel;
  final int questionCount;
  final bool isCustomCount;
  final Set<QuizType> selectedQuizTypes;
  final Set<QuizItemType> selectedItemTypes;

  QuizSetupState copyWith({
    int? selectedJlptLevel,
    int? questionCount,
    bool? isCustomCount,
    Set<QuizType>? selectedQuizTypes,
    Set<QuizItemType>? selectedItemTypes,
  }) {
    return QuizSetupState(
      selectedJlptLevel: selectedJlptLevel ?? this.selectedJlptLevel,
      questionCount: questionCount ?? this.questionCount,
      isCustomCount: isCustomCount ?? this.isCustomCount,
      selectedQuizTypes: selectedQuizTypes ?? this.selectedQuizTypes,
      selectedItemTypes: selectedItemTypes ?? this.selectedItemTypes,
    );
  }

  @override
  List<Object?> get props => [
        selectedJlptLevel,
        questionCount,
        isCustomCount,
        selectedQuizTypes,
        selectedItemTypes,
      ];
}

class QuizSetupNotifier extends StateNotifier<QuizSetupState> {
  QuizSetupNotifier() : super(const QuizSetupState());

  void setJlptLevel(int? level) {
    state = state.copyWith(selectedJlptLevel: level);
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

  void setItemTypes(Set<QuizItemType> types) {
    state = state.copyWith(selectedItemTypes: types);
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
    if (setup.selectedItemTypes.contains(QuizItemType.kanji) || setup.selectedItemTypes.contains(QuizItemType.sentence)) {
      final chars = await kanjiRepo.getKanjiListByJlpt(setup.selectedJlptLevel!);
      maxCount += chars.length;
    }
    if (setup.selectedItemTypes.contains(QuizItemType.vocab) || setup.selectedItemTypes.contains(QuizItemType.sentence)) {
      final vocabs = await vocabRepo.getVocabByLevel(setup.selectedJlptLevel!);
      maxCount += vocabs.length;
    }
  } else {
    final learned = await db.getAllProgress();
    final learnedKanji = learned.where((e) => e.kanjiCharacter.length == 1).toList();
    final learnedVocab = learned.where((e) => e.kanjiCharacter.length > 1).toList();

    if (setup.selectedItemTypes.contains(QuizItemType.kanji) || setup.selectedItemTypes.contains(QuizItemType.sentence)) {
      maxCount += learnedKanji.length;
    }
    if (setup.selectedItemTypes.contains(QuizItemType.vocab) || setup.selectedItemTypes.contains(QuizItemType.sentence)) {
      maxCount += learnedVocab.length;
    }
  }

  return maxCount == 0 ? 10 : maxCount;
});

// ─── Generator & Question Provider ─────────────────────────────────

final quizGeneratorProvider = Provider<QuizGenerator>((ref) {
  return QuizGenerator();
});



class QuizSessionInitData {
  QuizSessionInitData({
    required this.tasks,
    required this.kanjiDistractors,
    required this.vocabDistractors,
    required this.isId,
  });

  final List<QuizTask> tasks;
  final List<Kanji> kanjiDistractors;
  final List<JlptVocab> vocabDistractors;
  final bool isId;
}

/// A future provider that fetches the pools and creates QuizTasks (very fast)
final quizInitDataProvider = FutureProvider.autoDispose<QuizSessionInitData>((ref) async {
  final setup = ref.watch(quizSetupProvider);
  final isId = ref.watch(localeProvider).languageCode == 'id';

  final db = ref.watch(databaseProvider);
  final localDataSource = ref.watch(kanjiLocalDataSourceProvider);
  final repo = ref.watch(kanjiRepositoryProvider);
  final vocabRepo = ref.watch(jlptVocabRepositoryProvider);

  List<Kanji> kanjiPool = [];
  List<JlptVocab> vocabPool = [];

  if (setup.selectedJlptLevel != null) {
    final allProgress = await db.getAllProgress();
    final progressMap = {for (var p in allProgress) p.kanjiCharacter: p};
    final rnd = math.Random();
    
    double getPriorityScore(String char) {
      final p = progressMap[char];
      if (p == null) return 80.0 + (rnd.nextDouble() * 20); // New (unseen)
      if (p.status == 'mastered') return 0.0 + (rnd.nextDouble() * 10);
      
      double score = 20.0;
      final total = p.correctCount + p.wrongCount;
      if (total > 0) {
        final wrongRatio = p.wrongCount / total;
        if (wrongRatio > 0.5) score += 60.0; // Weak
        else if (wrongRatio > 0.3) score += 30.0;
      }
      if (p.status == 'learning') score += 40.0;
      if (p.nextReviewAt != null && p.nextReviewAt!.isBefore(DateTime.now())) score += 20.0;
      return score + (rnd.nextDouble() * 10); // Random noise
    }

    if (setup.selectedItemTypes.contains(QuizItemType.kanji) || setup.selectedItemTypes.contains(QuizItemType.sentence)) {
      final chars = await repo.getKanjiListByJlpt(setup.selectedJlptLevel!);
      final poolSize = (setup.questionCount + 5).clamp(10, chars.length);
      
      final sortedChars = List.of(chars)..sort((a, b) => getPriorityScore(b).compareTo(getPriorityScore(a)));
      
      for (final char in sortedChars) {
        try {
          kanjiPool.add(await repo.getKanjiDetail(char));
        } catch (_) {}
        if (kanjiPool.length >= poolSize) break;
      }
    }
    if (setup.selectedItemTypes.contains(QuizItemType.vocab) || setup.selectedItemTypes.contains(QuizItemType.sentence)) {
      final vocabs = await vocabRepo.getVocabByLevel(setup.selectedJlptLevel!);
      vocabPool = List.of(vocabs)..sort((a, b) => getPriorityScore(b.word).compareTo(getPriorityScore(a.word)));
    }
  } else {
    final learned = await db.getAllProgress();
    final learnedChars = learned.map((e) => e.kanjiCharacter).toList();
    
    if (setup.selectedItemTypes.contains(QuizItemType.kanji) || setup.selectedItemTypes.contains(QuizItemType.sentence)) {
      final kanjiOnly = learnedChars.where((c) => c.length == 1).toList();
      final allKanji = await localDataSource.searchKanji('');
      kanjiPool = allKanji.where((k) => kanjiOnly.contains(k.character) && k.meanings.isNotEmpty).toList();
    }
    
    if (setup.selectedItemTypes.contains(QuizItemType.vocab) || setup.selectedItemTypes.contains(QuizItemType.sentence)) {
      final vocabOnly = learnedChars.where((c) => c.length > 1).toList();
      for (var word in vocabOnly) {
        final v = await vocabRepo.getVocabByWord(word);
        if (v != null) vocabPool.add(v);
      }
    }
  }

  final allKanji = await localDataSource.searchKanji('');
  final allVocab = await vocabRepo.getAllVocab();

  final List<QuizTask> allTasks = [];

  void addTasksForType(QuizType type) {
    final kanjiCount = setup.selectedItemTypes.contains(QuizItemType.kanji) ? kanjiPool.length : 0;
    final vocabCount = setup.selectedItemTypes.contains(QuizItemType.vocab) ? vocabPool.length : 0;
    
    int qKanji = 0;
    int qVocab = 0;
    if (kanjiCount > 0 && vocabCount > 0) {
      qKanji = setup.questionCount ~/ 2;
      qVocab = setup.questionCount - qKanji;
    } else if (kanjiCount > 0) {
      qKanji = setup.questionCount;
    } else if (vocabCount > 0) {
      qVocab = setup.questionCount;
    }

    final Set<String> usedPrompts = {};

    if (qKanji > 0) {
      List<Kanji> validKanji = List.of(kanjiPool);
      if (type == QuizType.meaning || type == QuizType.writing) {
        validKanji.retainWhere((k) => k.meanings.isNotEmpty);
      } else if (type == QuizType.reading) {
        validKanji.retainWhere((k) => k.allReadings.isNotEmpty);
      }
      validKanji.shuffle();
      final selected = validKanji.take(qKanji).toList();
      usedPrompts.addAll(selected.map((k) => k.character));
      allTasks.addAll(selected.map((k) => QuizTask(type: type, kanji: k)));
    }

    if (qVocab > 0) {
      List<JlptVocab> validVocab = List.of(vocabPool);
      if (type == QuizType.meaning || type == QuizType.writing) {
        validVocab.retainWhere((v) => v.meaning.isNotEmpty);
      } else if (type == QuizType.reading) {
        validVocab.retainWhere((v) => v.furigana.isNotEmpty);
      }
      validVocab.removeWhere((v) => usedPrompts.contains(v.word));
      validVocab.shuffle();
      allTasks.addAll(validVocab.take(qVocab).map((v) => QuizTask(type: type, vocab: v)));
    }
  }
  
  if (setup.selectedQuizTypes.contains(QuizType.meaning)) addTasksForType(QuizType.meaning);
  if (setup.selectedQuizTypes.contains(QuizType.reading)) addTasksForType(QuizType.reading);
  if (setup.selectedQuizTypes.contains(QuizType.writing)) addTasksForType(QuizType.writing);
  
  if (setup.selectedItemTypes.contains(QuizItemType.sentence)) {
    final validVocab = List.of(vocabPool)..shuffle();
    List<QuizType> sentenceQuizTypes = [];
    if (setup.selectedQuizTypes.contains(QuizType.meaning)) sentenceQuizTypes.add(QuizType.meaning);
    if (setup.selectedQuizTypes.contains(QuizType.reading)) sentenceQuizTypes.add(QuizType.reading);
    if (sentenceQuizTypes.isEmpty) sentenceQuizTypes.add(QuizType.meaning);

    for (int i = 0; i < setup.questionCount; i++) {
       if (i >= validVocab.length) break;
       final qt = sentenceQuizTypes[i % sentenceQuizTypes.length];
       allTasks.add(QuizTask(type: qt, vocab: validVocab[i], isSentence: true));
    }
  }

  allTasks.shuffle();
  final finalTasks = allTasks.take(setup.questionCount).toList();

  return QuizSessionInitData(
    tasks: finalTasks,
    kanjiDistractors: allKanji,
    vocabDistractors: allVocab,
    isId: isId,
  );
});

// ─── Active Quiz Session ──────────────────────────────────────────

class QuizSessionState {
  const QuizSessionState({
    required this.tasks,
    required this.resolvedQuestions,
    required this.currentIndex,
    required this.answers,
    required this.isFinished,
    required this.isGeneratingNext,
    this.hintedQuestionIndices = const {},
  });

  final List<QuizTask> tasks;
  final List<QuizQuestion> resolvedQuestions;
  final int currentIndex;
  final List<int> answers;
  final bool isFinished;
  final bool isGeneratingNext;
  final Set<int> hintedQuestionIndices;

  QuizQuestion? get currentQuestion => 
      currentIndex < resolvedQuestions.length ? resolvedQuestions[currentIndex] : null;

  QuizSessionState copyWith({
    List<QuizTask>? tasks,
    List<QuizQuestion>? resolvedQuestions,
    int? currentIndex,
    List<int>? answers,
    bool? isFinished,
    bool? isGeneratingNext,
    Set<int>? hintedQuestionIndices,
  }) {
    return QuizSessionState(
      tasks: tasks ?? this.tasks,
      resolvedQuestions: resolvedQuestions ?? this.resolvedQuestions,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      isFinished: isFinished ?? this.isFinished,
      isGeneratingNext: isGeneratingNext ?? this.isGeneratingNext,
      hintedQuestionIndices: hintedQuestionIndices ?? this.hintedQuestionIndices,
    );
  }
}

class QuizSessionNotifier extends StateNotifier<QuizSessionState> {
  QuizSessionNotifier(this._db, this._generator, this._ref) 
      : super(const QuizSessionState(
          tasks: [],
          resolvedQuestions: [],
          currentIndex: 0,
          answers: [],
          isFinished: false,
          isGeneratingNext: false,
        ));

  final AppDatabase _db;
  final QuizGenerator _generator;
  final Ref _ref;
  
  QuizSessionInitData? _initData;
  bool get isGeneratingNext => state.isGeneratingNext;
  bool get isFinished => state.isFinished;

  void startRetake(List<QuizQuestion> questions) {
    state = state.copyWith(
      tasks: [],
      resolvedQuestions: questions,
      currentIndex: 0,
      answers: [],
      hintedQuestionIndices: {},
      isFinished: false,
      isGeneratingNext: false,
    );
  }

  void initialize(QuizSessionInitData initData) {
    if (state.tasks.isNotEmpty) return; // already initialized
    _initData = initData;
    state = state.copyWith(
      tasks: initData.tasks,
      isFinished: initData.tasks.isEmpty,
    );
    if (initData.tasks.isNotEmpty) {
      _generateNext();
    }
  }

  Future<void> _generateNext() async {
    if (state.isGeneratingNext || _initData == null) return;
    if (state.resolvedQuestions.length >= state.tasks.length) return;

    state = state.copyWith(isGeneratingNext: true);

    try {
      final taskIndex = state.resolvedQuestions.length;
      final nextTask = state.tasks[taskIndex];
      
      final question = await _generator.generateSingleQuestion(
        nextTask,
        kanjiDistractors: _initData!.kanjiDistractors,
        vocabDistractors: _initData!.vocabDistractors,
        isSentence: nextTask.isSentence,
        fetchSentences: (query) => _ref.read(kanjiSentencesProvider(query).future),
        isId: _initData!.isId,
      );

      if (question != null) {
        state = state.copyWith(
          resolvedQuestions: [...state.resolvedQuestions, question],
          isGeneratingNext: false,
        );
      } else {
        // Fallback: task failed. Remove it and try the next one.
        final newTasks = List<QuizTask>.from(state.tasks)..removeAt(taskIndex);
        state = state.copyWith(
          tasks: newTasks,
          isFinished: newTasks.isEmpty || (state.currentIndex >= newTasks.length),
          isGeneratingNext: false,
        );
        if (!state.isFinished) {
          _generateNext();
        }
      }
    } catch (e) {
      state = state.copyWith(isGeneratingNext: false);
    }
  }
  
  void markHintUsed() {
    if (state.isFinished || state.currentQuestion == null) return;
    final newHints = Set<int>.from(state.hintedQuestionIndices)..add(state.currentIndex);
    state = state.copyWith(hintedQuestionIndices: newHints);
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
    
    final isHintUsed = state.hintedQuestionIndices.contains(state.currentIndex);
    _updateProgress(item, isCorrect, isHintUsed: isHintUsed);

    // Prefetch next question while user views explanation
    _generateNext();
  }
  
  Future<void> _updateProgress(String item, bool isCorrect, {bool isHintUsed = false}) async {
    final effectiveCorrect = isCorrect && !isHintUsed;
    
    final progress = await _db.getProgress(item);
    if (progress == null) {
      final now = DateTime.now();
      await _db.upsertProgress(UserKanjiProgressEntriesCompanion.insert(
        kanjiCharacter: item,
        status: const drift.Value('learning'),
        correctCount: drift.Value(effectiveCorrect ? 1 : 0),
        wrongCount: drift.Value(effectiveCorrect ? 0 : 1),
        firstLearnedAt: drift.Value(now),
        nextReviewAt: drift.Value(now),
      ));
    } else {
      final total = progress.correctCount + progress.wrongCount + 1;
      final correct = progress.correctCount + (effectiveCorrect ? 1 : 0);
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
        correctCount: drift.Value(progress.correctCount + (effectiveCorrect ? 1 : 0)),
        wrongCount: drift.Value(progress.wrongCount + (effectiveCorrect ? 0 : 1)),
        updatedAt: drift.Value(DateTime.now()),
      ));
    }
  }
  
  void nextQuestion() {
    if (state.isFinished) return;
    
    final nextIndex = state.currentIndex + 1;
    if (nextIndex >= state.tasks.length) {
      state = state.copyWith(isFinished: true);
      _saveQuizResult();
    } else {
      state = state.copyWith(currentIndex: nextIndex);
    }
  }

  Future<void> _saveQuizResult() async {
    int correctCount = 0;
    List<QuizAttemptRecord> attempts = [];

    for (int i = 0; i < state.resolvedQuestions.length; i++) {
      final question = state.resolvedQuestions[i];
      final isAnswered = i < state.answers.length;
      final userAnswerIndex = isAnswered ? state.answers[i] : -1;
      final isCorrect = userAnswerIndex == question.correctIndex;

      if (isCorrect) correctCount++;
      
      attempts.add(QuizAttemptRecord(
        question: question,
        userAnswer: isAnswered && userAnswerIndex >= 0 ? question.options[userAnswerIndex].text : '',
        isCorrect: isCorrect,
      ));
    }
    
    final accuracy = state.resolvedQuestions.isEmpty ? 0.0 : correctCount / state.resolvedQuestions.length;
    final questionsJsonStr = jsonEncode(attempts.map((a) => a.toJson()).toList());
    
    await _db.insertQuizResult(QuizResultEntriesCompanion.insert(
      quizType: 'mixed',
      totalQuestions: state.resolvedQuestions.length,
      correctAnswers: correctCount,
      accuracy: accuracy,
      questionsJson: drift.Value(questionsJsonStr),
    ));
    
    // Add Daily Progress
    _ref.read(dailyProgressProvider.notifier).addProgress(correctCount);
  }
}

final quizSessionProvider = StateNotifierProvider.autoDispose<QuizSessionNotifier, QuizSessionState>((ref) {
  final db = ref.watch(databaseProvider);
  final generator = ref.watch(quizGeneratorProvider);
  return QuizSessionNotifier(db, generator, ref);
});
