import 'package:flutter/material.dart';

/// Application color palette
class AppColors {
  AppColors._();

  // Primary palette - Deep indigo
  static const Color primaryLight = Color(0xFF5C6BC0);
  static const Color primary = Color(0xFF3949AB);
  static const Color primaryDark = Color(0xFF283593);

  // Secondary palette - Warm coral
  static const Color secondaryLight = Color(0xFFFF8A80);
  static const Color secondary = Color(0xFFFF5252);
  static const Color secondaryDark = Color(0xFFD32F2F);

  // Surface colors - Light
  static const Color surfaceLight = Color(0xFFF8F9FE);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF5F5F7);

  // Surface colors - Dark
  static const Color surfaceDark = Color(0xFF1A1A2E);
  static const Color cardDark = Color(0xFF232340);
  static const Color backgroundDark = Color(0xFF121220);

  // Feedback colors
  static const Color correct = Color(0xFF4CAF50);
  static const Color correctLight = Color(0xFFE8F5E9);
  static const Color incorrect = Color(0xFFEF5350);
  static const Color incorrectLight = Color(0xFFFFEBEE);
  static const Color warning = Color(0xFFFFA726);
  static const Color warningLight = Color(0xFFFFF3E0);

  // JLPT Level Colors
  static const Color jlptN5 = Color(0xFF66BB6A);
  static const Color jlptN4 = Color(0xFF42A5F5);
  static const Color jlptN3 = Color(0xFFFFCA28);
  static const Color jlptN2 = Color(0xFFFFA726);
  static const Color jlptN1 = Color(0xFFEF5350);

  static Color jlptColor(int level) {
    switch (level) {
      case 5:
        return jlptN5;
      case 4:
        return jlptN4;
      case 3:
        return jlptN3;
      case 2:
        return jlptN2;
      case 1:
        return jlptN1;
      default:
        return primary;
    }
  }

  // Text colors
  static const Color textPrimaryLight = Color(0xFF1A1A2E);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textTertiaryLight = Color(0xFF9CA3AF);

  static const Color textPrimaryDark = Color(0xFFF0F0F5);
  static const Color textSecondaryDark = Color(0xFFB0B3C5);
  static const Color textTertiaryDark = Color(0xFF6B7088);

  // Kanji display colors
  static const Color kanjiStroke = Color(0xFF1A1A2E);
  static const Color kanjiStrokeDark = Color(0xFFF0F0F5);
  static const Color kanjiGhost = Color(0xFFE0E0E0);
  static const Color kanjiGhostDark = Color(0xFF3A3A5C);

  // Streak / Achievement
  static const Color streak = Color(0xFFFF6D00);
  static const Color gold = Color(0xFFFFD700);
}
