import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kanji_lesson/core/constants/srs_constants.dart';
import 'package:kanji_lesson/core/database/app_database.dart';
import 'package:kanji_lesson/core/theme/app_colors.dart';
import 'package:kanji_lesson/core/theme/app_theme.dart';
import 'package:kanji_lesson/core/widgets/error_widget.dart';
import 'package:kanji_lesson/core/widgets/loading_widget.dart';
import 'package:kanji_lesson/features/kanji/domain/entities/kanji.dart';
import 'package:kanji_lesson/features/kanji/domain/entities/vocabulary.dart';
import 'package:kanji_lesson/features/kanji/presentation/providers/kanji_providers.dart';

class KanjiDetailScreen extends ConsumerWidget {
  const KanjiDetailScreen({
    super.key,
    required this.character,
    required this.jlptLevel,
  });

  final String character;
  final int jlptLevel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kanjiAsync = ref.watch(kanjiDetailProvider(character));
    final vocabularyAsync = ref.watch(kanjiVocabularyProvider(character));

    return Scaffold(
      appBar: AppBar(
        title: Text(character),
        actions: [
          IconButton(
            icon: const Icon(Icons.quiz_rounded),
            tooltip: 'Start Quiz',
            onPressed: () => context.go('/quiz'),
          ),
        ],
      ),
      body: kanjiAsync.when(
        data: (kanji) => _KanjiDetailBody(
          kanji: kanji,
          vocabularyAsync: vocabularyAsync,
          ref: ref,
        ),
        loading: () => const AppLoadingWidget(message: 'Loading kanji...'),
        error: (error, _) => AppErrorWidget(
          message: 'Unable to load kanji details.',
          onRetry: () => ref.invalidate(kanjiDetailProvider(character)),
        ),
      ),
      bottomNavigationBar: kanjiAsync.whenOrNull(
        data: (kanji) => _ActionBar(kanji: kanji),
      ),
    );
  }
}

class _KanjiDetailBody extends StatelessWidget {
  const _KanjiDetailBody({
    required this.kanji,
    required this.vocabularyAsync,
    required this.ref,
  });

  final Kanji kanji;
  final AsyncValue<List<Vocabulary>> vocabularyAsync;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // ─── Large Kanji Display ─────────────────────────
          const SizedBox(height: 16),
          Text(
            kanji.character,
            style: AppTheme.kanjiLarge(context),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${kanji.strokeCount} strokes',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 32),

          // ─── Meanings ────────────────────────────────────
          _SectionCard(
            title: 'Meaning',
            icon: Icons.translate_rounded,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: kanji.meanings
                  .map((m) => Chip(
                        label: Text(m),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),

          // ─── Readings ────────────────────────────────────
          if (kanji.onyomi.isNotEmpty)
            _SectionCard(
              title: "On'yomi",
              icon: Icons.volume_up_rounded,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: kanji.onyomi
                    .map((r) => Chip(
                          label: Text(r, style: AppTheme.japaneseText(context, fontSize: 14)),
                          backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                        ))
                    .toList(),
              ),
            ),
          if (kanji.onyomi.isNotEmpty) const SizedBox(height: 12),

          if (kanji.kunyomi.isNotEmpty)
            _SectionCard(
              title: "Kun'yomi",
              icon: Icons.volume_up_rounded,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: kanji.kunyomi
                    .map((r) => Chip(
                          label: Text(r, style: AppTheme.japaneseText(context, fontSize: 14)),
                          backgroundColor: AppColors.secondary.withValues(alpha: 0.08),
                        ))
                    .toList(),
              ),
            ),
          if (kanji.kunyomi.isNotEmpty) const SizedBox(height: 12),

          // ─── JLPT & Grade ───────────────────────────────
          _SectionCard(
            title: 'Info',
            icon: Icons.info_outline_rounded,
            child: Row(
              children: [
                if (kanji.jlptLevel != null)
                  _InfoChip(
                    label: 'JLPT N${kanji.jlptLevel}',
                    color: AppColors.jlptColor(kanji.jlptLevel!),
                  ),
                if (kanji.grade != null)
                  _InfoChip(
                    label: 'Grade ${kanji.grade}',
                    color: AppColors.primary,
                  ),
                if (kanji.frequency != null)
                  _InfoChip(
                    label: 'Freq #${kanji.frequency}',
                    color: AppColors.warning,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ─── Vocabulary Section ─────────────────────────
          Row(
            children: [
              Text(
                'Vocabulary',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              Text(
                'JLPT level based on KanjiAPI.dev dataset',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          vocabularyAsync.when(
            data: (vocabs) {
              if (vocabs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No vocabulary data available.'),
                );
              }
              return Column(
                children: vocabs
                    .take(15)
                    .map((v) => _VocabularyTile(vocabulary: v))
                    .toList(),
              );
            },
            loading: () =>
                const AppLoadingWidget(message: 'Loading vocabulary...'),
            error: (_, __) => const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Unable to load vocabulary.'),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─── Section Card ───────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

// ─── Info Chip ──────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}

// ─── Vocabulary Tile ────────────────────────────────────────────

class _VocabularyTile extends StatelessWidget {
  const _VocabularyTile({required this.vocabulary});

  final Vocabulary vocabulary;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          vocabulary.word,
          style: AppTheme.japaneseText(context, fontSize: 20),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              vocabulary.reading,
              style: AppTheme.japaneseReading(context, fontSize: 14),
            ),
            Text(
              vocabulary.primaryMeaning,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: vocabulary.isCommon
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.correct.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'common',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.correct,
                      ),
                ),
              )
            : null,
        isThreeLine: true,
      ),
    );
  }
}

// ─── Action Bar ─────────────────────────────────────────────────

class _ActionBar extends ConsumerWidget {
  const _ActionBar({required this.kanji});

  final Kanji kanji;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _addToReview(context, ref),
                icon: const Icon(Icons.replay_rounded),
                label: const Text('Add to Review'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _markAsLearned(context, ref),
                icon: const Icon(Icons.check_rounded),
                label: const Text('Mark Known'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addToReview(BuildContext context, WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    await db.upsertProgress(UserKanjiProgressEntriesCompanion(
      kanjiCharacter: drift.Value(kanji.character),
      status: const drift.Value('learning'),
      firstLearnedAt: drift.Value(DateTime.now()),
      nextReviewAt: drift.Value(DateTime.now().add(const Duration(minutes: 10))),
      updatedAt: drift.Value(DateTime.now()),
    ));
    ref.invalidate(kanjiProgressProvider(kanji.character));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${kanji.character} added to review'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _markAsLearned(BuildContext context, WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    await db.upsertProgress(UserKanjiProgressEntriesCompanion(
      kanjiCharacter: drift.Value(kanji.character),
      status: const drift.Value('reviewing'),
      firstLearnedAt: drift.Value(DateTime.now()),
      nextReviewAt: drift.Value(DateTime.now().add(const Duration(days: 1))),
      ease: const drift.Value(SrsConstants.defaultEase),
      intervalDays: const drift.Value(1),
      repetitions: const drift.Value(1),
      updatedAt: drift.Value(DateTime.now()),
    ));
    ref.invalidate(kanjiProgressProvider(kanji.character));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${kanji.character} marked as known'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
}
