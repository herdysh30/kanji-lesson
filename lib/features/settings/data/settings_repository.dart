import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  SettingsRepository(this._prefs);
  final SharedPreferences _prefs;

  static const _keyLocale = 'app_locale';
  static const _keyThemeMode = 'app_theme_mode';
  static const _keyDailyGoal = 'app_daily_goal';
  
  // Streak & Progress Keys
  static const _keyLastActiveDate = 'app_last_active_date';
  static const _keyCurrentStreak = 'app_current_streak';
  static const _keyBestStreak = 'app_best_streak';
  static const _keyTodayProgressDate = 'app_today_progress_date';
  static const _keyTodayProgressCount = 'app_today_progress_count';

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

  // ─── Daily Progress & Streak ─────────────────────────────────

  String get lastActiveDate => _prefs.getString(_keyLastActiveDate) ?? '';
  int get currentStreak => _prefs.getInt(_keyCurrentStreak) ?? 0;
  int get bestStreak => _prefs.getInt(_keyBestStreak) ?? 0;
  String get todayProgressDate => _prefs.getString(_keyTodayProgressDate) ?? '';
  int get todayProgressCount => _prefs.getInt(_keyTodayProgressCount) ?? 0;

  Future<void> addDailyProgress(int correctCount) async {
    if (correctCount <= 0) return;

    final todayStr = DateTime.now().toIso8601String().split('T').first;
    
    int currentCount = 0;
    if (todayProgressDate == todayStr) {
      currentCount = todayProgressCount;
    } else {
      // It's a new day! Reset daily progress
      await _prefs.setString(_keyTodayProgressDate, todayStr);
    }
    
    final newCount = currentCount + correctCount;
    await _prefs.setInt(_keyTodayProgressCount, newCount);

    // Check if goal reached
    final goal = dailyGoal;
    if (currentCount < goal && newCount >= goal) {
      // Goal reached for today! Update streak!
      _updateStreak(todayStr);
    }
  }

  Future<void> _updateStreak(String todayStr) async {
    int streak = currentStreak;
    int best = bestStreak;
    final lastActive = lastActiveDate;

    if (lastActive == todayStr) {
      // Already incremented today, do nothing
      return;
    }

    if (lastActive.isNotEmpty) {
      final lastDate = DateTime.parse(lastActive);
      final todayDate = DateTime.parse(todayStr);
      final diff = todayDate.difference(lastDate).inDays;

      if (diff == 1) {
        // Streak continues
        streak += 1;
      } else if (diff > 1) {
        // Streak broken
        streak = 1;
      }
    } else {
      // First time reaching goal
      streak = 1;
    }

    if (streak > best) best = streak;

    await _prefs.setString(_keyLastActiveDate, todayStr);
    await _prefs.setInt(_keyCurrentStreak, streak);
    await _prefs.setInt(_keyBestStreak, best);
  }
}
