import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kanji_lesson/core/widgets/error_widget.dart';
import 'package:kanji_lesson/core/widgets/loading_widget.dart';
import 'package:kanji_lesson/features/kanji/presentation/providers/kanji_providers.dart';
import 'package:kanji_lesson/features/kanji/presentation/widgets/kanji_drawing_pad.dart';
import 'package:kanji_lesson/features/settings/presentation/providers/settings_providers.dart';

class WritingPracticeScreen extends ConsumerStatefulWidget {
  const WritingPracticeScreen({
    super.key,
    required this.jlptLevel,
  });

  final int jlptLevel;

  @override
  ConsumerState<WritingPracticeScreen> createState() => _WritingPracticeScreenState();
}

class _WritingPracticeScreenState extends ConsumerState<WritingPracticeScreen> {
  final _random = Random();
  String? _currentCharacter;
  List<String> _pool = [];

  void _pickRandomKanji() {
    if (_pool.isEmpty) return;
    setState(() {
      _currentCharacter = _pool[_random.nextInt(_pool.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(kanjiListProvider(widget.jlptLevel));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Random Practice'),
      ),
      body: listAsync.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No Kanji available to practice.'));
          }

          if (_pool.isEmpty) {
            _pool = list;
            // Schedule the first pick after build
            Future.microtask(_pickRandomKanji);
            return const AppLoadingWidget(message: 'Preparing...');
          }

          if (_currentCharacter == null) {
            return const AppLoadingWidget(message: 'Preparing...');
          }

          // Fetch detail to show meaning/reading
          final kanjiDetailAsync = ref.watch(kanjiDetailProvider(_currentCharacter!));

          return Column(
            children: [
              kanjiDetailAsync.when(
                data: (kanji) {
                  final isId = ref.watch(localeProvider).languageCode == 'id';
                  final meanings = isId && kanji.meaningsId.isNotEmpty ? kanji.meaningsId : kanji.meanings;
                  final meaningStr = meanings.isNotEmpty ? meanings.first : kanji.character;
                  final readingStr = kanji.primaryReading.isNotEmpty ? kanji.primaryReading : '';

                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          meaningStr,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        if (readingStr.isNotEmpty)
                          Text(
                            readingStr,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
                            textAlign: TextAlign.center,
                          ),
                      ],
                    ),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
                error: (_, __) => const SizedBox(height: 64),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: KanjiDrawingPad(
                    key: ValueKey(_currentCharacter), // Forces redraw when character changes
                    character: _currentCharacter!,
                    showBackground: true, // Always show hint in practice mode
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: _pickRandomKanji,
                    icon: const Icon(Icons.shuffle_rounded),
                    label: const Text('Next Random Kanji', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const AppLoadingWidget(message: 'Loading Kanji List...'),
        error: (e, _) => AppErrorWidget(
          message: 'Failed to load Kanji List',
          onRetry: () => ref.invalidate(kanjiListProvider(widget.jlptLevel)),
        ),
      ),
    );
  }
}
