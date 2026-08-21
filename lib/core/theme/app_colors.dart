import 'package:flutter/material.dart';

/// Japanese minimalist color palette
class AppColors {
  AppColors._();

  // ─── Primary — dynamically swappable ──────────────────────
  static Color primary = const Color(0xFFC62828);
  static Color primaryLight = const Color(0xFFE53935);
  static Color primaryDark = const Color(0xFFB71C1C);
  static Color primarySurface = const Color(0xFFFFF5F5);

  // ─── Background — Warm off-white ──────────────────────────
  static const Color backgroundLight = Color(0xFFFAF9F6);
  static const Color surfaceLight = Color(0xFFF5F4F1);
  static const Color cardLight = Color(0xFFFFFFFF);

  // ─── Background — Warm dark ───────────────────────────────
  static const Color backgroundDark = Color(0xFF151515);
  static const Color surfaceDark = Color(0xFF202020);
  static const Color cardDark = Color(0xFF1E1E1E);

  // ─── Text ─────────────────────────────────────────────────
  static const Color textPrimaryLight = Color(0xFF1C1C1C);
  static const Color textSecondaryLight = Color(0xFF6B6B6B);
  static const Color textTertiaryLight = Color(0xFF9E9E9E);
  static const Color textPrimaryDark = Color(0xFFF5F5F5);
  static const Color textSecondaryDark = Color(0xFFAAAAAA);
  static const Color textTertiaryDark = Color(0xFF666666);

  // ─── Semantic ─────────────────────────────────────────────
  static const Color correct = Color(0xFF2E7D32);
  static const Color correctLight = Color(0xFFE8F5E9);
  static const Color incorrect = Color(0xFFC62828);
  static const Color incorrectLight = Color(0xFFFFEBEE);
  static const Color warning = Color(0xFFE65100);
  static const Color warningLight = Color(0xFFFFF3E0);

  // ─── Divider & Border ─────────────────────────────────────
  static const Color dividerLight = Color(0xFFE5E5E5);
  static const Color dividerDark = Color(0xFF2A2A2A);

  // ─── JLPT Levels ─────────────────────────────────────────
  static const Color jlptN5 = Color(0xFFC62828);
  static const Color jlptN4 = Color(0xFFD32F2F);
  static const Color jlptN3 = Color(0xFFE53935);
  static const Color jlptN2 = Color(0xFFEF5350);
  static const Color jlptN1 = Color(0xFFF44336);

  static Color jlptColor(int level) {
    switch (level) {
      case 5: return jlptN5;
      case 4: return jlptN4;
      case 3: return jlptN3;
      case 2: return jlptN2;
      case 1: return jlptN1;
      default: return primary;
    }
  }

  // ─── Kanji ────────────────────────────────────────────────
  static const Color kanjiStroke = Color(0xFF1C1C1C);
  static const Color kanjiStrokeDark = Color(0xFFF5F5F5);
  static const Color kanjiGhost = Color(0xFFE0E0E0);
  static const Color kanjiGhostDark = Color(0xFF333333);

  // ─── Other ────────────────────────────────────────────────
  static const Color streak = Color(0xFFE65100);
  static const Color gold = Color(0xFFFFC107);

  /// Mutate primary color family based on user selection
  static void applyAccent(Color accent) {
    primary = accent;
    primaryLight = Color.lerp(accent, Colors.white, 0.2)!;
    primaryDark = Color.lerp(accent, Colors.black, 0.15)!;
    primarySurface = Color.lerp(accent, Colors.white, 0.92)!;
  }
}

/// Accent color palettes for user selection
class AppAccentPalette {
  AppAccentPalette._();

  static const List<AccentOption> options = [
    AccentOption(name: 'Vermillion', color: Color(0xFFC62828)),
    AccentOption(name: 'Indigo', color: Color(0xFF283593)),
    AccentOption(name: 'Forest', color: Color(0xFF2E7D32)),
    AccentOption(name: 'Royal', color: Color(0xFF6A1B9A)),
    AccentOption(name: 'Ocean', color: Color(0xFF00838F)),
  ];
}

/// Single accent color option
class AccentOption {
  const AccentOption({required this.name, required this.color});
  final String name;
  final Color color;
}
