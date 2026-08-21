import 'package:flutter/material.dart';
import 'package:kanji_lesson/core/theme/app_theme.dart';

/// Reusable large kanji character display
class KanjiDisplay extends StatelessWidget {
  const KanjiDisplay({
    super.key,
    required this.character,
    this.size = KanjiDisplaySize.large,
    this.color,
  });

  final String character;
  final KanjiDisplaySize size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final textStyle = switch (size) {
      KanjiDisplaySize.large => AppTheme.kanjiLarge(context),
      KanjiDisplaySize.medium => AppTheme.kanjiMedium(context),
      KanjiDisplaySize.small => AppTheme.kanjiSmall(context),
    };

    return Text(
      character,
      style: color != null ? textStyle.copyWith(color: color) : textStyle,
    );
  }
}

enum KanjiDisplaySize { large, medium, small }
