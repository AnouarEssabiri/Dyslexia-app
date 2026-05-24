import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Premium Animation Helper Widgets
/// Using flutter_animate for declarative and powerful animations

enum SlideDirection { up, down, left, right }

class PremiumAnimation extends StatelessWidget {

  const PremiumAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.delay = Duration.zero,
    this.slide = true,
    this.slideDirection = SlideDirection.up,
    this.slideOffset = 20.0,
    this.fade = true,
    this.scale = false,
    this.blur = false,
  });
  final Widget child;
  final Duration duration;
  final Duration delay;
  final bool slide;
  final SlideDirection slideDirection;
  final double slideOffset;
  final bool fade;
  final bool scale;
  final bool blur;

  @override
  Widget build(BuildContext context) {
    Animate animate = child.animate(delay: delay);

    if (fade) {
      animate = animate.fadeIn(duration: duration, curve: Curves.easeOutCubic);
    }

    if (slide) {
      Offset begin;
      switch (slideDirection) {
        case SlideDirection.up:
          begin = Offset(0, slideOffset);
          break;
        case SlideDirection.down:
          begin = Offset(0, -slideOffset);
          break;
        case SlideDirection.left:
          begin = Offset(slideOffset, 0);
          break;
        case SlideDirection.right:
          begin = Offset(-slideOffset, 0);
          break;
      }
      animate = animate.slide(
        begin: begin / 100, // Normalize for flutter_animate
        duration: duration,
        curve: Curves.easeOutCubic,
      );
    }

    if (scale) {
      animate = animate.scale(
        begin: const Offset(0.9, 0.9),
        duration: duration,
        curve: Curves.easeOutCubic,
      );
    }

    if (blur) {
      animate = animate.blur(
        begin: const Offset(10, 10),
        end: Offset.zero,
        duration: duration,
        curve: Curves.easeOutCubic,
      );
    }

    return animate;
  }
}

/// Shimmer Effect for Loading States
class PremiumShimmer extends StatelessWidget {

  const PremiumShimmer({
    super.key,
    required this.child,
    this.enabled = true,
  });
  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    
    return child.animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: const Duration(milliseconds: 1500),
          color: Colors.white.withValues(alpha: 0.5),
        );
  }
}
