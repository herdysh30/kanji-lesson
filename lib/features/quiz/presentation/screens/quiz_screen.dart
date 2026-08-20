import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kanji_lesson/core/theme/app_colors.dart';
import 'package:kanji_lesson/core/theme/app_theme.dart';
import 'package:kanji_lesson/features/quiz/domain/services/quiz_generator.dart';
import 'package:kanji_lesson/features/quiz/presentation/providers/quiz_providers.dart';
import 'package:kanji_lesson/features/kanji/presentation/widgets/kanji_drawing_pad.dart';
import 'package:kanji_lesson/core/services/mlkit_digital_ink_service.dart';
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart' as mlkit;

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

    // Wait a bit to show correct/incorrect state, then proceed
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      
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
        notifier.nextQuestion();
        
        // Check again if it just finished (if it was the last question)
        if (ref.read(quizSessionProvider).isFinished) {
           context.pushReplacement('/quiz/result');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(quizQuestionsProvider);
    final sessionState = ref.watch(quizSessionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Session'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => _confirmExit(context),
        ),
      ),
      body: questionsAsync.when(
        data: (questions) {
          if (questions.isEmpty) {
            return const Center(child: Text('Not enough kanji to generate quiz.'));
          }

          // Initialize session with loaded questions
          Future.microtask(() {
            ref.read(quizSessionProvider.notifier).initialize(questions);
          });

          final currentQuestion = sessionState.currentQuestion;
          if (currentQuestion == null) return const SizedBox.shrink();

          final progress = sessionState.currentIndex / sessionState.questions.length;

          return Column(
            children: [
              // Progress Bar
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Question ${sessionState.currentIndex + 1} of ${sessionState.questions.length}',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              
              // Prompt Area
              Expanded(
                flex: 4,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      currentQuestion.prompt,
                      style: currentQuestion.type == QuizType.meaning
                          ? AppTheme.kanjiLarge(context).copyWith(fontSize: 120)
                          : Theme.of(context).textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),

              // Question Instruction
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  _getInstructionText(currentQuestion.type),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),

              // Options or Drawing Pad
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: currentQuestion.type == QuizType.writing
                      ? _buildWritingPad(currentQuestion)
                      : Column(
                          children: List.generate(currentQuestion.options.length, (index) {
                            final isSelected = _selectedAnswerIndex == index;
                            final isCorrectOption = index == currentQuestion.correctIndex;
                            
                            Color buttonColor = Theme.of(context).colorScheme.surfaceContainer;
                            Color textColor = Theme.of(context).colorScheme.onSurface;
                            
                            if (_isAnswerRevealed) {
                              if (isCorrectOption) {
                                buttonColor = AppColors.correct;
                                textColor = Colors.white;
                              } else if (isSelected && !isCorrectOption) {
                                buttonColor = AppColors.incorrect;
                                textColor = Colors.white;
                              } else {
                                buttonColor = Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: 0.5);
                                textColor = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5);
                              }
                            }
      
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: SizedBox(
                                width: double.infinity,
                                height: 64,
                                child: FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: buttonColor,
                                    foregroundColor: textColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  onPressed: () => _handleOptionSelected(index, currentQuestion),
                                  child: Text(
                                    currentQuestion.options[index],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: _isAnswerRevealed && (isCorrectOption || isSelected) ? FontWeight.bold : FontWeight.normal,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            );
                          }),
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
    );
  }

  String _getInstructionText(QuizType type) {
    switch (type) {
      case QuizType.meaning:
        return 'What does this Kanji mean?';
      case QuizType.reading:
        return 'How do you read this Kanji?';
      case QuizType.vocabulary:
        return 'What is the reading of this word?';
      case QuizType.kanjiFromReading:
        return 'Pick the correct answer';
      case QuizType.writing:
        return 'Draw the Kanji';
      default:
        return 'Choose the correct answer';
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
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              onPressed: _isAnswerRevealed ? null : () => setState(() => _showHint = !_showHint),
              icon: Icon(_showHint ? Icons.visibility_off : Icons.visibility),
              label: Text(_showHint ? 'Hide Hint' : 'Show Hint'),
            ),
          ],
        ),
        Expanded(
          child: IgnorePointer(
            ignoring: _isAnswerRevealed,
            child: KanjiDrawingPad(
              character: currentQuestion.kanjiCharacter ?? currentQuestion.correctAnswer,
              showBackground: _showHint || _isAnswerRevealed,
              onInkChanged: (ink) => setState(() => _currentInk = ink),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: _isAnswerRevealed
              ? FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: _selectedAnswerIndex == 0 ? AppColors.correct : AppColors.incorrect),
                  onPressed: () {},
                  child: Text(_selectedAnswerIndex == 0 ? 'Correct!' : 'Incorrect. The answer is ${currentQuestion.correctAnswer}'),
                )
              : FilledButton.icon(
                  onPressed: _isChecking || _currentInk == null || _currentInk!.strokes.isEmpty
                      ? null
                      : () => _handleCheckDrawing(currentQuestion),
                  icon: _isChecking
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.check_circle_rounded),
                  label: Text(_isChecking ? 'Checking...' : 'Check Answer'),
                ),
        ),
        const SizedBox(height: 16),
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
    final target = currentQuestion.kanjiCharacter ?? currentQuestion.correctAnswer;
    
    // Check if any of the top candidates match the target character exactly
    if (candidates.isNotEmpty) {
      // Look through top 5 candidates to be more generous
      final topCandidates = candidates.take(5).map((c) => c.text).toList();
      if (topCandidates.contains(target)) {
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

    // Wait and proceed
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      
      final sessionState = ref.read(quizSessionProvider);
      if (sessionState.isFinished) {
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
    });
  }
}
