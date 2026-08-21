import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kanji_lesson/core/constants/app_constants.dart';
import 'package:kanji_lesson/core/theme/app_colors.dart';
import 'package:kanji_lesson/core/theme/app_spacing.dart';
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
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenH,
              vertical: AppSpacing.screenV,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Greeting ──────────────────────────────────
                const SizedBox(height: 8),
                Text(
                  'こんにちは',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  "What shall we learn today?",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.xl),

                // ─── Daily Goal ────────────────────────────────
                _DailyGoalCard(),
                const SizedBox(height: AppSpacing.lg),

                // ─── Quick Actions ────────────────────────────
                Row(
                  children: [
                    Expanded(child: _QuickActionCard(
                      label: 'Review',
                      icon: Icons.replay_rounded,
                      onTap: () => context.go('/review'),
                      count: ref.watch(dueReviewCountProvider),
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: _QuickActionCard(
                      label: 'Progress',
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
                    onPressed: () => context.go('/learn'),
                    child: const Text('Continue Learning'),
                  ),
                ),
                const SizedBox(height: AppSpacing.sectionGap),

                // ─── JLPT Progress ─────────────────────────────
                Text(
                  'JLPT Progress',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Track your progress across levels',
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
    final stats = ref.watch(dailyStatsProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: stats.when(
        data: (data) {
          final goal = data?.dailyGoal ?? AppConstants.defaultDailyGoal;
          final done = (data?.newKanjiCount ?? 0) +
              (data?.reviewedKanjiCount ?? 0);
          final progress = goal > 0 ? (done / goal).clamp(0.0, 1.0) : 0.0;
          final completed = data?.goalCompleted == true || done >= goal;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                completed ? 'Today\'s Goal — Complete ✓' : 'Today\'s Goal',
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
                  '${goal - done} more to complete today\'s goal',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          );
        },
        loading: () => const SizedBox(
          height: 80,
          child: Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
        error: (_, __) => const Text(
          'Unable to load',
          style: TextStyle(color: Colors.white),
        ),
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
