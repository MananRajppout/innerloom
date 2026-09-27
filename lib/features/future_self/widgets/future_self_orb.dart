import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_durations.dart';

/// Future Self, as presence.
///
/// The orb breathes. It does not spin, pulse, or decorate the screen.
class FutureSelfOrb extends StatefulWidget {
  const FutureSelfOrb({
    super.key,
    this.diameter = restingDiameter,
    this.semanticLabel = 'Future Self',
  });

  /// Core size when the screen has room for the full presence.
  static const double restingDiameter = 156;

  /// How far the glow extends past the core, as a multiple of [restingDiameter].
  static const double glowFactor = 2.15;

  /// Diameter of the core. The glow extends past it.
  final double diameter;

  /// Spoken name. Pass an empty string when nearby text already names Future Self.
  final String semanticLabel;

  @override
  State<FutureSelfOrb> createState() => _FutureSelfOrbState();
}

class _FutureSelfOrbState extends State<FutureSelfOrb>
    with SingleTickerProviderStateMixin {
  static const double _breathFloor = 0.975;
  static const double _breathRise = 0.055;
  static const double _glowFloor = 0.18;
  static const double _glowRise = 0.28;
  static const double _restingBreath = 0.42;
  static const double _glowBlur = 48;
  static const double _glowSpread = 2;

  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: AppDurations.breath,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion) {
      _breath
        ..stop()
        ..value = _restingBreath;
      return;
    }
    if (!_breath.isAnimating) {
      _breath.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double extent = widget.diameter * FutureSelfOrb.glowFactor;
    final Widget orb = RepaintBoundary(
      child: SizedBox(
        width: extent,
        height: extent,
        child: AnimatedBuilder(
          animation: _breath,
          builder: (BuildContext context, Widget? child) {
            final double t = AppDurations.curve.transform(_breath.value);
            final double scale = _breathFloor + (_breathRise * t);
            final double glow = _glowFloor + (_glowRise * t);
            return Transform.scale(
              scale: scale,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Container(
                    width: widget.diameter * 1.95,
                    height: widget.diameter * 1.95,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: <Color>[
                          AppColors.orbGlow.withValues(alpha: glow * 0.55),
                          AppColors.orbGlow.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: widget.diameter * 1.35,
                    height: widget.diameter * 1.35,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: <Color>[
                          AppColors.orbMid.withValues(alpha: glow),
                          AppColors.orbMid.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: widget.diameter,
                    height: widget.diameter,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        center: Alignment(-0.28, -0.34),
                        radius: 0.9,
                        colors: <Color>[
                          AppColors.orbHighlight,
                          AppColors.orbMid,
                          AppColors.orbDeep,
                        ],
                        stops: <double>[0, 0.52, 1],
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: AppColors.orbGlow.withValues(alpha: glow),
                          blurRadius: _glowBlur,
                          spreadRadius: _glowSpread,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );

    if (widget.semanticLabel.isEmpty) {
      return ExcludeSemantics(child: orb);
    }

    return Semantics(label: widget.semanticLabel, image: true, child: orb);
  }
}
