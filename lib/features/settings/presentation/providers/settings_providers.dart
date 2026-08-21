import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kanji_lesson/features/settings/data/settings_repository.dart';
import 'package:kanji_lesson/features/kanji/presentation/providers/kanji_providers.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(sharedPreferencesProvider));
});

// ─── Locale ──────────────────────────────────────────────────

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  return LocaleNotifier(repo);
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier(this._repository) : super(Locale(_repository.locale));
  final SettingsRepository _repository;

  Future<void> setLocale(String languageCode) async {
    await _repository.setLocale(languageCode);
    state = Locale(languageCode);
  }
}

// ─── Theme Mode ─────────────────────────────────────────────

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  return ThemeModeNotifier(repo);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(this._repository) : super(_repository.themeMode);
  final SettingsRepository _repository;

  Future<void> setThemeMode(ThemeMode mode) async {
    await _repository.setThemeMode(mode);
    state = mode;
  }
}

// ─── Daily Goal ─────────────────────────────────────────────

final dailyGoalProvider = StateNotifierProvider<DailyGoalNotifier, int>((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  return DailyGoalNotifier(repo);
});

class DailyGoalNotifier extends StateNotifier<int> {
  DailyGoalNotifier(this._repository) : super(_repository.dailyGoal);
  final SettingsRepository _repository;

  Future<void> setDailyGoal(int goal) async {
    await _repository.setDailyGoal(goal);
    state = goal;
  }
}

// ─── Reminder ───────────────────────────────────────────────

class ReminderState {
  const ReminderState({required this.enabled, required this.time});
  final bool enabled;
  final TimeOfDay time;
}

final reminderProvider = StateNotifierProvider<ReminderNotifier, ReminderState>((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  return ReminderNotifier(repo);
});

class ReminderNotifier extends StateNotifier<ReminderState> {
  ReminderNotifier(this._repository) 
      : super(ReminderState(
          enabled: _repository.reminderEnabled,
          time: _repository.reminderTime,
        ));
        
  final SettingsRepository _repository;

  Future<void> setEnabled(bool enabled) async {
    await _repository.setReminderEnabled(enabled);
    state = ReminderState(enabled: enabled, time: state.time);
  }

  Future<void> setTime(TimeOfDay time) async {
    await _repository.setReminderTime(time);
    state = ReminderState(enabled: state.enabled, time: time);
  }
}

// ─── Daily Progress & Streak ────────────────────────────────

class DailyProgressState {
  const DailyProgressState({
    required this.todayCount,
    required this.currentStreak,
    required this.bestStreak,
  });

  final int todayCount;
  final int currentStreak;
  final int bestStreak;
}

final dailyProgressProvider = StateNotifierProvider<DailyProgressNotifier, DailyProgressState>((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  return DailyProgressNotifier(repo);
});

class DailyProgressNotifier extends StateNotifier<DailyProgressState> {
  DailyProgressNotifier(this._repository)
      : super(DailyProgressState(
          todayCount: _getTodayCount(_repository),
          currentStreak: _repository.currentStreak,
          bestStreak: _repository.bestStreak,
        ));

  final SettingsRepository _repository;

  static int _getTodayCount(SettingsRepository repo) {
    final todayStr = DateTime.now().toIso8601String().split('T').first;
    if (repo.todayProgressDate == todayStr) {
      return repo.todayProgressCount;
    }
    return 0; // reset visually for a new day
  }

  Future<void> addProgress(int correctAnswersCount) async {
    await _repository.addDailyProgress(correctAnswersCount);
    // Reload state after repository updates it
    state = DailyProgressState(
      todayCount: _getTodayCount(_repository),
      currentStreak: _repository.currentStreak,
      bestStreak: _repository.bestStreak,
    );
  }
}

// ─── Accent Color ───────────────────────────────────────────

final accentColorProvider = StateNotifierProvider<AccentColorNotifier, int>((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  return AccentColorNotifier(repo);
});

class AccentColorNotifier extends StateNotifier<int> {
  AccentColorNotifier(this._repository) : super(_repository.accentColorValue);
  final SettingsRepository _repository;

  Future<void> setAccentColor(int colorValue) async {
    await _repository.setAccentColor(colorValue);
    state = colorValue;
  }
}
