import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kanji_lesson/core/constants/app_constants.dart';
import 'package:kanji_lesson/core/theme/app_colors.dart';
import 'package:kanji_lesson/core/utils/date_utils.dart';
import 'package:kanji_lesson/features/kanji/presentation/providers/kanji_providers.dart';
import 'package:kanji_lesson/features/progress/presentation/providers/progress_providers.dart';
import 'package:kanji_lesson/features/progress/presentation/widgets/streak_calendar_widget.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(overallProgressProvider);
          ref.invalidate(weeklyActivityProvider);
          ref.invalidate(quizHistoryProvider);
          ref.invalidate(studyStreakProvider);
          ref.invalidate(weakKanjiCountProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Overall Stats ────────────────────────────
              const _OverallStatsSection(),
              const SizedBox(height: 24),

              // ─── Study Streak ─────────────────────────────
              const _StudyStreakCard(),
              const SizedBox(height: 16),
              const StreakCalendarWidget(),
              const SizedBox(height: 24),

              // ─── Weekly Activity ──────────────────────────
              Text(
                'Weekly Activity',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              const _WeeklyActivityChart(),
              const SizedBox(height: 24),

              // ─── Weak Items ───────────────────────────────
              const _WeakItemsCard(),
              const SizedBox(height: 24),

              // ─── JLPT Breakdown ───────────────────────────
              Text(
                'JLPT Breakdown',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              ...AppConstants.jlptLevels.map(
                (level) => _JlptDetailTile(level: level),
              ),
              const SizedBox(height: 24),

              // ─── Quiz History ─────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Quiz Results',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () => context.push('/progress/quiz-history'),
                    child: const Text('See All'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const _QuizHistorySection(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Overall Stats ──────────────────────────────────────────────

class _OverallStatsSection extends ConsumerWidget {
  const _OverallStatsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overallAsync = ref.watch(overallProgressProvider);

    return overallAsync.when(
      data: (overall) {
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.school_rounded,
                    iconColor: AppColors.primary,
                    label: 'Learned',
                    value: '${overall.totalLearned}',
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const _ProgressListBottomSheet(title: 'Learned Items', statusFilter: 'learned'),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.star_rounded,
                    iconColor: AppColors.gold,
                    label: 'Mastered',
                    value: '${overall.mastered}',
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const _ProgressListBottomSheet(title: 'Mastered Items', statusFilter: 'mastered'),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.replay_rounded,
                    iconColor: AppColors.primary,
                    label: 'Reviewing',
                    value: '${overall.reviewing}',
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const _ProgressListBottomSheet(title: 'Reviewing Items', statusFilter: 'reviewing'),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.percent_rounded,
                    iconColor: AppColors.correct,
                    label: 'Accuracy',
                    value: '${(overall.accuracy * 100).round()}%',
                  ),
                ),
              ],
            ),
          ],
        );
      },
      loading: () => const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const Text('Unable to load progress'),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

// ─── Study Streak Card ──────────────────────────────────────────

class _StudyStreakCard extends ConsumerWidget {
  const _StudyStreakCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(studyStreakProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.streak, AppColors.warning],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.local_fire_department_rounded,
                  color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Study Streak',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  streakAsync.when(
                    data: (streak) => Text(
                      '$streak ${streak == 1 ? 'day' : 'days'}',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: streak > 0
                                    ? AppColors.streak
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                    ),
                    loading: () => const Text('...'),
                    error: (_, __) => const Text('—'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Weekly Activity Chart ──────────────────────────────────────

class _WeeklyActivityChart extends ConsumerWidget {
  const _WeeklyActivityChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyAsync = ref.watch(weeklyActivityProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: weeklyAsync.when(
          data: (days) {
            if (days.isEmpty) {
              return const SizedBox(
                height: 120,
                child: Center(child: Text('No activity yet')),
              );
            }

            final maxValue = days
                .map((d) => d.reviewed)
                .fold<int>(1, (a, b) => a > b ? a : b);

            return SizedBox(
              height: 180,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: days.map((day) {
                  final barHeight =
                      maxValue > 0 ? (day.reviewed / maxValue) * 120.0 : 0.0;
                  final isToday = AppDateUtils.isToday(day.date);
                  final dayLabel = DateFormat('E').format(day.date).substring(0, 2);

                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${day.reviewed}',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                color: isToday
                                    ? AppColors.primary
                                    : Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Tooltip(
                          message: '${DateFormat('MMM d, yyyy').format(day.date)}\nReviewed: ${day.reviewed}\nAccuracy: ${(day.accuracy * 100).round()}%',
                          child: Container(
                            width: 28,
                            height: barHeight.clamp(4.0, 100.0),
                            decoration: BoxDecoration(
                              gradient: day.reviewed > 0
                                  ? LinearGradient(
                                      colors: isToday
                                          ? [AppColors.primary, AppColors.primaryLight]
                                          : [
                                              AppColors.primary.withValues(alpha: 0.5),
                                              AppColors.primaryLight.withValues(alpha: 0.5),
                                            ],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    )
                                  : null,
                              color: day.reviewed == 0
                                  ? Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest
                                  : null,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          dayLabel,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                color: isToday
                                    ? AppColors.primary
                                    : Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            );
          },
          loading: () => const SizedBox(
            height: 180,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => const SizedBox(
            height: 180,
            child: Center(child: Text('Unable to load activity')),
          ),
        ),
      ),
    );
  }
}

// ─── Weak Items Card ────────────────────────────────────────────

class _WeakItemsCard extends ConsumerWidget {
  const _WeakItemsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weakCount = ref.watch(weakKanjiCountProvider);

    return GestureDetector(
      onTap: () => context.push('/progress/weak'),
      child: Card(
        color: AppColors.warningLight,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.warning_amber_rounded,
                    color: AppColors.warning, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weak Items',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 2),
                    weakCount.when(
                      data: (count) => Text(
                        count > 0
                            ? '$count items need more practice'
                            : 'No weak items — great job!',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      loading: () => const Text('Checking...'),
                      error: (_, __) => const Text('—'),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── JLPT Detail Tile ───────────────────────────────────────────

class _JlptDetailTile extends ConsumerWidget {
  const _JlptDetailTile({required this.level});
  final int level;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(jlptStatsProvider(level));

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: stats.when(
            data: (data) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'JLPT N$level',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${data.learned} / ${data.total}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: data.progress,
                    minHeight: 8,
                    color: AppColors.primary,
                    backgroundColor:
                        AppColors.primary.withValues(alpha: 0.15),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${data.mastered} mastered',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.correct,
                          ),
                    ),
                    Text(
                      data.progressPercent,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ],
            ),
            loading: () => const SizedBox(height: 60),
            error: (_, __) => Text('N$level — Unable to load'),
          ),
        ),
      ),
    );
  }
}

// ─── Quiz History Section ───────────────────────────────────────

class _QuizHistorySection extends ConsumerWidget {
  const _QuizHistorySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(quizHistoryProvider);

    return historyAsync.when(
      data: (results) {
        if (results.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.quiz_rounded,
                        size: 40,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(height: 8),
                    Text(
                      'No quiz results yet',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Take a quiz to see your history here',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Card(
          child: Column(
            children: results.asMap().entries.map((entry) {
              final result = entry.value;
              final isLast = entry.key == results.length - 1;
              final accuracyColor = result.accuracy >= 0.8
                  ? AppColors.correct
                  : result.accuracy >= 0.5
                      ? AppColors.warning
                      : AppColors.incorrect;

              return Column(
                children: [
                  ListTile(
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: accuracyColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '${(result.accuracy * 100).round()}%',
                          style: TextStyle(
                            color: accuracyColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      _formatQuizType(result.quizType),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${result.correctAnswers}/${result.totalQuestions} correct  ·  ${AppDateUtils.relativeTime(result.date)}',
                    ),
                    trailing: result.jlptLevel != null
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'N${result.jlptLevel}',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : null,
                  ),
                  if (!isLast) const Divider(height: 1, indent: 16, endIndent: 16),
                ],
              );
            }).toList(),
          ),
        );
      },
      loading: () => const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const Text('Unable to load quiz history'),
    );
  }

  String _formatQuizType(String type) {
    switch (type) {
      case 'meaning':
        return 'Meaning Quiz';
      case 'reading':
        return 'Reading Quiz';
      case 'writing':
        return 'Writing Quiz';
      default:
        return type[0].toUpperCase() + type.substring(1);
    }
  }
}

// ─── Progress List Bottom Sheet ─────────────────────────────────

class _ProgressListBottomSheet extends ConsumerStatefulWidget {
  const _ProgressListBottomSheet({required this.title, required this.statusFilter});
  final String title;
  final String statusFilter;

  @override
  ConsumerState<_ProgressListBottomSheet> createState() => _ProgressListBottomSheetState();
}

class _ProgressListBottomSheetState extends ConsumerState<_ProgressListBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(progressListProvider(widget.statusFilter));

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              Expanded(
                child: listAsync.when(
                  data: (items) {
                    if (items.isEmpty) {
                      return const Center(child: Text('No items found.'));
                    }
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final total = item.correctCount + item.wrongCount;
                        final accuracy = total > 0 ? item.correctCount / total : 0.0;
                        return ListTile(
                          title: Text(item.kanjiCharacter, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          subtitle: Text('Status: ${item.status[0].toUpperCase()}${item.status.substring(1)}'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('${(accuracy * 100).round()}%', style: TextStyle(
                                color: accuracy >= 0.8 ? AppColors.correct : (accuracy >= 0.5 ? AppColors.warning : Theme.of(context).colorScheme.error),
                                fontWeight: FontWeight.bold,
                              )),
                              Text('${item.correctCount}/$total', style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Center(child: Text('Error: $e')),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
