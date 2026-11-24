import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kanji_lesson/core/theme/app_colors.dart';
import 'package:kanji_lesson/core/theme/app_spacing.dart';

/// Japanese minimalist × claymorphism theme — Noto Sans JP throughout
class AppTheme {
  AppTheme._();

  // ─── Cached theme instances (rebuilt only on accent change) ──
  static ThemeData? _light;
  static ThemeData? _dark;
  static int? _accentKey;

  static ThemeData get lightTheme {
    _ensureCache();
    return _light!;
  }

  static ThemeData get darkTheme {
    _ensureCache();
    return _dark!;
  }

  static void _ensureCache() {
    final key = AppColors.primary.toARGB32();
    if (_light == null || key != _accentKey) {
      _light = _buildLight();
      _dark = _buildDark();
      _accentKey = key;
    }
  }

  // ─── Claymorphism helpers ────────────────────────────────────
  static List<BoxShadow> clayShadowLight({double blur = 12, double offset = 4}) {
    return [
      BoxShadow(
        color: AppColors.shadowLight,
        blurRadius: blur,
        offset: Offset(offset, offset),
      ),
      BoxShadow(
        color: AppColors.highlightLight,
        blurRadius: blur - 2,
        offset: Offset(-offset / 2, -offset / 2),
      ),
    ];
  }

  static List<BoxShadow> clayShadowDark({double blur = 12, double offset = 4}) {
    return [
      BoxShadow(
        color: AppColors.shadowDark,
        blurRadius: blur,
        offset: Offset(offset, offset),
      ),
      BoxShadow(
        color: AppColors.highlightDark,
        blurRadius: blur - 2,
        offset: Offset(-offset / 2, -offset / 2),
      ),
    ];
  }

  // ─── Light Theme ──────────────────────────────────────────────
  static ThemeData _buildLight() {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primarySurface,
      onPrimaryContainer: AppColors.primary,
      secondary: AppColors.primaryLight,
      onSecondary: Colors.white,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.textPrimaryLight,
      onSurfaceVariant: AppColors.textSecondaryLight,
      error: AppColors.incorrect,
      onError: Colors.white,
      outline: AppColors.dividerLight,
      outlineVariant: AppColors.dividerLight,
      surfaceContainerLowest: AppColors.cardLight,
      surfaceContainerLow: AppColors.surfaceLight,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      textTheme: _buildTextTheme(Brightness.light),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        titleTextStyle: _notoSans(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryLight,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardLight,
        elevation: 2,
        shadowColor: AppColors.shadowLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          side: BorderSide(color: AppColors.dividerLight, width: 0.5),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        surfaceTintColor: Colors.transparent,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardLight,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiaryLight,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        enableFeedback: false,
        selectedLabelStyle: _notoSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: _notoSans(
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          textStyle: _notoSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          side: const BorderSide(color: AppColors.dividerLight),
          textStyle: _notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          textStyle: _notoSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: _notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: _notoSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textTertiaryLight,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceLight,
        selectedColor: AppColors.primary,
        checkmarkColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          side: const BorderSide(color: AppColors.dividerLight, width: 0.5),
        ),
        labelStyle: _notoSans(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimaryLight,
        ),
        secondaryLabelStyle: _notoSans(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        side: BorderSide.none,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerLight,
        thickness: 0.5,
        space: 1,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.dividerLight,
        linearMinHeight: 8,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimaryLight,
        contentTextStyle: _notoSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ─── Dark Theme ───────────────────────────────────────────────
  static ThemeData _buildDark() {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primaryLight,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryDark,
      onPrimaryContainer: AppColors.primarySurface,
      secondary: AppColors.primaryLight,
      onSecondary: Colors.white,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textPrimaryDark,
      onSurfaceVariant: AppColors.textSecondaryDark,
      error: AppColors.incorrect,
      onError: Colors.white,
      outline: AppColors.dividerDark,
      outlineVariant: AppColors.dividerDark,
      surfaceContainerLowest: AppColors.cardDark,
      surfaceContainerLow: AppColors.surfaceDark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      textTheme: _buildTextTheme(Brightness.dark),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        titleTextStyle: _notoSans(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryDark,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        elevation: 2,
        shadowColor: AppColors.shadowDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.06),
            width: 0.5,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        surfaceTintColor: Colors.transparent,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardDark,
        selectedItemColor: AppColors.primaryLight,
        unselectedItemColor: AppColors.textTertiaryDark,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        enableFeedback: false,
        selectedLabelStyle: _notoSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: _notoSans(
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          textStyle: _notoSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.12),
          ),
          textStyle: _notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          textStyle: _notoSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          textStyle: _notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          borderSide: BorderSide(color: AppColors.primaryLight, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: _notoSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textTertiaryDark,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedColor: AppColors.primaryLight,
        checkmarkColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.06),
            width: 0.5,
          ),
        ),
        labelStyle: _notoSans(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimaryDark,
        ),
        secondaryLabelStyle: _notoSans(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        side: BorderSide.none,
      ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withValues(alpha: 0.06),
        thickness: 0.5,
        space: 1,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primaryLight,
        linearTrackColor: Colors.white.withValues(alpha: 0.06),
        linearMinHeight: 8,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        contentTextStyle: _notoSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimaryDark,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ─── Typography ───────────────────────────────────────────────
  static TextTheme _buildTextTheme(Brightness brightness) {
    final primary = brightness == Brightness.light
        ? AppColors.textPrimaryLight
        : AppColors.textPrimaryDark;
    final secondary = brightness == Brightness.light
        ? AppColors.textSecondaryLight
        : AppColors.textSecondaryDark;
    final tertiary = brightness == Brightness.light
        ? AppColors.textTertiaryLight
        : AppColors.textTertiaryDark;

    return TextTheme(
      displayLarge: _notoSans(fontSize: 32, fontWeight: FontWeight.w700, color: primary),
      displayMedium: _notoSans(fontSize: 28, fontWeight: FontWeight.w700, color: primary),
      displaySmall: _notoSans(fontSize: 24, fontWeight: FontWeight.w600, color: primary),
      headlineLarge: _notoSans(fontSize: 24, fontWeight: FontWeight.w700, color: primary),
      headlineMedium: _notoSans(fontSize: 22, fontWeight: FontWeight.w600, color: primary),
      headlineSmall: _notoSans(fontSize: 20, fontWeight: FontWeight.w600, color: primary),
      titleLarge: _notoSans(fontSize: 18, fontWeight: FontWeight.w600, color: primary),
      titleMedium: _notoSans(fontSize: 16, fontWeight: FontWeight.w600, color: primary),
      titleSmall: _notoSans(fontSize: 14, fontWeight: FontWeight.w600, color: primary),
      bodyLarge: _notoSans(fontSize: 16, fontWeight: FontWeight.w400, color: primary),
      bodyMedium: _notoSans(fontSize: 14, fontWeight: FontWeight.w400, color: secondary),
      bodySmall: _notoSans(fontSize: 12, fontWeight: FontWeight.w400, color: secondary),
      labelLarge: _notoSans(fontSize: 14, fontWeight: FontWeight.w500, color: primary),
      labelMedium: _notoSans(fontSize: 12, fontWeight: FontWeight.w500, color: secondary),
      labelSmall: _notoSans(fontSize: 11, fontWeight: FontWeight.w500, color: tertiary),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────
  static TextStyle _notoSans({
    required double fontSize,
    required FontWeight fontWeight,
    Color? color,
  }) {
    return GoogleFonts.notoSansJp(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  /// Large kanji display (detail screen, flashcard)
  static TextStyle kanjiLarge(BuildContext context) {
    return GoogleFonts.notoSansJp(
      fontSize: 96,
      fontWeight: FontWeight.w400,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  /// Medium kanji display (list items, quiz)
  static TextStyle kanjiMedium(BuildContext context) {
    return GoogleFonts.notoSansJp(
      fontSize: 48,
      fontWeight: FontWeight.w400,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  /// Small kanji display (cards, chips)
  static TextStyle kanjiSmall(BuildContext context) {
    return GoogleFonts.notoSansJp(
      fontSize: 32,
      fontWeight: FontWeight.w400,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  /// Japanese reading text (hiragana/katakana)
  static TextStyle japaneseReading(BuildContext context, {double fontSize = 16}) {
    return GoogleFonts.notoSansJp(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }

  /// Japanese text style
  static TextStyle japaneseText(BuildContext context, {double fontSize = 16}) {
    return GoogleFonts.notoSansJp(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }
}
