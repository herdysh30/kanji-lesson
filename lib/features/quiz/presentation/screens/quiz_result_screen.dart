import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kanji_lesson/core/theme/app_colors.dart';
import 'package:kanji_lesson/features/quiz/domain/services/quiz_generator.dart';
import 'package:kanji_lesson/features/quiz/presentation/providers/quiz_providers.dart';

class QuizResultScreen extends ConsumerWidget {
  const QuizResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quizSessionProvider);
    final setup = ref.watch(quizSetupProvider);

    // Calculate score
    final result = QuizSessionResult(
      questions: state.resolvedQuestions,
      answers: state.answers,
      jlptLevel: setup.selectedJlptLevel,
      selectedQuizTypes: setup.selectedQuizTypes,
    );

    final isPerfect = result.incorrectCount == 0;
    final isGood = result.accuracy >= 0.7;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Result'),
        automaticallyImplyLeading: false, // Prevent going back to quiz
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            // Header Image/Icon
            Icon(
              isPerfect ? Icons.workspace_premium_rounded : 
              (isGood ? Icons.star_rounded : Icons.school_rounded),
              size: 100,
              color: isPerfect ? Colors.amber.shade700 : (isGood ? AppColors.primary : Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Text(
              isPerfect ? 'Perfect!' : (isGood ? 'Good Job!' : 'Keep Practicing!'),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isPerfect ? Colors.amber.shade800 : (isGood ? AppColors.primary : null),
              ),
            ),
            const SizedBox(height: 32),
            
            // Score Board
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ScoreItem(
                      label: 'Score',
                      value: result.accuracyPercent,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 24),
                    _ScoreItem(
                      label: 'Correct',
                      value: '${result.correctCount}',
                      color: AppColors.correct,
                    ),
                    const SizedBox(width: 24),
                    _ScoreItem(
                      label: 'Wrong',
                      value: '${result.incorrectCount}',
                      color: AppColors.incorrect,
                    ),
                    if (result.skippedCount > 0) ...[
                      const SizedBox(width: 24),
                      _ScoreItem(
                        label: 'Skipped',
                        value: '${result.skippedCount}',
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 48),

            // Answers review section
            if (result.questions.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Review your answers:',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: result.questions.length,
                itemBuilder: (context, index) {
                  final q = result.questions[index];
                  // Find the answer they picked
                  final selectedAnswerIndex = state.answers[index];
                  final selectedAnswer = (selectedAnswerIndex >= 0 && selectedAnswerIndex < q.options.length)
                      ? q.options[selectedAnswerIndex].text
                      : (q.type == QuizType.writing ? '(Incorrect Drawing)' : 'Skipped');

                  final correctOption = (q.correctIndex >= 0 && q.correctIndex < q.options.length) 
                        ? q.options[q.correctIndex] 
                        : null;
                  
                  String topText = q.prompt;
                  String bottomText = '';
                  String rightText = '';

                  if (q.type == QuizType.meaning) {
                    bottomText = correctOption?.explanation ?? '';
                    rightText = q.correctAnswer;
                  } else if (q.type == QuizType.reading) {
                    bottomText = q.correctAnswer;
                    rightText = correctOption?.explanation ?? '';
                  } else {
                    bottomText = '';
                    rightText = q.correctAnswer;
                  }

                  final isCorrect = q.correctIndex == selectedAnswerIndex;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isCorrect ? AppColors.correct.withValues(alpha: 0.3) : AppColors.incorrect.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      topText,
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: q.sentenceObj != null ? 18 : 24,
                                      ),
                                    ),
                                    if (bottomText.isNotEmpty)
                                      Text(
                                        bottomText,
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  rightText,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.correct,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          Row(
                            children: [
                              Icon(
                                isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                color: isCorrect ? AppColors.correct : AppColors.incorrect,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'You answered: $selectedAnswer',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: isCorrect ? AppColors.correct : AppColors.incorrect,
                                    fontWeight: isCorrect ? FontWeight.w500 : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
            ],

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Just invalidate the session provider, it will load new tasks and reset
                      ref.invalidate(quizInitDataProvider);
                      ref.invalidate(quizSessionProvider);
                      context.pushReplacement('/quiz/session');
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Retry', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      context.pop(); // Go back to Home
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Done', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreItem extends StatelessWidget {
  const _ScoreItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
