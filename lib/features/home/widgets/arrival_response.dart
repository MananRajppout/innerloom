import 'package:flutter/material.dart';

import '../../../theme/app_durations.dart';

/// One reply from Future Self, after the person says how they arrived.
class ArrivalResponse extends StatefulWidget {
  const ArrivalResponse({super.key, required this.text});

  final String text;

  @override
  State<ArrivalResponse> createState() => _ArrivalResponseState();
}

class _ArrivalResponseState extends State<ArrivalResponse> {
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
      child: Text(
        widget.text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }
}
