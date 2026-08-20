import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kanji_lesson/features/kanji/data/datasources/jlpt_vocab_local_data_source.dart';
import 'package:kanji_lesson/features/kanji/data/datasources/jlpt_vocab_remote_data_source.dart';
import 'package:kanji_lesson/features/kanji/data/repositories/jlpt_vocab_repository_impl.dart';
import 'package:kanji_lesson/features/kanji/domain/entities/jlpt_vocab.dart';
import 'package:kanji_lesson/features/kanji/domain/repositories/jlpt_vocab_repository.dart';
import 'package:kanji_lesson/features/kanji/presentation/providers/kanji_providers.dart';

final jlptVocabRemoteDataSourceProvider = Provider<JlptVocabRemoteDataSource>((ref) {
  return JlptVocabRemoteDataSource(ref.watch(dioClientProvider));
});

final jlptVocabLocalDataSourceProvider = Provider<JlptVocabLocalDataSource>((ref) {
  return JlptVocabLocalDataSource(ref.watch(databaseProvider));
});

final jlptVocabRepositoryProvider = Provider<JlptVocabRepository>((ref) {
  return JlptVocabRepositoryImpl(
    remoteDataSource: ref.watch(jlptVocabRemoteDataSourceProvider),
    localDataSource: ref.watch(jlptVocabLocalDataSourceProvider),
    translationService: ref.watch(translationServiceProvider),
  );
});

final jlptVocabListProvider = FutureProvider.family<List<JlptVocab>, int>((ref, level) async {
  final repo = ref.watch(jlptVocabRepositoryProvider);
  return repo.getVocabByLevel(level);
});
