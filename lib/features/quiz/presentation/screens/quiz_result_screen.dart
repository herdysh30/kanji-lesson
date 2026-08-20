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
      questions: state.questions,
      answers: state.answers,
      jlptLevel: setup.selectedJlptLevel,
      quizType: setup.quizType,
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
              color: isPerfect ? Colors.amber : (isGood ? AppColors.primary : Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(
              isPerfect ? 'Perfect!' : (isGood ? 'Good Job!' : 'Keep Practicing!'),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isPerfect ? Colors.amber[700] : (isGood ? AppColors.primary : null),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ScoreItem(
                    label: 'Score',
                    value: result.accuracyPercent,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  _ScoreItem(
                    label: 'Correct',
                    value: '${result.correctCount}',
                    color: AppColors.correct,
                  ),
                  _ScoreItem(
                    label: 'Wrong',
                    value: '${result.incorrectCount}',
                    color: AppColors.incorrect,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 48),

            // Mistakes section
            if (result.incorrectQuestions.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Mistakes to review:',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: result.incorrectQuestions.length,
                itemBuilder: (context, index) {
                  final q = result.incorrectQuestions[index];
                  // Find the answer they picked
                  final questionIndex = state.questions.indexOf(q);
                  final selectedAnswerIndex = state.answers[questionIndex];
                  final selectedAnswer = (selectedAnswerIndex >= 0 && selectedAnswerIndex < q.options.length)
                      ? q.options[selectedAnswerIndex].text
                      : (q.type == QuizType.writing ? '(Incorrect Drawing)' : 'Unknown');

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                q.prompt,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  q.correctAnswer,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.correct,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          Text(
                            'You answered: $selectedAnswer',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.incorrect,
                            ),
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
                      // Just invalidate the session provider, it will load new questions and reset
                      ref.invalidate(quizQuestionsProvider);
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
