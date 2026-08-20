import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kanji_lesson/core/theme/app_colors.dart';
import 'package:kanji_lesson/core/theme/app_theme.dart';
import 'package:kanji_lesson/core/widgets/error_widget.dart';
import 'package:kanji_lesson/core/widgets/loading_widget.dart';
import 'package:kanji_lesson/core/widgets/empty_state_widget.dart';
import 'package:kanji_lesson/features/kanji/presentation/providers/kanji_providers.dart';

class KanjiListScreen extends ConsumerWidget {
  const KanjiListScreen({super.key, required this.jlptLevel});

  final int jlptLevel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kanjiList = ref.watch(kanjiListProvider(jlptLevel));
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
            child: Row(
              children: KanjiFilter.values.map((f) {
                final isSelected = filter == f;
                final label = switch (f) {
                  KanjiFilter.all => 'All',
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

          // ─── Kanji Grid ──────────────────────────────────
          Expanded(
            child: kanjiList.when(
              data: (characters) {
                if (characters.isEmpty) {
                  return const EmptyStateWidget(
                    message: 'No kanji found',
                    icon: Icons.search_off_rounded,
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: characters.length,
                  itemBuilder: (context, index) {
                    final character = characters[index];
                    return _KanjiGridTile(
                      character: character,
                      jlptLevel: jlptLevel,
                    );
                  },
                );
              },
              loading: () => const AppLoadingWidget(message: 'Loading kanji...'),
              error: (error, _) => AppErrorWidget(
                message: 'Unable to load kanji list.\nPlease check your internet connection.',
                onRetry: () => ref.invalidate(kanjiListProvider(jlptLevel)),
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
              child: Text(
                character,
                style: AppTheme.kanjiSmall(context),
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
