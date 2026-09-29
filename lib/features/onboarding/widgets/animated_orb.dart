import 'package:flutter/material.dart';

import '../../../theme/app_durations.dart';
import '../../future_self/widgets/future_self_orb.dart';

/// The orb for this arrival. It stays mounted so the breath is never restarted.
class AnimatedOrb extends StatelessWidget {
  const AnimatedOrb({
    super.key,
    required this.diameter,
    this.emphasis = 0,
  });

  /// Size while words share the screen.
  static const double conversationDiameter = 104;

  final double diameter;
  final double emphasis;

  @override
  Widget build(BuildContext context) {
    final Duration duration = AppDurations.resolve(context, AppDurations.fade);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: diameter),
      duration: duration,
      curve: AppDurations.curve,
      builder: (BuildContext context, double size, Widget? child) {
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(end: emphasis),
          duration: duration,
          curve: AppDurations.curve,
          builder: (BuildContext context, double glow, Widget? child) {
            return FutureSelfOrb(
              diameter: size,
              emphasis: glow,
              semanticLabel: 'Future Self',
            );
          },
        );
      },
    );
  }
}
