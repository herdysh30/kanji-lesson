import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';

class MlkitDigitalInkService {
  final _modelManager = DigitalInkRecognizerModelManager();
  final String _languageCode = 'ja';

  /// Check if Japanese recognition model is downloaded
  Future<bool> isModelDownloaded() async {
    return await _modelManager.isModelDownloaded(_languageCode);
  }

  /// Download the model (on-demand)
  Future<bool> downloadModel() async {
    return await _modelManager.downloadModel(_languageCode, isWifiRequired: false);
  }
  
  /// Delete the model to free up space
  Future<bool> deleteModel() async {
    return await _modelManager.deleteModel(_languageCode);
  }

  /// Recognize drawn Kanji from an Ink object
  Future<List<RecognitionCandidate>> recognizeKanji(Ink ink) async {
    final recognizer = DigitalInkRecognizer(languageCode: _languageCode);
    try {
      final candidates = await recognizer.recognize(ink);
      debugPrint('ML Kit Candidates: ${candidates.map((c) => c.text).toList()}');
      return candidates;
    } catch (e) {
      debugPrint('ML Kit Error: $e');
      return [];
    } finally {
      try {
        recognizer.close();
      } catch (_) {
        // Ignore close errors
      }
    }
  }
}

final mlkitDigitalInkServiceProvider = Provider<MlkitDigitalInkService>((ref) {
  return MlkitDigitalInkService();
});

final digitalInkModelStatusProvider = FutureProvider.autoDispose<bool>((ref) async {
  final service = ref.watch(mlkitDigitalInkServiceProvider);
  return service.isModelDownloaded();
});
