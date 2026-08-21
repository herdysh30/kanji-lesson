import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';
import 'package:kanji_lesson/features/review/presentation/providers/review_providers.dart';
import 'package:kanji_lesson/core/widgets/error_widget.dart';
import 'package:kanji_lesson/core/widgets/loading_widget.dart';
import 'package:kanji_lesson/core/theme/app_colors.dart';
import 'package:kanji_lesson/features/kanji/presentation/providers/kanji_providers.dart';
import 'package:kanji_lesson/core/database/app_database.dart';
import 'package:kanji_lesson/l10n/app_localizations.dart';

class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final dueReviewsAsync = ref.watch(dueReviewsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reviewDashboard)),
      body: dueReviewsAsync.when(
        data: (dueReviews) {
          final count = dueReviews.length;
          
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: count > 0 
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : Theme.of(context).colorScheme.surfaceContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.replay_rounded,
                      size: 80,
                      color: count > 0 
                          ? AppColors.primary 
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    count > 0 ? l10n.reviewsDue(count) : l10n.noReviewsDue,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    count > 0 
                        ? l10n.timeToStrengthen 
                        : l10n.youreAllCaughtUp,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton.icon(
                      onPressed: count > 0 
                          ? () => context.push('/review/session') 
                          : null,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: Text(
                        l10n.startReview, 
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: () => _showLearnNewKanjiDialog(context, ref),
                      icon: const Icon(Icons.add_rounded),
                      label: Text(
                        l10n.learnNewItems, 
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => AppLoadingWidget(message: l10n.loadingReviews),
        error: (_, __) => AppErrorWidget(
          message: l10n.unableToLoadReviews,
          onRetry: () => ref.invalidate(dueReviewsProvider),
        ),
      ),
    );
  }
}

Future<void> _showLearnNewKanjiDialog(BuildContext rootContext, WidgetRef ref) async {
  int? selectedJlpt;
  int selectedAmount = 5;
  ReviewItemType selectedType = ReviewItemType.kanji;
  final l10n = AppLocalizations.of(rootContext)!;

  await showModalBottomSheet(
    context: rootContext,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (stateContext, setState) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.learnNewItems,
                    style: Theme.of(stateContext).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Item Type', style: Theme.of(stateContext).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: Text(l10n.kanjiOnly),
                        selected: selectedType == ReviewItemType.kanji,
                        onSelected: (val) {
                          if (val) setState(() => selectedType = ReviewItemType.kanji);
                        },
                      ),
                      ChoiceChip(
                        label: Text(l10n.vocabOnly),
                        selected: selectedType == ReviewItemType.vocab,
                        onSelected: (val) {
                          if (val) setState(() => selectedType = ReviewItemType.vocab);
                        },
                      ),
                      ChoiceChip(
                        label: Text(l10n.mixed),
                        selected: selectedType == ReviewItemType.mixed,
                        onSelected: (val) {
                          if (val) setState(() => selectedType = ReviewItemType.mixed);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(l10n.jlptLevel, style: Theme.of(stateContext).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [null, 5, 4, 3, 2, 1].map((level) {
                      final isSelected = selectedJlpt == level;
                      return ChoiceChip(
                        label: Text(level == null ? l10n.anyLevel : 'N$level'),
                        selected: isSelected,
                        onSelected: (val) {
                          if (val) setState(() => selectedJlpt = level);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Text(l10n.amount, style: Theme.of(stateContext).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [5, 10, 15, 20].map((amount) {
                      final isSelected = selectedAmount == amount;
                      return ChoiceChip(
                        label: Text(l10n.itemsCount(amount)),
                        selected: isSelected,
                        onSelected: (val) {
                          if (val) setState(() => selectedAmount = amount);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: () async {
                        Navigator.pop(sheetContext);
                        
                        showDialog(
                          context: rootContext, 
                          barrierDismissible: false,
                          builder: (_) => const Center(child: CircularProgressIndicator()),
                        );
                        
                        final db = ref.read(databaseProvider);
                        final newItems = await db.startLearningNewItems(selectedAmount, jlptLevel: selectedJlpt, type: selectedType);
                        
                        if (rootContext.mounted) {
                          Navigator.of(rootContext, rootNavigator: true).pop(); // dismiss loading
                          
                          if (newItems.isEmpty) {
                            ScaffoldMessenger.of(rootContext).showSnackBar(
                              SnackBar(content: Text(l10n.noNewItemsAvailable)),
                            );
                            return;
                          }
                          
                          ref.invalidate(dueReviewsProvider);
                          ref.invalidate(dueReviewCountProvider);
                          
                          // Wait for provider to load the new reviews
                          await ref.read(dueReviewsProvider.future);
                          
                          if (rootContext.mounted) {
                            rootContext.push('/review/session');
                          }
                        }
                      },
                      child: Text(l10n.startLearning, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        }
      );
    },
  );
}
