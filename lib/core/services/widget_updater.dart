import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kanji_lesson/core/services/widget_service.dart';
import 'package:kanji_lesson/features/kanji/presentation/providers/kanji_providers.dart';
import 'package:kanji_lesson/features/progress/presentation/providers/progress_providers.dart';
import 'package:kanji_lesson/features/settings/presentation/providers/settings_providers.dart';

final widgetUpdaterProvider = Provider((ref) {
  ref.listen(itemOfTheDayProvider, (previous, next) {
    if (next.hasValue) _updateWidget(ref);
  });

  ref.listen(dailyProgressProvider, (previous, next) {
    _updateWidget(ref);
  });
});

void _updateWidget(Ref ref) async {
  final itemState = ref.read(itemOfTheDayProvider);
  final item = itemState.value;
  if (item == null) return;

  final streak = ref.read(studyStreakProvider).valueOrNull ?? 0;
  final goal = ref.read(dailyGoalProvider);
  final progress = ref.read(dailyProgressProvider);

  await WidgetService.updateWidget(
    kanji: item.text,
    meaning: item.meaning,
    reading: item.reading,
    streak: streak,
    goalReached: progress.todayCount >= goal,
  );

  // Pre-generate 7 days so native widget can rotate without the app running.
  final week = await ref.read(weeklyItemsProvider.future).catchError(
    (Object _) => <ItemOfTheDay>[],
  );
  if (week.isNotEmpty) {
    await WidgetService.preGenerateWeek(
      week.map((w) => WidgetServiceItem(
        text: w.text,
        meaning: w.meaning,
        reading: w.reading,
      )).toList(),
    );
  }
}
