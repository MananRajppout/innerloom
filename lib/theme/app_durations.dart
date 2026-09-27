import 'package:flutter/widgets.dart';

/// Slow on purpose. The product should breathe, not snap.
///
/// [curve] lives here because every duration in the app uses this one easing.
abstract final class AppDurations {
  static const Duration breath = Duration(milliseconds: 5600);
  static const Duration entrance = Duration(milliseconds: 900);
  static const Duration fade = Duration(milliseconds: 700);

  static const Curve curve = Curves.easeInOut;

  static Duration resolve(BuildContext context, Duration duration) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return Duration.zero;
    }
    return duration;
  }
}
