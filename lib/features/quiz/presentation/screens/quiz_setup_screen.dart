import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kanji_lesson/core/constants/app_constants.dart';
import 'package:kanji_lesson/core/database/app_database.dart';
import 'package:kanji_lesson/core/theme/app_colors.dart';
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
    final maxItemsAsync = ref.watch(maxQuizItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Setup'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // JLPT Level Selection
            Text(
              'Select Source',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('My Learned'),
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
            
            const SizedBox(height: 18),

            // Item Type Selection
            Text(
              'Item Type',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Mixed (Kanji & Vocab)'),
                  selected: setup.itemType == ReviewItemType.mixed,
                  onSelected: (val) {
                    if (val) notifier.setItemType(ReviewItemType.mixed);
                  },
                ),
                ChoiceChip(
                  label: const Text('Kanji Only'),
                  selected: setup.itemType == ReviewItemType.kanji,
                  onSelected: (val) {
                    if (val) notifier.setItemType(ReviewItemType.kanji);
                  },
                ),
                ChoiceChip(
                  label: const Text('Vocabulary Only'),
                  selected: setup.itemType == ReviewItemType.vocab,
                  onSelected: (val) {
                    if (val) notifier.setItemType(ReviewItemType.vocab);
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 18),
            
            // Quiz Type Selection
            Text(
              'Quiz Type',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: const Text('Meaning'),
                  selected: setup.selectedQuizTypes.contains(QuizType.meaning),
                  onSelected: (_) => notifier.toggleQuizType(QuizType.meaning),
                ),
                FilterChip(
                  label: const Text('Reading'),
                  selected: setup.selectedQuizTypes.contains(QuizType.reading),
                  onSelected: (_) => notifier.toggleQuizType(QuizType.reading),
                ),
                FilterChip(
                  label: const Text('Writing'),
                  selected: setup.selectedQuizTypes.contains(QuizType.writing),
                  onSelected: (_) => notifier.toggleQuizType(QuizType.writing),
                ),
              ],
            ),
            
            // ML Kit Model Download Indicator
            if (setup.selectedQuizTypes.contains(QuizType.writing))
              Consumer(
                builder: (context, ref, _) {
                  final statusAsync = ref.watch(digitalInkModelStatusProvider);
                  return statusAsync.when(
                    data: (isDownloaded) {
                      if (isDownloaded) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 6.0),
                          child: Text(
                            '✓ Japanese Handwriting Model Ready',
                            style: TextStyle(color: AppColors.correct, fontSize: 12),
                          ),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 6.0),
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
                          icon: const Icon(Icons.download_rounded, size: 16),
                          label: const Text('Download Handwriting Model'),
                        ),
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.only(top: 6.0),
                      child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                  );
                },
              ),
            
            const SizedBox(height: 18),
            
            // Amount Selection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Number of Questions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                maxItemsAsync.when(
                  data: (max) => Text(
                    'Max: $max items',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...[10, 20, 30].map((count) {
                  return ChoiceChip(
                    label: Text('$count Questions'),
                    selected: setup.questionCount == count && !setup.isCustomCount,
                    onSelected: (val) {
                      if (val) notifier.setQuestionCount(count);
                    },
                  );
                }),
                ChoiceChip(
                  label: const Text('Custom'),
                  selected: setup.isCustomCount,
                  onSelected: (val) {
                    if (val) {
                      notifier.setQuestionCount(setup.questionCount, isCustom: true);
                    }
                  },
                ),
              ],
            ),
            if (setup.isCustomCount)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Builder(
                  builder: (context) {
                    final maxVal = (maxItemsAsync.valueOrNull ?? 100).toDouble().clamp(1.0, 1000.0);
                    final currentValue = setup.questionCount.toDouble().clamp(1.0, maxVal);
                    return Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: currentValue,
                            min: 1.0,
                            max: maxVal,
                            divisions: maxVal.toInt(),
                            label: currentValue.toInt().toString(),
                            onChanged: (val) {
                              notifier.setQuestionCount(val.round(), isCustom: true);
                            },
                          ),
                        ),
                        SizedBox(
                          width: 48,
                          child: Text(
                            '${currentValue.toInt()}',
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    );
                  }
                ),
              ),
            
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: () async {
                  if (setup.selectedQuizTypes.contains(QuizType.writing)) {
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
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
