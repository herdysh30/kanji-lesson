import 'package:kanji_lesson/core/constants/srs_constants.dart';
import 'package:kanji_lesson/core/utils/date_utils.dart';

/// Result of an SRS calculation
class SrsResult {
  const SrsResult({
    required this.newEase,
    required this.newIntervalDays,
    required this.newRepetitions,
    required this.nextReviewAt,
    required this.newStatus,
  });

  final double newEase;
  final int newIntervalDays;
  final int newRepetitions;
  final DateTime nextReviewAt;
  final String newStatus; // KanjiStatus as string
}

/// Spaced Repetition System engine
/// Implements a simplified SM-2 algorithm
class SrsEngine {
  const SrsEngine();

  /// Calculate the next review schedule based on user rating
  SrsResult calculate({
    required SrsRating rating,
    required double currentEase,
    required int currentIntervalDays,
    required int repetitions,
    required int correctCount,
    required int wrongCount,
  }) {
    double newEase = currentEase;
    int newInterval;
    int newRepetitions = repetitions;

    switch (rating) {
      case SrsRating.again:
        // Reset - card was forgotten
        newEase = (currentEase - SrsConstants.easeDecreaseAgain)
            .clamp(SrsConstants.minEase, SrsConstants.maxEase);
        newInterval = 0; // Will use minutes instead
        newRepetitions = 0;

        return SrsResult(
          newEase: newEase,
          newIntervalDays: 0,
          newRepetitions: newRepetitions,
          nextReviewAt: AppDateUtils.nextReviewFromMinutes(
            SrsConstants.againIntervalMinutes,
          ),
          newStatus: 'learning',
        );

      case SrsRating.hard:
        newEase = (currentEase - SrsConstants.easeDecreaseHard)
            .clamp(SrsConstants.minEase, SrsConstants.maxEase);

        if (repetitions == 0) {
          newInterval = SrsConstants.hardIntervalDays;
        } else {
          newInterval =
              (currentIntervalDays * SrsConstants.hardMultiplier).round();
          if (newInterval < SrsConstants.hardIntervalDays) {
            newInterval = SrsConstants.hardIntervalDays;
          }
        }
        newRepetitions = repetitions + 1;

      case SrsRating.good:
        // Ease stays the same
        if (repetitions == 0) {
          newInterval = SrsConstants.goodIntervalDays;
        } else {
          newInterval = (currentIntervalDays * currentEase).round();
          if (newInterval < SrsConstants.goodIntervalDays) {
            newInterval = SrsConstants.goodIntervalDays;
          }
        }
        newRepetitions = repetitions + 1;

      case SrsRating.easy:
        newEase = (currentEase + SrsConstants.easeIncreaseEasy)
            .clamp(SrsConstants.minEase, SrsConstants.maxEase);

        if (repetitions == 0) {
          newInterval = SrsConstants.easyIntervalDays;
        } else {
          newInterval = (currentIntervalDays *
                  currentEase *
                  SrsConstants.easyBonusMultiplier)
              .round();
          if (newInterval < SrsConstants.easyIntervalDays) {
            newInterval = SrsConstants.easyIntervalDays;
          }
        }
        newRepetitions = repetitions + 1;
    }

    // Determine status
    final totalReviews = correctCount + wrongCount + 1;
    final totalCorrect =
        correctCount + (rating != SrsRating.again ? 1 : 0);
    final accuracy = totalReviews > 0 ? totalCorrect / totalReviews : 0.0;

    String newStatus;
    if (newInterval >= 21 && accuracy >= 0.85 && newRepetitions >= 3) {
      newStatus = 'mastered';
    } else if (newRepetitions > 0) {
      newStatus = 'reviewing';
    } else {
      newStatus = 'learning';
    }

    return SrsResult(
      newEase: newEase,
      newIntervalDays: newInterval,
      newRepetitions: newRepetitions,
      nextReviewAt: AppDateUtils.nextReviewDate(newInterval),
      newStatus: newStatus,
    );
  }
}
