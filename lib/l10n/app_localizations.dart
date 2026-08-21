import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Kanji Lesson'**
  String get appName;

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'こんにちは'**
  String get greeting;

  /// No description provided for @readyToLearn.
  ///
  /// In en, this message translates to:
  /// **'Ready to learn some Kanji?'**
  String get readyToLearn;

  /// No description provided for @todaysGoal.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Goal'**
  String get todaysGoal;

  /// No description provided for @goalCompleted.
  ///
  /// In en, this message translates to:
  /// **'🎉 Goal completed!'**
  String get goalCompleted;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review;

  /// No description provided for @kanji.
  ///
  /// In en, this message translates to:
  /// **'Kanji'**
  String get kanji;

  /// No description provided for @weakKanji.
  ///
  /// In en, this message translates to:
  /// **'Weak Kanji'**
  String get weakKanji;

  /// No description provided for @continueLearning.
  ///
  /// In en, this message translates to:
  /// **'Continue Learning'**
  String get continueLearning;

  /// No description provided for @jlptProgress.
  ///
  /// In en, this message translates to:
  /// **'JLPT Progress'**
  String get jlptProgress;

  /// No description provided for @learned.
  ///
  /// In en, this message translates to:
  /// **'learned'**
  String get learned;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @learning.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get learning;

  /// No description provided for @mastered.
  ///
  /// In en, this message translates to:
  /// **'Mastered'**
  String get mastered;

  /// No description provided for @strokes.
  ///
  /// In en, this message translates to:
  /// **'strokes'**
  String get strokes;

  /// No description provided for @meaning.
  ///
  /// In en, this message translates to:
  /// **'Meaning'**
  String get meaning;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @vocabulary.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary'**
  String get vocabulary;

  /// No description provided for @addToReview.
  ///
  /// In en, this message translates to:
  /// **'Add to Review'**
  String get addToReview;

  /// No description provided for @markKnown.
  ///
  /// In en, this message translates to:
  /// **'Mark Known'**
  String get markKnown;

  /// No description provided for @kanjiAddedToReview.
  ///
  /// In en, this message translates to:
  /// **'{kanji} added to review'**
  String kanjiAddedToReview(String kanji);

  /// No description provided for @kanjiMarkedKnown.
  ///
  /// In en, this message translates to:
  /// **'{kanji} marked as known'**
  String kanjiMarkedKnown(String kanji);

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @accentColor.
  ///
  /// In en, this message translates to:
  /// **'Accent Color'**
  String get accentColor;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language / Bahasa'**
  String get language;

  /// No description provided for @dailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily Goal'**
  String get dailyGoal;

  /// No description provided for @currentGoal.
  ///
  /// In en, this message translates to:
  /// **'Current goal: {count} correct answers'**
  String currentGoal(int count);

  /// No description provided for @dailyReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily Reminder'**
  String get dailyReminder;

  /// No description provided for @reminderSetFor.
  ///
  /// In en, this message translates to:
  /// **'Reminder set for {time}'**
  String reminderSetFor(String time);

  /// No description provided for @turnOnToGetReminded.
  ///
  /// In en, this message translates to:
  /// **'Turn on to get reminded to study'**
  String get turnOnToGetReminded;

  /// No description provided for @notificationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Notification permission denied'**
  String get notificationPermissionDenied;

  /// No description provided for @changeReminderTime.
  ///
  /// In en, this message translates to:
  /// **'Change Reminder Time'**
  String get changeReminderTime;

  /// No description provided for @sound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get sound;

  /// No description provided for @vibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get vibration;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @resetLearningProgress.
  ///
  /// In en, this message translates to:
  /// **'Reset Learning Progress'**
  String get resetLearningProgress;

  /// No description provided for @clearProgressSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Clear progress for all or specific JLPT levels'**
  String get clearProgressSubtitle;

  /// No description provided for @resetAllData.
  ///
  /// In en, this message translates to:
  /// **'Reset ALL Data (Danger)'**
  String get resetAllData;

  /// No description provided for @deleteAllProgressSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Deletes ALL progress, history, and cached data'**
  String get deleteAllProgressSubtitle;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @resetProgressDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Progress?'**
  String get resetProgressDialogTitle;

  /// No description provided for @resetProgressDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Do you want to reset progress for a specific JLPT level or all levels? This action cannot be undone.'**
  String get resetProgressDialogContent;

  /// No description provided for @allLevels.
  ///
  /// In en, this message translates to:
  /// **'All Levels'**
  String get allLevels;

  /// No description provided for @progressResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Progress reset successfully'**
  String get progressResetSuccess;

  /// No description provided for @dangerZoneResetTitle.
  ///
  /// In en, this message translates to:
  /// **'RESET ALL DATA'**
  String get dangerZoneResetTitle;

  /// No description provided for @dangerZoneResetContent.
  ///
  /// In en, this message translates to:
  /// **'Are you absolutely sure you want to delete ALL data? This includes your streaks, custom settings, and learning progress. This action is PERMANENT.'**
  String get dangerZoneResetContent;

  /// No description provided for @quizSetup.
  ///
  /// In en, this message translates to:
  /// **'Quiz Setup'**
  String get quizSetup;

  /// No description provided for @startQuiz.
  ///
  /// In en, this message translates to:
  /// **'Start Quiz'**
  String get startQuiz;

  /// No description provided for @jlptLevel.
  ///
  /// In en, this message translates to:
  /// **'JLPT Level'**
  String get jlptLevel;

  /// No description provided for @numberOfQuestions.
  ///
  /// In en, this message translates to:
  /// **'Number of Questions'**
  String get numberOfQuestions;

  /// No description provided for @itemType.
  ///
  /// In en, this message translates to:
  /// **'Item Type'**
  String get itemType;

  /// No description provided for @questionType.
  ///
  /// In en, this message translates to:
  /// **'Question Type'**
  String get questionType;

  /// No description provided for @multipleChoice.
  ///
  /// In en, this message translates to:
  /// **'Multiple Choice'**
  String get multipleChoice;

  /// No description provided for @typing.
  ///
  /// In en, this message translates to:
  /// **'Typing'**
  String get typing;

  /// No description provided for @reading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get reading;

  /// No description provided for @quiz.
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get quiz;

  /// No description provided for @quitQuiz.
  ///
  /// In en, this message translates to:
  /// **'Quit Quiz'**
  String get quitQuiz;

  /// No description provided for @quitQuizConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to quit? Your current progress will be lost.'**
  String get quitQuizConfirm;

  /// No description provided for @quit.
  ///
  /// In en, this message translates to:
  /// **'Quit'**
  String get quit;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @quizResult.
  ///
  /// In en, this message translates to:
  /// **'Quiz Result'**
  String get quizResult;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// No description provided for @correct.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get correct;

  /// No description provided for @incorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect'**
  String get incorrect;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// No description provided for @selectSource.
  ///
  /// In en, this message translates to:
  /// **'Select Source'**
  String get selectSource;

  /// No description provided for @myLearned.
  ///
  /// In en, this message translates to:
  /// **'My Learned'**
  String get myLearned;

  /// No description provided for @sentence.
  ///
  /// In en, this message translates to:
  /// **'Sentence'**
  String get sentence;

  /// No description provided for @writing.
  ///
  /// In en, this message translates to:
  /// **'Writing'**
  String get writing;

  /// No description provided for @questionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Questions'**
  String questionsCount(int count);

  /// No description provided for @maxItems.
  ///
  /// In en, this message translates to:
  /// **'Max: {max} items'**
  String maxItems(int max);

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @notEnoughItemsError.
  ///
  /// In en, this message translates to:
  /// **'Not enough items in the selected source for the chosen types.'**
  String get notEnoughItemsError;

  /// No description provided for @whatShallWeLearnToday.
  ///
  /// In en, this message translates to:
  /// **'What shall we learn today?'**
  String get whatShallWeLearnToday;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @trackYourProgressAcrossLevels.
  ///
  /// In en, this message translates to:
  /// **'Track your progress across levels'**
  String get trackYourProgressAcrossLevels;

  /// No description provided for @todaysGoalComplete.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Goal — Complete ✓'**
  String get todaysGoalComplete;

  /// No description provided for @moreToComplete.
  ///
  /// In en, this message translates to:
  /// **'{remaining} more to complete today\'s goal'**
  String moreToComplete(int remaining);

  /// No description provided for @reviewDashboard.
  ///
  /// In en, this message translates to:
  /// **'Review Dashboard'**
  String get reviewDashboard;

  /// No description provided for @reviewsDue.
  ///
  /// In en, this message translates to:
  /// **'{count} Reviews Due'**
  String reviewsDue(int count);

  /// No description provided for @noReviewsDue.
  ///
  /// In en, this message translates to:
  /// **'No Reviews Due'**
  String get noReviewsDue;

  /// No description provided for @timeToStrengthen.
  ///
  /// In en, this message translates to:
  /// **'Time to strengthen your memory!'**
  String get timeToStrengthen;

  /// No description provided for @youreAllCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up for now.'**
  String get youreAllCaughtUp;

  /// No description provided for @startReview.
  ///
  /// In en, this message translates to:
  /// **'Start Review'**
  String get startReview;

  /// No description provided for @learnNewItems.
  ///
  /// In en, this message translates to:
  /// **'Learn New Items'**
  String get learnNewItems;

  /// No description provided for @loadingReviews.
  ///
  /// In en, this message translates to:
  /// **'Loading reviews...'**
  String get loadingReviews;

  /// No description provided for @unableToLoadReviews.
  ///
  /// In en, this message translates to:
  /// **'Unable to load due reviews.'**
  String get unableToLoadReviews;

  /// No description provided for @kanjiOnly.
  ///
  /// In en, this message translates to:
  /// **'Kanji Only'**
  String get kanjiOnly;

  /// No description provided for @vocabOnly.
  ///
  /// In en, this message translates to:
  /// **'Vocab Only'**
  String get vocabOnly;

  /// No description provided for @mixed.
  ///
  /// In en, this message translates to:
  /// **'Mixed (Kanji & Vocab)'**
  String get mixed;

  /// No description provided for @anyLevel.
  ///
  /// In en, this message translates to:
  /// **'Any Level'**
  String get anyLevel;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @itemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Items'**
  String itemsCount(int count);

  /// No description provided for @startLearning.
  ///
  /// In en, this message translates to:
  /// **'Start Learning'**
  String get startLearning;

  /// No description provided for @noNewItemsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No new items available for this selection.'**
  String get noNewItemsAvailable;

  /// No description provided for @jlptLevels.
  ///
  /// In en, this message translates to:
  /// **'JLPT Levels'**
  String get jlptLevels;

  /// No description provided for @learnedCount.
  ///
  /// In en, this message translates to:
  /// **'{learned} / {total} learned'**
  String learnedCount(int learned, int total);

  /// No description provided for @practiceRandom.
  ///
  /// In en, this message translates to:
  /// **'Practice Random'**
  String get practiceRandom;

  /// No description provided for @searchKanjiHint.
  ///
  /// In en, this message translates to:
  /// **'Search kanji, reading, or meaning...'**
  String get searchKanjiHint;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterKanji.
  ///
  /// In en, this message translates to:
  /// **'Kanji'**
  String get filterKanji;

  /// No description provided for @filterVocab.
  ///
  /// In en, this message translates to:
  /// **'Vocab'**
  String get filterVocab;

  /// No description provided for @filterLearning.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get filterLearning;

  /// No description provided for @filterMastered.
  ///
  /// In en, this message translates to:
  /// **'Mastered'**
  String get filterMastered;

  /// No description provided for @noItemsFound.
  ///
  /// In en, this message translates to:
  /// **'No items found'**
  String get noItemsFound;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @unableToLoadData.
  ///
  /// In en, this message translates to:
  /// **'Unable to load data.\nPlease check your internet connection.'**
  String get unableToLoadData;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
