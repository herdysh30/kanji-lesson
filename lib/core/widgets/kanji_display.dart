import 'package:flutter/material.dart';
import 'package:kanji_lesson/core/theme/app_theme.dart';

/// Reusable large kanji character display
class KanjiDisplay extends StatelessWidget {
  const KanjiDisplay({
    super.key,
    required this.character,
    this.size = KanjiDisplaySize.large,
    this.showShadow = false,
    this.color,
  });

  final String character;
  final KanjiDisplaySize size;
  final bool showShadow;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final textStyle = switch (size) {
      KanjiDisplaySize.large => AppTheme.kanjiLarge(context),
      KanjiDisplaySize.medium => AppTheme.kanjiMedium(context),
      KanjiDisplaySize.small => AppTheme.kanjiSmall(context),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: showShadow
          ? BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).cardTheme.color,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            )
          : null,
      child: Text(
        character,
        style: color != null ? textStyle.copyWith(color: color) : textStyle,
      ),
    );
  }
}

enum KanjiDisplaySize { large, medium, small }
