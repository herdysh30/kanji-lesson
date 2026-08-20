// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appName => 'Kanji Lesson';

  @override
  String get greeting => 'Halo 👋';

  @override
  String get readyToLearn => 'Siap untuk belajar Kanji?';

  @override
  String get todaysGoal => 'Target Hari Ini';

  @override
  String get goalCompleted => '🎉 Target tercapai!';

  @override
  String get review => 'Ulasan';

  @override
  String get kanji => 'Kanji';

  @override
  String get weakKanji => 'Kanji Lemah';

  @override
  String get continueLearning => 'Lanjut Belajar';

  @override
  String get jlptProgress => 'Progres JLPT';

  @override
  String get learned => 'dipelajari';

  @override
  String get all => 'Semua';

  @override
  String get learning => 'Belajar';

  @override
  String get mastered => 'Dikuasai';

  @override
  String get strokes => 'coretan';

  @override
  String get meaning => 'Arti';

  @override
  String get info => 'Info';

  @override
  String get vocabulary => 'Kosakata';

  @override
  String get addToReview => 'Tambah ke Ulasan';

  @override
  String get markKnown => 'Tandai Tahu';

  @override
  String kanjiAddedToReview(String kanji) {
    return '$kanji ditambahkan ke ulasan';
  }

  @override
  String kanjiMarkedKnown(String kanji) {
    return '$kanji ditandai sudah tahu';
  }

  @override
  String get settings => 'Pengaturan';
}
