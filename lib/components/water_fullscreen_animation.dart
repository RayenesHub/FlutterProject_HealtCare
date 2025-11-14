import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class WaterFullScreenAnimation extends StatefulWidget {
  final VoidCallback onFinished;

  const WaterFullScreenAnimation({super.key, required this.onFinished});

  @override
  State<WaterFullScreenAnimation> createState() =>
      _WaterFullScreenAnimationState();
}

class _WaterFullScreenAnimationState extends State<WaterFullScreenAnimation>
    with TickerProviderStateMixin {
  late AnimationController _riseCtrl;
  late VideoPlayerController _videoCtrl;

  @override
  void initState() {
    super.initState();

    // montée de l’eau
    _riseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward().whenComplete(widget.onFinished);

    // vidéo réaliste
    _videoCtrl = VideoPlayerController.asset("assets/videos/water.mp4")
      ..setLooping(true)
      ..setVolume(0)
      ..initialize().then((_) {
        _videoCtrl.play();
        setState(() {});
      });
  }

  @override
  void dispose() {
    _riseCtrl.dispose();
    _videoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return IgnorePointer( // empêche interaction
      child: AnimatedBuilder(
        animation: _riseCtrl,
        builder: (_, __) {
          final h = screenHeight * _riseCtrl.value;

          return Stack(
            children: [
              // FILTRE BLEUTÉ TRANSPARENT
              Container(
                color: Colors.blue.withOpacity(0.05),
              ),

              // EAU RÉALISTE QUI MONTE
              Align(
                alignment: Alignment.bottomCenter,
                child: ClipRect(
                  child: SizedBox(
                    height: h,
                    width: double.infinity,
                    child: Opacity(
                      opacity: 0.85, // eau visible mais interface visible aussi
                      child: _videoCtrl.value.isInitialized
                          ? FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _videoCtrl.value.size.width,
                          height: _videoCtrl.value.size.height,
                          child: VideoPlayer(_videoCtrl),
                        ),
                      )
                          : const SizedBox(),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
