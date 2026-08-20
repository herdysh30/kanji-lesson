import 'package:kanji_lesson/core/network/dio_client.dart';
import 'package:kanji_lesson/core/constants/api_constants.dart';

/// Remote data source for KanjiAPI.dev
class KanjiRemoteDataSource {
  KanjiRemoteDataSource(this._client);

  final DioClient _client;

  /// Get list of kanji characters by JLPT level
  /// Returns a list of kanji character strings
  Future<List<String>> getKanjiByJlptLevel(int level) async {
    final response = await _client.get<List<dynamic>>(
      ApiConstants.kanjiByJlpt(level),
    );
    return response.data?.cast<String>() ?? [];
  }

  /// Get detailed kanji information
  /// Returns raw JSON map
  Future<Map<String, dynamic>> getKanjiDetail(String character) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiConstants.kanjiDetail(character),
    );
    return response.data ?? {};
  }

  /// Get words/vocabulary for a kanji character
  /// Returns list of raw JSON maps
  Future<List<Map<String, dynamic>>> getWordsForKanji(
      String character) async {
    final response = await _client.get<List<dynamic>>(
      ApiConstants.wordsForKanji(character),
    );
    return response.data?.cast<Map<String, dynamic>>() ?? [];
  }
}
