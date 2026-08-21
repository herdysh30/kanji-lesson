import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart' as mlkit;
import 'package:kanji_lesson/core/services/mlkit_digital_ink_service.dart';
import 'package:kanji_lesson/core/theme/app_colors.dart';
import 'package:kanji_lesson/core/theme/app_theme.dart';
import 'package:kanji_lesson/features/settings/presentation/providers/settings_providers.dart';
import 'package:kanji_lesson/features/kanji/presentation/widgets/kanji_drawing_pad.dart';
import 'package:kanji_lesson/features/kanji/presentation/widgets/kanji_alive_display.dart' as kanji_alive;

/// Reusable header for handwriting prompts across Quiz, Random Practice, and Detail Screens
class WritingPromptHeader extends StatelessWidget {
  const WritingPromptHeader({
    super.key,
    required this.text,
    this.reading,
    this.meaning,
  });

  final String text;
  final String? reading;
  final String? meaning;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Reading / Furigana
          if (reading != null && reading!.isNotEmpty && reading != text)
            Text(
              reading!,
              style: AppTheme.japaneseReading(context, fontSize: 16).copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 2),

          // Kanji / Word
          Text(
            text,
            style: AppTheme.japaneseText(context, fontSize: 32).copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),

          // Meaning
          if (meaning != null && meaning!.isNotEmpty)
            Text(
              meaning!,
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
}

/// Show reusable full-width Practice Writing dialog
void showPracticeWritingDialog(
  BuildContext context, {
  required String character,
  String? reading,
  String? meaning,
}) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SizedBox(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.75,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: _PracticeWritingDialogContent(
            character: character,
            reading: reading,
            meaning: meaning,
          ),
        ),
      ),
    ),
  );
}

class _PracticeWritingDialogContent extends ConsumerStatefulWidget {
  const _PracticeWritingDialogContent({
    required this.character,
    this.reading,
    this.meaning,
  });

  final String character;
  final String? reading;
  final String? meaning;

  @override
  ConsumerState<_PracticeWritingDialogContent> createState() => _PracticeWritingDialogContentState();
}

class _PracticeWritingDialogContentState extends ConsumerState<_PracticeWritingDialogContent> {
  bool _showAnimation = true;
  bool _isCorrect = false;
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onInkChanged(mlkit.Ink ink) {
    if (ink.strokes.isEmpty) {
      if (_isCorrect) setState(() => _isCorrect = false);
      return;
    }

    if (_isCorrect) return;
    _debounceTimer?.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 1200), () async {
      if (!mounted || _isCorrect) return;

      final mlkitService = ref.read(mlkitDigitalInkServiceProvider);
      final candidates = await mlkitService.recognizeKanji(ink);

      if (!mounted || _isCorrect) return;

      if (candidates.isNotEmpty) {
        final allCandidates = candidates.map((c) => c.text).toList();
        if (allCandidates.contains(widget.character)) {
          setState(() {
            _isCorrect = true;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isId = ref.watch(localeProvider).languageCode == 'id';

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => Navigator.pop(context),
              tooltip: 'Close',
            ),
          ],
        ),
        WritingPromptHeader(
          text: widget.character,
          reading: widget.reading,
          meaning: widget.meaning,
        ),
        const SizedBox(height: 8),
        if (_showAnimation) ...[
          Expanded(
            child: kanji_alive.KanjiAliveDisplay(
              character: widget.character,
              onComplete: () {
                if (mounted) setState(() => _showAnimation = false);
              },
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => setState(() => _showAnimation = false),
            icon: const Icon(Icons.fast_forward_rounded),
            label: Text(isId ? 'Lewati & Mulai Menulis' : 'Skip & Start Writing'),
          ),
          const SizedBox(height: 8),
        ] else ...[
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: KanjiDrawingPad(
                    character: widget.character,
                    onInkChanged: _onInkChanged,
                  ),
                ),
                if (_isCorrect)
                  Positioned(
                    top: 12,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.correct,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              isId ? 'Tepat Sekali!' : 'Correct!',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_isCorrect) ...[
            FilledButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.check_rounded),
              label: Text(isId ? 'Selesai' : 'Done'),
              style: FilledButton.styleFrom(backgroundColor: AppColors.correct),
            ),
          ] else ...[
            OutlinedButton.icon(
              onPressed: () => setState(() => _showAnimation = true),
              icon: const Icon(Icons.replay_rounded),
              label: Text(isId ? 'Tonton Ulang Video' : 'Rewatch Video'),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

