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
  String get greeting => 'Hello 👋';

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
  String get strokes => 'strokes';

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
}
