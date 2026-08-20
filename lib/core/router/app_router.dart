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
import 'package:kanji_lesson/features/quiz/presentation/screens/quiz_setup_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return ScaffoldWithBottomNavBar(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
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
        GoRoute(
          path: '/review',
          builder: (context, state) => const ReviewScreen(),
        ),
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
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/quiz',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const QuizSetupScreen(),
    ),
  ],
);

class ScaffoldWithBottomNavBar extends StatelessWidget {
  const ScaffoldWithBottomNavBar({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
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
        currentIndex: _calculateSelectedIndex(context),
        onTap: (int idx) => _onItemTapped(idx, context),
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/learn')) return 1;
    if (location.startsWith('/review')) return 2;
    if (location.startsWith('/progress')) return 3;
    if (location.startsWith('/settings')) return 4;
    return 0; // Default to Home
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/learn');
        break;
      case 2:
        context.go('/review');
        break;
      case 3:
        context.go('/progress');
        break;
      case 4:
        context.go('/settings');
        break;
    }
  }
}
