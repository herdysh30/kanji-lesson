import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kanji_lesson/features/home/presentation/screens/home_screen.dart';
import 'package:kanji_lesson/features/kanji/presentation/screens/jlpt_selection_screen.dart';
import 'package:kanji_lesson/features/kanji/presentation/screens/kanji_list_screen.dart';
import 'package:kanji_lesson/features/kanji/presentation/screens/kanji_detail_screen.dart';
import 'package:kanji_lesson/features/review/presentation/screens/review_screen.dart';
import 'package:kanji_lesson/features/progress/presentation/screens/progress_screen.dart';
import 'package:kanji_lesson/features/progress/presentation/screens/weak_kanji_screen.dart';
import 'package:kanji_lesson/features/settings/presentation/screens/settings_screen.dart';
import 'package:kanji_lesson/features/kanji/presentation/screens/writing_practice_screen.dart';
import 'package:kanji_lesson/features/review/presentation/screens/review_session_screen.dart';
import 'package:kanji_lesson/features/review/presentation/screens/review_result_screen.dart';
import 'package:kanji_lesson/features/quiz/presentation/screens/quiz_setup_screen.dart';
import 'package:kanji_lesson/features/quiz/presentation/screens/quiz_screen.dart';
import 'package:kanji_lesson/features/quiz/presentation/screens/quiz_result_screen.dart';
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithBottomNavBar(navigationShell: navigationShell);
      },
      branches: [
        // Branch 0: Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        // Branch 1: Learn
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
        // Branch 2: Review
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/review',
              builder: (context, state) => const ReviewScreen(),
              routes: [
                GoRoute(
                  path: 'session',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const ReviewSessionScreen(),
                ),
                GoRoute(
                  path: 'result',
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
              ],
            ),
          ],
        ),
        // Branch 3: Progress
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/progress',
              builder: (context, state) => const ProgressScreen(),
              routes: [
                GoRoute(
                  path: 'weak',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const WeakKanjiScreen(),
                ),
              ],
            ),
          ],
        ),
        // Branch 4: Settings
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
    // Screens without bottom nav bar (Quiz setup)
    GoRoute(
      path: '/quiz',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const QuizSetupScreen(),
      routes: [
        GoRoute(
          path: 'session',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const QuizScreen(),
        ),
        GoRoute(
          path: 'result',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const QuizResultScreen(),
        ),
      ],
    ),
  ],
);

class ScaffoldWithBottomNavBar extends StatelessWidget {
  const ScaffoldWithBottomNavBar({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_rounded),
            label: 'Learn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.replay_rounded),
            label: 'Review',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
        currentIndex: navigationShell.currentIndex,
        onTap: (int idx) => _onItemTapped(idx, context),
      ),
    );
  }

  void _onItemTapped(int index, BuildContext context) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
