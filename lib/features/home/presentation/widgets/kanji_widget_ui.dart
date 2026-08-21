import 'package:flutter/material.dart';

class KanjiWidgetUi extends StatelessWidget {
  const KanjiWidgetUi({
    super.key,
    required this.kanji,
    required this.meaning,
    required this.reading,
  });

  final String kanji;
  final String meaning;
  final String reading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 400,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: FittedBox(
              fit: BoxFit.contain,
              child: Text(
                kanji,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.0,
                  shadows: [
                    Shadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 4)),
                    Shadow(color: Colors.black38, blurRadius: 20, offset: Offset(0, 8)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (reading.isNotEmpty)
            Text(
              reading,
              style: const TextStyle(
                fontSize: 48,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                shadows: [
                  Shadow(color: Colors.black87, blurRadius: 8, offset: Offset(0, 2)),
                ],
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 4),
          if (meaning.isNotEmpty)
            Text(
              meaning,
              style: const TextStyle(
                fontSize: 52,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(color: Colors.black87, blurRadius: 8, offset: Offset(0, 2)),
                ],
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
