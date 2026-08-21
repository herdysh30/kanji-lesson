import 'package:flutter/material.dart';
import 'package:kanji_lesson/core/theme/app_theme.dart';
import 'package:kanji_lesson/features/kanji/presentation/widgets/kanji_drawing_pad.dart';

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
          child: Column(
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
                text: character,
                reading: reading,
                meaning: meaning,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: KanjiDrawingPad(character: character),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
