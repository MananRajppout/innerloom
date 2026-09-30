import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_durations.dart';
import 'models/onboarding_answers.dart';
import 'onboarding_script.dart';
import 'providers/onboarding_controller.dart';
import 'screens/arrival_page.dart';
import 'screens/choice_page.dart';
import 'screens/name_page.dart';
import 'screens/spoken_page.dart';
import 'widgets/minimal_button.dart';

/// The words of arrival. The orb lives in the shell around this route.
class OnboardingFlow extends ConsumerWidget {
  const OnboardingFlow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final OnboardingAnswers answers = ref.watch(onboardingProvider);

    ref.listen<OnboardingStep>(
      onboardingProvider.select((OnboardingAnswers answers) => answers.step),
      (OnboardingStep? previous, OnboardingStep next) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
    );

    final OnboardingController controller = ref.read(
      onboardingProvider.notifier,
    );

    return _FadingStep(
      step: answers.step,
      allowExit: answers.step == OnboardingStep.arrival,
      onBack: controller.back,
      child: _page(answers, controller),
    );
  }

  Widget _page(OnboardingAnswers answers, OnboardingController controller) {
    final OnboardingStep step = answers.step;
    return switch (step) {
      OnboardingStep.arrival => ArrivalPage(onBegin: controller.advance),
      OnboardingStep.introduction => SpokenPage(
        lines: OnboardingScript.introduction,
        instant: answers.heard.contains(OnboardingStep.introduction),
        onHeard: () => controller.hear(OnboardingStep.introduction),
        footer: (BuildContext context) {
          return MinimalButton(
            label: 'Continue',
            onPressed: controller.advance,
          );
        },
      ),
      OnboardingStep.name => NamePage(
        initialName: answers.name,
        onSubmit: controller.submitName,
      ),
      OnboardingStep.whatMatters => ChoicePage(
        question: OnboardingScript.mattersQuestion,
        options: OnboardingScript.matters,
        hint: OnboardingScript.ownWords,
        initialAnswer: answers.whatMatters,
        onSubmit: controller.submitWhatMatters,
      ),
      OnboardingStep.currentLoop => ChoicePage(
        question: OnboardingScript.loopQuestion,
        options: OnboardingScript.loops,
        hint: OnboardingScript.ownWords,
        initialAnswer: answers.currentLoop,
        onSubmit: controller.submitCurrentLoop,
      ),
      OnboardingStep.promise => SpokenPage(
        lines: OnboardingScript.promise,
        instant: answers.heard.contains(OnboardingStep.promise),
        onHeard: () => controller.hear(OnboardingStep.promise),
        footer: (BuildContext context) {
          return MinimalButton(
            label: 'Continue',
            onPressed: controller.advance,
          );
        },
      ),
      OnboardingStep.permission => SpokenPage(
        lines: OnboardingScript.permission,
        instant: answers.heard.contains(OnboardingStep.permission),
        onHeard: () => controller.hear(OnboardingStep.permission),
        footer: (BuildContext context) {
          return PermissionActions(
            onYes: () => controller.chooseMemory(true),
            onNotYet: () => controller.chooseMemory(false),
          );
        },
      ),
      OnboardingStep.complete => SpokenPage(
        lines: answers.mayRemember == true
            ? OnboardingScript.thanks
            : OnboardingScript.thanksDeclined,
        instant: answers.heard.contains(OnboardingStep.complete),
        onHeard: () => controller.hear(OnboardingStep.complete),
        footer: (BuildContext context) {
          return MinimalButton(
            label: 'Begin Today',
            onPressed: () {
              if (!controller.beginToday()) {
                return;
              }
              context.go('/home');
            },
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
  const _FadingStep({
    required this.step,
    required this.child,
    required this.allowExit,
    required this.onBack,
  });

  final OnboardingStep step;
  final Widget child;
  final bool allowExit;
  final VoidCallback onBack;

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
    if (!mounted ||
        status != AnimationStatus.dismissed ||
        _pendingChild == null) {
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
    final bool outgoing = _pendingChild != null;
    return PopScope(
      canPop: widget.allowExit && !outgoing,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop || outgoing) {
          return;
        }
        widget.onBack();
      },
      child: ExcludeSemantics(
        excluding: outgoing,
        child: IgnorePointer(
          ignoring: outgoing,
          child: FadeTransition(
            opacity: _opacity,
            child: KeyedSubtree(
              key: ValueKey<OnboardingStep>(_step),
              child: _child,
            ),
          ),
        ),
      ),
    );
  }
}
