import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kanji_lesson/core/constants/app_constants.dart';
import 'package:kanji_lesson/features/quiz/domain/services/quiz_generator.dart';
import 'package:kanji_lesson/features/quiz/presentation/providers/quiz_providers.dart';
import 'package:kanji_lesson/core/services/mlkit_digital_ink_service.dart';

class QuizSetupScreen extends ConsumerWidget {
  const QuizSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setup = ref.watch(quizSetupProvider);
    final notifier = ref.read(quizSetupProvider.notifier);
    final modelStatus = ref.watch(digitalInkModelStatusProvider);

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
                ChoiceChip(
                  label: const Text('Writing (Draw Kanji)'),
                  selected: setup.quizType == QuizType.writing,
                  onSelected: (val) {
                    if (val) notifier.setQuizType(QuizType.writing);
                  },
                ),
              ],
            ),
            
            // ML Kit Model Download Indicator
            if (setup.quizType == QuizType.writing)
              Consumer(
                builder: (context, ref, _) {
                  final statusAsync = ref.watch(digitalInkModelStatusProvider);
                  return statusAsync.when(
                    data: (isDownloaded) {
                      if (isDownloaded) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            '✓ Japanese Handwriting Model Ready',
                            style: TextStyle(color: Colors.green[700], fontSize: 12),
                          ),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final service = ref.read(mlkitDigitalInkServiceProvider);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Downloading model... (~20MB)')),
                            );
                            final success = await service.downloadModel();
                            ref.invalidate(digitalInkModelStatusProvider);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(success ? 'Download complete!' : 'Download failed.')),
                              );
                            }
                          },
                          icon: const Icon(Icons.download_rounded, size: 18),
                          label: const Text('Download Japanese Handwriting Model'),
                        ),
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: CircularProgressIndicator(),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                  );
                },
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
                onPressed: () async {
                  if (setup.quizType == QuizType.writing) {
                    final isDownloaded = modelStatus.valueOrNull ?? false;
                    if (!isDownloaded) {
                      // Prompt user
                      final shouldDownload = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Model Required'),
                          content: const Text('To use the Writing Quiz, you need to download the Japanese Handwriting AI Model (~20MB). Do you want to download it now?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Download'),
                            ),
                          ],
                        ),
                      );

                      if (shouldDownload == true) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Downloading model... (~20MB)')),
                        );
                        final success = await ref.read(mlkitDigitalInkServiceProvider).downloadModel();
                        ref.invalidate(digitalInkModelStatusProvider);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(success ? 'Download complete! You can now start the quiz.' : 'Download failed.')),
                          );
                        }
                      }
                      return; // Don't start quiz yet
                    }
                  }
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
