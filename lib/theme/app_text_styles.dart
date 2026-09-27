import 'package:flutter/material.dart';

/// Fraunces for the human voice. Nunito Sans for everything else.
///
/// Fraunces is a soft serif, closer to a journal than to a product UI.
/// Nunito Sans stays readable and warm at small sizes.
abstract final class AppTextStyles {
  static const String displayFamily = 'Fraunces';
  static const String textFamily = 'NunitoSans';

  static TextTheme get textTheme {
    return TextTheme(
      displayLarge: _display(size: 48, height: 1.15),
      displayMedium: _display(size: 40, height: 1.18),
      headlineLarge: _display(size: 34, height: 1.2),
      headlineMedium: _display(size: 28, height: 1.25),
      headlineSmall: _display(size: 22, height: 1.3),
      titleLarge: _display(size: 20, height: 1.35),
      titleMedium: _text(size: 16, weight: FontWeight.w600, height: 1.4),
      titleSmall: _text(size: 14, weight: FontWeight.w600, height: 1.4),
      bodyLarge: _text(size: 17, height: 1.55),
      bodyMedium: _text(size: 15, height: 1.55),
      bodySmall: _text(size: 13, height: 1.5),
      labelLarge: _text(
        size: 13,
        weight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 1.4,
      ),
      labelMedium: _text(
        size: 12,
        weight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 1.2,
      ),
      labelSmall: _text(
        size: 11,
        weight: FontWeight.w500,
        height: 1.2,
        letterSpacing: 1.1,
      ),
    );
  }

  static TextStyle _display({
    required double size,
    required double height,
  }) {
    return TextStyle(
      fontFamily: displayFamily,
      fontWeight: FontWeight.w500,
      fontSize: size,
      height: height,
      letterSpacing: -0.4,
    );
  }

  static TextStyle _text({
    required double size,
    required double height,
    FontWeight weight = FontWeight.w400,
    double letterSpacing = 0,
  }) {
    return TextStyle(
      fontFamily: textFamily,
      fontWeight: weight,
      fontSize: size,
      height: height,
      letterSpacing: letterSpacing,
    );
  }
}
