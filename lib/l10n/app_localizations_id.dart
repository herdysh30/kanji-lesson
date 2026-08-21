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
  String get greeting => 'こんにちは';

  @override
  String get readyToLearn => 'Siap untuk belajar Kanji?';

  @override
  String get todaysGoal => 'Target Harian';

  @override
  String get goalCompleted => '🎉 Target tercapai!';

  @override
  String get review => 'Ulas';

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

  @override
  String get accentColor => 'Warna Aksen';

  @override
  String get language => 'Bahasa / Language';

  @override
  String get dailyGoal => 'Target Harian';

  @override
  String currentGoal(int count) {
    return 'Target saat ini: $count jawaban benar';
  }

  @override
  String get dailyReminder => 'Pengingat Harian';

  @override
  String reminderSetFor(String time) {
    return 'Pengingat diatur untuk $time';
  }

  @override
  String get turnOnToGetReminded => 'Nyalakan untuk pengingat belajar';

  @override
  String get notificationPermissionDenied => 'Izin notifikasi ditolak';

  @override
  String get changeReminderTime => 'Ubah Waktu Pengingat';

  @override
  String get sound => 'Suara';

  @override
  String get vibration => 'Getar';

  @override
  String get theme => 'Tema';

  @override
  String get system => 'Sistem';

  @override
  String get light => 'Terang';

  @override
  String get dark => 'Gelap';

  @override
  String get resetLearningProgress => 'Atur Ulang Progres Belajar';

  @override
  String get clearProgressSubtitle =>
      'Hapus progres untuk semua atau tingkat JLPT tertentu';

  @override
  String get resetAllData => 'Hapus SEMUA Data (Bahaya)';

  @override
  String get deleteAllProgressSubtitle =>
      'Menghapus SEMUA progres, riwayat, dan data cache';

  @override
  String get cancel => 'Batal';

  @override
  String get reset => 'Atur Ulang';

  @override
  String get resetProgressDialogTitle => 'Atur Ulang Progres?';

  @override
  String get resetProgressDialogContent =>
      'Apakah Anda ingin mengatur ulang progres untuk tingkat JLPT tertentu atau semua tingkat? Tindakan ini tidak dapat dibatalkan.';

  @override
  String get allLevels => 'Semua Tingkat';

  @override
  String get progressResetSuccess => 'Progres berhasil diatur ulang';

  @override
  String get dangerZoneResetTitle => 'HAPUS SEMUA DATA';

  @override
  String get dangerZoneResetContent =>
      'Apakah Anda benar-benar yakin ingin menghapus SEMUA data? Ini termasuk streak, pengaturan kustom, dan progres belajar Anda. Tindakan ini PERMANEN.';

  @override
  String get quizSetup => 'Persiapan Kuis';

  @override
  String get startQuiz => 'Mulai Kuis';

  @override
  String get jlptLevel => 'Level JLPT';

  @override
  String get numberOfQuestions => 'Jumlah Pertanyaan';

  @override
  String get itemType => 'Jenis Item';

  @override
  String get questionType => 'Jenis Pertanyaan';

  @override
  String get multipleChoice => 'Pilihan Ganda';

  @override
  String get typing => 'Mengetik';

  @override
  String get reading => 'Cara Baca';

  @override
  String get quiz => 'Kuis';

  @override
  String get quitQuiz => 'Keluar Kuis';

  @override
  String get quitQuizConfirm =>
      'Apakah Anda yakin ingin keluar? Progres Anda saat ini akan hilang.';

  @override
  String get quit => 'Keluar';

  @override
  String get next => 'Selanjutnya';

  @override
  String get finish => 'Selesai';

  @override
  String get quizResult => 'Hasil Kuis';

  @override
  String get score => 'Skor';

  @override
  String get correct => 'Benar';

  @override
  String get incorrect => 'Salah';

  @override
  String get backToHome => 'Kembali ke Beranda';

  @override
  String get streak => 'Streak';

  @override
  String get selectSource => 'Pilih Sumber';

  @override
  String get myLearned => 'Telah Dipelajari';

  @override
  String get sentence => 'Kalimat';

  @override
  String get writing => 'Menulis';

  @override
  String questionsCount(int count) {
    return '$count Pertanyaan';
  }

  @override
  String maxItems(int max) {
    return 'Maks: $max item';
  }

  @override
  String get custom => 'Khusus';

  @override
  String get notEnoughItemsError =>
      'Tidak cukup item pada sumber dan jenis yang dipilih.';

  @override
  String get whatShallWeLearnToday => 'Apa yang ingin kita pelajari hari ini?';

  @override
  String get progress => 'Progres';

  @override
  String get trackYourProgressAcrossLevels =>
      'Pantau progres belajarmu di berbagai level';

  @override
  String get todaysGoalComplete => 'Target Harian — Selesai ✓';

  @override
  String moreToComplete(int remaining) {
    return '$remaining lagi untuk menyelesaikan target harian';
  }

  @override
  String get reviewDashboard => 'Dasbor Ulasan';

  @override
  String reviewsDue(int count) {
    return 'Ada $count Ulasan';
  }

  @override
  String get noReviewsDue => 'Tidak Ada Ulasan';

  @override
  String get timeToStrengthen => 'Waktunya memperkuat ingatanmu!';

  @override
  String get youreAllCaughtUp => 'Semua ulasan sudah selesai untuk saat ini.';

  @override
  String get startReview => 'Mulai Ulasan';

  @override
  String get learnNewItems => 'Pelajari Item Baru';

  @override
  String get loadingReviews => 'Memuat ulasan...';

  @override
  String get unableToLoadReviews => 'Gagal memuat ulasan.';

  @override
  String get kanjiOnly => 'Hanya Kanji';

  @override
  String get vocabOnly => 'Hanya Kosakata';

  @override
  String get mixed => 'Campuran (Kanji & Kosakata)';

  @override
  String get anyLevel => 'Semua Level';

  @override
  String get amount => 'Jumlah';

  @override
  String itemsCount(int count) {
    return '$count Item';
  }

  @override
  String get startLearning => 'Mulai Belajar';

  @override
  String get noNewItemsAvailable =>
      'Tidak ada item baru yang tersedia untuk pilihan ini.';

  @override
  String get jlptLevels => 'Level JLPT';

  @override
  String learnedCount(int learned, int total) {
    return '$learned / $total dipelajari';
  }

  @override
  String get practiceRandom => 'Latihan Acak';

  @override
  String get searchKanjiHint => 'Cari kanji, bacaan, atau arti...';

  @override
  String get filterAll => 'Semua';

  @override
  String get filterKanji => 'Kanji';

  @override
  String get filterVocab => 'Kosakata';

  @override
  String get filterLearning => 'Sedang Dipelajari';

  @override
  String get filterMastered => 'Dikuasai';

  @override
  String get noItemsFound => 'Tidak ada item ditemukan';

  @override
  String get loading => 'Memuat...';

  @override
  String get unableToLoadData =>
      'Gagal memuat data.\nPeriksa koneksi internet Anda.';
}
