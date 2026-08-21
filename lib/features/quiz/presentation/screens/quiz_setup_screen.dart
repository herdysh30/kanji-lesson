import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kanji_lesson/core/constants/app_constants.dart';

import 'package:kanji_lesson/core/theme/app_colors.dart';
import 'package:kanji_lesson/features/quiz/domain/services/quiz_generator.dart';
import 'package:kanji_lesson/features/quiz/presentation/providers/quiz_providers.dart';
import 'package:kanji_lesson/core/services/mlkit_digital_ink_service.dart';
import 'package:kanji_lesson/l10n/app_localizations.dart';

class QuizSetupScreen extends ConsumerWidget {
  const QuizSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setup = ref.watch(quizSetupProvider);
    final notifier = ref.read(quizSetupProvider.notifier);
    final modelStatus = ref.watch(digitalInkModelStatusProvider);
    final maxItemsAsync = ref.watch(maxQuizItemsProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.quizSetup, style: const TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 120.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Source Section
            _buildSection(
              context,
              title: l10n.selectSource,
              icon: Icons.source_rounded,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildChoiceChip(
                    context,
                    label: l10n.myLearned,
                    selected: setup.selectedJlptLevel == null,
                    onSelected: (val) {
                      if (val) notifier.setJlptLevel(null);
                    },
                  ),
                  ...AppConstants.jlptLevels.map((level) {
                    return _buildChoiceChip(
                      context,
                      label: 'JLPT N$level',
                      selected: setup.selectedJlptLevel == level,
                      onSelected: (val) {
                        if (val) notifier.setJlptLevel(level);
                      },
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Content Type Section
            _buildSection(
              context,
              title: l10n.itemType,
              subtitle: l10n.canSelectMultiple,
              icon: Icons.category_rounded,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildFilterChip(
                    context,
                    label: l10n.kanji,
                    selected: setup.selectedItemTypes.contains(QuizItemType.kanji),
                    onSelected: (val) {
                      final newTypes = Set<QuizItemType>.from(setup.selectedItemTypes);
                      if (val) {
                        newTypes.add(QuizItemType.kanji);
                      } else {
                        newTypes.remove(QuizItemType.kanji);
                      }
                      if (newTypes.isNotEmpty) {
                        notifier.setItemTypes(newTypes);
                      }
                    },
                  ),
                  _buildFilterChip(
                    context,
                    label: l10n.vocabulary,
                    selected: setup.selectedItemTypes.contains(QuizItemType.vocab),
                    onSelected: (val) {
                      final newTypes = Set<QuizItemType>.from(setup.selectedItemTypes);
                      if (val) {
                        newTypes.add(QuizItemType.vocab);
                      } else {
                        newTypes.remove(QuizItemType.vocab);
                      }
                      if (newTypes.isNotEmpty) {
                        notifier.setItemTypes(newTypes);
                      }
                    },
                  ),
                  _buildFilterChip(
                    context,
                    label: l10n.sentence,
                    selected: setup.selectedItemTypes.contains(QuizItemType.sentence),
                    onSelected: (val) {
                      final newTypes = Set<QuizItemType>.from(setup.selectedItemTypes);
                      if (val) {
                        newTypes.add(QuizItemType.sentence);
                      } else {
                        newTypes.remove(QuizItemType.sentence);
                      }
                      if (newTypes.isNotEmpty) {
                        notifier.setItemTypes(newTypes);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Question Type Section
            _buildSection(
              context,
              title: l10n.questionType,
              subtitle: l10n.canSelectMultiple,
              icon: Icons.quiz_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildFilterChip(
                        context,
                        label: l10n.meaning,
                        selected: setup.selectedQuizTypes.contains(QuizType.meaning),
                        onSelected: (_) => notifier.toggleQuizType(QuizType.meaning),
                      ),
                      _buildFilterChip(
                        context,
                        label: l10n.reading,
                        selected: setup.selectedQuizTypes.contains(QuizType.reading),
                        onSelected: (_) => notifier.toggleQuizType(QuizType.reading),
                      ),
                      _buildFilterChip(
                        context,
                        label: l10n.writing,
                        selected: setup.selectedQuizTypes.contains(QuizType.writing),
                        onSelected: (_) => notifier.toggleQuizType(QuizType.writing),
                      ),
                    ],
                  ),
                  // ML Kit Model Download Indicator
                  if (setup.selectedQuizTypes.contains(QuizType.writing))
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Consumer(
                        builder: (context, ref, _) {
                          final statusAsync = ref.watch(digitalInkModelStatusProvider);
                          return statusAsync.when(
                            data: (isDownloaded) {
                              if (isDownloaded) {
                                return Row(
                                  children: [
                                    const Icon(Icons.check_circle_rounded, color: AppColors.correct, size: 16),
                                    const SizedBox(width: 8),
                                    Text(
                                      l10n.handwritingModelReady,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.correct),
                                    ),
                                  ],
                                );
                              }
                              return OutlinedButton.icon(
                                onPressed: () async {
                                  final service = ref.read(mlkitDigitalInkServiceProvider);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(l10n.downloadingModel)),
                                  );
                                  final success = await service.downloadModel();
                                  ref.invalidate(digitalInkModelStatusProvider);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(success ? l10n.downloadComplete : l10n.downloadFailed)),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.download_rounded, size: 16),
                                label: Text(l10n.downloadHandwritingModel),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  minimumSize: Size.zero,
                                ),
                              );
                            },
                            loading: () => const SizedBox(
                              width: 16, height: 16, 
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            error: (_, __) => const SizedBox.shrink(),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Amount Section
            _buildSection(
              context,
              title: l10n.numberOfQuestions,
              icon: Icons.format_list_numbered_rounded,
              trailing: maxItemsAsync.when(
                data: (max) => Text(
                  l10n.maxItems(max),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...[10, 20, 30].map((count) {
                        return _buildChoiceChip(
                          context,
                          label: l10n.questionsCount(count),
                          selected: setup.questionCount == count && !setup.isCustomCount,
                          onSelected: (val) {
                            if (val) notifier.setQuestionCount(count);
                          },
                        );
                      }),
                      _buildChoiceChip(
                        context,
                        label: l10n.custom,
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
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Builder(
                        builder: (context) {
                          final maxVal = (maxItemsAsync.valueOrNull ?? 100).toDouble().clamp(1.0, 1000.0);
                          final currentValue = setup.questionCount.toDouble().clamp(1.0, maxVal);
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Theme.of(context).dividerTheme.color ?? const Color(0xFFE5E5E5),
                                width: 0.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      activeTrackColor: Theme.of(context).colorScheme.primary,
                                      thumbColor: Theme.of(context).colorScheme.primary,
                                      overlayColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                                    ),
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
                                ),
                                Container(
                                  width: 40,
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${currentValue.toInt()}',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      ),
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            SizedBox(
              height: 56,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () async {
                  if (setup.selectedQuizTypes.contains(QuizType.writing)) {
                    final isDownloaded = modelStatus.valueOrNull ?? false;
                    if (!isDownloaded) {
                      // Prompt user
                      final shouldDownload = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          title: Text(l10n.modelRequired),
                          content: Text(l10n.modelRequiredContent),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text(l10n.cancel),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text(l10n.download),
                            ),
                          ],
                        ),
                      );

                      if (shouldDownload == true) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.downloadingModel)),
                        );
                        final success = await ref.read(mlkitDigitalInkServiceProvider).downloadModel();
                        ref.invalidate(digitalInkModelStatusProvider);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(success ? l10n.downloadComplete : l10n.downloadFailed)),
                          );
                        }
                      }
                      return; // Don't start quiz yet
                    }
                  }
                  context.push('/quiz/session');
                },
                icon: const Icon(Icons.play_arrow_rounded, size: 24),
                label: Text(
                  l10n.startQuiz, 
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, String? subtitle, required IconData icon, required Widget child, Widget? trailing}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerTheme.color ?? const Color(0xFFE5E5E5),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontSize: 11,
                            ),
                      ),
                  ],
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildChoiceChip(BuildContext context, {required String label, required bool selected, required ValueChanged<bool> onSelected}) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      labelStyle: TextStyle(
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        color: selected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      selectedColor: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onSelected: onSelected,
    );
  }

  Widget _buildFilterChip(BuildContext context, {required String label, required bool selected, required ValueChanged<bool> onSelected}) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      showCheckmark: true,
      checkmarkColor: Theme.of(context).colorScheme.onPrimary,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      labelStyle: TextStyle(
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        color: selected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      selectedColor: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onSelected: onSelected,
    );
  }
}
