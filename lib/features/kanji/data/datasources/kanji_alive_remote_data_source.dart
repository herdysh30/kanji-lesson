import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kanji_lesson/core/network/dio_client.dart';
import 'package:kanji_lesson/features/kanji/domain/entities/kanji_alive_data.dart';

class KanjiAliveRemoteDataSource {
  const KanjiAliveRemoteDataSource(this._dioClient);

  final DioClient _dioClient;

  Future<KanjiAliveData?> getKanjiDetails(String character) async {
    try {
      final apiKey = dotenv.env['KANJIALIVE_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        // If no API key is provided, we can't make the request
        return null;
      }

      final response = await _dioClient.dio.get(
        'https://kanjialive-api.p.rapidapi.com/api/public/kanji/$character',
        options: Options(
          headers: {
            'x-rapidapi-host': 'kanjialive-api.p.rapidapi.com',
            'x-rapidapi-key': apiKey,
          },
        ),
      );

      final data = response.data;
      if (data is Map<String, dynamic> && !data.containsKey('error')) {
        return KanjiAliveData.fromJson(data);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // Kanji not found in KanjiAlive DB
        return null;
      }
      // If error occurs, we gracefully return null so the app doesn't crash 
      // and can just fallback to normal JLPT display
      return null;
    } catch (e) {
      return null;
    }
  }
}
