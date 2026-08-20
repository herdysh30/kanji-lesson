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
  
  final allProgress = await db.getAllProgress();
  
  int learned = 0;
  int mastered = 0;
  int reviewing = 0;
  
  for (var p in allProgress) {
    if (p.status == 'mastered') {
      mastered++;
      learned++;
    } else if (p.status == 'reviewing' || p.status == 'learning') {
      reviewing++;
      learned++;
    }
  }
  
  return OverallProgress(
    totalLearned: learned,
    mastered: mastered,
    reviewing: reviewing,
    accuracy: _calculateOverallAccuracy(allProgress),
  );
});

double _calculateOverallAccuracy(List<UserKanjiProgressEntry> progress) {
  int correct = 0;
  int total = 0;
  for (var p in progress) {
    correct += p.correctCount;
    total += p.correctCount + p.wrongCount;
  }
  return total > 0 ? correct / total : 0.0;
}

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
