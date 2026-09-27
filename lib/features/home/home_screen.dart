import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/app_info.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/future_self_orb.dart';

/// The room you enter.
///
/// Rituals, memory, and emergency are later. This screen only holds presence.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.atmosphere),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screen,
                          vertical: AppSpacing.xxl,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 440),
                            child: TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0, end: 1),
                              duration: AppMotion.resolve(
                                context,
                                AppMotion.entrance,
                              ),
                              curve: AppMotion.curve,
                              builder:
                                  (
                                    BuildContext context,
                                    double value,
                                    Widget? child,
                                  ) {
                                    return Opacity(opacity: value, child: child);
                                  },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    AppInfo.name,
                                    textAlign: TextAlign.center,
                                    style: text.labelLarge?.copyWith(
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xl),
                                  LayoutBuilder(
                                    builder: (
                                      BuildContext context,
                                      BoxConstraints orbConstraints,
                                    ) {
                                      final double diameter = math.min(
                                        156,
                                        orbConstraints.maxWidth / 2.2,
                                      );
                                      return FutureSelfOrb(
                                        diameter: diameter,
                                        semanticLabel: '',
                                      );
                                    },
                                  ),
                                  const SizedBox(height: AppSpacing.xl),
                                  Text(
                                    'Future Self',
                                    textAlign: TextAlign.center,
                                    style: text.headlineMedium,
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    "I'm with you.",
                                    textAlign: TextAlign.center,
                                    style: text.bodyLarge?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
