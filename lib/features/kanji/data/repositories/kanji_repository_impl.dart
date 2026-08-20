import 'package:kanji_lesson/core/network/app_exception.dart';
import 'package:kanji_lesson/features/kanji/data/datasources/kanji_local_data_source.dart';
import 'package:kanji_lesson/features/kanji/data/datasources/kanji_remote_data_source.dart';
import 'package:kanji_lesson/features/kanji/domain/entities/kanji.dart';
import 'package:kanji_lesson/features/kanji/domain/entities/vocabulary.dart';
import 'package:kanji_lesson/features/kanji/domain/repositories/kanji_repository.dart';

/// Repository implementation with offline-first caching strategy
class KanjiRepositoryImpl implements KanjiRepository {
  KanjiRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  final KanjiRemoteDataSource remoteDataSource;
  final KanjiLocalDataSource localDataSource;

  @override
  Future<List<String>> getKanjiListByJlpt(int level) async {
    try {
      // Try remote first
      final characters = await remoteDataSource.getKanjiByJlptLevel(level);
      // Cache the list
      await localDataSource.cacheKanjiList(characters, level);
      return characters;
    } on AppException {
      // Fallback to cache
      final cached = await localDataSource.getKanjiListByJlpt(level);
      if (cached.isNotEmpty) return cached;
      rethrow;
    } catch (e) {
      // Fallback to cache for any error
      final cached = await localDataSource.getKanjiListByJlpt(level);
      if (cached.isNotEmpty) return cached;
      throw const NetworkException();
    }
  }

  @override
  Future<Kanji> getKanjiDetail(String character) async {
    // Check cache first for full detail
    final isCached = await localDataSource.isKanjiDetailCached(character);
    if (isCached) {
      final cached = await localDataSource.getKanjiDetail(character);
      if (cached != null) return cached;
    }

    try {
      // Fetch from remote
      final data = await remoteDataSource.getKanjiDetail(character);
      final kanji = _mapApiToKanji(data);
      // Cache
      await localDataSource.cacheKanji(kanji);
      return kanji;
    } on AppException {
      // Try cache even without full detail
      final cached = await localDataSource.getKanjiDetail(character);
      if (cached != null) return cached;
      rethrow;
    } catch (e) {
      final cached = await localDataSource.getKanjiDetail(character);
      if (cached != null) return cached;
      throw const NetworkException();
    }
  }

  @override
  Future<List<Vocabulary>> getVocabularyForKanji(String character) async {
    // Check cache first
    final isCached = await localDataSource.isVocabularyCached(character);
    if (isCached) {
      return localDataSource.getVocabularyForKanji(character);
    }

    try {
      // Fetch from remote
      final data = await remoteDataSource.getWordsForKanji(character);
      final vocabularies = _mapApiToVocabularyList(data, character);
      // Cache
      await localDataSource.cacheVocabulary(character, vocabularies);
      return vocabularies;
    } on AppException {
      final cached = await localDataSource.getVocabularyForKanji(character);
      if (cached.isNotEmpty) return cached;
      rethrow;
    } catch (e) {
      final cached = await localDataSource.getVocabularyForKanji(character);
      if (cached.isNotEmpty) return cached;
      throw const NetworkException();
    }
  }

  @override
  Future<List<Kanji>> searchKanji(String query, {int? jlptLevel}) async {
    return localDataSource.searchKanji(query, jlptLevel: jlptLevel);
  }

  @override
  Future<bool> isKanjiCached(String character) async {
    return localDataSource.isKanjiDetailCached(character);
  }

  @override
  Future<bool> isJlptListCached(int level) async {
    return localDataSource.isJlptListCached(level);
  }

  @override
  Future<int> getKanjiCountByJlpt(int level) async {
    return localDataSource.getKanjiCountByJlpt(level);
  }

  // ─── Mappers ──────────────────────────────────────────────────

  Kanji _mapApiToKanji(Map<String, dynamic> data) {
    return Kanji(
      character: data['kanji'] as String? ?? '',
      jlptLevel: data['jlpt'] as int?,
      meanings: _castStringList(data['meanings']),
      onyomi: _castStringList(data['on_readings']),
      kunyomi: _castStringList(data['kun_readings']),
      nameReadings: _castStringList(data['name_readings']),
      strokeCount: data['stroke_count'] as int? ?? 0,
      grade: data['grade'] as int?,
      heisigKeyword: data['heisig_en'] as String?,
      frequency: data['freq_mainichi_shinbun'] as int?,
      unicode: data['unicode'] as String? ?? '',
    );
  }

  List<Vocabulary> _mapApiToVocabularyList(
      List<Map<String, dynamic>> data, String kanjiCharacter) {
    final result = <Vocabulary>[];

    for (final wordEntry in data) {
      final meanings = wordEntry['meanings'] as List<dynamic>? ?? [];
      final variants = wordEntry['variants'] as List<dynamic>? ?? [];

      // Collect all glosses from meanings
      final glosses = <String>[];
      for (final meaning in meanings) {
        final meaningMap = meaning as Map<String, dynamic>;
        final glossesList = meaningMap['glosses'] as List<dynamic>? ?? [];
        glosses.addAll(glossesList.cast<String>());
      }

      if (glosses.isEmpty) continue;

      // Process variants - pick the best one containing our kanji
      for (final variant in variants) {
        final variantMap = variant as Map<String, dynamic>;
        final written = variantMap['written'] as String? ?? '';
        final pronounced = variantMap['pronounced'] as String? ?? '';
        final priorities =
            (variantMap['priorities'] as List<dynamic>?)?.cast<String>() ?? [];

        // Only include words that contain our kanji
        if (written.contains(kanjiCharacter)) {
          result.add(Vocabulary(
            word: written,
            reading: pronounced,
            meanings: glosses,
            priorities: priorities,
          ));
          break; // Take first matching variant per word entry
        }
      }
    }

    // Sort: common words first, then by word length
    result.sort((a, b) {
      if (a.isCommon && !b.isCommon) return -1;
      if (!a.isCommon && b.isCommon) return 1;
      return a.word.length.compareTo(b.word.length);
    });

    // Limit to reasonable count
    return result.take(30).toList();
  }

  List<String> _castStringList(dynamic value) {
    if (value is List) return value.cast<String>();
    return [];
  }
}
