import 'package:kanji_lesson/core/services/translation_service.dart';
import 'package:kanji_lesson/features/kanji/data/datasources/jlpt_vocab_local_data_source.dart';
import 'package:kanji_lesson/features/kanji/data/datasources/jlpt_vocab_remote_data_source.dart';
import 'package:kanji_lesson/features/kanji/domain/entities/jlpt_vocab.dart';
import 'package:kanji_lesson/features/kanji/domain/repositories/jlpt_vocab_repository.dart';

class JlptVocabRepositoryImpl implements JlptVocabRepository {
  const JlptVocabRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.translationService,
  });

  final JlptVocabRemoteDataSource remoteDataSource;
  final JlptVocabLocalDataSource localDataSource;
  final TranslationService translationService;

  @override
  Future<List<JlptVocab>> getVocabByLevel(int level) async {
    // 1. Check local cache first
    final localVocab = await localDataSource.getVocabByLevel(level);
    if (localVocab.isNotEmpty) {
      return localVocab;
    }

    // 2. Fetch from remote if cache is empty
    final remoteVocab = await remoteDataSource.getVocabByLevel(level);
    
    // 3. Translate meanings to Indonesian if needed
    // The locale check will be done in the provider, but we translate here for simplicity if requested.
    // For now, we will cache the English meanings directly, and translate on the fly in the provider,
    // OR translate before caching. We'll translate before caching to save API calls in the future.
    // Actually, TranslationService translates a list of strings.
    
    // To avoid translating thousands of words at once (which might fail or take too long),
    // we'll just cache the remote vocab as is. The translation can be done on the provider side
    // or we can translate the meanings in chunks here. Let's do it in chunks.
    
    try {
      final meaningsToTranslate = remoteVocab.map((v) => v.meaning).toList();
      final translatedMeanings = await translationService.translateMeanings(meaningsToTranslate);
      
      if (translatedMeanings.length == remoteVocab.length) {
        final translatedVocabList = <JlptVocab>[];
        for (var i = 0; i < remoteVocab.length; i++) {
          translatedVocabList.add(JlptVocab(
            word: remoteVocab[i].word,
            meaning: remoteVocab[i].meaning, 
            meaningId: translatedMeanings[i], 
            furigana: remoteVocab[i].furigana,
            romaji: remoteVocab[i].romaji,
            level: remoteVocab[i].level,
          ));
        }
        await localDataSource.cacheVocabList(translatedVocabList);
        return translatedVocabList;
      }
    } catch (e) {
      // If translation fails, just cache and return the english ones
    }

    // Cache the original (English) if translation failed or was skipped
    await localDataSource.cacheVocabList(remoteVocab);
    return remoteVocab;
  }

  @override
  Future<JlptVocab?> getVocabByWord(String word) async {
    return localDataSource.getVocabByWord(word);
  }
}
