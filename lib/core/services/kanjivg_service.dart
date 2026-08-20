import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kanji_lesson/core/network/dio_client.dart';

class KanjiVgService {
  KanjiVgService(this._dio);
  final Dio _dio;
  
  final Map<String, String> _cache = {};

  String _getHexCode(String kanji) {
    if (kanji.isEmpty) return '';
    return kanji.codeUnitAt(0).toRadixString(16).padLeft(5, '0');
  }

  Future<String?> getSvgForKanji(String kanji) async {
    final hex = _getHexCode(kanji);
    if (hex.isEmpty) return null;

    if (_cache.containsKey(hex)) {
      return _cache[hex];
    }

    try {
      final url = 'https://raw.githubusercontent.com/KanjiVG/kanjivg/master/kanji/$hex.svg';
      final response = await _dio.get(url);
      
      if (response.statusCode == 200 && response.data != null) {
        final svgString = response.data.toString();
        _cache[hex] = svgString;
        return svgString;
      }
    } catch (e) {
      // Ignore errors (e.g. kanji not found in KanjiVG)
      debugPrint('KanjiVG fetch error for $kanji ($hex): $e');
    }
    
    return null;
  }
}

final kanjiVgServiceProvider = Provider<KanjiVgService>((ref) {
  return KanjiVgService(ref.watch(dioProvider));
});

final kanjiSvgProvider = FutureProvider.family<String?, String>((ref, kanji) async {
  final service = ref.watch(kanjiVgServiceProvider);
  return service.getSvgForKanji(kanji);
});

final wordSvgProvider = FutureProvider.family<List<String?>, String>((ref, word) async {
  final service = ref.watch(kanjiVgServiceProvider);
  return Future.wait(word.split('').map((char) => service.getSvgForKanji(char)));
});
