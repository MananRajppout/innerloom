import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';
import 'quiet_scroll_behavior.dart';
import 'slow_fade_page_transition.dart';

/// Dark mode is the only theme. Light mode is intentionally absent.
abstract final class AppTheme {
  static ThemeData get dark {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.orbMid,
      onPrimary: AppColors.inkOnPresence,
      secondary: AppColors.orbDeep,
      onSecondary: AppColors.textPrimary,
      error: AppColors.error,
      onError: AppColors.onError,
      surface: AppColors.background,
      onSurface: AppColors.textPrimary,
      primaryContainer: AppColors.surface,
      onPrimaryContainer: AppColors.textPrimary,
      secondaryContainer: AppColors.surfaceRaised,
      onSecondaryContainer: AppColors.textPrimary,
      surfaceContainerLowest: AppColors.background,
      surfaceContainerLow: AppColors.backgroundLift,
      surfaceContainer: AppColors.surface,
      surfaceContainerHigh: AppColors.surfaceRaised,
      surfaceContainerHighest: AppColors.surfaceRaised,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineSoft,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      fontFamily: AppTypography.textFamily,
      textTheme: AppTypography.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      splashFactory: NoSplash.splashFactory,
      splashColor: const Color(0x00000000),
      highlightColor: const Color(0x00000000),
      hoverColor: const Color(0x0AF6F1E8),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: SlowFadePageTransitionsBuilder(),
          TargetPlatform.iOS: SlowFadePageTransitionsBuilder(),
          TargetPlatform.macOS: SlowFadePageTransitionsBuilder(),
          TargetPlatform.windows: SlowFadePageTransitionsBuilder(),
          TargetPlatform.linux: SlowFadePageTransitionsBuilder(),
          TargetPlatform.fuchsia: SlowFadePageTransitionsBuilder(),
        },
      ),
    );
  }

  static const ScrollBehavior scrollBehavior = QuietScrollBehavior();
}
