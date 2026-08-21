import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kanji_lesson/core/constants/app_constants.dart';
import 'package:kanji_lesson/core/database/app_database.dart';
import 'package:kanji_lesson/core/network/dio_client.dart';
import 'package:kanji_lesson/core/services/translation_service.dart';
import 'package:kanji_lesson/features/kanji/data/datasources/kanji_local_data_source.dart';
import 'package:kanji_lesson/features/settings/presentation/providers/settings_providers.dart';
import 'package:kanji_lesson/features/kanji/data/datasources/kanji_remote_data_source.dart';
import 'package:kanji_lesson/features/kanji/data/repositories/kanji_repository_impl.dart';
import 'package:kanji_lesson/features/kanji/domain/entities/kanji.dart';
import 'package:kanji_lesson/features/kanji/domain/entities/vocabulary.dart';
import 'package:kanji_lesson/features/kanji/domain/repositories/kanji_repository.dart';
import 'package:kanji_lesson/features/kanji/presentation/providers/jlpt_vocab_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kanji_lesson/features/kanji/data/datasources/kanji_alive_remote_data_source.dart';
import 'package:kanji_lesson/features/kanji/domain/entities/kanji_alive_data.dart';
import 'package:kanji_lesson/features/kanji/data/datasources/sentence_remote_data_source.dart';
import 'package:kanji_lesson/features/kanji/domain/entities/sentence.dart';

// ─── Core Providers ─────────────────────────────────────────────

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Must be overridden in ProviderScope');
});

// ─── Data Source Providers ──────────────────────────────────────

final translationServiceProvider = Provider<TranslationService>((ref) {
  return TranslationService(ref.watch(dioClientProvider).dio);
});

final kanjiRemoteDataSourceProvider = Provider<KanjiRemoteDataSource>((ref) {
  return KanjiRemoteDataSource(ref.watch(dioClientProvider));
});

final kanjiLocalDataSourceProvider = Provider<KanjiLocalDataSource>((ref) {
  return KanjiLocalDataSource(ref.watch(databaseProvider));
});

final sentenceRemoteDataSourceProvider = Provider<SentenceRemoteDataSource>((ref) {
  return SentenceRemoteDataSource(
    dio: ref.watch(dioClientProvider).dio,
    translationService: ref.watch(translationServiceProvider),
  );
});

// ─── Repository Providers ───────────────────────────────────────

final kanjiRepositoryProvider = Provider<KanjiRepository>((ref) {
  return KanjiRepositoryImpl(
    remoteDataSource: ref.watch(kanjiRemoteDataSourceProvider),
    localDataSource: ref.watch(kanjiLocalDataSourceProvider),
  );
});

// ─── Kanji List Provider ────────────────────────────────────────

final kanjiListProvider = FutureProvider.family<List<String>, int>(
  (ref, jlptLevel) async {
    final repo = ref.watch(kanjiRepositoryProvider);
    return repo.getKanjiListByJlpt(jlptLevel);
  },
);

// ─── Kanji Detail Provider ──────────────────────────────────────

final kanjiDetailProvider = FutureProvider.family<Kanji, String>(
  (ref, character) async {
    final repo = ref.watch(kanjiRepositoryProvider);
    final kanji = await repo.getKanjiDetail(character);

    final locale = ref.watch(localeProvider);
    if (locale.languageCode == 'id' && kanji.meaningsId.isEmpty && kanji.meanings.isNotEmpty) {
      final translator = ref.read(translationServiceProvider);
      final translated = await translator.translateMeanings(kanji.meanings);
      if (translated.isNotEmpty) {
        final newKanji = Kanji(
          character: kanji.character,
          jlptLevel: kanji.jlptLevel,
          meanings: kanji.meanings,
          meaningsId: translated,
          onyomi: kanji.onyomi,
          kunyomi: kanji.kunyomi,
          nameReadings: kanji.nameReadings,
          strokeCount: kanji.strokeCount,
          grade: kanji.grade,
          heisigKeyword: kanji.heisigKeyword,
          frequency: kanji.frequency,
          unicode: kanji.unicode,
        );
        final localDataSource = ref.read(kanjiLocalDataSourceProvider);
        await localDataSource.cacheKanji(newKanji);
        return newKanji;
      }
    }

    return kanji;
  },
);

// ─── Sentences Provider ─────────────────────────────────────────

final kanjiSentencesProvider = FutureProvider.family<List<Sentence>, String>(
  (ref, character) async {
    final dataSource = ref.watch(sentenceRemoteDataSourceProvider);
    // You might want to add database caching here in the future
    return dataSource.fetchSentences(character);
  },
);

// ─── Vocabulary Provider ────────────────────────────────────────

final kanjiVocabularyProvider = FutureProvider.family<List<Vocabulary>, String>(
  (ref, character) async {
    final repo = ref.watch(kanjiRepositoryProvider);
    final vocabularies = await repo.getVocabularyForKanji(character);

    final locale = ref.watch(localeProvider);
    if (locale.languageCode == 'id') {
      final translator = ref.read(translationServiceProvider);
      final targetVocabs = vocabularies.take(15).toList();
      final restVocabs = vocabularies.skip(15).toList();

      final stringsToTranslate = <String>[];
      for (final vocab in targetVocabs) {
        if (vocab.meaningsId.isEmpty && vocab.meanings.isNotEmpty) {
          stringsToTranslate.add(vocab.meanings.first);
        }
      }

      if (stringsToTranslate.isNotEmpty) {
        final translated = await translator.translateMeanings(stringsToTranslate);
        
        // If translation is successful and counts match
        if (translated.isNotEmpty && translated.length == stringsToTranslate.length) {
          int tIndex = 0;
          final newVocabularies = <Vocabulary>[];
          
          for (final vocab in targetVocabs) {
            if (vocab.meaningsId.isEmpty && vocab.meanings.isNotEmpty) {
              newVocabularies.add(Vocabulary(
                word: vocab.word,
                reading: vocab.reading,
                meanings: vocab.meanings,
                meaningsId: [translated[tIndex++]],
                priorities: vocab.priorities,
              ));
            } else {
              newVocabularies.add(vocab);
            }
          }
          
          newVocabularies.addAll(restVocabs);
          
          final localDataSource = ref.read(kanjiLocalDataSourceProvider);
          await localDataSource.cacheVocabulary(character, newVocabularies);
          return newVocabularies;
        }
      }
    }

    // Cross-reference with JLPT Vocab
    final jlptRepo = ref.read(jlptVocabRepositoryProvider);
    final finalVocabularies = <Vocabulary>[];
    for (final vocab in vocabularies) {
      final jlptData = await jlptRepo.getVocabByWord(vocab.word);
      if (jlptData != null) {
        finalVocabularies.add(Vocabulary(
          word: vocab.word,
          reading: vocab.reading,
          meanings: vocab.meanings,
          meaningsId: vocab.meaningsId,
          priorities: vocab.priorities,
          jlptLevel: jlptData.level,
        ));
      } else {
        finalVocabularies.add(vocab);
      }
    }

    return finalVocabularies;
  },
);

// ─── Search Provider ────────────────────────────────────────────

final kanjiSearchQueryProvider = StateProvider<String>((ref) => '');

final kanjiSearchResultsProvider =
    FutureProvider.family<List<Kanji>, int>((ref, jlptLevel) async {
  final query = ref.watch(kanjiSearchQueryProvider);
  if (query.isEmpty) return [];
  final repo = ref.watch(kanjiRepositoryProvider);
  return repo.searchKanji(query, jlptLevel: jlptLevel);
});

// ─── Filter Provider ────────────────────────────────────────────

enum KanjiFilter { all, kanji, vocab, learning, mastered }

final kanjiFilterProvider = StateProvider<KanjiFilter>((ref) => KanjiFilter.all);

// ─── Grid Item Model ────────────────────────────────────────────

class GridItem {
  const GridItem({
    required this.text,
    required this.isVocab,
    this.meaning,
    this.reading,
  });

  final String text;
  final bool isVocab;
  final String? meaning; 
  final String? reading; 
}

// ─── Filtered Grid List Provider ───────────────────────────────

final filteredGridListProvider = FutureProvider.family<List<GridItem>, int>((ref, jlptLevel) async {
  final query = ref.watch(kanjiSearchQueryProvider).toLowerCase();
  final filter = ref.watch(kanjiFilterProvider);
  
  final db = ref.watch(databaseProvider);
  final kanjiRepo = ref.watch(kanjiRepositoryProvider);
  final vocabRepo = ref.watch(jlptVocabRepositoryProvider);

  final result = <GridItem>[];

  // 1. Fetch source data based on filter
  final loadKanji = filter != KanjiFilter.vocab;
  final loadVocab = filter != KanjiFilter.kanji;

  if (loadKanji) {
    List<Kanji> kanjis = [];
    if (query.isNotEmpty) {
      kanjis = await kanjiRepo.searchKanji(query, jlptLevel: jlptLevel);
    } else {
      final chars = await kanjiRepo.getKanjiListByJlpt(jlptLevel);
      // For just characters we don't need full Kanji objects if we don't have search query,
      // but to keep it simple, we just map characters to GridItems directly.
      for (final char in chars) {
        result.add(GridItem(text: char, isVocab: false));
      }
    }
    
    if (query.isNotEmpty) {
      for (final k in kanjis) {
        result.add(GridItem(text: k.character, isVocab: false));
      }
    }
  }

  if (loadVocab) {
    final vocabs = await vocabRepo.getVocabByLevel(jlptLevel);
    for (final v in vocabs) {
      final isId = ref.watch(localeProvider).languageCode == 'id';
      if (query.isNotEmpty) {
        if (!v.word.contains(query) &&
            !v.furigana.contains(query) &&
            !v.primaryMeaning(isId).toLowerCase().contains(query) &&
            !v.romaji.toLowerCase().contains(query)) {
          continue;
        }
      }
      result.add(GridItem(text: v.word, isVocab: true, meaning: v.primaryMeaning(isId), reading: v.furigana));
    }
  }

  // 2. Filter by learning/mastered progress if needed
  if (filter == KanjiFilter.learning || filter == KanjiFilter.mastered) {
    final filteredByProgress = <GridItem>[];
    for (final item in result) {
      final progress = await db.getProgress(item.text);
      if (filter == KanjiFilter.mastered && progress?.status == 'mastered') {
        filteredByProgress.add(item);
      } else if (filter == KanjiFilter.learning && 
                 (progress?.status == 'learning' || progress?.status == 'reviewing')) {
        filteredByProgress.add(item);
      }
    }
    return filteredByProgress;
  }
  
  // Sort mixed list alphabetically (optional) or just return as is
  return result;
});

// ─── JLPT Stats Provider ───────────────────────────────────────

final jlptStatsProvider = FutureProvider.family<JlptStats, int>(
  (ref, level) async {
    final db = ref.watch(databaseProvider);
    final kanjiTotal = AppConstants.jlptKanjiCounts[level] ?? 100;
    final vocabTotal = await db.getVocabTotalCount(jlptLevel: level);
    
    final total = kanjiTotal + vocabTotal;
    
    final kanjiLearned = await db.getLearnedCount(jlptLevel: level);
    final vocabLearned = await db.getVocabLearnedCount(jlptLevel: level);
    final learned = kanjiLearned + vocabLearned;
    
    final kanjiMastered = await db.getMasteredCount(jlptLevel: level);
    final vocabMastered = await db.getVocabMasteredCount(jlptLevel: level);
    final mastered = kanjiMastered + vocabMastered;
    
    return JlptStats(
      level: level,
      total: total,
      learned: learned,
      mastered: mastered,
    );
  },
);

class JlptStats {
  const JlptStats({
    required this.level,
    required this.total,
    required this.learned,
    required this.mastered,
  });

  final int level;
  final int total;
  final int learned;
  final int mastered;

  double get progress => total > 0 ? learned / total : 0.0;
  String get progressPercent => '${(progress * 100).round()}%';
}

// ─── Kanji Progress Provider ────────────────────────────────────

final kanjiProgressProvider =
    FutureProvider.family<UserKanjiProgressEntry?, String>(
  (ref, character) async {
    final db = ref.watch(databaseProvider);
    return db.getProgress(character);
  },
);

// ─── KanjiAlive Provider ────────────────────────────────────────

final kanjiAliveRemoteDataSourceProvider = Provider<KanjiAliveRemoteDataSource>((ref) {
  return KanjiAliveRemoteDataSource(ref.watch(dioClientProvider));
});

final kanjiAliveDetailProvider = FutureProvider.family<KanjiAliveData?, String>((ref, character) async {
  final dataSource = ref.watch(kanjiAliveRemoteDataSourceProvider);
  return dataSource.getKanjiDetails(character);
});
