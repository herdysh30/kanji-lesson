import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kanji_lesson/core/theme/app_colors.dart';
import 'package:kanji_lesson/core/theme/app_theme.dart';
import 'package:kanji_lesson/core/widgets/error_widget.dart';
import 'package:kanji_lesson/core/widgets/loading_widget.dart';
import 'package:kanji_lesson/core/widgets/empty_state_widget.dart';
import 'package:kanji_lesson/features/kanji/presentation/providers/kanji_providers.dart';
import 'package:kanji_lesson/features/settings/presentation/providers/settings_providers.dart';

class KanjiListScreen extends ConsumerWidget {
  const KanjiListScreen({super.key, required this.jlptLevel});

  final int jlptLevel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gridItems = ref.watch(filteredGridListProvider(jlptLevel));
    final searchQuery = ref.watch(kanjiSearchQueryProvider);
    final filter = ref.watch(kanjiFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('N$jlptLevel Kanji'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/learn/$jlptLevel/practice');
        },
        icon: const Icon(Icons.draw_rounded),
        label: const Text('Practice Random'),
      ),
      body: Column(
        children: [
          // ─── Search Bar ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search kanji, reading, or meaning...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () =>
                            ref.read(kanjiSearchQueryProvider.notifier).state = '',
                      )
                    : null,
              ),
              onChanged: (value) {
                ref.read(kanjiSearchQueryProvider.notifier).state = value;
              },
            ),
          ),

          // ─── Filter Tabs ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: KanjiFilter.values.map((f) {
                  final isSelected = filter == f;
                  final label = switch (f) {
                    KanjiFilter.all => 'All',
                    KanjiFilter.kanji => 'Kanji',
                    KanjiFilter.vocab => 'Vocab',
                    KanjiFilter.learning => 'Learning',
                    KanjiFilter.mastered => 'Mastered',
                  };
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(label),
                      onSelected: (_) =>
                          ref.read(kanjiFilterProvider.notifier).state = f,
                      selectedColor: AppColors.primary.withValues(alpha: 0.15),
                      checkmarkColor: AppColors.primary,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // ─── Content Area ────────────────────────────────
          Expanded(
            child: gridItems.when(
              data: (items) {
                if (items.isEmpty) {
                  return const EmptyStateWidget(
                    message: 'No items found',
                    icon: Icons.search_off_rounded,
                  );
                }

                return RawScrollbar(
                  interactive: true,
                  thickness: 6,
                  radius: const Radius.circular(8),
                  crossAxisMargin: 4,
                  thumbColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                  child: GridView.builder(
                    primary: true,
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                    final item = items[index];
                    if (item.isVocab) {
                      return _VocabGridTile(
                        word: item.text,
                        meaning: item.meaning,
                        reading: item.reading,
                        jlptLevel: jlptLevel,
                      );
                    } else {
                      return _KanjiGridTile(
                        character: item.text,
                        jlptLevel: jlptLevel,
                      );
                    }
                  },
                ),
              );
            },
              loading: () => const AppLoadingWidget(message: 'Loading...'),
              error: (error, _) => AppErrorWidget(
                message: 'Unable to load data.\nPlease check your internet connection.',
                onRetry: () => ref.invalidate(filteredGridListProvider(jlptLevel)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _KanjiGridTile extends ConsumerWidget {
  const _KanjiGridTile({
    required this.character,
    required this.jlptLevel,
  });

  final String character;
  final int jlptLevel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(kanjiProgressProvider(character));

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go('/learn/$jlptLevel/$character'),
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(
                  character,
                  style: AppTheme.kanjiSmall(context).copyWith(fontSize: 40),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: ref.watch(kanjiDetailProvider(character)).when(
                data: (kanji) {
                  final isId = ref.read(localeProvider).languageCode == 'id';
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (kanji.primaryReading.isNotEmpty)
                          Text(
                            kanji.primaryReading,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        Text(
                          kanji.primaryMeaning(isId),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
            // Progress dot indicator
            progress.when(
              data: (p) {
                if (p == null) return const SizedBox.shrink();
                final color = switch (p.status) {
                  'mastered' => AppColors.correct,
                  'reviewing' => AppColors.primary,
                  'learning' => AppColors.warning,
                  _ => Colors.transparent,
                };
                if (color == Colors.transparent) {
                  return const SizedBox.shrink();
                }
                return Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                    ),
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
class _VocabGridTile extends ConsumerWidget {
  const _VocabGridTile({
    required this.word,
    this.meaning,
    this.reading,
    required this.jlptLevel,
  });

  final String word;
  final String? meaning;
  final String? reading;
  final int jlptLevel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(kanjiProgressProvider(word));

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go('/learn/$jlptLevel/vocab/${Uri.encodeComponent(word)}'),
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    word,
                    style: AppTheme.kanjiSmall(context).copyWith(fontSize: 32),
                  ),
                ),
              ),
            ),
            if (reading != null || meaning != null)
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (reading != null && reading!.isNotEmpty)
                        Text(
                          reading!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (meaning != null && meaning!.isNotEmpty)
                        Text(
                          meaning!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ),
            // Progress dot indicator
            progress.when(
              data: (p) {
                if (p == null) return const SizedBox.shrink();
                final color = switch (p.status) {
                  'mastered' => AppColors.correct,
                  'reviewing' => AppColors.primary,
                  'learning' => AppColors.warning,
                  _ => Colors.transparent,
                };
                if (color == Colors.transparent) {
                  return const SizedBox.shrink();
                }
                return Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                    ),
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
