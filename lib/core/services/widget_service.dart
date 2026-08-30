import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:kanji_lesson/features/home/presentation/widgets/kanji_widget_ui.dart';
import 'package:kanji_lesson/features/home/presentation/widgets/streak_widget_ui.dart';

class WidgetService {
  static const String appGroupId = 'group.com.yourcompany.kanjilesson';
  static const String androidWidgetName = 'KanjiAppWidgetProvider';

  static Future<void> initialize() async {
    await HomeWidget.setAppGroupId(appGroupId);
  }

  static Future<void> updateWidget({
    required String? kanji,
    required String meaning,
    required String reading,
    required int streak,
    required bool goalReached,
  }) async {
    try {
      final kanjiPath = await HomeWidget.renderFlutterWidget(
        KanjiWidgetUi(
          kanji: kanji ?? '?',
          meaning: meaning,
          reading: reading,
        ),
        key: 'kanji_image',
        logicalSize: const Size(400, 400),
      );

      final streakPath = await HomeWidget.renderFlutterWidget(
        StreakWidgetUi(
          streak: streak,
          goalReached: goalReached,
        ),
        key: 'streak_image',
        logicalSize: const Size(400, 400),
      );

      if (kanjiPath.isNotEmpty && streakPath.isNotEmpty) {
        await HomeWidget.saveWidgetData<String>('kanji_image', kanjiPath);
        await HomeWidget.saveWidgetData<String>('streak_image_path', streakPath);
        await HomeWidget.saveWidgetData<int>('current_view', 0);

        await HomeWidget.updateWidget(
          name: androidWidgetName,
          iOSName: 'KanjiLessonWidget',
        );
      }
    } catch (e) {
      debugPrint('Failed to update home widget: $e');
    }
  }

  /// Pre-generate kanji images for the next 7 days and save start date.
  static Future<void> preGenerateWeek(List<WidgetServiceItem> items) async {
    try {
      final startDate = DateTime.now();
      final dateStr =
          '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
      await HomeWidget.saveWidgetData<String>('kanji_start_date', dateStr);

      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        final path = await HomeWidget.renderFlutterWidget(
          KanjiWidgetUi(
            kanji: item.text,
            meaning: item.meaning,
            reading: item.reading,
          ),
          key: 'kanji_image_$i',
          logicalSize: const Size(400, 400),
        );
        await HomeWidget.saveWidgetData<String>('kanji_image_path_$i', path);
      }
    } catch (e) {
      debugPrint('Failed to pre-generate widget week: $e');
    }
  }
}

class WidgetServiceItem {
  final String text;
  final String meaning;
  final String reading;

  WidgetServiceItem({
    required this.text,
    required this.meaning,
    required this.reading,
  });
}
