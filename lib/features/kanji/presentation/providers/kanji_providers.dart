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
import 'package:shared_preferences/shared_preferences.dart';

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

    return vocabularies;
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

enum KanjiFilter { all, learning, mastered }

final kanjiFilterProvider = StateProvider<KanjiFilter>((ref) => KanjiFilter.all);

// ─── JLPT Stats Provider ───────────────────────────────────────

final jlptStatsProvider = FutureProvider.family<JlptStats, int>(
  (ref, level) async {
    final db = ref.watch(databaseProvider);
    final total = AppConstants.jlptKanjiCounts[level] ?? 100;
    final learned = await db.getLearnedCount(jlptLevel: level);
    final mastered = await db.getMasteredCount(jlptLevel: level);
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
