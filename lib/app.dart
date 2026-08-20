import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kanji_lesson/core/router/app_router.dart';
import 'package:kanji_lesson/core/theme/app_theme.dart';

class KanjiLessonApp extends ConsumerWidget {
  const KanjiLessonApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We would normally watch a theme provider here to toggle dark/light mode
    // For now we'll rely on system theme
    return MaterialApp.router(
      title: 'Kanji Lesson',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
