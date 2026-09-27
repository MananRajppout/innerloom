import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_durations.dart';
import 'app_text_styles.dart';

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
      fontFamily: AppTextStyles.textFamily,
      textTheme: AppTextStyles.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: AppColors.textPrimary.withValues(alpha: 0.04),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: _SlowFadePageTransitionsBuilder(),
          TargetPlatform.iOS: _SlowFadePageTransitionsBuilder(),
          TargetPlatform.macOS: _SlowFadePageTransitionsBuilder(),
          TargetPlatform.windows: _SlowFadePageTransitionsBuilder(),
          TargetPlatform.linux: _SlowFadePageTransitionsBuilder(),
          TargetPlatform.fuchsia: _SlowFadePageTransitionsBuilder(),
        },
      ),
    );
  }

  static const ScrollBehavior scrollBehavior = _QuietScrollBehavior();
}

/// A fade with no slide and no bounce.
class _SlowFadePageTransitionsBuilder extends PageTransitionsBuilder {
  const _SlowFadePageTransitionsBuilder();

  @override
  Duration get transitionDuration => AppDurations.fade;

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
    curve: AppDurations.curve,
    reverseCurve: AppDurations.curve,
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

/// No glow and no bounce. Movement, when it happens, stays quiet.
class _QuietScrollBehavior extends MaterialScrollBehavior {
  const _QuietScrollBehavior();

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
