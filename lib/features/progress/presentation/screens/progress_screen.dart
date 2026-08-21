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
import 'package:kanji_lesson/l10n/app_localizations.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.progress),
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
                l10n.weeklyActivity,
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
                l10n.jlptBreakdown,
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
                    l10n.recentQuizResults,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () => context.push('/progress/quiz-history'),
                    child: Text(l10n.seeAll),
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
    final l10n = AppLocalizations.of(context)!;
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
                    label: l10n.learned,
                    value: '${overall.totalLearned}',
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => _ProgressListBottomSheet(title: l10n.learnedItems, statusFilter: 'learned'),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.star_rounded,
                    iconColor: AppColors.gold,
                    label: l10n.mastered,
                    value: '${overall.mastered}',
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => _ProgressListBottomSheet(title: l10n.masteredItems, statusFilter: 'mastered'),
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
                    label: l10n.learning,
                    value: '${overall.reviewing}',
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => _ProgressListBottomSheet(title: l10n.reviewingItems, statusFilter: 'reviewing'),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.percent_rounded,
                    iconColor: AppColors.correct,
                    label: l10n.accuracy,
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
      error: (_, __) => Text(l10n.unableToLoadProgress),
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
    final l10n = AppLocalizations.of(context)!;
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
                    l10n.studyStreak,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  streakAsync.when(
                    data: (streak) => Text(
                      '$streak ${streak == 1 ? l10n.day : l10n.days}',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: streak > 0
                                    ? AppColors.streak
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                    ),
                    loading: () => Text(l10n.loading),
                    error: (_, __) => Text(l10n.unableToLoad),
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
    final l10n = AppLocalizations.of(context)!;
    final weeklyAsync = ref.watch(weeklyActivityProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: weeklyAsync.when(
          data: (days) {
            if (days.isEmpty) {
              return SizedBox(
                height: 120,
                child: Center(child: Text(l10n.noActivityYet)),
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
                  final locale = Localizations.localeOf(context).languageCode;
                  final dayLabel = DateFormat('E', locale).format(day.date);

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
                          message: '${DateFormat('d MMM yyyy', locale).format(day.date)}\n${l10n.reviewed}: ${day.reviewed}\n${l10n.accuracy}: ${(day.accuracy * 100).round()}%',
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
          error: (_, __) => SizedBox(
            height: 180,
            child: Center(child: Text(l10n.unableToLoadActivity)),
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
    final l10n = AppLocalizations.of(context)!;
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
                      l10n.weakItems,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 2),
                    weakCount.when(
                      data: (count) => Text(
                        count > 0
                            ? l10n.itemsNeedPractice(count)
                            : l10n.noWeakItemsCard,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      loading: () => Text(l10n.loading),
                      error: (_, __) => Text(l10n.unableToLoad),
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
    final l10n = AppLocalizations.of(context)!;
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
                      l10n.masteredLabel(data.mastered),
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
            error: (_, __) => Text(l10n.unableToLoadLevel(level)),
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
    final l10n = AppLocalizations.of(context)!;
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
                      l10n.noQuizResultsYet,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.takeQuizToSeeHistory,
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
                      _formatQuizType(l10n, result.quizType),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      l10n.quizHistorySubtitle(result.correctAnswers, result.totalQuestions, AppDateUtils.relativeTime(result.date)),
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
      error: (_, __) => Text(l10n.unableToLoadQuizHistory),
    );
  }

  String _formatQuizType(AppLocalizations l10n, String type) {
    switch (type) {
      case 'meaning':
        return l10n.meaningQuiz;
      case 'reading':
        return l10n.readingQuiz;
      case 'writing':
        return l10n.writingQuiz;
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
    final l10n = AppLocalizations.of(context)!;
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
                      return Center(child: Text(l10n.noItemsFound));
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
                          subtitle: Text(l10n.statusLabel(item.status)),
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
