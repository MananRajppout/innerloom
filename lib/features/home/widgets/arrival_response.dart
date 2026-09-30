import 'package:flutter/material.dart';

import 'quiet_fade.dart';

/// One reply from Future Self, after the person says how they arrived.
class ArrivalResponse extends StatelessWidget {
  const ArrivalResponse({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return QuietFade(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }
}
