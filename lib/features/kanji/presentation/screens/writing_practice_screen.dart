import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart' as mlkit;
import 'package:kanji_lesson/core/services/mlkit_digital_ink_service.dart';
import 'package:kanji_lesson/core/theme/app_colors.dart';
import 'package:kanji_lesson/core/theme/app_theme.dart';
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

  Timer? _debounceTimer;
  bool _isChecking = false;
  bool _isCorrect = false;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _pickRandomItem() {
    if (_pool.isEmpty) return;
    _debounceTimer?.cancel();
    setState(() {
      _isCorrect = false;
      _isChecking = false;
      _currentItem = _pool[_random.nextInt(_pool.length)];
    });
  }

  void _onInkChanged(mlkit.Ink ink) {
    if (_isCorrect || _currentItem == null) return;
    _debounceTimer?.cancel();

    if (ink.strokes.isEmpty) return;

    // Debounce recognition by 1.1s so user has time to draw without interruption
    _debounceTimer = Timer(const Duration(milliseconds: 1100), () async {
      if (!mounted || _isCorrect || _currentItem == null) return;

      setState(() {
        _isChecking = true;
      });

      final mlkitService = ref.read(mlkitDigitalInkServiceProvider);
      final candidates = await mlkitService.recognizeKanji(ink);

      if (!mounted) return;

      setState(() {
        _isChecking = false;
      });

      final target = _currentItem!.text;
      if (candidates.isNotEmpty) {
        final topCandidates = candidates.take(5).map((c) => c.text).toList();
        if (topCandidates.contains(target)) {
          setState(() {
            _isCorrect = true;
          });

          // Wait 1.2s to show success feedback, then automatically advance to the next item
          Future.delayed(const Duration(milliseconds: 1200), () {
            if (mounted && _isCorrect) {
              _pickRandomItem();
            }
          });
        }
      }
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

            String meaningStr;
            String readingStr;

            if (_currentItem!.isVocab) {
              meaningStr = _currentItem!.meaning ?? _currentItem!.text;
              readingStr = _currentItem!.reading ?? '';
            } else {
              final kanjiDetailAsync = ref.watch(kanjiDetailProvider(_currentItem!.text));
              final kanji = kanjiDetailAsync.valueOrNull;
              if (kanji != null) {
                final meanings = isId && kanji.meaningsId.isNotEmpty ? kanji.meaningsId : kanji.meanings;
                meaningStr = meanings.isNotEmpty ? meanings.first : kanji.character;
                readingStr = kanji.primaryReading.isNotEmpty ? kanji.primaryReading : '';
              } else {
                meaningStr = _currentItem!.meaning ?? '';
                readingStr = _currentItem!.reading ?? '';
              }
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: [
                  // Reading/Furigana
                  if (readingStr.isNotEmpty)
                    Text(
                      readingStr,
                      style: AppTheme.japaneseReading(context, fontSize: 16).copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 2),

                  // Kanji / Word Text
                  Text(
                    _currentItem!.text,
                    style: AppTheme.japaneseText(context, fontSize: 32).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),

                  // Meaning
                  if (meaningStr.isNotEmpty)
                    Text(
                      meaningStr,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            );
          }

          return Column(
            children: [
              buildHeader(),

              // Status Banner (Correct / Checking)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: _isCorrect || _isChecking ? 36 : 0,
                curve: Curves.easeInOut,
                margin: EdgeInsets.only(bottom: _isCorrect || _isChecking ? 8 : 0),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: _isCorrect
                      ? AppColors.correct
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: _isCorrect
                    ? const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                          SizedBox(width: 6),
                          Text(
                            'Correct! Loading next...',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      )
                    : _isChecking
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Checking handwriting...',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
                  child: KanjiDrawingPad(
                    key: ValueKey(_currentItem!.text), // Forces redraw when character changes
                    character: _currentItem!.text,
                    showBackground: true, // Always show hint in practice mode
                    onInkChanged: _onInkChanged,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
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
