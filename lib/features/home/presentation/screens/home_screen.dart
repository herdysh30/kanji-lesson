import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kanji_lesson/core/constants/app_constants.dart';
import 'package:kanji_lesson/core/theme/app_colors.dart';
import 'package:kanji_lesson/core/theme/app_spacing.dart';
import 'package:kanji_lesson/features/kanji/presentation/providers/kanji_providers.dart';
import 'package:kanji_lesson/features/review/presentation/providers/review_providers.dart';
import 'package:kanji_lesson/features/progress/presentation/providers/progress_providers.dart';
import 'package:kanji_lesson/features/settings/presentation/providers/settings_providers.dart';
import 'package:kanji_lesson/core/services/widget_updater.dart';
import 'package:kanji_lesson/l10n/app_localizations.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    // Keep widget updater alive
    ref.read(widgetUpdaterProvider);
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
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenH,
              vertical: AppSpacing.screenV,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Greeting ──────────────────────────────────
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.greeting,
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.whatShallWeLearnToday,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    Consumer(
                      builder: (context, ref, child) {
                        final progress = ref.watch(dailyProgressProvider);
                        final hasStreak = progress.currentStreak > 0;
                        
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: hasStreak 
                                ? Colors.orange.withValues(alpha: 0.15)
                                : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Text(hasStreak ? '🔥' : '📓', style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 6),
                              Text(
                                '${progress.currentStreak}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: hasStreak 
                                      ? Colors.orange 
                                      : Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),

                // ─── Daily Goal ────────────────────────────────
                _DailyGoalCard(),
                const SizedBox(height: AppSpacing.lg),

                // ─── Kanji of the Day ──────────────────────────
                if (ref.watch(showKanjiOfTheDayProvider)) ...[
                  _KanjiOfTheDayCard(),
                  const SizedBox(height: AppSpacing.lg),
                ],

                // ─── Quick Actions ────────────────────────────
                Row(
                  children: [
                    Expanded(child: _QuickActionCard(
                      label: l10n.review,
                      icon: Icons.replay_rounded,
                      onTap: () => context.go('/review'),
                      count: ref.watch(dueReviewCountProvider),
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: _QuickActionCard(
                      label: l10n.progress,
                      icon: Icons.bar_chart_rounded,
                      onTap: () => context.push('/progress'),
                    )),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),

                // ─── Continue Learning ─────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => StatefulNavigationShell.of(context).goBranch(1),
                    child: Text(l10n.continueLearning),
                  ),
                ),
                const SizedBox(height: AppSpacing.sectionGap),

                // ─── JLPT Progress ─────────────────────────────
                Text(
                  l10n.jlptProgress,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.trackYourProgressAcrossLevels,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.md),
                ...AppConstants.jlptLevels.map(
                  (level) => _JlptProgressRow(level: level),
                ),
                const SizedBox(height: 40),
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
    final l10n = AppLocalizations.of(context)!;
    final progressState = ref.watch(dailyProgressProvider);
    final goal = ref.watch(dailyGoalProvider);
    
    final done = progressState.todayCount;
    final progress = goal > 0 ? (done / goal).clamp(0.0, 1.0) : 0.0;
    final completed = done >= goal;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            completed ? l10n.todaysGoalComplete : l10n.todaysGoal,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '$done / $goal',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          if (!completed) ...[
            const SizedBox(height: 8),
            Text(
              l10n.moreToComplete(goal - done),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Quick Action Card ──────────────────────────────────────────

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.label,
    required this.icon,
    required this.onTap,
    this.count,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final AsyncValue<int>? count;

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: Theme.of(context).dividerTheme.color ?? const Color(0xFFE5E5E5),
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 2),
            if (count != null) count!.when(
              data: (c) => Text(
                '$c items',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              loading: () => const Text('...'),
              error: (_, __) => const Text('—'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── JLPT Progress Row ─────────────────────────────────────────

class _JlptProgressRow extends ConsumerWidget {
  const _JlptProgressRow({required this.level});
  final int level;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(jlptStatsProvider(level));

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: () => context.go('/learn/$level'),
        child: stats.when(
          data: (data) => Row(
            children: [
              // Level label
              SizedBox(
                width: 32,
                child: Text(
                  'N$level',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Progress bar
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
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: data.progress,
                        minHeight: 5,
                        color: AppColors.primary,
                        backgroundColor: AppColors.primaryLight.withValues(alpha: 0.08),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
          loading: () => const SizedBox(height: 36),
          error: (_, __) => Text('N$level — Unable to load'),
        ),
      ),
    );
  }
}

// ─── Kanji of the Day Card ──────────────────────────────────────

class _KanjiOfTheDayCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final itemAsync = ref.watch(itemOfTheDayProvider);

    return itemAsync.when(
      data: (item) {
        if (item == null) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () {
            ref.read(kanjiSearchQueryProvider.notifier).state = item.text;
            if (item.isVocab) {
              context.push('/learn/${item.jlptLevel}/vocab/${item.text}');
            } else {
              context.push('/learn/${item.jlptLevel}/${item.text}');
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  Theme.of(context).colorScheme.secondary.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.isVocab ? "Vocab of the Day" : ((l10n as dynamic).kanjiOfTheDay as String),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (item.meaning.isNotEmpty)
                        Text(
                          item.meaning,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (item.reading.isNotEmpty)
                        Text(
                          item.reading,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                    ],
                  ),
                ),
                Text(
                  item.text,
                  style: TextStyle(
                    fontSize: item.isVocab ? 32 : 48,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
