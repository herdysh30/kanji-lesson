import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class TranslationService {
  TranslationService(this._dio);

  final Dio _dio;

  /// Translates a list of English meanings to Indonesian.
  Future<List<String>> translateMeanings(List<String> meanings) async {
    if (meanings.isEmpty) return [];

    try {
      // Join meanings into a single string separated by ' | ' to translate in one go
      final textToTranslate = meanings.join(' | ');

      final response = await _dio.get(
        'https://translate.googleapis.com/translate_a/single',
        queryParameters: {
          'client': 'gtx',
          'sl': 'en',
          'tl': 'id',
          'dt': 't',
          'q': textToTranslate,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as List;
        // Google Translate returns an array of segments: [ [[translated, original, ...], ...], ... ]
        final segments = data[0] as List;
        
        final StringBuffer translatedText = StringBuffer();
        for (final segment in segments) {
          translatedText.write(segment[0] as String);
        }

        // Split back by '|' and trim
        return translatedText
            .toString()
            .split('|')
            .map((e) => e.trim())
            .toList();
      }
    } catch (e) {
      // If translation fails, silently return empty or throw
      debugPrint('Translation Error: $e');
    }
    
    return [];
  }

  /// Retrieves romaji for a list of Japanese texts
  Future<List<String>> getRomajis(List<String> japaneseTexts) async {
    if (japaneseTexts.isEmpty) return [];

    try {
      final textToTranslate = japaneseTexts.join(' | ');

      final response = await _dio.get(
        'https://translate.googleapis.com/translate_a/single',
        queryParameters: {
          'client': 'gtx',
          'sl': 'ja',
          'tl': 'ja',
          'dt': 'rm',
          'q': textToTranslate,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as List;
        final segments = data[0] as List;
        
        final StringBuffer romaji = StringBuffer();
        for (final segment in segments) {
          if (segment is List && segment.length >= 4 && segment[3] != null) {
            romaji.write(segment[3].toString());
          }
        }

        return romaji
            .toString()
            .split('|')
            .map((e) => e.trim())
            .toList();
      }
    } catch (e) {
      debugPrint('Romaji Error: $e');
    }
    
    return List.filled(japaneseTexts.length, '');
  }
}
