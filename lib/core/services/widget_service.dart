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
      // 1. Render Kanji UI
      final kanjiPath = await HomeWidget.renderFlutterWidget(
        KanjiWidgetUi(
          kanji: kanji ?? '?',
          meaning: meaning,
          reading: reading,
        ),
        key: 'kanji_image',
        logicalSize: const Size(400, 400),
      );

      // 2. Render Streak UI
      final streakPath = await HomeWidget.renderFlutterWidget(
        StreakWidgetUi(
          streak: streak,
          goalReached: goalReached,
        ),
        key: 'streak_image',
        logicalSize: const Size(400, 400),
      );

      if (kanjiPath.isNotEmpty && streakPath.isNotEmpty) {
        // 3. Save Paths to Native Storage
        await HomeWidget.saveWidgetData<String>('kanji_image_path', kanjiPath);
        await HomeWidget.saveWidgetData<String>('streak_image_path', streakPath);
        // By default, let's reset to view 0 (Kanji) when updating data
        await HomeWidget.saveWidgetData<int>('current_view', 0);
        
        // 4. Trigger Native Widget Update
        await HomeWidget.updateWidget(
          name: androidWidgetName,
          iOSName: 'KanjiLessonWidget',
        );
      }
    } catch (e) {
      debugPrint('Failed to update home widget: $e');
    }
  }
}
