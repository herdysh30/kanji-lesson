import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _videoController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  bool _videoReady = false;
  bool _navigated = false;
  static const _minDuration = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();

    _initVideo();
  }

  Future<void> _initVideo() async {
    _videoController =
        VideoPlayerController.asset('assets/manabu.mp4');
    await _videoController.initialize();

    final duration = _videoController.value.duration;
    if (duration.inMilliseconds > 0) {
      final speed = duration.inMilliseconds / _minDuration.inMilliseconds;
      await _videoController.setPlaybackSpeed(speed);
    }

    await _videoController.play();
    setState(() => _videoReady = true);

    _videoController.addListener(_onVideoProgress);
  }

  void _onVideoProgress() {
    if (_navigated) return;
    if (_videoController.value.position >= _videoController.value.duration) {
      _navigateAway();
    }
  }

  Future<void> _navigateAway() async {
    if (_navigated || !mounted) return;
    _navigated = true;

    _videoController.removeListener(_onVideoProgress);
    await _fadeController.reverse();
    if (mounted) {
      context.go('/');
    }
  }

  @override
  void dispose() {
    _videoController.removeListener(_onVideoProgress);
    _videoController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: _videoReady
              ? Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.sizeOf(context).width * 0.6,
                      maxHeight: MediaQuery.sizeOf(context).height * 0.6,
                    ),
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: SizedBox(
                        width: _videoController.value.size.width,
                        height: _videoController.value.size.height,
                        child: VideoPlayer(_videoController),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
