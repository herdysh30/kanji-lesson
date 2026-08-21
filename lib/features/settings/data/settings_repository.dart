import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  SettingsRepository(this._prefs);
  final SharedPreferences _prefs;

  static const _keyLocale = 'app_locale';
  static const _keyThemeMode = 'app_theme_mode';
  static const _keyDailyGoal = 'app_daily_goal';

  // Locale
  String get locale => _prefs.getString(_keyLocale) ?? 'en';
  Future<void> setLocale(String languageCode) =>
      _prefs.setString(_keyLocale, languageCode);

  // Theme
  ThemeMode get themeMode {
    final val = _prefs.getString(_keyThemeMode);
    if (val == 'light') return ThemeMode.light;
    if (val == 'dark') return ThemeMode.dark;
    return ThemeMode.system;
  }
  
  Future<void> setThemeMode(ThemeMode mode) {
    if (mode == ThemeMode.system) {
      return _prefs.remove(_keyThemeMode);
    }
    return _prefs.setString(_keyThemeMode, mode.name);
  }

  // Daily Goal
  int get dailyGoal => _prefs.getInt(_keyDailyGoal) ?? 10;
  Future<void> setDailyGoal(int goal) => _prefs.setInt(_keyDailyGoal, goal);

  // Accent Color
  static const _keyAccent = 'app_accent_color';
  int get accentColorValue => _prefs.getInt(_keyAccent) ?? 0xFFC62828;
  Future<void> setAccentColor(int value) => _prefs.setInt(_keyAccent, value);
}
