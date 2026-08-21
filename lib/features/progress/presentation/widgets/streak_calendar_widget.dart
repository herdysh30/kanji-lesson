import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:kanji_lesson/core/theme/app_colors.dart';
import 'package:kanji_lesson/features/progress/presentation/providers/progress_providers.dart';

class StreakCalendarWidget extends ConsumerStatefulWidget {
  const StreakCalendarWidget({super.key});

  @override
  ConsumerState<StreakCalendarWidget> createState() => _StreakCalendarWidgetState();
}

class _StreakCalendarWidgetState extends ConsumerState<StreakCalendarWidget> {
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final streakDatesAsync = ref.watch(streakDatesProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: streakDatesAsync.when(
          data: (dates) {
            final activeDates = dates.map((d) => DateTime(d.year, d.month, d.day)).toSet();

            return TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              onPageChanged: (focusedDay) => _focusedDay = focusedDay,
              calendarFormat: CalendarFormat.month,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  final isStreak = activeDates.contains(DateTime(day.year, day.month, day.day));
                  if (isStreak) {
                    return Container(
                      margin: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.streak,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }
                  return null;
                },
                todayBuilder: (context, day, focusedDay) {
                  final isStreak = activeDates.contains(DateTime(day.year, day.month, day.day));
                  return Container(
                    margin: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isStreak ? AppColors.streak : Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                      border: isStreak ? Border.all(color: AppColors.gold, width: 2) : null,
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          color: isStreak ? Colors.white : Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
          loading: () => const SizedBox(height: 300, child: Center(child: CircularProgressIndicator())),
          error: (_, __) => const SizedBox(height: 300, child: Center(child: Text('Unable to load calendar'))),
        ),
      ),
    );
  }
}
