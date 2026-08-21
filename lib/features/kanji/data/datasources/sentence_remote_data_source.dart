import 'package:dio/dio.dart';
import 'package:kanji_lesson/core/services/translation_service.dart';
import 'package:kanji_lesson/features/kanji/domain/entities/sentence.dart';

class SentenceRemoteDataSource {
  final Dio dio;
  final TranslationService translationService;

  SentenceRemoteDataSource({
    required this.dio,
    required this.translationService,
  });

  Future<List<Sentence>> fetchSentences(String query) async {
    try {
      final url = 'https://tatoeba.org/en/api_v0/search?from=jpn&to=eng&query=${Uri.encodeComponent(query)}';
      
      final response = await dio.get(url, options: Options(headers: {
        'Accept': 'application/json',
      }));

      if (response.statusCode != 200) {
        return [];
      }

      final data = response.data;
      final results = data['results'] as List?;
      if (results == null || results.isEmpty) {
        return [];
      }

      List<Sentence> sentences = [];
      List<String> japaneseList = [];
      List<String> englishList = [];
      
      // Limit to max 5 sentences to save translation API calls
      for (var i = 0; i < results.length && i < 5; i++) {
        final result = results[i];
        final japanese = result['text'] as String? ?? '';
        
        String english = '';
        final translations = result['translations'] as List?;
        if (translations != null && translations.isNotEmpty) {
          final transList = translations[0] as List?;
          if (transList != null && transList.isNotEmpty) {
            english = transList[0]['text'] as String? ?? '';
          }
        }

        if (japanese.isNotEmpty && english.isNotEmpty) {
          japaneseList.add(japanese);
          englishList.add(english);
        }
      }

      if (japaneseList.isEmpty) return [];

      // 2. Translate English to Indonesian using Google Translate free API
      final indonesianList = await translationService.translateMeanings(englishList);
      final romajiList = await translationService.getRomajis(japaneseList);

      for (var i = 0; i < japaneseList.length; i++) {
        sentences.add(Sentence(
          japanese: japaneseList[i],
          english: englishList[i],
          indonesian: i < indonesianList.length ? indonesianList[i] : '',
          romaji: i < romajiList.length ? romajiList[i] : '',
        ));
      }

      return sentences;
    } catch (e) {
      return [];
    }
  }
}
