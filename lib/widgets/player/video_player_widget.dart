import 'dart:async';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'player_error.dart';
import 'player_loading.dart';
import 'player_controls.dart';
import 'player_fullscreen.dart';

/// A reusable, production-ready video player component integrated with the MediaKit engine.
/// Optimally handles live streams (M3U8) and video on demand (MP4) assets.
class VideoPlayerWidget extends StatefulWidget {
  final String url;
  final bool autoPlay;
  final bool keepScreenAwake;

  const VideoPlayerWidget({
    super.key,
    required this.url,
    this.autoPlay = true,
    this.keepScreenAwake = true,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  Player? _player;
  VideoController? _controller;

  bool _isInitialized = false;
  bool _isLoading = true;
  String? _errorMessage;

  // Control overlay visibility state
  bool _showControls = true;
  Timer? _controlsTimer;

  // Stream subscriptions cache to prevent memory leaks
  StreamSubscription<bool>? _bufferingSubscription;
  StreamSubscription<dynamic>? _errorSubscription;

  // Flag to manage robust automatic retry exactly once on stream error
  bool _hasRetried = false;

  // Track the current stream URL being loaded to prevent async race conditions
  String? _loadingUrl;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _cleanupPlayer() {
    try {
      _bufferingSubscription?.cancel();
    } catch (e) {
      debugPrint('Error canceling buffering subscription: $e');
    }
    _bufferingSubscription = null;

    try {
      _errorSubscription?.cancel();
    } catch (e) {
      debugPrint('Error canceling error subscription: $e');
    }
    _errorSubscription = null;

    _controlsTimer?.cancel();
    _controlsTimer = null;

    try {
      _player?.dispose();
    } catch (e) {
      debugPrint('Error disposing player: $e');
    }
    _player = null;
    _controller = null;
  }

  /// Initialized the MediaKit player engine, configures state streams, opens the stream URL,
  /// and requests wakelocks to keep screen active.
  Future<void> _initializePlayer() async {
    if (!mounted) return;

    final currentUrl = widget.url;
    _loadingUrl = currentUrl;

    // Clean up any existing instances first to prevent resource & memory leaks
    _cleanupPlayer();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isInitialized = false;
    });

    try {
      // Safely ensure MediaKit native bridge dependencies are loaded
      try {
        MediaKit.ensureInitialized();
      } catch (e) {
        debugPrint('MediaKit.ensureInitialized error: $e');
      }

      final player = Player();
      final controller = VideoController(player);

      if (!mounted || _loadingUrl != currentUrl) {
        player.dispose();
        return;
      }

      // Listen to player buffering status to toggle Loading indicator dynamically with cached subscription
      _bufferingSubscription = player.stream.buffering.listen((isBuffering) {
        if (mounted && _isLoading != isBuffering) {
          setState(() {
            _isLoading = isBuffering;
          });
        }
      }, onError: (e) {
        debugPrint('Buffering stream error: $e');
      });

      // Listen to native stream playback errors with cached subscription and auto-retry once
      _errorSubscription = player.stream.error.listen((error) {
        if (mounted) {
          if (!_hasRetried) {
            _hasRetried = true;
            debugPrint('Video Player stream error: $error. Retrying stream once...');
            _initializePlayer();
          } else {
            setState(() {
              _errorMessage = 'Playback stream failure: ${error.toString()}';
              _isLoading = false;
            });
          }
        }
      }, onError: (e) {
        debugPrint('Player error stream error: $e');
      });

      // Apply screen wake configurations if requested
      if (widget.keepScreenAwake) {
        try {
          await WakelockPlus.enable();
        } catch (e) {
          debugPrint('WakelockPlus.enable error: $e');
        }
      }

      if (!mounted || _loadingUrl != currentUrl) {
        player.dispose();
        return;
      }

      // Pre-configure autoplay parameters
      if (!widget.autoPlay) {
        try {
          await player.setPlaying(false);
        } catch (e) {
          debugPrint('Error setting playing state: $e');
        }
      }

      if (!mounted || _loadingUrl != currentUrl) {
        player.dispose();
        return;
      }

      // Open the broadcast live feed or file media
      try {
        await player.open(Media(currentUrl));
      } catch (e) {
        if (!mounted || _loadingUrl != currentUrl) {
          player.dispose();
          return;
        }
        if (!_hasRetried) {
          _hasRetried = true;
          debugPrint('Initial stream open failed: $e. Retrying stream once...');
          _initializePlayer();
          return;
        } else {
          rethrow;
        }
      }

      if (!mounted || _loadingUrl != currentUrl) {
        player.dispose();
        return;
      }

      setState(() {
        _player = player;
        _controller = controller;
        _isInitialized = true;
        _isLoading = false;
      });
      _startControlsTimer();
    } catch (e) {
      if (mounted && _loadingUrl == currentUrl) {
        setState(() {
          _errorMessage = 'Failed to initialize player engine: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void didUpdateWidget(covariant VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _hasRetried = false; // Reset retry flag for new stream
      _loadNewStream();
    }
  }

  Future<void> _loadNewStream() async {
    if (_player == null) return;
    final currentUrl = widget.url;
    _loadingUrl = currentUrl;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      try {
        await _player!.open(Media(currentUrl));
      } catch (e) {
        if (!mounted || _loadingUrl != currentUrl) return;
        if (!_hasRetried) {
          _hasRetried = true;
          debugPrint('New stream open failed: $e. Retrying load once...');
          await _player!.open(Media(currentUrl));
        } else {
          rethrow;
        }
      }
      if (mounted && _loadingUrl == currentUrl) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted && _loadingUrl == currentUrl) {
        setState(() {
          _errorMessage = 'Failed to load stream: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  /// Cancels any active fade timers, disposes the native video controllers, 
  /// and releases system wakelocks.
  @override
  void dispose() {
    _cleanupPlayer();
    if (widget.keepScreenAwake) {
      try {
        WakelockPlus.disable();
      } catch (e) {
        debugPrint('WakelockPlus.disable error: $e');
      }
    }
    super.dispose();
  }

  /// Refreshes/cancels the visibility timer for the control overlay HUD
  void _startControlsTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _showControls) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  /// Toggles the interactive control HUD layout visibility
  void _toggleControlsOverlay() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startControlsTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLive = widget.url.toLowerCase().contains('.m3u8');

    // 1. Render active stream error state layout if failed
    if (_errorMessage != null) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: PlayerError(
          error: _errorMessage!,
          onRetry: _initializePlayer,
        ),
      );
    }

    // 2. Render initial loading screen prior to engine initialization
    if (!_isInitialized || _controller == null || _player == null) {
      return const AspectRatio(
        aspectRatio: 16 / 9,
        child: PlayerLoading(message: 'Initializing player engine...'),
      );
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: GestureDetector(
        onTap: _toggleControlsOverlay,
        onDoubleTap: () {
          _player?.playOrPause();
          if (!_showControls) {
            setState(() {
              _showControls = true;
            });
          }
          _startControlsTimer();
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Standard hardware-accelerated video renderer
            Container(
              color: Colors.black,
              width: double.infinity,
              height: double.infinity,
              child: Video(controller: _controller!),
            ),

            // Secondary buffering indicator overlay
            if (_isLoading)
              const Center(
                child: SizedBox(
                  width: 40.0,
                  height: 40.0,
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 3.0,
                  ),
                ),
              ),

            // Premium HUD Player Controls overlay (Play, Pause, Replay, autohide, timeline)
            PlayerControls(
              player: _player!,
              visible: _showControls,
              streamUrl: widget.url,
              onUserInteraction: _startControlsTimer,
            ),

            // Fullscreen trigger button overlay
            Positioned(
              bottom: isLive ? 12.0 : 56.0,
              right: 16.0,
              child: AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: IgnorePointer(
                  ignoring: !_showControls,
                  child: IconButton(
                    icon: const Icon(Icons.fullscreen_rounded, color: Colors.white, size: 24.0),
                    onPressed: () {
                      _startControlsTimer();
                      PlayerFullscreen.enter(
                        context: context,
                        player: _player!,
                        controller: _controller!,
                        streamUrl: widget.url,
                      );
                    },
                    tooltip: 'Fullscreen',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black54,
                      side: const BorderSide(color: AppColors.borderTranslucent, width: 1.0),
                      padding: const EdgeInsets.all(8.0),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
