import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kanji_lesson/core/theme/app_colors.dart';
import 'package:kanji_lesson/core/theme/app_theme.dart';
import 'package:kanji_lesson/features/kanji/presentation/providers/kanji_providers.dart';
import 'package:kanji_lesson/l10n/app_localizations.dart';

// ─── Global Search Provider ─────────────────────────────────────

final globalSearchProvider = FutureProvider.family<List<SearchResultItem>, String>((ref, query) async {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return [];

  final db = ref.watch(databaseProvider);

  // Fetch all kanji
  final kanjiList = await db.getAllKanjiEntries();
  // Fetch all JLPT vocab
  final vocabList = await db.getAllJlptVocabEntries();

  final results = <SearchResultItem>[];

  for (final k in kanjiList) {
    final meanings = k.meanings.replaceAll(RegExp(r'[\[\]"]'), '').split(',');
    final meaningsId = k.meaningsId?.replaceAll(RegExp(r'[\[\]"]'), '').split(',') ?? [];
    final onyomi = k.onyomi.replaceAll(RegExp(r'[\[\]"]'), '').split(',');
    final kunyomi = k.kunyomi.replaceAll(RegExp(r'[\[\]"]'), '').split(',');
    final heisig = k.heisigKeyword ?? '';

    final match =
        k.character.contains(q) ||
        meanings.any((m) => m.trim().toLowerCase().contains(q)) ||
        meaningsId.any((m) => m.trim().toLowerCase().contains(q)) ||
        onyomi.any((m) => m.trim().toLowerCase().contains(q)) ||
        kunyomi.any((m) => m.trim().toLowerCase().contains(q)) ||
        heisig.toLowerCase().contains(q);

    if (match) {
      results.add(SearchResultItem(
        text: k.character,
        isVocab: false,
        jlptLevel: k.jlptLevel,
        reading: onyomi.isNotEmpty ? onyomi.first.trim() : '',
        meaning: meanings.isNotEmpty ? meanings.first.trim() : '',
      ));
    }
  }

  for (final v in vocabList) {
    final match =
        v.word.toLowerCase().contains(q) ||
        v.furigana.toLowerCase().contains(q) ||
        v.romaji.toLowerCase().contains(q) ||
        v.meaning.toLowerCase().contains(q) ||
        (v.meaningId?.toLowerCase().contains(q) ?? false);

    if (match) {
      results.add(SearchResultItem(
        text: v.word,
        isVocab: true,
        jlptLevel: v.level,
        reading: v.furigana,
        meaning: v.meaning,
      ));
    }
  }

  results.sort((a, b) {
    // Exact character match first
    if (a.text == q) return -1;
    if (b.text == q) return 1;
    final al = a.jlptLevel ?? 5;
    final bl = b.jlptLevel ?? 5;
    return al.compareTo(bl);
  });

  return results.take(50).toList();
});

class SearchResultItem {
  const SearchResultItem({
    required this.text,
    required this.isVocab,
    this.jlptLevel,
    this.reading = '',
    this.meaning = '',
  });

  final String text;
  final bool isVocab;
  final int? jlptLevel;
  final String reading;
  final String meaning;
}

// ─── Search Screen ──────────────────────────────────────────────

class GlobalSearchScreen extends ConsumerStatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  ConsumerState<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends ConsumerState<GlobalSearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final query = _controller.text;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: l10n.searchKanjiVocabulary,
            border: InputBorder.none,
            hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),
        actions: [
          if (query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () {
                _controller.clear();
                setState(() {});
              },
            ),
        ],
      ),
      body: query.trim().isEmpty
          ? _EmptySearch()
          : ref.watch(globalSearchProvider(query.trim())).when(
              data: (results) {
                if (results.isEmpty) {
                  return Center(child: Text(l10n.noItemsFound));
                }
                return ListView.separated(
                  itemCount: results.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = results[index];
                    return ListTile(
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: (item.isVocab ? AppColors.primary : AppColors.warning).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          item.text.characters.first,
                          style: AppTheme.japaneseText(context, fontSize: item.isVocab ? 16 : 24),
                        ),
                      ),
                      title: Text(
                        item.text,
                        style: AppTheme.japaneseText(context, fontSize: item.isVocab ? 18 : 20),
                      ),
                      subtitle: Text(
                        [item.reading, item.meaning].where((s) => s.isNotEmpty).join(' — '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: item.jlptLevel != null
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'N${item.jlptLevel}',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : null,
                      onTap: () {
                        final level = item.jlptLevel ?? 5;
                        if (item.isVocab) {
                          context.push('/learn/$level/vocab/${Uri.encodeComponent(item.text)}');
                        } else {
                          context.push('/learn/$level/${item.text}');
                        }
                      },
                    );
                  },
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
    );
  }
}

class _EmptySearch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.searchHint,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
