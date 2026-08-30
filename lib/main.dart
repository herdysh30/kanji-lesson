import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kanji_lesson/firebase_options.dart';
import 'package:kanji_lesson/app.dart';
import 'package:kanji_lesson/features/kanji/presentation/providers/kanji_providers.dart';
import 'package:kanji_lesson/core/services/notification_service.dart';

import 'package:kanji_lesson/core/services/widget_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // No local font assets bundled — disable runtime fetch to avoid
  // network + font-swap jank during theme animations. System CJK
  // fonts (NotoSansCJK on Android) render kanji almost identically.
  GoogleFonts.config.allowRuntimeFetching = false;
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
