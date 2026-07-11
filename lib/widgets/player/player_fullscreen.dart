import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'player_controls.dart';
import 'player_buffer.dart';

/// A reusable, production-ready fullscreen controller and route manager.
/// Optimally handles system navigation, orientation changes (Portrait/Landscape),
/// and locks back gestures so that pressing "back" exits fullscreen instead of closing the app.
class PlayerFullscreen {
  // Prevent instantiation
  const PlayerFullscreen._();

  /// Enters fullscreen mode by pushing a dedicated [PlayerFullscreenPage] route.
  /// Seamlessly takes the existing [Player] and [VideoController] so that video
  /// playback continues without interruption or buffering.
  static Future<void> enter({
    required BuildContext context,
    required Player player,
    required VideoController controller,
    required String streamUrl,
  }) async {
    // Hide standard System UI overlays for immersive viewing
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Enable both Landscape and Portrait orientations for flexible full-screen rotation
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);

    if (!context.mounted) return;

    // Push the fullscreen route
    await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        pageBuilder: (context, animation, secondaryAnimation) {
          return PlayerFullscreenPage(
            player: player,
            controller: controller,
            streamUrl: streamUrl,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );

    // RESTORE orientations and System UI when exiting fullscreen
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }
}

/// Dedicated immersive overlay page for fullscreen playback.
class PlayerFullscreenPage extends StatefulWidget {
  final Player player;
  final VideoController controller;
  final String streamUrl;

  const PlayerFullscreenPage({
    super.key,
    required this.player,
    required this.controller,
    required this.streamUrl,
  });

  @override
  State<PlayerFullscreenPage> createState() => _PlayerFullscreenPageState();
}

class _PlayerFullscreenPageState extends State<PlayerFullscreenPage> {
  bool _showControls = true;
  Timer? _controlsTimer;
  bool _isLandscape = true;
  bool _isBuffering = false;
  StreamSubscription? _bufferingSubscription;

  @override
  void initState() {
    super.initState();
    _startControlsTimer();

    // Auto-detect initial orientation aspect ratios
    _updateOrientationStatus();

    // Listen to buffering state to display custom PlayerBuffer overlay
    _bufferingSubscription = widget.player.stream.buffering.listen((buffering) {
      if (mounted) {
        setState(() {
          _isBuffering = buffering;
        });
      }
    });
  }

  void _updateOrientationStatus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final orientation = MediaQuery.of(context).orientation;
      setState(() {
        _isLandscape = orientation == Orientation.landscape;
      });
    });
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    _bufferingSubscription?.cancel();
    super.dispose();
  }

  /// Start or refresh the timer to automatically hide interactive controls
  void _startControlsTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  /// Manually toggle control HUD visibility
  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startControlsTimer();
    }
  }

  /// Rotate display manually between Landscape and Portrait
  Future<void> _toggleManualOrientation() async {
    _startControlsTimer();
    if (_isLandscape) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
    setState(() {
      _isLandscape = !_isLandscape;
    });
  }

  /// Safe pop handler that returns to normal inline player mode
  void _exitFullscreen() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to orientation updates reactively
    final currentOrientation = MediaQuery.of(context).orientation;
    final isCurrentlyLandscape = currentOrientation == Orientation.landscape;

    return PopScope(
      canPop: false, // Prevent default system back gesture from bypassing exit routine
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _exitFullscreen();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          top: !isCurrentlyLandscape,
          bottom: !isCurrentlyLandscape,
          left: !isCurrentlyLandscape,
          right: !isCurrentlyLandscape,
          child: PlayerBuffer(
            isBuffering: _isBuffering,
            message: 'Optimizing buffer for high-fidelity fullscreen stream...',
            child: GestureDetector(
              onTap: _toggleControls,
              onDoubleTap: () {
                widget.player.playOrPause();
                setState(() {
                  _showControls = true;
                });
                _startControlsTimer();
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Fullscreen hardware video canvas
                  Center(
                    child: Hero(
                      tag: 'fullscreen_video_hero',
                      child: AspectRatio(
                        aspectRatio: isCurrentlyLandscape ? 16 / 9 : 9 / 16,
                        child: Video(
                          controller: widget.controller,
                          controls: null, // Custom overlay controls are used instead
                        ),
                      ),
                    ),
                  ),

                  // Immersive HUD controls
                  PlayerControls(
                    player: widget.player,
                    visible: _showControls,
                    streamUrl: widget.streamUrl,
                    onUserInteraction: _startControlsTimer,
                  ),

                  // Dedicated Fullscreen controls (Exit and Orientation locks)
                  AnimatedOpacity(
                    opacity: _showControls ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: IgnorePointer(
                      ignoring: !_showControls,
                      child: Stack(
                        children: [
                          // Top Right Corner Action Toolbar
                          Positioned(
                            top: 12.0,
                            right: 16.0,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Toggle Orientation Button
                                Container(
                                  margin: const EdgeInsets.only(right: 8.0),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.borderTranslucent,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: IconButton(
                                    tooltip: 'Rotate Orientation',
                                    icon: Icon(
                                      isCurrentlyLandscape
                                          ? Icons.screen_lock_portrait_rounded
                                          : Icons.screen_lock_landscape_rounded,
                                      color: Colors.white,
                                      size: 20.0,
                                    ),
                                    onPressed: _toggleManualOrientation,
                                  ),
                                ),

                                // Exit Fullscreen Button
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.borderTranslucent,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: IconButton(
                                    tooltip: 'Exit Fullscreen',
                                    icon: const Icon(
                                      Icons.fullscreen_exit_rounded,
                                      color: AppColors.primary,
                                      size: 22.0,
                                    ),
                                    onPressed: _exitFullscreen,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Top Left Navigation Title Overlay override
                          Positioned(
                            top: 12.0,
                            left: 16.0,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.borderTranslucent,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: IconButton(
                                    tooltip: 'Go Back',
                                    icon: const Icon(
                                      Icons.arrow_back_rounded,
                                      color: Colors.white,
                                      size: 20.0,
                                    ),
                                    onPressed: _exitFullscreen,
                                  ),
                                ),
                                const SizedBox(width: 10.0),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 4.0),
                                  decoration: BoxDecoration(
                                    color: Colors.black87,
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  child: Text(
                                    'FULLSCREEN MODE',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10.0,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
