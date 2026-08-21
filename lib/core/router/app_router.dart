import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:kanji_lesson/core/database/app_database.dart';
import 'package:kanji_lesson/features/home/presentation/screens/home_screen.dart';
import 'package:kanji_lesson/features/kanji/presentation/screens/jlpt_selection_screen.dart';
import 'package:kanji_lesson/features/kanji/presentation/screens/kanji_list_screen.dart';
import 'package:kanji_lesson/features/kanji/presentation/screens/kanji_detail_screen.dart';
import 'package:kanji_lesson/features/kanji/presentation/screens/vocab_detail_screen.dart';
import 'package:kanji_lesson/features/review/presentation/screens/review_screen.dart';
import 'package:kanji_lesson/features/progress/presentation/screens/progress_screen.dart';
import 'package:kanji_lesson/features/progress/presentation/screens/weak_kanji_screen.dart';
import 'package:kanji_lesson/features/progress/presentation/screens/quiz_history_screen.dart';
import 'package:kanji_lesson/features/progress/presentation/screens/quiz_history_detail_screen.dart';
import 'package:kanji_lesson/features/settings/presentation/screens/settings_screen.dart';
import 'package:kanji_lesson/features/kanji/presentation/screens/writing_practice_screen.dart';
import 'package:kanji_lesson/features/review/presentation/screens/review_session_screen.dart';
import 'package:kanji_lesson/features/review/presentation/screens/review_result_screen.dart';
import 'package:kanji_lesson/features/quiz/presentation/screens/quiz_setup_screen.dart';
import 'package:kanji_lesson/features/quiz/presentation/screens/quiz_screen.dart';
import 'package:kanji_lesson/features/quiz/presentation/screens/quiz_result_screen.dart';
import 'package:kanji_lesson/features/splash/presentation/screens/splash_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithBottomNavBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/learn',
              builder: (context, state) => const JlptSelectionScreen(),
              routes: [
                GoRoute(
                  path: ':level',
                  builder: (context, state) {
                    final level = int.parse(state.pathParameters['level']!);
                    return KanjiListScreen(jlptLevel: level);
                  },
                  routes: [
                    GoRoute(
                      path: 'practice',
                      parentNavigatorKey: _rootNavigatorKey,
                      builder: (context, state) {
                        final level = int.parse(state.pathParameters['level']!);
                        return WritingPracticeScreen(jlptLevel: level);
                      },
                    ),
                    GoRoute(
                      path: 'vocab/:word',
                      parentNavigatorKey: _rootNavigatorKey,
                      builder: (context, state) {
                        final level = int.parse(state.pathParameters['level']!);
                        final word = state.pathParameters['word']!;
                        return VocabDetailScreen(jlptLevel: level, word: word);
                      },
                    ),
                    GoRoute(
                      path: ':kanji',
                      parentNavigatorKey: _rootNavigatorKey,
                      builder: (context, state) {
                        final level = int.parse(state.pathParameters['level']!);
                        final kanji = state.pathParameters['kanji']!;
                        return KanjiDetailScreen(character: kanji, jlptLevel: level);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/review',
              builder: (context, state) => const ReviewScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/quiz',
              builder: (context, state) => const QuizSetupScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/quiz/session',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const QuizScreen(),
    ),
    GoRoute(
      path: '/quiz/result',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const QuizResultScreen(),
    ),
    GoRoute(
      path: '/review/session',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ReviewSessionScreen(),
    ),
    GoRoute(
      path: '/review/result',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final extras = state.extra as Map<String, dynamic>? ?? {};
        return ReviewResultScreen(
          correctCount: extras['correct'] as int? ?? 0,
          wrongCount: extras['wrong'] as int? ?? 0,
          totalCount: extras['total'] as int? ?? 0,
        );
      },
    ),
    GoRoute(
      path: '/progress',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ProgressScreen(),
      routes: [
        GoRoute(
          path: 'weak',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const WeakKanjiScreen(),
        ),
        GoRoute(
          path: 'quiz-history',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const QuizHistoryScreen(),
        ),
        GoRoute(
          path: 'quiz-history-detail',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final entry = state.extra as QuizResultEntry;
            return QuizHistoryDetailScreen(entry: entry);
          },
        ),
      ],
    ),
  ],
);

// ─── Minimalist Bottom Navigation ────────────────────────────────

class ScaffoldWithBottomNavBar extends StatelessWidget {
  const ScaffoldWithBottomNavBar({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    // Use primary color for the bar to make the curve clearly visible
    final navColor = Theme.of(context).colorScheme.primary;
    // Use scaffold background color for the floating button to match the gap
    final activeBtnColor = bgColor;
    // Unselected icons are white with some transparency
    final unselectedIconColor = Colors.white.withValues(alpha: 0.7);
    final currentIndex = navigationShell.currentIndex;

    return PopScope(
      canPop: currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _go(0);
        }
      },
      child: Scaffold(
        extendBody: true,
        body: navigationShell,
        bottomNavigationBar: CurvedNavigationBar(
          index: currentIndex,
          color: navColor,
          backgroundColor: Colors.transparent, // Background of the gap
          buttonBackgroundColor: activeBtnColor, // Color of the active floating circle
          animationCurve: Curves.easeOutBack,
          animationDuration: const Duration(milliseconds: 350),
          onTap: _go,
          items: <Widget>[
            Icon(Icons.home_rounded, color: currentIndex == 0 ? navColor : unselectedIconColor, size: 28),
            Icon(Icons.menu_book_rounded, color: currentIndex == 1 ? navColor : unselectedIconColor, size: 28),
            // Review: Card stack icon
            Icon(Icons.style_rounded, color: currentIndex == 2 ? navColor : unselectedIconColor, size: 28),
            // Quiz: Original quiz icon
            Icon(Icons.quiz_rounded, color: currentIndex == 3 ? navColor : unselectedIconColor, size: 28),
            Icon(Icons.settings_rounded, color: currentIndex == 4 ? navColor : unselectedIconColor, size: 28),
          ],
        ),
      ),
    );
  }

  void _go(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
