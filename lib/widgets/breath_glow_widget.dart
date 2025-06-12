import 'package:flutter/material.dart';

class BreathGlowController {
  final int breathCount;
  final Duration duration;
  final double maxOpacity;
  final VoidCallback? onBreathComplete;

  BreathGlowController({
    this.breathCount = 4,
    this.duration = const Duration(seconds: 1),
    this.maxOpacity = 0.2,
    this.onBreathComplete,
  });

  AnimationController? _controller;
  Animation<double>? _animation;
  int _currentBreathCount = 0;
  bool _isAnimating = false;

  void init(TickerProvider vsync) {
    _controller = AnimationController(
      duration: duration,
      vsync: vsync,
    );

    _animation = Tween<double>(begin: 0.0, end: maxOpacity).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: Curves.easeInOut,
      ),
    );

    _controller!.addStatusListener(_handleAnimationStatus);
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _currentBreathCount++;
      if (_currentBreathCount >= breathCount) {
        _controller?.reset();
        _currentBreathCount = 0;
        _isAnimating = false;
        onBreathComplete?.call();
      } else {
        _controller?.reverse();
      }
    } else if (status == AnimationStatus.dismissed && _currentBreathCount < breathCount) {
      _controller?.forward();
    }
  }

  void start() {
    if (_controller != null) {
      _controller?.reset();
      _currentBreathCount = 0;
      _isAnimating = true;
      _controller!.forward();
    }
  }

  void stop() {
    _controller?.stop();
    _controller?.reset();
    _currentBreathCount = 0;
    _isAnimating = false;
  }

  bool get isAnimating => _isAnimating;
  Animation<double> get animation => _animation ?? kAlwaysCompleteAnimation;
  double get opacity => _animation?.value ?? 0.0;

  void dispose() {
    _controller?.dispose();
    _controller = null;
    _animation = null;
  }
}

class BreathGlowWidget extends StatefulWidget {
  final BreathGlowController controller;
  final Widget child;
  final Color glowColor;
  final double blurRadius;
  final double spreadRadius;

  const BreathGlowWidget({
    super.key,
    required this.controller,
    required this.child,
    required this.glowColor,
    this.blurRadius = 6.0,
    this.spreadRadius = 0.5,
  });

  @override
  State<BreathGlowWidget> createState() => _BreathGlowWidgetState();
}

class _BreathGlowWidgetState extends State<BreathGlowWidget> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    widget.controller.init(this);
    widget.controller.start();
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller.animation,
      builder: (context, child) {
        final opacity = widget.controller.opacity;
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withOpacity(opacity),
                blurRadius: widget.blurRadius * opacity * 2,
                spreadRadius: widget.spreadRadius * opacity * 2,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
