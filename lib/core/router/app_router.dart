import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kanji_lesson/features/home/presentation/screens/home_screen.dart';
import 'package:kanji_lesson/features/kanji/presentation/screens/jlpt_selection_screen.dart';
import 'package:kanji_lesson/features/kanji/presentation/screens/kanji_list_screen.dart';
import 'package:kanji_lesson/features/kanji/presentation/screens/kanji_detail_screen.dart';
import 'package:kanji_lesson/features/kanji/presentation/screens/vocab_detail_screen.dart';
import 'package:kanji_lesson/features/review/presentation/screens/review_screen.dart';
import 'package:kanji_lesson/features/progress/presentation/screens/progress_screen.dart';
import 'package:kanji_lesson/features/progress/presentation/screens/weak_kanji_screen.dart';
import 'package:kanji_lesson/features/progress/presentation/screens/quiz_history_screen.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedColor = Theme.of(context).colorScheme.primary;
    final unselectedColor = Theme.of(context).colorScheme.onSurfaceVariant;
    final bgColor = Theme.of(context).colorScheme.surface;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(
            top: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : const Color(0xFFE5E5E5),
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 56,
            child: Row(
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Home',
                  isActive: navigationShell.currentIndex == 0,
                  activeColor: selectedColor,
                  inactiveColor: unselectedColor,
                  onTap: () => _go(0),
                ),
                _NavItem(
                  icon: Icons.menu_book_outlined,
                  activeIcon: Icons.menu_book_rounded,
                  label: 'Learn',
                  isActive: navigationShell.currentIndex == 1,
                  activeColor: selectedColor,
                  inactiveColor: unselectedColor,
                  onTap: () => _go(1),
                ),
                _NavItem(
                  icon: Icons.replay_outlined,
                  activeIcon: Icons.replay_rounded,
                  label: 'Review',
                  isActive: navigationShell.currentIndex == 2,
                  activeColor: selectedColor,
                  inactiveColor: unselectedColor,
                  onTap: () => _go(2),
                ),
                _NavItem(
                  icon: Icons.quiz_outlined,
                  activeIcon: Icons.quiz_rounded,
                  label: 'Quiz',
                  isActive: navigationShell.currentIndex == 3,
                  activeColor: selectedColor,
                  inactiveColor: unselectedColor,
                  onTap: () => _go(3),
                ),
                _NavItem(
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings_rounded,
                  label: 'Settings',
                  isActive: navigationShell.currentIndex == 4,
                  activeColor: selectedColor,
                  inactiveColor: unselectedColor,
                  onTap: () => _go(4),
                ),
              ],
            ),
          ),
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

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? activeColor : inactiveColor;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 22,
              color: color,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
