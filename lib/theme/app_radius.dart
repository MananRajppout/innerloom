import 'package:flutter/widgets.dart';

/// Soft corners. Nothing sharp, nothing perfectly square.
abstract final class AppRadius {
  static const double sm = 16;
  static const double md = 24;
  static const double lg = 32;
  static const double pill = 999;

  static const BorderRadius borderSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius borderMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius borderLg = BorderRadius.all(Radius.circular(lg));
}
