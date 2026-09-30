import 'package:flutter/material.dart';

import '../../../theme/app_durations.dart';

/// A slow fade in. Later rebuilds do not play it again.
class QuietFade extends StatefulWidget {
  const QuietFade({super.key, required this.child});

  final Widget child;

  @override
  State<QuietFade> createState() => _QuietFadeState();
}

class _QuietFadeState extends State<QuietFade> {
  double _opacity = 0;
  bool _armed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_armed) {
      return;
    }
    _armed = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _opacity = 1;
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _opacity = 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: AppDurations.resolve(context, AppDurations.fade),
      curve: AppDurations.curve,
      child: widget.child,
    );
  }
}
