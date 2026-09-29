import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/onboarding_answers.dart';

/// In-memory arrival. Nothing is sent anywhere yet.
final NotifierProvider<OnboardingController, OnboardingAnswers>
onboardingProvider = NotifierProvider<OnboardingController, OnboardingAnswers>(
  OnboardingController.new,
);

class OnboardingController extends Notifier<OnboardingAnswers> {
  @override
  OnboardingAnswers build() => const OnboardingAnswers();

  void advance() {
    final OnboardingStep? next = switch (state.step) {
      OnboardingStep.arrival => OnboardingStep.introduction,
      OnboardingStep.introduction => OnboardingStep.name,
      OnboardingStep.promise => OnboardingStep.permission,
      _ => null,
    };
    if (next == null) {
      return;
    }
    state = state.copyWith(step: next);
  }

  void submitName(String name) {
    final String trimmed = name.trim();
    if (trimmed.isEmpty) {
      return;
    }
    state = state.copyWith(name: trimmed, step: OnboardingStep.whatMatters);
  }

  void submitWhatMatters(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return;
    }
    state = state.copyWith(
      whatMatters: trimmed,
      step: OnboardingStep.currentLoop,
    );
  }

  void submitCurrentLoop(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return;
    }
    state = state.copyWith(
      currentLoop: trimmed,
      step: OnboardingStep.promise,
    );
  }

  void chooseMemory(bool allowed) {
    state = state.copyWith(
      mayRemember: allowed,
      updateMemory: true,
      step: OnboardingStep.complete,
    );
  }

  void beginToday() {
    state = state.copyWith(completed: true);
  }
}
