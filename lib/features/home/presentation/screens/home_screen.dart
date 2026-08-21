import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kanji_lesson/core/constants/app_constants.dart';
import 'package:kanji_lesson/core/theme/app_colors.dart';
import 'package:kanji_lesson/core/theme/app_theme.dart';
import 'package:kanji_lesson/features/kanji/presentation/providers/kanji_providers.dart';
import 'package:kanji_lesson/features/review/presentation/providers/review_providers.dart';
import 'package:kanji_lesson/features/progress/presentation/providers/progress_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(dailyStatsProvider);
            ref.invalidate(dueReviewCountProvider);
            ref.invalidate(overallProgressProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Greeting ──────────────────────────────────
                Text(
                  'こんにちは 👋',
                  style: AppTheme.japaneseText(context, fontSize: 28),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ready to learn some Kanji?',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),

                // ─── Daily Goal Card ───────────────────────────
                _DailyGoalCard(),
                const SizedBox(height: 16),

                // ─── Action Cards Row ──────────────────────────
                Row(
                  children: [
                    Expanded(child: _ReviewCard()),
                    const SizedBox(width: 12),
                    Expanded(child: _WeakKanjiCard()),
                  ],
                ),
                const SizedBox(height: 24),

                // ─── Continue Learning ─────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/learn'),
                    icon: const Icon(Icons.school_rounded),
                    label: const Text('Continue Learning'),
                  ),
                ),
                const SizedBox(height: 32),

                // ─── JLPT Progress ─────────────────────────────
                Text(
                  'JLPT Progress',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ...AppConstants.jlptLevels.map(
                  (level) => _JlptProgressTile(level: level),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Daily Goal Card ────────────────────────────────────────────

class _DailyGoalCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(dailyStatsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: stats.when(
          data: (data) {
            final goal = data?.dailyGoal ?? AppConstants.defaultDailyGoal;
            final done = (data?.newKanjiCount ?? 0) +
                (data?.reviewedKanjiCount ?? 0);
            final progress = goal > 0 ? (done / goal).clamp(0.0, 1.0) : 0.0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Today's Goal",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '$done / $goal',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: Theme.of(context)
                        .progressIndicatorTheme
                        .linearTrackColor,
                  ),
                ),
                if (data?.goalCompleted == true) ...[
                  const SizedBox(height: 8),
                  Text(
                    '🎉 Goal completed!',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.correct,
                        ),
                  ),
                ],
              ],
            );
          },
          loading: () => const SizedBox(
            height: 60,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => const Text('Unable to load daily stats'),
        ),
      ),
    );
  }
}

// ─── Review Card ────────────────────────────────────────────────

class _ReviewCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(dueReviewCountProvider);

    return GestureDetector(
      onTap: () => context.go('/review'),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                Icons.replay_rounded,
                size: 32,
                color: AppColors.primary,
              ),
              const SizedBox(height: 8),
              Text(
                'Review',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              count.when(
                data: (c) => Text(
                  '$c Kanji',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: c > 0 ? AppColors.secondary : null,
                        fontWeight: c > 0 ? FontWeight.w600 : null,
                      ),
                ),
                loading: () => const Text('...'),
                error: (_, __) => const Text('—'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Weak Kanji Card ────────────────────────────────────────────

class _WeakKanjiCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weak = ref.watch(weakKanjiCountProvider);

    return GestureDetector(
      onTap: () => context.push('/progress/weak'),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 32,
                color: AppColors.warning,
              ),
              const SizedBox(height: 8),
              Text(
                'Weak Kanji',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              weak.when(
                data: (c) => Text(
                  '$c Kanji',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                loading: () => const Text('...'),
                error: (_, __) => const Text('—'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── JLPT Progress Tile ────────────────────────────────────────

class _JlptProgressTile extends ConsumerWidget {
  const _JlptProgressTile({required this.level});
  final int level;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(jlptStatsProvider(level));

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => context.go('/learn/$level'),
        child: stats.when(
          data: (data) => Row(
            children: [
              Container(
                width: 48,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.jlptColor(level).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'N$level',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.jlptColor(level),
                      ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${data.learned} / ${data.total}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          data.progressPercent,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: data.progress,
                        minHeight: 6,
                        color: AppColors.jlptColor(level),
                        backgroundColor: AppColors.jlptColor(level)
                            .withValues(alpha: 0.15),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ],
          ),
          loading: () => const SizedBox(height: 40),
          error: (_, __) => Text('N$level — Unable to load'),
        ),
      ),
    );
  }
}
