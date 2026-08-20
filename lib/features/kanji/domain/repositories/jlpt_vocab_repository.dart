import 'package:kanji_lesson/features/kanji/domain/entities/jlpt_vocab.dart';

abstract class JlptVocabRepository {
  Future<List<JlptVocab>> getVocabByLevel(int level);
  Future<JlptVocab?> getVocabByWord(String word);
  Future<List<JlptVocab>> getAllVocab();
}
