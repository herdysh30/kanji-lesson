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
