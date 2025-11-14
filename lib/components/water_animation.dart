import 'package:flutter/material.dart';

class WaterAddedAnimation extends StatefulWidget {
  final VoidCallback onAnimationFinished;

  const WaterAddedAnimation({super.key, required this.onAnimationFinished});

  @override
  State<WaterAddedAnimation> createState() => _WaterAddedAnimationState();
}

class _WaterAddedAnimationState extends State<WaterAddedAnimation>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scale = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _controller.forward();

    // Quand l’animation se termine → on ferme
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 300), () {
          widget.onAnimationFinished();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Colors.blueAccent,
                blurRadius: 30,
                spreadRadius: 5,
              )
            ],
          ),
          child: const Icon(
            Icons.water_drop,
            size: 80,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }
}
