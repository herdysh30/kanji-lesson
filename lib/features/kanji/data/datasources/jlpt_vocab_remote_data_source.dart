import 'package:dio/dio.dart';
import 'package:kanji_lesson/core/network/dio_client.dart';
import 'package:kanji_lesson/features/kanji/domain/entities/jlpt_vocab.dart';

class JlptVocabRemoteDataSource {
  const JlptVocabRemoteDataSource(this._dioClient);

  final DioClient _dioClient;

  /// Fetches all vocabulary for a given JLPT level (1-5) from jlpt-vocab-api
  Future<List<JlptVocab>> getVocabByLevel(int level) async {
    try {
      // Limit 1000 to ensure we get all data (N1 is max ~3500 but we can use 4000)
      final limit = 4000;
      final response = await _dioClient.dio.get(
        'https://jlpt-vocab-api.vercel.app/api/words?level=$level&limit=$limit',
      );
      
      final data = response.data;
      if (data is Map<String, dynamic> && data['words'] is List) {
        final wordsList = data['words'] as List;
        return wordsList
            .map((json) => JlptVocab.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception('Failed to fetch JLPT vocabulary: ${e.message}');
    }
  }
}
