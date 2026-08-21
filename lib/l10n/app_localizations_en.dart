// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Kanji Lesson';

  @override
  String get greeting => 'こんにちは';

  @override
  String get readyToLearn => 'Ready to learn some Kanji?';

  @override
  String get todaysGoal => 'Today\'s Goal';

  @override
  String get goalCompleted => '🎉 Goal completed!';

  @override
  String get review => 'Review';

  @override
  String get kanji => 'Kanji';

  @override
  String get weakKanji => 'Weak Kanji';

  @override
  String get continueLearning => 'Continue Learning';

  @override
  String get jlptProgress => 'JLPT Progress';

  @override
  String get learned => 'learned';

  @override
  String get all => 'All';

  @override
  String get learning => 'Learning';

  @override
  String get mastered => 'Mastered';

  @override
  String get strokes => 'Strokes';

  @override
  String get meaning => 'Meaning';

  @override
  String get info => 'Info';

  @override
  String get vocabulary => 'Vocabulary';

  @override
  String get addToReview => 'Add to Review';

  @override
  String get markKnown => 'Mark Known';

  @override
  String kanjiAddedToReview(String kanji) {
    return '$kanji added to review';
  }

  @override
  String kanjiMarkedKnown(String kanji) {
    return '$kanji marked as known';
  }

  @override
  String get settings => 'Settings';

  @override
  String get accentColor => 'Accent Color';

  @override
  String get language => 'Language / Bahasa';

  @override
  String get dailyGoal => 'Daily Goal';

  @override
  String currentGoal(int count) {
    return 'Current goal: $count correct answers';
  }

  @override
  String get dailyReminder => 'Daily Reminder';

  @override
  String reminderSetFor(String time) {
    return 'Reminder set for $time';
  }

  @override
  String get turnOnToGetReminded => 'Turn on to get reminded to study';

  @override
  String get notificationPermissionDenied => 'Notification permission denied';

  @override
  String get changeReminderTime => 'Change Reminder Time';

  @override
  String get sound => 'Sound';

  @override
  String get vibration => 'Vibration';

  @override
  String get theme => 'Theme';

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get resetLearningProgress => 'Reset Learning Progress';

  @override
  String get clearProgressSubtitle =>
      'Clear progress for all or specific JLPT levels';

  @override
  String get resetAllData => 'Reset ALL Data (Danger)';

  @override
  String get deleteAllProgressSubtitle =>
      'Deletes ALL progress, history, and cached data';

  @override
  String get cancel => 'Cancel';

  @override
  String get reset => 'Reset';

  @override
  String get resetProgressDialogTitle => 'Reset Progress?';

  @override
  String get resetProgressDialogContent =>
      'Do you want to reset progress for a specific JLPT level or all levels? This action cannot be undone.';

  @override
  String get allLevels => 'All Levels';

  @override
  String get progressResetSuccess => 'Progress reset successfully';

  @override
  String get dangerZoneResetTitle => 'RESET ALL DATA';

  @override
  String get dangerZoneResetContent =>
      'Are you absolutely sure you want to delete ALL data? This includes your streaks, custom settings, and learning progress. This action is PERMANENT.';

  @override
  String get quizSetup => 'Quiz Setup';

  @override
  String get startQuiz => 'Start Quiz';

  @override
  String get jlptLevel => 'JLPT Level';

  @override
  String get numberOfQuestions => 'Number of Questions';

  @override
  String get itemType => 'Item Type';

  @override
  String get questionType => 'Question Type';

  @override
  String get multipleChoice => 'Multiple Choice';

  @override
  String get typing => 'Typing';

  @override
  String get reading => 'Reading';

  @override
  String get quiz => 'Quiz';

  @override
  String get quitQuiz => 'Quit Quiz';

  @override
  String get quitQuizConfirm =>
      'Are you sure you want to quit? Your current progress will be lost.';

  @override
  String get quit => 'Quit';

  @override
  String get next => 'Next';

  @override
  String get finish => 'Finish';

  @override
  String get quizResult => 'Quiz Result';

  @override
  String get score => 'Score';

  @override
  String get correct => 'Correct';

  @override
  String get incorrect => 'Incorrect';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get streak => 'Streak';

  @override
  String get selectSource => 'Select Source';

  @override
  String get myLearned => 'My Learned';

  @override
  String get sentence => 'Sentence';

  @override
  String get writing => 'Writing';

  @override
  String questionsCount(int count) {
    return '$count Questions';
  }

  @override
  String maxItems(int max) {
    return 'Max: $max items';
  }

  @override
  String get custom => 'Custom';

  @override
  String get notEnoughItemsError =>
      'Not enough items in the selected source for the chosen types.';

  @override
  String get whatShallWeLearnToday => 'What shall we learn today?';

  @override
  String get progress => 'Progress';

  @override
  String get trackYourProgressAcrossLevels =>
      'Track your progress across levels';

  @override
  String get todaysGoalComplete => 'Today\'s Goal — Complete ✓';

  @override
  String moreToComplete(int remaining) {
    return '$remaining more to complete today\'s goal';
  }

  @override
  String get reviewDashboard => 'Review Dashboard';

  @override
  String reviewsDue(int count) {
    return '$count Reviews Due';
  }

  @override
  String get noReviewsDue => 'No Reviews Due';

  @override
  String get timeToStrengthen => 'Time to strengthen your memory!';

  @override
  String get youreAllCaughtUp => 'You\'re all caught up for now.';

  @override
  String get startReview => 'Start Review';

  @override
  String get learnNewItems => 'Learn New Items';

  @override
  String get loadingReviews => 'Loading reviews...';

  @override
  String get unableToLoadReviews => 'Unable to load due reviews.';

  @override
  String get kanjiOnly => 'Kanji Only';

  @override
  String get vocabOnly => 'Vocab Only';

  @override
  String get mixed => 'Mixed (Kanji & Vocab)';

  @override
  String get anyLevel => 'Any Level';

  @override
  String get amount => 'Amount';

  @override
  String itemsCount(int count) {
    return '$count Items';
  }

  @override
  String get startLearning => 'Start Learning';

  @override
  String get noNewItemsAvailable =>
      'No new items available for this selection.';

  @override
  String get jlptLevels => 'JLPT Levels';

  @override
  String learnedCount(int learned, int total) {
    return '$learned / $total learned';
  }

  @override
  String get practiceRandom => 'Practice Random';

  @override
  String get searchKanjiHint => 'Search kanji, reading, or meaning...';

  @override
  String get filterAll => 'All';

  @override
  String get filterKanji => 'Kanji';

  @override
  String get filterVocab => 'Vocab';

  @override
  String get filterLearning => 'Learning';

  @override
  String get filterMastered => 'Mastered';

  @override
  String get noItemsFound => 'No items found';

  @override
  String get loading => 'Loading...';

  @override
  String get unableToLoadData =>
      'Unable to load data.\nPlease check your internet connection.';

  @override
  String get onyomi => 'Onyomi';

  @override
  String get kunyomi => 'Kunyomi';

  @override
  String get details => 'Details';

  @override
  String get grade => 'Grade';

  @override
  String get jlpt => 'JLPT';

  @override
  String get frequency => 'Frequency';

  @override
  String get action => 'Action';

  @override
  String get learnThisKanji =>
      'Learn this Kanji to start tracking its progress.';

  @override
  String get practiceWriting => 'Practice Writing';

  @override
  String get nextReview => 'Next Review';

  @override
  String get stage => 'Stage';

  @override
  String get failedToLoadDetails => 'Failed to load details';

  @override
  String get vocabularyDetail => 'Vocabulary Detail';

  @override
  String get exampleSentences => 'Example Sentences';

  @override
  String get noExampleSentences => 'No example sentences available.';

  @override
  String get failedToLoadExamples => 'Failed to load examples.';

  @override
  String get failedToLoadVocabulary => 'Failed to load vocabulary';
}
