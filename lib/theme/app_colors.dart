import 'package:flutter/material.dart';

/// Warm dark palette.
///
/// The room is a soft charcoal, never pure black and never a cold blue.
/// The apricot tones belong to Future Self. They are presence, not accent chrome.
abstract final class AppColors {
  static const Color background = Color(0xFF161311);
  static const Color backgroundLift = Color(0xFF231F1B);
  static const Color surface = Color(0xFF2C2722);
  static const Color surfaceRaised = Color(0xFF383229);
  static const Color outline = Color(0xFF4A433A);
  static const Color outlineSoft = Color(0xFF3A342C);

  static const Color textPrimary = Color(0xFFF6F1E8);
  static const Color textSecondary = Color(0xFFC9BBA8);
  static const Color textTertiary = Color(0xFF8F8274);

  static const Color orbHighlight = Color(0xFFF8DCC4);
  static const Color orbMid = Color(0xFFE3A87C);
  static const Color orbDeep = Color(0xFFB56B4C);
  static const Color orbGlow = Color(0xFFE8B48A);
  static const Color inkOnPresence = Color(0xFF2A1812);

  /// Quiet enough that a future error does not feel like an alarm.
  static const Color error = Color(0xFFD4A194);
  static const Color onError = Color(0xFF2C1612);

  static const RadialGradient atmosphere = RadialGradient(
    center: Alignment(0, -0.35),
    radius: 1.15,
    colors: <Color>[backgroundLift, background],
    stops: <double>[0, 0.72],
  );
}
