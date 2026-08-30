import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kanji_lesson/core/theme/app_colors.dart';
import 'package:kanji_lesson/core/theme/app_theme.dart';
import 'package:kanji_lesson/core/widgets/error_widget.dart';
import 'package:kanji_lesson/core/widgets/loading_widget.dart';
import 'package:kanji_lesson/features/kanji/domain/entities/jlpt_vocab.dart';
import 'package:kanji_lesson/features/kanji/presentation/providers/jlpt_vocab_providers.dart';
import 'package:kanji_lesson/features/settings/presentation/providers/settings_providers.dart';
import 'package:kanji_lesson/l10n/app_localizations.dart';

class VocabularyBrowserScreen extends ConsumerStatefulWidget {
  const VocabularyBrowserScreen({super.key, this.initialLevel});

  final int? initialLevel;

  @override
  ConsumerState<VocabularyBrowserScreen> createState() => _VocabularyBrowserScreenState();
}

class _VocabularyBrowserScreenState extends ConsumerState<VocabularyBrowserScreen> {
  late int _selectedLevel;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _selectedLevel = widget.initialLevel ?? 5;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isId = ref.watch(localeProvider).languageCode == 'id';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.vocabulary),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              onChanged: (value) => setState(() => _query = value.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: l10n.searchKanjiVocabulary,
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                isDense: true,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Level filter chips
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [5, 4, 3, 2, 1].map((level) {
                final selected = level == _selectedLevel;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('N$level'),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedLevel = level),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: ref.watch(jlptVocabListProvider(_selectedLevel)).when(
              data: (vocabs) {
                final filtered = _query.isEmpty
                    ? vocabs
                    : vocabs.where((v) =>
                        v.word.toLowerCase().contains(_query) ||
                        v.furigana.toLowerCase().contains(_query) ||
                        v.meaning.toLowerCase().contains(_query) ||
                        (v.meaningId?.toLowerCase().contains(_query) ?? false)).toList();
                if (filtered.isEmpty) {
                  return Center(child: Text(l10n.noItemsFound));
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final vocab = filtered[index];
                    return _VocabTile(vocab: vocab, isId: isId, onTap: () {
                      context.push('/learn/$_selectedLevel/vocab/${vocab.word}');
                    });
                  },
                );
              },
              loading: () => AppLoadingWidget(message: l10n.loading),
              error: (e, _) => AppErrorWidget(
                message: 'Unable to load vocabulary.',
                onRetry: () => ref.invalidate(jlptVocabListProvider(_selectedLevel)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VocabTile extends StatelessWidget {
  const _VocabTile({required this.vocab, required this.isId, required this.onTap});

  final JlptVocab vocab;
  final bool isId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final meaning = vocab.primaryMeaning(isId);
    return ListTile(
      onTap: onTap,
      title: Text(
        vocab.word,
        style: AppTheme.japaneseText(context, fontSize: 20),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            vocab.furigana,
            style: AppTheme.japaneseReading(context, fontSize: 13),
          ),
          Text(
            meaning,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Icon(Icons.menu_book_rounded, size: 20, color: AppColors.primary),
      ),
    );
  }
}
