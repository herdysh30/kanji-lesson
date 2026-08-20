import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kanji_lesson/core/database/app_database.dart';
import 'package:kanji_lesson/features/kanji/presentation/providers/kanji_providers.dart';

// ─── Review Providers ───────────────────────────────────────────

final dueReviewCountProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(databaseProvider);
  final dueReviews = await db.getDueReviews(DateTime.now());
  return dueReviews.length;
});

final dueReviewsProvider = FutureProvider<List<UserKanjiProgressEntry>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.getDueReviews(DateTime.now());
});
