import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kanji_lesson/core/database/app_database.dart';
import 'package:kanji_lesson/core/theme/app_colors.dart';
import 'package:kanji_lesson/features/kanji/presentation/providers/kanji_providers.dart';
import 'package:kanji_lesson/l10n/app_localizations.dart';

final fullQuizHistoryProvider = FutureProvider<List<QuizResultEntry>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.getRecentQuizResults(100);
});

class QuizHistoryScreen extends ConsumerStatefulWidget {
  const QuizHistoryScreen({super.key});

  @override
  ConsumerState<QuizHistoryScreen> createState() => _QuizHistoryScreenState();
}

class _QuizHistoryScreenState extends ConsumerState<QuizHistoryScreen> {
  int? _selectedJlptLevel;
  String? _selectedQuizType;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final historyAsync = ref.watch(fullQuizHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.quizHistory),
      ),
      body: historyAsync.when(
        data: (results) {
          if (results.isEmpty) {
            return Center(child: Text(l10n.noQuizHistory));
          }

          final filtered = results.where((r) {
            if (_selectedJlptLevel != null && r.jlptLevel != _selectedJlptLevel) {
              return false;
            }
            if (_selectedQuizType != null && r.quizType != _selectedQuizType) {
              return false;
            }
            return true;
          }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Filters
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    FilterChip(
                      label: Text(l10n.allLevels),
                      selected: _selectedJlptLevel == null,
                      onSelected: (_) => setState(() => _selectedJlptLevel = null),
                    ),
                    const SizedBox(width: 8),
                    ...List.generate(5, (index) {
                      final level = 5 - index;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text('N$level'),
                          selected: _selectedJlptLevel == level,
                          onSelected: (_) => setState(() => _selectedJlptLevel = level),
                        ),
                      );
                    }),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: Text(l10n.allTypes),
                      selected: _selectedQuizType == null,
                      onSelected: (_) => setState(() => _selectedQuizType = null),
                    ),
                    const SizedBox(width: 8),
                    ...['meaning', 'reading', 'writing'].map((type) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(type[0].toUpperCase() + type.substring(1)),
                        selected: _selectedQuizType == type,
                        onSelected: (_) => setState(() => _selectedQuizType = type),
                      ),
                    )),
                  ],
                ),
              ),
              const Divider(),
              // List
              Expanded(
                child: filtered.isEmpty
                    ? Center(child: Text(l10n.noQuizzesMatchFilters))
                    : ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          final isPerfect = item.accuracy >= 1.0;
                          final isGood = item.accuracy >= 0.8;
                          
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: (isPerfect ? AppColors.correct : (isGood ? AppColors.primary : AppColors.warning)).withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isPerfect ? Icons.workspace_premium_rounded : (isGood ? Icons.star_rounded : Icons.star_half_rounded),
                                color: isPerfect ? AppColors.correct : (isGood ? AppColors.primary : AppColors.warning),
                              ),
                            ),
                            title: Text(
                              '${item.quizType[0].toUpperCase()}${item.quizType.substring(1)} Quiz${item.jlptLevel != null ? ' (N${item.jlptLevel})' : ''}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              DateFormat('MMM d, yyyy - HH:mm').format(item.date),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${(item.accuracy * 100).round()}%',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isPerfect ? AppColors.correct : (isGood ? AppColors.primary : Theme.of(context).colorScheme.onSurface),
                                  ),
                                ),
                                Text(
                                  '${item.correctAnswers}/${item.totalQuestions}',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                            onTap: () {
                              context.push('/progress/quiz-history-detail', extra: item);
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text(e.toString())),
      ),
    );
  }
}
