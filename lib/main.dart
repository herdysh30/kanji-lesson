import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kanji_lesson/app.dart';
import 'package:kanji_lesson/features/kanji/presentation/providers/kanji_providers.dart';
import 'package:kanji_lesson/core/services/notification_service.dart';

import 'package:kanji_lesson/core/services/widget_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final sharedPreferences = await SharedPreferences.getInstance();
  try {
    await NotificationService().init();
  } catch (e) {
    debugPrint('Init error: $e');
  }

  try {
    await WidgetService.initialize();
  } catch (e) {
    debugPrint('WidgetService init error: $e');
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const KanjiLessonApp(),
    ),
  );
}
