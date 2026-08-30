import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kanji_lesson/core/database/app_database.dart';
import 'package:kanji_lesson/core/theme/app_colors.dart';
import 'package:kanji_lesson/core/theme/app_theme.dart';
import 'package:kanji_lesson/features/kanji/presentation/providers/kanji_providers.dart';

// ─── Bookmarked Items Provider ──────────────────────────────────

final bookmarkedItemsProvider = FutureProvider<List<UserKanjiProgressEntry>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.getBookmarkedItems();
});

// ─── Bookmark Screen ────────────────────────────────────────────

class BookmarkScreen extends ConsumerWidget {
  const BookmarkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(bookmarkedItemsProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Bookmarks')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(bookmarkedItemsProvider),
        child: itemsAsync.when(
          data: (items) {
            if (items.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 120),
                  Icon(
                    Icons.bookmark_border_rounded,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'No bookmarks yet.\nTap the bookmark icon on any kanji to save it here.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            }
            return ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = items[index];
                return FutureBuilder(
                  future: ref.read(databaseProvider).getKanjiByCharacter(item.kanjiCharacter),
                  builder: (context, snapshot) {
                    final kanji = snapshot.data;
                    final meanings = kanji?.meanings
                        .replaceAll(RegExp(r'[\[\]"]'), '')
                        .split(',')
                        .where((s) => s.trim().isNotEmpty)
                        .toList();
                    return ListTile(
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          item.kanjiCharacter,
                          style: AppTheme.japaneseText(context, fontSize: 24),
                        ),
                      ),
                      title: Text(
                        item.kanjiCharacter,
                        style: AppTheme.japaneseText(context, fontSize: 20),
                      ),
                      subtitle: Text(
                        meanings?.take(2).join(', ') ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.bookmark_rounded, color: AppColors.warning),
                        onPressed: () async {
                          final db = ref.read(databaseProvider);
                          await db.toggleBookmark(item.kanjiCharacter, false);
                          ref.invalidate(bookmarkedItemsProvider);
                        },
                      ),
                      onTap: () {
                        final level = kanji?.jlptLevel ?? 5;
                        context.push('/learn/$level/${item.kanjiCharacter}');
                      },
                    );
                  },
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(e.toString())),
        ),
      ),
    );
  }
}
