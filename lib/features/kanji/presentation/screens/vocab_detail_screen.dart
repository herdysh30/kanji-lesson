import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kanji_lesson/core/theme/app_colors.dart';
import 'package:kanji_lesson/core/theme/app_theme.dart';
import 'package:kanji_lesson/features/kanji/presentation/providers/jlpt_vocab_providers.dart';
import 'package:kanji_lesson/core/widgets/error_widget.dart';
import 'package:kanji_lesson/core/widgets/loading_widget.dart';
import 'package:kanji_lesson/features/kanji/presentation/widgets/practice_writing_dialog.dart';

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
    // The vocab list provider is already cached locally, so we can fetch all and find the word
    final vocabListAsync = ref.watch(jlptVocabListProvider(jlptLevel));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vocabulary Detail'),
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
              style: const TextStyle(
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
                    Text(
                      vocab.word,
                      style: AppTheme.kanjiLarge(context),
                      textAlign: TextAlign.center,
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
                      label: const Text('Practice Writing'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // ─── Meaning Section ───────────────────────────────
              Text(
                'Meaning',
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
            ],
          );
        },
        loading: () => const AppLoadingWidget(),
        error: (error, _) => AppErrorWidget(
          message: 'Failed to load vocabulary',
          onRetry: () => ref.invalidate(jlptVocabListProvider(jlptLevel)),
        ),
      ),
    );
  }
}
