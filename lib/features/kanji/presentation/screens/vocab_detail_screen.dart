import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kanji_lesson/core/theme/app_colors.dart';
import 'package:kanji_lesson/core/theme/app_theme.dart';
import 'package:kanji_lesson/features/kanji/presentation/providers/jlpt_vocab_providers.dart';
import 'package:kanji_lesson/features/kanji/presentation/providers/kanji_providers.dart';
import 'package:kanji_lesson/features/settings/presentation/providers/settings_providers.dart';
import 'package:kanji_lesson/core/widgets/error_widget.dart';
import 'package:kanji_lesson/core/widgets/loading_widget.dart';
import 'package:kanji_lesson/features/kanji/presentation/widgets/practice_writing_dialog.dart';
import 'package:kanji_lesson/features/kanji/presentation/widgets/kanji_audio_button.dart';
import 'package:kanji_lesson/l10n/app_localizations.dart';

class VocabDetailScreen extends ConsumerWidget {
  const VocabDetailScreen({
    super.key,
    required this.jlptLevel,
    required this.word,
  });

  final int jlptLevel;
  final String word;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    // The vocab list provider is already cached locally, so we can fetch all and find the word
    final vocabListAsync = ref.watch(jlptVocabListProvider(jlptLevel));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.vocabularyDetail),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'N$jlptLevel',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: vocabListAsync.when(
        data: (vocabs) {
          final vocab = vocabs.firstWhere(
            (v) => v.word == word,
            orElse: () => throw Exception('Vocabulary not found'),
          );

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // ─── Header ───────────────────────────────────────
              Center(
                child: Column(
                  children: [
                    if (vocab.furigana.isNotEmpty && vocab.furigana != vocab.word)
                      Text(
                        vocab.furigana,
                        style: AppTheme.japaneseReading(context, fontSize: 24),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(width: 40),
                        Text(
                          vocab.word,
                          style: AppTheme.kanjiLarge(context),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          width: 40,
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: KanjiAudioButton(character: vocab.word),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      vocab.romaji,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            letterSpacing: 1.2,
                          ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.tonalIcon(
                      onPressed: () {
                        showPracticeWritingDialog(
                          context,
                          character: vocab.word,
                          reading: vocab.furigana,
                          meaning: vocab.meaning,
                        );
                      },
                      icon: const Icon(Icons.draw_rounded),
                      label: Text(l10n.practiceWriting),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // ─── Meaning Section ───────────────────────────────
              Text(
                l10n.meaning,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  vocab.meaning,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.5,
                      ),
                ),
              ),

              // ─── Sentences Section ──────────────────────────────
              const SizedBox(height: 32),
              Text(
                l10n.exampleSentences,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              ref.watch(vocabSentencesProvider(word)).when(
                    data: (sentences) {
                      if (sentences.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(l10n.noExampleSentences),
                        );
                      }
                      
                      final isId = ref.watch(localeProvider).languageCode == 'id';

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: sentences.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final sentence = sentences[index];
                          final meaning = isId && sentence.indonesian.isNotEmpty
                              ? sentence.indonesian
                              : sentence.english;
                          
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(context).dividerTheme.color ?? const Color(0xFFE5E5E5),
                                width: 0.5,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sentence.japanese,
                                  style: AppTheme.japaneseReading(context, fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  meaning,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (_, __) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(l10n.failedToLoadExamples),
                    ),
                  ),
            ],
          );
        },
        loading: () => const AppLoadingWidget(),
        error: (error, _) => AppErrorWidget(
          message: l10n.failedToLoadVocabulary,
          onRetry: () => ref.invalidate(jlptVocabListProvider(jlptLevel)),
        ),
      ),
    );
  }
}
