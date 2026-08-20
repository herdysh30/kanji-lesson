/// Spaced Repetition System constants
class SrsConstants {
  SrsConstants._();

  /// Default values for new cards
  static const double defaultEase = 2.5;
  static const int defaultInterval = 0;
  static const int defaultRepetitions = 0;

  /// Ease bounds
  static const double minEase = 1.3;
  static const double maxEase = 3.5;

  /// Ease adjustments per rating
  static const double easeDecreaseAgain = 0.2;
  static const double easeDecreaseHard = 0.15;
  static const double easeIncreaseEasy = 0.15;

  /// Interval multipliers
  static const double hardMultiplier = 1.2;
  static const double easyBonusMultiplier = 1.3;

  /// Base intervals (in minutes)
  static const int againIntervalMinutes = 10;
  static const int hardIntervalDays = 1;
  static const int goodIntervalDays = 3;
  static const int easyIntervalDays = 7;

  /// Graduation
  static const int graduatingIntervalDays = 1;
}

/// SRS rating from user after reviewing a card
enum SrsRating {
  again, // Forgot completely
  hard, // Remembered with difficulty
  good, // Remembered correctly
  easy, // Very easy to remember
}

/// Learning status of a kanji
enum KanjiStatus {
  unseen, // Never studied
  learning, // Currently learning
  reviewing, // In SRS review cycle
  mastered, // High accuracy, long intervals
}
