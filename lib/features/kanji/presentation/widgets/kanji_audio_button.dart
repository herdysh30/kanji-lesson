import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class KanjiAudioButton extends StatefulWidget {
  const KanjiAudioButton({
    super.key,
    required this.character,
    this.autoPlay = false,
  });

  final String character;
  final bool autoPlay;

  @override
  State<KanjiAudioButton> createState() => _KanjiAudioButtonState();
}

class _KanjiAudioButtonState extends State<KanjiAudioButton> {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("ja-JP");
    
    // Set up handlers to animate icon state
    _flutterTts.setStartHandler(() {
      if (mounted) setState(() => _isPlaying = true);
    });
    
    _flutterTts.setCompletionHandler(() {
      if (mounted) setState(() => _isPlaying = false);
    });
    
    _flutterTts.setErrorHandler((msg) {
      if (mounted) setState(() => _isPlaying = false);
    });

    _isInit = true;
    
    if (widget.autoPlay) {
      _playAudio();
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _playAudio() async {
    if (_isPlaying || !_isInit) return;

    try {
      await _flutterTts.speak(widget.character);
    } catch (e) {
      if (mounted) {
        setState(() => _isPlaying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memutar audio (TTS)')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _playAudio,
      icon: Icon(
        _isPlaying ? Icons.volume_up_rounded : Icons.volume_down_rounded,
        size: 28,
      ),
      color: Theme.of(context).colorScheme.primary,
      tooltip: 'Play Audio (TTS)',
    );
  }
}
