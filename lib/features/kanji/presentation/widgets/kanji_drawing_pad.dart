import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kanji_lesson/core/services/kanjivg_service.dart';

class KanjiDrawingPad extends ConsumerStatefulWidget {
  const KanjiDrawingPad({super.key, required this.character});
  final String character;

  @override
  ConsumerState<KanjiDrawingPad> createState() => _KanjiDrawingPadState();
}

class _KanjiDrawingPadState extends ConsumerState<KanjiDrawingPad> {
  final List<List<Offset>> _paths = [];
  List<Offset> _currentPath = [];

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _currentPath = [details.localPosition];
      _paths.add(_currentPath);
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _currentPath.add(details.localPosition);
    });
  }

  void _clearPad() {
    setState(() {
      _paths.clear();
      _currentPath = [];
    });
  }

  void _undo() {
    if (_paths.isNotEmpty) {
      setState(() {
        _paths.removeLast();
        _currentPath = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final svgAsync = ref.watch(kanjiSvgProvider(widget.character));

    return Column(
      children: [
        // Top Toolbar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Trace the Kanji',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.undo_rounded),
                  tooltip: 'Undo last stroke',
                  onPressed: _paths.isNotEmpty ? _undo : null,
                ),
                IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  tooltip: 'Clear Pad',
                  onPressed: _paths.isNotEmpty ? _clearPad : null,
                ),
              ],
            )
          ],
        ),
        const SizedBox(height: 16),
        // The Pad
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: 1, // KanjiVG is 109x109 square
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    children: [
                      // Background SVG
                      Positioned.fill(
                        child: svgAsync.when(
                          data: (svgString) {
                            if (svgString == null) {
                              return Center(
                                child: Text(
                                  widget.character,
                                  style: TextStyle(
                                    fontSize: 120,
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                                  ),
                                ),
                              );
                            }
                            return SvgPicture.string(
                              svgString,
                              fit: BoxFit.contain,
                              colorFilter: ColorFilter.mode(
                                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15),
                                BlendMode.srcIn,
                              ),
                            );
                          },
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (_, __) => Center(
                            child: Text(
                              widget.character,
                              style: TextStyle(
                                fontSize: 120,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Drawing Canvas
                      Positioned.fill(
                        child: GestureDetector(
                          onPanStart: _onPanStart,
                          onPanUpdate: _onPanUpdate,
                          onPanEnd: (_) {},
                          child: CustomPaint(
                            painter: _DrawingPainter(
                              paths: _paths,
                              strokeColor: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DrawingPainter extends CustomPainter {
  _DrawingPainter({required this.paths, required this.strokeColor});

  final List<List<Offset>> paths;
  final Color strokeColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final pathPoints in paths) {
      if (pathPoints.isEmpty) continue;
      
      final path = Path();
      path.moveTo(pathPoints.first.dx, pathPoints.first.dy);
      for (int i = 1; i < pathPoints.length; i++) {
        path.lineTo(pathPoints[i].dx, pathPoints[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DrawingPainter oldDelegate) {
    // Only repaint if paths size or last path points changed. 
    // For simplicity, just return true on active drawing.
    return true; 
  }
}
