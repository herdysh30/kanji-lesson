import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kanji_lesson/core/constants/app_constants.dart';
import 'package:kanji_lesson/features/quiz/domain/services/quiz_generator.dart';
import 'package:kanji_lesson/features/quiz/presentation/providers/quiz_providers.dart';

class QuizSetupScreen extends ConsumerWidget {
  const QuizSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setup = ref.watch(quizSetupProvider);
    final notifier = ref.read(quizSetupProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Setup'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // JLPT Level Selection
            Text(
              'Select Source',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose where the Kanji should be picked from:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('My Learned Kanji'),
                  selected: setup.selectedJlptLevel == null,
                  onSelected: (val) {
                    if (val) notifier.setJlptLevel(null);
                  },
                ),
                ...AppConstants.jlptLevels.map((level) {
                  return ChoiceChip(
                    label: Text('JLPT N$level'),
                    selected: setup.selectedJlptLevel == level,
                    onSelected: (val) {
                      if (val) notifier.setJlptLevel(level);
                    },
                  );
                }),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Quiz Type Selection
            Text(
              'Quiz Type',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Meaning'),
                  selected: setup.quizType == QuizType.meaning,
                  onSelected: (val) {
                    if (val) notifier.setQuizType(QuizType.meaning);
                  },
                ),
                ChoiceChip(
                  label: const Text('Reading'),
                  selected: setup.quizType == QuizType.reading,
                  onSelected: (val) {
                    if (val) notifier.setQuizType(QuizType.reading);
                  },
                ),
                ChoiceChip(
                  label: const Text('Mixed (Meaning & Reading)'),
                  selected: setup.quizType == QuizType.kanjiFromReading, // Using kanjiFromReading as a placeholder for mixed
                  onSelected: (val) {
                    if (val) notifier.setQuizType(QuizType.kanjiFromReading);
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Amount Selection
            Text(
              'Number of Questions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [10, 20, 30].map((count) {
                return ChoiceChip(
                  label: Text('$count Questions'),
                  selected: setup.questionCount == count,
                  onSelected: (val) {
                    if (val) notifier.setQuestionCount(count);
                  },
                );
              }).toList(),
            ),
            
            const SizedBox(height: 48),
            
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: () {
                  context.push('/quiz/session');
                },
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text(
                  'Start Quiz', 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
