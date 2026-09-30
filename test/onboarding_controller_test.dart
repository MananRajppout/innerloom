import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loop_break/features/onboarding/models/onboarding_answers.dart';
import 'package:loop_break/features/onboarding/providers/onboarding_controller.dart';

void main() {
  test('controller methods ignore the wrong step', () {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);
    final OnboardingController controller = container.read(
      onboardingProvider.notifier,
    );

    OnboardingAnswers read() => container.read(onboardingProvider);

    controller.submitName('Avery');
    controller.chooseMemory(true);
    controller.beginToday();
    controller.back();

    expect(read().step, OnboardingStep.arrival);
    expect(read().name, isEmpty);
    expect(read().mayRemember, isNull);
    expect(read().completed, isFalse);

    controller.advance();
    controller.advance();
    controller.submitName('  Avery  ');
    controller.submitName('Someone else');

    expect(read().name, 'Avery');
    expect(read().step, OnboardingStep.whatMatters);

    controller.submitCurrentLoop('Fear');
    expect(read().currentLoop, isEmpty);
    expect(read().step, OnboardingStep.whatMatters);

    controller.submitWhatMatters('Peace');
    controller.back();
    expect(read().step, OnboardingStep.whatMatters);
    expect(read().whatMatters, 'Peace');

    controller.submitWhatMatters('Family');
    controller.submitCurrentLoop('Work');
    controller.chooseMemory(false);
    expect(read().step, OnboardingStep.promise);

    controller.advance();
    controller.chooseMemory(false);
    expect(read().mayRemember, isFalse);
    expect(read().step, OnboardingStep.complete);

    controller.chooseMemory(true);
    expect(read().mayRemember, isFalse);

    expect(controller.beginToday(), isTrue);
    expect(read().completed, isTrue);
    expect(controller.beginToday(), isTrue);
  });
}
