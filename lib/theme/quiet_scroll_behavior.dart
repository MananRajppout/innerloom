import 'package:flutter/material.dart';

/// No glow and no bounce. Movement, when it happens, stays quiet.
class QuietScrollBehavior extends MaterialScrollBehavior {
  const QuietScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
