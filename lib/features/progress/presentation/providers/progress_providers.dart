import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kanji_lesson/core/database/app_database.dart';
import 'package:kanji_lesson/core/utils/date_utils.dart';
import 'package:kanji_lesson/features/kanji/presentation/providers/kanji_providers.dart';

// ─── Progress Providers ─────────────────────────────────────────

final dailyStatsProvider = FutureProvider<DailyProgressEntry?>((ref) async {
  final db = ref.watch(databaseProvider);
  final today = AppDateUtils.todayString();
  return db.getDailyProgress(today);
});

final weakKanjiCountProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(databaseProvider);
  final weak = await db.getWeakKanji();
  // Consider weak if accuracy is < 60% and has been reviewed
  return weak.where((k) {
    final total = k.correctCount + k.wrongCount;
    if (total == 0) return false;
    return (k.correctCount / total) < 0.60;
  }).length;
});

final overallProgressProvider = FutureProvider<OverallProgress>((ref) async {
  final db = ref.watch(databaseProvider);

  final summary = await db.getProgressSummary();

  final total = summary.totalCorrect + summary.totalWrong;

  return OverallProgress(
    totalLearned: summary.learned,
    mastered: summary.mastered,
    reviewing: summary.reviewing,
    accuracy: total > 0 ? summary.totalCorrect / total : 0.0,
  );
});

class OverallProgress {
  const OverallProgress({
    required this.totalLearned,
    required this.mastered,
    required this.reviewing,
    required this.accuracy,
  });
  
  final int totalLearned;
  final int mastered;
  final int reviewing;
  final double accuracy;
}

// ─── Weekly Activity Provider ───────────────────────────────────

final weeklyActivityProvider = FutureProvider<List<DailyActivity>>((ref) async {
  final db = ref.watch(databaseProvider);
  final recentProgress = await db.getRecentDailyProgress(7);
  
  // Build a map of the last 7 days
  final now = DateTime.now();
  final result = <DailyActivity>[];
  
  for (int i = 6; i >= 0; i--) {
    final date = now.subtract(Duration(days: i));
    final dateStr = AppDateUtils.formatDate(date);
    
    final entry = recentProgress.where((e) => e.date == dateStr).firstOrNull;
    
    result.add(DailyActivity(
      date: date,
      dateStr: dateStr,
      reviewed: entry != null ? (entry.newKanjiCount + entry.reviewedKanjiCount) : 0,
      correct: entry?.correctAnswers ?? 0,
      wrong: entry?.wrongAnswers ?? 0,
    ));
  }
  
  return result;
});

class DailyActivity {
  const DailyActivity({
    required this.date,
    required this.dateStr,
    required this.reviewed,
    required this.correct,
    required this.wrong,
  });
  
  final DateTime date;
  final String dateStr;
  final int reviewed;
  final int correct;
  final int wrong;
  
  int get total => correct + wrong;
  double get accuracy => total > 0 ? correct / total : 0.0;
}

// ─── Quiz History Provider ──────────────────────────────────────

final quizHistoryProvider = FutureProvider<List<QuizResultEntry>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.getRecentQuizResults(10);
});

// ─── Study Streak Provider ──────────────────────────────────────

final studyStreakProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(databaseProvider);
  final recentProgress = await db.getRecentDailyProgress(365);
  final dates = recentProgress
      .where((e) => (e.newKanjiCount + e.reviewedKanjiCount) > 0)
      .map((e) => e.date)
      .toList();
  return AppDateUtils.calculateStreak(dates);
});

// ─── Streak Dates Provider ──────────────────────────────────────

final streakDatesProvider = FutureProvider<List<DateTime>>((ref) async {
  final db = ref.watch(databaseProvider);
  final recentProgress = await db.getRecentDailyProgress(365);
  final datesStr = recentProgress
      .where((e) => (e.newKanjiCount + e.reviewedKanjiCount) > 0)
      .map((e) => e.date)
      .toList();
  return datesStr.map((s) => DateTime.parse(s)).toList();
});

// ─── Progress List Provider ──────────────────────────────────────

final progressListProvider = FutureProvider.family<List<UserKanjiProgressEntry>, String?>((ref, status) async {
  final db = ref.watch(databaseProvider);
  if (status == null || status == 'learned') {
    final all = await db.getAllProgress();
    return all.where((e) => e.status != 'unseen').toList();
  }
  return db.getProgressByStatus(status);
});

// ─── Weak Kanji List Provider (Full Data) ───────────────────────

final weakKanjiListProvider = FutureProvider<List<WeakItem>>((ref) async {
  final db = ref.watch(databaseProvider);
  final allWeak = await db.getWeakKanji();

  final weakProgress = allWeak.where((p) {
    final total = p.correctCount + p.wrongCount;
    if (total == 0) return false;
    return (p.correctCount / total) < 0.60;
  }).toList();

  if (weakProgress.isEmpty) return [];

  final characters = weakProgress.map((p) => p.kanjiCharacter).toList();
  final kanjiMap = {
    for (final k in await db.getKanjiByCharacters(characters)) k.character: k,
  };
  final vocabGroups = <String, List<VocabularyEntry>>{};
  for (final v in await db.getVocabularyForCharacters(characters)) {
    vocabGroups.putIfAbsent(v.kanjiCharacter, () => []).add(v);
  }

  final result = <WeakItem>[];
  for (final progress in weakProgress) {
    final total = progress.correctCount + progress.wrongCount;
    final accuracy = progress.correctCount / total;

    String? meaning;
    String? reading;
    bool isVocab = false;

    final kanjiData = kanjiMap[progress.kanjiCharacter];
    if (kanjiData != null) {
      final meanings = kanjiData.meanings;
      meaning = meanings.isNotEmpty ? meanings.replaceAll(RegExp(r'[\[\]"]'), '').split(',').first.trim() : null;
      reading = kanjiData.onyomi.isNotEmpty ? kanjiData.onyomi.replaceAll(RegExp(r'[\[\]"]'), '').split(',').first.trim() : null;
    } else {
      isVocab = true;
      final vocabEntries = vocabGroups[progress.kanjiCharacter];
      if (vocabEntries != null && vocabEntries.isNotEmpty) {
        meaning = vocabEntries.first.meanings.replaceAll(RegExp(r'[\[\]"]'), '').split(',').first.trim();
        reading = vocabEntries.first.reading;
      }
    }

    result.add(WeakItem(
      character: progress.kanjiCharacter,
      correctCount: progress.correctCount,
      wrongCount: progress.wrongCount,
      accuracy: accuracy,
      meaning: meaning,
      reading: reading,
      isVocab: isVocab,
      status: progress.status,
      lastReviewedAt: progress.lastReviewedAt,
    ));
  }

  result.sort((a, b) => a.accuracy.compareTo(b.accuracy));

  return result;
});

class WeakItem {
  const WeakItem({
    required this.character,
    required this.correctCount,
    required this.wrongCount,
    required this.accuracy,
    this.meaning,
    this.reading,
    this.isVocab = false,
    required this.status,
    this.lastReviewedAt,
  });
  
  final String character;
  final int correctCount;
  final int wrongCount;
  final double accuracy;
  final String? meaning;
  final String? reading;
  final bool isVocab;
  final String status;
  final DateTime? lastReviewedAt;
  
  int get totalAttempts => correctCount + wrongCount;
  String get accuracyPercent => '${(accuracy * 100).round()}%';
}
