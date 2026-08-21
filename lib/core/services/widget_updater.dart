import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kanji_lesson/core/services/widget_service.dart';
import 'package:kanji_lesson/features/kanji/presentation/providers/kanji_providers.dart';
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
  
  final progress = ref.read(dailyProgressProvider);
  final goal = ref.read(dailyGoalProvider);
      
  await WidgetService.updateWidget(
    kanji: item.text,
    meaning: item.meaning,
    reading: item.reading,
    streak: progress.currentStreak,
    goalReached: progress.todayCount >= goal,
  );
}
