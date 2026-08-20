/// App-wide constants
class AppConstants {
  AppConstants._();

  static const String appName = 'Kanji Lesson';
  static const String appVersion = '1.0.0';

  /// JLPT Levels (5 = easiest, 1 = hardest)
  static const List<int> jlptLevels = [5, 4, 3, 2, 1];

  /// JLPT level display names
  static const Map<int, String> jlptLevelNames = {
    5: 'N5',
    4: 'N4',
    3: 'N3',
    2: 'N2',
    1: 'N1',
  };

  /// JLPT level descriptions
  static const Map<int, String> jlptLevelDescriptions = {
    5: 'Beginner',
    4: 'Elementary',
    3: 'Intermediate',
    2: 'Upper Intermediate',
    1: 'Advanced',
  };

  /// Pre-defined kanji counts for kanjiapi.dev JLPT lists
  static const Map<int, int> jlptKanjiCounts = {
    5: 79,
    4: 166,
    3: 367,
    2: 367,
    1: 1232,
  };

  /// Daily goal options
  static const List<int> dailyGoalOptions = [5, 10, 20, 30];
  static const int defaultDailyGoal = 10;

  /// Quiz
  static const int defaultQuizQuestionCount = 10;
  static const int quizOptionsCount = 4;

  /// Mastery thresholds
  static const double masteredAccuracyThreshold = 0.85;
  static const int masteredMinReviews = 3;
  static const double weakAccuracyThreshold = 0.60;

  /// Animation
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration strokeAnimationDuration = Duration(milliseconds: 500);

  /// Pagination
  static const int kanjiPageSize = 50;

  /// SharedPreferences keys
  static const String prefDailyGoal = 'daily_goal';
  static const String prefDarkMode = 'dark_mode';
  static const String prefAnimationSpeed = 'animation_speed';
  static const String prefSoundEnabled = 'sound_enabled';
  static const String prefLanguage = 'language';
  static const String prefSelectedJlpt = 'selected_jlpt';
  static const String prefStreakCount = 'streak_count';
  static const String prefLastStudyDate = 'last_study_date';
}
