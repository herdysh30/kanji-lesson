import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kanji_lesson/core/theme/app_colors.dart';
import 'package:kanji_lesson/core/theme/app_theme.dart';
import 'package:kanji_lesson/features/quiz/domain/services/quiz_generator.dart';
import 'package:kanji_lesson/features/quiz/presentation/providers/quiz_providers.dart';
import 'package:kanji_lesson/features/kanji/presentation/widgets/kanji_drawing_pad.dart';
import 'package:kanji_lesson/core/services/mlkit_digital_ink_service.dart';
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart'
    as mlkit;

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int? _selectedAnswerIndex;
  bool _isAnswerRevealed = false;

  // Writing Quiz state
  mlkit.Ink? _currentInk;
  bool _isChecking = false;
  bool _showHint = false;

  void _handleOptionSelected(int index, QuizQuestion question) {
    if (_isAnswerRevealed) return; // Prevent multiple taps

    setState(() {
      _selectedAnswerIndex = index;
      _isAnswerRevealed = true;
    });

    final notifier = ref.read(quizSessionProvider.notifier);
    notifier.answerCurrent(index);
  }

  void _onNextPressed() {
    final state = ref.read(quizSessionProvider);
    if (state.isFinished) {
      context.pushReplacement('/quiz/result');
    } else {
      setState(() {
        _selectedAnswerIndex = null;
        _isAnswerRevealed = false;
        _currentInk = null;
        _showHint = false;
      });
      ref.read(quizSessionProvider.notifier).nextQuestion();

      if (ref.read(quizSessionProvider).isFinished) {
        context.pushReplacement('/quiz/result');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(quizQuestionsProvider);
    final sessionState = ref.watch(quizSessionProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _confirmExit(context);
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 4.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Consumer(
                builder: (context, ref, _) {
                  final sessionState = ref.watch(quizSessionProvider);
                  final progress = sessionState.questions.isEmpty
                      ? 0.0
                      : sessionState.currentIndex /
                            sessionState.questions.length;
                  return SafeArea(
                    bottom: false,
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      color: AppColors.incorrect,
                      minHeight: 4,
                    ),
                  );
                },
              ),
              Expanded(
                child: AppBar(
                  title: const Text('Quiz Session'),
                  centerTitle: true,
                  leading: IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => _confirmExit(context),
                  ),
                  elevation: 0,
                  primary: false,
                ),
              ),
            ],
          ),
        ),
        body: questionsAsync.when(
          data: (questions) {
            if (questions.isEmpty) {
              final setup = ref.watch(quizSetupProvider);
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Not enough data to generate quiz.\n\nDebug Info:\n'
                    'JLPT Level: ${setup.selectedJlptLevel}\n'
                    'Item Type: ${setup.itemType.name}\n'
                    'Quiz Types: ${setup.selectedQuizTypes.map((e) => e.name).join(', ')}\n'
                    'Make sure you have learned some Kanji/Vocab first.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            // Initialize session with loaded questions
            Future.microtask(() {
              ref.read(quizSessionProvider.notifier).initialize(questions);
            });

            final currentQuestion = sessionState.currentQuestion;
            if (currentQuestion == null) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Text(
                    'Question ${sessionState.currentIndex + 1} of ${sessionState.questions.length}',
                    style: Theme.of(context).textTheme.labelMedium,
                    textAlign: TextAlign.center,
                  ),
                ),

                // Prompt Area (Prominently Centered at Top)
                if (currentQuestion.type != QuizType.writing)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 16.0,
                      ),
                      child: SizedBox(
                        height: 110,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: Text(
                            currentQuestion.prompt,
                            style: AppTheme.kanjiLarge(context).copyWith(
                              fontSize: 96,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (currentQuestion.type == QuizType.writing)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 16.0,
                      ),
                      child: Text(
                        currentQuestion.prompt,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                // Hint for Meaning/Reading Quizzes
                if (currentQuestion.type != QuizType.writing &&
                    !_isAnswerRevealed)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: AnimatedSize(
                        duration: const Duration(milliseconds: 200),
                        child: _showHint
                            ? Text(
                                currentQuestion
                                        .options[currentQuestion.correctIndex]
                                        .explanation ??
                                    '',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                textAlign: TextAlign.center,
                              )
                            : OutlinedButton(
                                onPressed: () =>
                                    setState(() => _showHint = true),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  side: BorderSide(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outlineVariant,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Show Hint',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.lightbulb_outline,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                  ),

                // Question Instruction
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      _getInstructionText(currentQuestion.type),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                // Options or Drawing Pad
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: currentQuestion.type == QuizType.writing
                        ? _buildWritingPad(currentQuestion)
                        : CustomScrollView(
                            slivers: [
                              SliverFillRemaining(
                                hasScrollBody: false,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ...List.generate(
                                      currentQuestion.options.length,
                                      (index) {
                                        final option =
                                            currentQuestion.options[index];
                                        final isSelected =
                                            _selectedAnswerIndex == index;
                                        final isCorrectOption =
                                            index ==
                                            currentQuestion.correctIndex;

                                        Color backgroundColor = Theme.of(
                                          context,
                                        ).colorScheme.surface;
                                        Color borderColor = Theme.of(
                                          context,
                                        ).colorScheme.outlineVariant;
                                        Color textColor = Theme.of(
                                          context,
                                        ).colorScheme.onSurface;

                                        if (_isAnswerRevealed) {
                                          if (isCorrectOption) {
                                            backgroundColor = AppColors.correct
                                                .withValues(alpha: 0.15);
                                            borderColor = AppColors.correct;
                                            textColor = AppColors.correct;
                                          } else if (isSelected &&
                                              !isCorrectOption) {
                                            backgroundColor = AppColors
                                                .incorrect
                                                .withValues(alpha: 0.15);
                                            borderColor = AppColors.incorrect;
                                            textColor = AppColors.incorrect;
                                          } else {
                                            borderColor = Theme.of(context)
                                                .colorScheme
                                                .outlineVariant
                                                .withValues(alpha: 0.5);
                                            textColor = Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.5);
                                          }
                                        }

                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 12.0,
                                          ),
                                          child: SizedBox(
                                            width: double.infinity,
                                            child: OutlinedButton(
                                              style: OutlinedButton.styleFrom(
                                                backgroundColor:
                                                    backgroundColor,
                                                foregroundColor: textColor,
                                                side: BorderSide(
                                                  color: borderColor,
                                                  width: 1.0,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 16,
                                                      horizontal: 20,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              onPressed: () =>
                                                  _handleOptionSelected(
                                                    index,
                                                    currentQuestion,
                                                  ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    option.text,
                                                    style: TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          _isAnswerRevealed &&
                                                              (isCorrectOption ||
                                                                  isSelected)
                                                          ? FontWeight.bold
                                                          : FontWeight.normal,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  // Show explanation after answering
                                                  if (_isAnswerRevealed &&
                                                      option.kanjiCharacter !=
                                                          null)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            top: 6,
                                                          ),
                                                      child: Text(
                                                        _getOptionExplanation(
                                                          currentQuestion.type,
                                                          option,
                                                        ),
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color: textColor
                                                              .withValues(
                                                                alpha: 0.85,
                                                              ),
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    // Skip / Don't Know button
                                    if (!_isAnswerRevealed)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 4,
                                          bottom: 8,
                                        ),
                                        child: SizedBox(
                                          width: double.infinity,
                                          height: 48,
                                          child: TextButton(
                                            onPressed: () =>
                                                _handleOptionSelected(
                                                  -1,
                                                  currentQuestion,
                                                ),
                                            style: TextButton.styleFrom(
                                              foregroundColor: Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant,
                                            ),
                                            child: const Text(
                                              'I don\'t know / Skip',
                                              style: TextStyle(fontSize: 15),
                                            ),
                                          ),
                                        ),
                                      ),
                                    // Next button
                                    if (_isAnswerRevealed)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 4,
                                          bottom: 8,
                                        ),
                                        child: SizedBox(
                                          width: double.infinity,
                                          height: 52,
                                          child: FilledButton.icon(
                                            onPressed: _onNextPressed,
                                            icon: const Icon(
                                              Icons.arrow_forward_rounded,
                                            ),
                                            label: Text(
                                              sessionState.currentIndex >=
                                                      sessionState
                                                              .questions
                                                              .length -
                                                          1
                                                  ? 'See Results'
                                                  : 'Next Question',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generating Quiz...'),
              ],
            ),
          ),
          error: (_, __) => const Center(child: Text('Failed to load quiz.')),
        ),
      ),
    );
  }

  String _getInstructionText(QuizType type) {
    switch (type) {
      case QuizType.meaning:
        return 'What does this mean?';
      case QuizType.reading:
        return 'How do you read this?';
      case QuizType.writing:
        return 'Draw the Character';
    }
  }

  /// Get explanation text for a quiz option based on quiz type
  String _getOptionExplanation(QuizType type, QuizOption option) {
    final kanji = option.kanjiCharacter ?? '';
    final explanation = option.explanation ?? '';
    switch (type) {
      case QuizType.meaning:
        return '$kanji — $explanation';
      case QuizType.reading:
        return '$kanji — $explanation';
      default:
        return kanji.isNotEmpty ? kanji : '';
    }
  }

  Future<void> _confirmExit(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quit Quiz?'),
        content: const Text('Your current progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Quit'),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      context.pop();
    }
  }

  Widget _buildWritingPad(QuizQuestion currentQuestion) {
    return Column(
      children: [
        Expanded(
          child: IgnorePointer(
            ignoring: _isAnswerRevealed,
            child: KanjiDrawingPad(
              key: ValueKey(
                currentQuestion.kanjiCharacter ?? currentQuestion.correctAnswer,
              ),
              character:
                  currentQuestion.kanjiCharacter ??
                  currentQuestion.correctAnswer,
              showBackground: _showHint || _isAnswerRevealed,
              topAction: TextButton.icon(
                onPressed: _isAnswerRevealed
                    ? null
                    : () => setState(() => _showHint = !_showHint),
                icon: Icon(
                  _showHint ? Icons.visibility_off : Icons.visibility,
                  size: 18,
                ),
                label: Text(_showHint ? 'Hide Hint' : 'Show Hint'),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
              ),
              onInkChanged: (ink) => setState(() => _currentInk = ink),
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (!_isAnswerRevealed)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: SizedBox(
              width: double.infinity,
              height: 44,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _isAnswerRevealed = true;
                    _showHint = true;
                    _selectedAnswerIndex = 1; // 1 means incorrect
                  });
                  ref.read(quizSessionProvider.notifier).answerCurrent(-1);
                },
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant,
                  visualDensity: VisualDensity.compact,
                ),
                child: const Text('I don\'t know / Skip'),
              ),
            ),
          ),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: _isAnswerRevealed
              ? FilledButton.icon(
                  onPressed: _onNextPressed,
                  icon: Icon(
                    _selectedAnswerIndex == 0
                        ? Icons.check_circle_rounded
                        : Icons.close_rounded,
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: _selectedAnswerIndex == 0
                        ? AppColors.correct
                        : AppColors.incorrect,
                  ),
                  label: Text(
                    _selectedAnswerIndex == 0
                        ? 'Correct! → Next'
                        : 'Wrong (${currentQuestion.correctAnswer}) → Next',
                  ),
                )
              : FilledButton.icon(
                  onPressed:
                      _isChecking ||
                          _currentInk == null ||
                          _currentInk!.strokes.isEmpty
                      ? null
                      : () => _handleCheckDrawing(currentQuestion),
                  icon: _isChecking
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_circle_rounded),
                  label: Text(_isChecking ? 'Checking...' : 'Check Answer'),
                ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Future<void> _handleCheckDrawing(QuizQuestion currentQuestion) async {
    if (_currentInk == null || _currentInk!.strokes.isEmpty) return;

    setState(() {
      _isChecking = true;
    });

    final mlkitService = ref.read(mlkitDigitalInkServiceProvider);
    final candidates = await mlkitService.recognizeKanji(_currentInk!);

    setState(() {
      _isChecking = false;
      _isAnswerRevealed = true;
      _showHint = true;
    });

    bool isCorrect = false;
    final target =
        currentQuestion.kanjiCharacter ?? currentQuestion.correctAnswer;

    // Check if any of the candidates match the target character
    if (candidates.isNotEmpty) {
      final allCandidates = candidates.map((c) => c.text).toList();
      if (allCandidates.contains(target)) {
        isCorrect = true;
      }
    }

    // Set 0 for correct, 1 for wrong (dummy index for the notifier)
    setState(() {
      _selectedAnswerIndex = isCorrect ? 0 : 1;
    });

    // We must manually add options to the question so the notifier knows about the correct index.
    // However, writing question options are already set to [k.character].
    // Let's modify the notifier's logic by just passing 0 or 1.
    // Wait, the notifier uses `answerCurrent` which expects `selectedIndex` against `correctIndex`.
    // For writing, `options` is `[targetKanji]`. So `correctIndex` is 0.
    // If it's correct, we pass 0. If wrong, we pass 1 (which is out of bounds, but it evaluates to wrong!)

    ref.read(quizSessionProvider.notifier).answerCurrent(isCorrect ? 0 : 1);
  }
}
