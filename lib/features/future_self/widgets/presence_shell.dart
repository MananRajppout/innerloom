import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../onboarding/models/onboarding_answers.dart';
import '../../onboarding/providers/onboarding_controller.dart';
import '../../onboarding/widgets/animated_orb.dart';
import 'future_self_orb.dart';

/// The room Future Self stays in. Words change. The orb does not.
class PresenceShell extends ConsumerWidget {
  const PresenceShell({super.key, required this.child});

  /// Tallest the room should grow, so a wide window still feels held.
  static const double stageHeight = 720;

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final OnboardingStep step = ref.watch(
      onboardingProvider.select((OnboardingAnswers answers) => answers.step),
    );
    final bool present = step == OnboardingStep.complete;
    // The scaffold consumes the inset, so this has to be read above it.
    final bool keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.atmosphere),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double desired = keyboardOpen
                  ? AppSpacing.xxxl
                  : AnimatedOrb.conversationDiameter;
              final double available =
                  constraints.maxWidth - (AppSpacing.screen * 2);
              final double diameter = math.min(
                desired,
                available / FutureSelfOrb.glowFactor,
              );
              final double stageHeight = math.min(
                constraints.maxHeight,
                PresenceShell.stageHeight,
              );
              return Align(
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: AppSpacing.content,
                    maxHeight: stageHeight,
                  ),
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: AppSpacing.lg),
                      AnimatedOrb(
                        diameter: diameter,
                        emphasis: present ? 1 : 0,
                      ),
                      Expanded(child: child),
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
