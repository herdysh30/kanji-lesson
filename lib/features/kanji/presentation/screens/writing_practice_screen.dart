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
  GridItem? _currentItem;
  List<GridItem> _pool = [];

  void _pickRandomItem() {
    if (_pool.isEmpty) return;
    setState(() {
      _currentItem = _pool[_random.nextInt(_pool.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(filteredGridListProvider(widget.jlptLevel));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Random Practice'),
      ),
      body: listAsync.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No items available to practice.'));
          }

          if (_pool.isEmpty) {
            _pool = list;
            // Schedule the first pick after build
            Future.microtask(_pickRandomItem);
            return const AppLoadingWidget(message: 'Preparing...');
          }

          if (_currentItem == null) {
            return const AppLoadingWidget(message: 'Preparing...');
          }

          Widget buildHeader() {
            final isId = ref.watch(localeProvider).languageCode == 'id';

            if (_currentItem!.isVocab) {
              final meaningStr = _currentItem!.meaning ?? _currentItem!.text;
              final readingStr = _currentItem!.reading ?? '';
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
            }

            final kanjiDetailAsync = ref.watch(kanjiDetailProvider(_currentItem!.text));
            return kanjiDetailAsync.when(
              data: (kanji) {
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
            );
          }

          return Column(
            children: [
              buildHeader(),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: KanjiDrawingPad(
                    key: ValueKey(_currentItem!.text), // Forces redraw when character changes
                    character: _currentItem!.text,
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
                    onPressed: _pickRandomItem,
                    icon: const Icon(Icons.shuffle_rounded),
                    label: const Text('Next Random Item', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const AppLoadingWidget(message: 'Loading List...'),
        error: (e, _) => AppErrorWidget(
          message: 'Failed to load List',
          onRetry: () => ref.invalidate(filteredGridListProvider(widget.jlptLevel)),
        ),
      ),
    );
  }
}
