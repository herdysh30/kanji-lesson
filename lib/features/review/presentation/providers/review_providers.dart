import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kanji_lesson/core/database/app_database.dart';
import 'package:kanji_lesson/features/kanji/presentation/providers/kanji_providers.dart';
import 'package:kanji_lesson/features/kanji/presentation/providers/jlpt_vocab_providers.dart';
import 'package:kanji_lesson/features/settings/presentation/providers/settings_providers.dart';

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

class ReviewItemDetail {
  const ReviewItemDetail({
    required this.text,
    required this.isVocab,
    this.primaryReading,
    this.primaryMeaning,
    this.onyomi,
    this.kunyomi,
    this.furigana,
    this.romaji,
  });

  final String text;
  final bool isVocab;
  final String? primaryReading;
  final String? primaryMeaning;
  final List<String>? onyomi;
  final List<String>? kunyomi;
  final String? furigana;
  final String? romaji;
}

final reviewItemDetailProvider = FutureProvider.family<ReviewItemDetail, String>((ref, text) async {
  final vocabRepo = ref.read(jlptVocabRepositoryProvider);
  final kanjiRepo = ref.read(kanjiRepositoryProvider);
  
  if (text.length > 1) {
    // Must be vocab
    final vocab = await vocabRepo.getVocabByWord(text);
    if (vocab != null) {
      final isId = ref.read(localeProvider).languageCode == 'id';
      return ReviewItemDetail(
        text: vocab.word,
        isVocab: true,
        primaryMeaning: vocab.primaryMeaning(isId),
        furigana: vocab.furigana,
        romaji: vocab.romaji,
      );
    }
  }

  // Could be 1-char Vocab or Kanji
  try {
    final kanji = await kanjiRepo.getKanjiDetail(text);
    final isId = ref.read(localeProvider).languageCode == 'id';
    return ReviewItemDetail(
      text: kanji.character,
      isVocab: false,
      primaryReading: kanji.primaryReading,
      primaryMeaning: kanji.primaryMeaning(isId),
      onyomi: kanji.onyomi,
      kunyomi: kanji.kunyomi,
    );
  } catch (_) {
    // Fallback to vocab
    final vocab = await vocabRepo.getVocabByWord(text);
    if (vocab != null) {
      final isId = ref.read(localeProvider).languageCode == 'id';
      return ReviewItemDetail(
        text: vocab.word,
        isVocab: true,
        primaryMeaning: vocab.primaryMeaning(isId),
        furigana: vocab.furigana,
        romaji: vocab.romaji,
      );
    }
    throw Exception('Failed to load detail for $text');
  }
});
