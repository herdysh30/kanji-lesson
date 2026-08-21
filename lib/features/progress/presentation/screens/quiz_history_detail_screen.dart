import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kanji_lesson/core/database/app_database.dart';
import 'package:kanji_lesson/core/theme/app_colors.dart';
import 'package:kanji_lesson/features/quiz/domain/models/quiz_attempt.dart';
import 'package:kanji_lesson/features/quiz/presentation/providers/quiz_providers.dart';

class QuizHistoryDetailScreen extends ConsumerWidget {
  const QuizHistoryDetailScreen({super.key, required this.entry});
  final QuizResultEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<QuizAttemptRecord> attempts = [];
    if (entry.questionsJson != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(entry.questionsJson!);
        attempts = jsonList.map((j) => QuizAttemptRecord.fromJson(j)).toList();
      } catch (e) {
        debugPrint('Error parsing questionsJson: $e');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Details'),
      ),
      body: attempts.isEmpty
          ? const Center(child: Text('No detailed history available for this quiz (Legacy).'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: attempts.length,
              itemBuilder: (context, index) {
                final attempt = attempts[index];
                final q = attempt.question;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Q${index + 1}: ${q.prompt}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        if (q.kanjiCharacter != null && q.prompt != q.kanjiCharacter)
                           Text('(${q.kanjiCharacter})', style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Text('Correct Answer: '),
                            Text(q.correctAnswer, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.correct)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Text('Your Answer: '),
                            Text(attempt.userAnswer.isEmpty ? 'Not Answered' : attempt.userAnswer, 
                               style: TextStyle(fontWeight: FontWeight.bold, color: attempt.isCorrect ? AppColors.correct : Theme.of(context).colorScheme.error)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: attempts.isEmpty ? null : Padding(
        padding: const EdgeInsets.all(16.0),
        child: FilledButton.icon(
          onPressed: () {
            ref.read(quizSessionProvider.notifier).startRetake(attempts.map((a) => a.question).toList());
            context.push('/quiz/session');
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Retake Exact Quiz'),
        ),
      ),
    );
  }
}
