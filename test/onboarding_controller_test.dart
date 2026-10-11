import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loop_break/core/persistence/local_memory.dart';
import 'package:loop_break/features/onboarding/models/onboarding_answers.dart';
import 'package:loop_break/features/onboarding/providers/onboarding_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/memory_harness.dart';

void main() {
  test('controller methods ignore the wrong step', () async {
    final ProviderContainer container = ProviderContainer(
      overrides: memoryScope(await openMemory()),
    );
    addTearDown(container.dispose);
    final OnboardingController controller = container.read(
      onboardingProvider.notifier,
    );

    OnboardingAnswers read() => container.read(onboardingProvider);

    controller.submitName('Avery');
    controller.chooseMemory(true);
    expect(await controller.beginToday(), isFalse);
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

    expect(await controller.beginToday(), isTrue);
    expect(read().completed, isTrue);
    expect(await controller.beginToday(), isTrue);
  });

  test('a failed save does not finish arrival', () async {
    final SharedPreferences prefs = await openMemory();
    final ProviderContainer container = ProviderContainer(
      overrides: [
        ...memoryScope(prefs),
        localMemoryProvider.overrideWithValue(_UnsavedMemory(prefs)),
      ],
    );
    addTearDown(container.dispose);
    final OnboardingController controller = container.read(
      onboardingProvider.notifier,
    );
    controller.advance();
    controller.advance();
    controller.submitName('Avery');
    controller.submitWhatMatters('Peace');
    controller.submitCurrentLoop('Work');
    controller.advance();
    controller.chooseMemory(true);

    expect(await controller.beginToday(), isFalse);
    expect(container.read(onboardingProvider).completed, isFalse);
    expect(container.read(onboardingProvider).step, OnboardingStep.complete);
    expect(prefs.getBool('completed'), isNot(true));
  });
}

class _UnsavedMemory extends LocalMemory {
  _UnsavedMemory(super.prefs);

  @override
  Future<void> remember(OnboardingAnswers answers) {
    throw StateError('disk');
  }
}
