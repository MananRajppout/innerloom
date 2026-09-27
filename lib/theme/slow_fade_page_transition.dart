import 'package:flutter/material.dart';

import 'app_motion.dart';

/// A fade with no slide and no bounce.
class SlowFadePageTransitionsBuilder extends PageTransitionsBuilder {
  const SlowFadePageTransitionsBuilder();

  @override
  Duration get transitionDuration => AppMotion.fade;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return _SlowFade(animation: animation, child: child);
  }
}

class _SlowFade extends StatefulWidget {
  const _SlowFade({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  State<_SlowFade> createState() => _SlowFadeState();
}

class _SlowFadeState extends State<_SlowFade> {
  late final CurvedAnimation _opacity = CurvedAnimation(
    parent: widget.animation,
    curve: AppMotion.curve,
    reverseCurve: AppMotion.curve,
  );

  @override
  void dispose() {
    _opacity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _opacity, child: widget.child);
  }
}
