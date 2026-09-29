import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_durations.dart';
import '../../theme/app_spacing.dart';
import '../future_self/widgets/future_self_orb.dart';
import 'models/onboarding_answers.dart';
import 'onboarding_script.dart';
import 'providers/onboarding_controller.dart';
import 'screens/arrival_page.dart';
import 'screens/choice_page.dart';
import 'screens/name_page.dart';
import 'screens/spoken_page.dart';
import 'widgets/animated_orb.dart';
import 'widgets/minimal_button.dart';

/// One route. The orb stays. Only the words change.
class OnboardingFlow extends ConsumerWidget {
  const OnboardingFlow({super.key});

  /// Tallest the room should grow, so a wide window still feels held.
  static const double stageHeight = 720;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final OnboardingStep step = ref.watch(
      onboardingProvider.select((OnboardingAnswers answers) => answers.step),
    );

    ref.listen<OnboardingStep>(
      onboardingProvider.select((OnboardingAnswers answers) => answers.step),
      (OnboardingStep? previous, OnboardingStep next) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
    );

    final OnboardingController controller = ref.read(
      onboardingProvider.notifier,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.atmosphere),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final bool keyboardOpen =
                  MediaQuery.viewInsetsOf(context).bottom > 0;
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
                OnboardingFlow.stageHeight,
              );
              return Align(
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: AppSpacing.content,
                    maxHeight: stageHeight,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(height: AppSpacing.lg),
                      AnimatedOrb(
                        diameter: diameter,
                        emphasis: step == OnboardingStep.complete ? 1 : 0,
                      ),
                      Expanded(
                        child: _FadingStep(
                          step: step,
                          child: _page(step, controller),
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

  Widget _page(OnboardingStep step, OnboardingController controller) {
    return switch (step) {
      OnboardingStep.arrival => ArrivalPage(onBegin: controller.advance),
      OnboardingStep.introduction => SpokenPage(
        lines: OnboardingScript.introduction,
        footer: (BuildContext context) {
          return MinimalButton(
            label: 'Continue',
            onPressed: controller.advance,
          );
        },
      ),
      OnboardingStep.name => NamePage(onSubmit: controller.submitName),
      OnboardingStep.whatMatters => ChoicePage(
        question: OnboardingScript.mattersQuestion,
        options: OnboardingScript.matters,
        hint: OnboardingScript.ownWords,
        onSubmit: controller.submitWhatMatters,
      ),
      OnboardingStep.currentLoop => ChoicePage(
        question: OnboardingScript.loopQuestion,
        options: OnboardingScript.loops,
        hint: OnboardingScript.ownWords,
        onSubmit: controller.submitCurrentLoop,
      ),
      OnboardingStep.promise => SpokenPage(
        lines: OnboardingScript.promise,
        footer: (BuildContext context) {
          return MinimalButton(
            label: 'Continue',
            onPressed: controller.advance,
          );
        },
      ),
      OnboardingStep.permission => SpokenPage(
        lines: OnboardingScript.permission,
        footer: (BuildContext context) {
          return PermissionActions(
            onYes: () => controller.chooseMemory(true),
            onNotYet: () => controller.chooseMemory(false),
          );
        },
      ),
      OnboardingStep.complete => SpokenPage(
        lines: OnboardingScript.thanks,
        footer: (BuildContext context) {
          return MinimalButton(
            label: 'Begin Today',
            onPressed: controller.beginToday,
          );
        },
      ),
    };
  }
}

/// Fades the current words out, then the next words in.
///
/// Only one step is mounted, so the screen never speaks twice at once.
class _FadingStep extends StatefulWidget {
  const _FadingStep({required this.step, required this.child});

  final OnboardingStep step;
  final Widget child;

  @override
  State<_FadingStep> createState() => _FadingStepState();
}

class _FadingStepState extends State<_FadingStep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fade;
  late final CurvedAnimation _opacity;
  late OnboardingStep _step;
  late Widget _child;
  OnboardingStep? _pendingStep;
  Widget? _pendingChild;

  @override
  void initState() {
    super.initState();
    _step = widget.step;
    _child = widget.child;
    _fade = AnimationController(
      vsync: this,
      duration: AppDurations.fade,
      value: 1,
    );
    _opacity = CurvedAnimation(parent: _fade, curve: AppDurations.curve);
    _fade.addStatusListener(_onStatus);
  }

  @override
  void didUpdateWidget(_FadingStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.step == _step || widget.step == _pendingStep) {
      if (widget.step == _step && _pendingChild == null) {
        _child = widget.child;
      }
      return;
    }
    final Duration duration = AppDurations.resolve(context, AppDurations.fade);
    if (duration == Duration.zero) {
      _step = widget.step;
      _child = widget.child;
      _pendingStep = null;
      _pendingChild = null;
      _fade.value = 1;
      return;
    }
    _pendingStep = widget.step;
    _pendingChild = widget.child;
    _fade.duration = duration;
    _fade.reverseDuration = duration;
    _fade.reverse();
  }

  void _onStatus(AnimationStatus status) {
    if (!mounted || status != AnimationStatus.dismissed || _pendingChild == null) {
      return;
    }
    setState(() {
      _step = _pendingStep!;
      _child = _pendingChild!;
      _pendingStep = null;
      _pendingChild = null;
    });
    _fade.forward();
  }

  @override
  void dispose() {
    _fade.removeStatusListener(_onStatus);
    _opacity.dispose();
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: KeyedSubtree(key: ValueKey<OnboardingStep>(_step), child: _child),
    );
  }
}
