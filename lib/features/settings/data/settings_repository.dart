import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kanji_lesson/core/services/notification_service.dart';

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
  
  // Reminder Keys
  static const _keyReminderEnabled = 'app_reminder_enabled';
  static const _keyReminderHour = 'app_reminder_hour';
  static const _keyReminderMinute = 'app_reminder_minute';
  static const _keyReminderSound = 'app_reminder_sound';
  static const _keyReminderVibration = 'app_reminder_vibration';

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

  // ─── Reminder ───────────────────────────────────────────────

  bool get reminderEnabled => _prefs.getBool(_keyReminderEnabled) ?? false;
  Future<void> setReminderEnabled(bool enabled) => _prefs.setBool(_keyReminderEnabled, enabled);

  TimeOfDay get reminderTime => TimeOfDay(
        hour: _prefs.getInt(_keyReminderHour) ?? 20,
        minute: _prefs.getInt(_keyReminderMinute) ?? 0,
      );
      
  Future<void> setReminderTime(TimeOfDay time) async {
    await _prefs.setInt(_keyReminderHour, time.hour);
    await _prefs.setInt(_keyReminderMinute, time.minute);
  }

  bool get reminderSound => _prefs.getBool(_keyReminderSound) ?? true;
  Future<void> setReminderSound(bool enabled) => _prefs.setBool(_keyReminderSound, enabled);

  bool get reminderVibration => _prefs.getBool(_keyReminderVibration) ?? true;
  Future<void> setReminderVibration(bool enabled) => _prefs.setBool(_keyReminderVibration, enabled);

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
    final lastActive = lastActiveDate;
    
    if (newCount >= goal && lastActive != todayStr) {
      // Goal reached for today and streak not yet updated!
      await _updateStreak(todayStr);
      
      if (reminderEnabled) {
        await NotificationService().scheduleDailyReminder(
          reminderTime, 
          skipToday: true,
          playSound: reminderSound,
          enableVibration: reminderVibration,
        );
      }
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
