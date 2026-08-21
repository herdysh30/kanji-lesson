import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kanji_lesson/core/theme/app_colors.dart';
import 'package:kanji_lesson/core/theme/app_theme.dart';
import 'package:kanji_lesson/core/utils/date_utils.dart';
import 'package:kanji_lesson/features/progress/presentation/providers/progress_providers.dart';

class WeakKanjiScreen extends ConsumerWidget {
  const WeakKanjiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weakListAsync = ref.watch(weakKanjiListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weak Items'),
      ),
      body: weakListAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.celebration_rounded,
                      size: 64,
                      color: AppColors.correct.withValues(alpha: 0.6),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Weak Items!',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'All your kanji and vocab have an accuracy of 60% or higher. Keep it up! 🎉',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(weakKanjiListProvider);
            },
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: items.length + 1, // +1 for header
              separatorBuilder: (_, __) => const SizedBox(height: 0),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      color: AppColors.warningLight,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline_rounded,
                                color: AppColors.warning, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '${items.length} items with accuracy below 60%. Practice these more!',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColors.warning,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                final item = items[index - 1];
                return _WeakItemTile(item: item);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Unable to load weak items')),
      ),
    );
  }
}

class _WeakItemTile extends StatelessWidget {
  const _WeakItemTile({required this.item});
  final WeakItem item;

  @override
  Widget build(BuildContext context) {
    final accuracyColor = item.accuracy < 0.3
        ? AppColors.incorrect
        : item.accuracy < 0.5
            ? AppColors.warning
            : AppColors.warning;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (item.isVocab) {
            context.push('/learn/vocab/${Uri.encodeComponent(item.character)}');
          } else {
            context.push('/learn/kanji/${item.character}');
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Character
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    item.character,
                    style: AppTheme.kanjiLarge(context).copyWith(
                      fontSize: item.character.length > 2 ? 20 : 28,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (item.isVocab)
                          Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'VOCAB',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryLight,
                              ),
                            ),
                          ),
                        if (item.meaning != null)
                          Expanded(
                            child: Text(
                              item.meaning!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.check_circle_outline,
                            size: 14, color: AppColors.correct),
                        const SizedBox(width: 4),
                        Text(
                          '${item.correctCount}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.correct,
                              ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.cancel_outlined,
                            size: 14, color: AppColors.incorrect),
                        const SizedBox(width: 4),
                        Text(
                          '${item.wrongCount}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.incorrect,
                              ),
                        ),
                        const SizedBox(width: 12),
                        if (item.lastReviewedAt != null)
                          Text(
                            AppDateUtils.relativeTime(item.lastReviewedAt!),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Accuracy Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: accuracyColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.accuracyPercent,
                  style: TextStyle(
                    color: accuracyColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
