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

  void back() {
    final OnboardingStep? previous = switch (state.step) {
      OnboardingStep.introduction => OnboardingStep.arrival,
      OnboardingStep.name => OnboardingStep.introduction,
      OnboardingStep.whatMatters => OnboardingStep.name,
      OnboardingStep.currentLoop => OnboardingStep.whatMatters,
      OnboardingStep.promise => OnboardingStep.currentLoop,
      OnboardingStep.permission => OnboardingStep.promise,
      OnboardingStep.complete => OnboardingStep.permission,
      OnboardingStep.arrival => null,
    };
    if (previous == null) {
      return;
    }
    state = state.copyWith(step: previous);
  }

  void submitName(String name) {
    if (state.step != OnboardingStep.name) {
      return;
    }
    final String trimmed = name.trim();
    if (trimmed.isEmpty) {
      return;
    }
    state = state.copyWith(name: trimmed, step: OnboardingStep.whatMatters);
  }

  void submitWhatMatters(String value) {
    if (state.step != OnboardingStep.whatMatters) {
      return;
    }
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
    if (state.step != OnboardingStep.currentLoop) {
      return;
    }
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return;
    }
    state = state.copyWith(currentLoop: trimmed, step: OnboardingStep.promise);
  }

  void chooseMemory(bool allowed) {
    if (state.step != OnboardingStep.permission) {
      return;
    }
    state = state.copyWith(
      mayRemember: allowed,
      updateMemory: true,
      step: OnboardingStep.complete,
    );
  }

  /// Records the end of arrival. False when this step cannot finish yet.
  bool beginToday() {
    if (state.step != OnboardingStep.complete) {
      return false;
    }
    if (!state.completed) {
      state = state.copyWith(completed: true);
    }
    return true;
  }
}
