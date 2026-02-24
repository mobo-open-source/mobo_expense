import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import '../../app_entry.dart';
import '../../core/constants/app_theme.dart';
import '../home/get_started_screen.dart';

class SplashScreen extends StatefulWidget {
  final bool isTest;
  const SplashScreen({super.key, this.isTest = false});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static bool _hasPlayedOnce = false;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isValidatingModules = false;
  Timer? _safetyTimer;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    if (widget.isTest) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _navigateSafely();
        }
      });
      return;
    }

    /// If splash has already played, skip directly to main app
    if (_hasPlayedOnce) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _navigateSafely();
        }
      });
      return;
    }
    _hasPlayedOnce = true;
    _startSafetyTimer();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.asset(
        'assets/splash/expense.mp4',
      );

      /// Guard against devices/codecs that may stall initialize forever
      await _videoController!.initialize().timeout(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });

        try {
          await _videoController!.play().timeout(const Duration(seconds: 1));
        } catch (_) {
          /// If play stalls, rely on safety timer
        }

        _videoController!.addListener(() {
          if (!_hasNavigated &&
              _videoController!.value.position >=
                  _videoController!.value.duration) {
            if (mounted) {
              _navigateSafely();
            }
          }
        });
      }
    } on TimeoutException {
      /// Initialization took too long; rely on safety timer to move on
    } catch (e) {
      /// If video fails to load, navigate after 1 second
      if (mounted) {
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            _navigateSafely();
          }
        });
      }
    }
  }

  void _startSafetyTimer() {
    ///Ensure we never stay on splash longer than this duration
    _safetyTimer?.cancel();
    _safetyTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        _navigateSafely();
      }
    });
  }

  /// navigate safely
  Future<void> _navigateSafely() async {
    final prefs = await SharedPreferences.getInstance();

    final isAlreadyGetStaerted =
        await prefs.getBool("hasSeenGetStarted") ?? false;

    if (isAlreadyGetStaerted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AppEntry()),
        (route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const GetStartedScreen()),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _safetyTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Stack(
        children: [
          /// Full screen background color
          Positioned.fill(child: Container(color: AppTheme.primaryColor)),

          /// Video player that fills entire screen
          if (_isVideoInitialized && _videoController != null)
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController!.value.size.width,
                  height: _videoController!.value.size.height,
                  child: VideoPlayer(_videoController!),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
