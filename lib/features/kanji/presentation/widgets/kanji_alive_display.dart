import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kanji_lesson/core/theme/app_theme.dart';
import 'package:kanji_lesson/features/kanji/presentation/providers/kanji_providers.dart';
import 'package:video_player/video_player.dart';

// Dialog removed. Use showPracticeWritingDialog instead.

class KanjiAliveDisplay extends ConsumerStatefulWidget {
  const KanjiAliveDisplay({
    super.key, 
    required this.character,
    this.onComplete,
  });

  final String character;
  final VoidCallback? onComplete;

  @override
  ConsumerState<KanjiAliveDisplay> createState() => _KanjiAliveDisplayState();
}

class _KanjiAliveDisplayState extends ConsumerState<KanjiAliveDisplay> {
  VideoPlayerController? _videoController;

  bool _hasCompleted = false;

  @override
  void dispose() {
    _videoController?.removeListener(_videoListener);
    _videoController?.dispose();
    super.dispose();
  }

  void _videoListener() {
    if (_videoController == null || !_videoController!.value.isInitialized) return;

    final position = _videoController!.value.position;
    final duration = _videoController!.value.duration;

    if (position >= duration && duration > Duration.zero && !_hasCompleted) {
      _hasCompleted = true;
      if (widget.onComplete != null) {
        // Post frame to avoid calling setState during build/layout if it somehow triggers
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onComplete!();
        });
      }
    }
  }

  Future<void> _initMedia(String mp4Url) async {
    if (_videoController == null) {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(mp4Url));
      await _videoController!.initialize();
      _videoController!.setLooping(false);
      _videoController!.addListener(_videoListener);
      _videoController!.play();
      
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final aliveAsync = ref.watch(kanjiAliveDetailProvider(widget.character));

    return aliveAsync.when(
      data: (data) {
        if (data == null || data.videoMp4Url == null) {
          return _buildFallback();
        }

        if (_videoController == null) {
          _initMedia(data.videoMp4Url!);
          return const Expanded(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!_videoController!.value.isInitialized) {
          return const Expanded(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
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
                      child: VideoPlayer(_videoController!),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (data.radical != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Radical: ${data.radical!.character}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Text(data.radical!.englishMeaning, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
          ],
        );
      },
      loading: () => const Expanded(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => _buildFallback(),
    );
  }

  Widget _buildFallback() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.character,
              style: AppTheme.kanjiLarge(context),
            ),
            const SizedBox(height: 8),
            const Text('Animation not available'),
          ],
        ),
      ),
    );
  }
}

