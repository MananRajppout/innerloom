import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loop_break/app.dart';
import 'package:loop_break/features/home/home_script.dart';
import 'package:loop_break/features/home/home_visit.dart';
import 'package:loop_break/features/onboarding/models/onboarding_answers.dart';
import 'package:loop_break/features/onboarding/providers/onboarding_controller.dart';
import 'package:loop_break/routing/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/memory_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a first launch has nothing to restore', () async {
    final SharedPreferences prefs = await openMemory();
    final ProviderContainer container = ProviderContainer(
      overrides: memoryScope(prefs),
    );
    addTearDown(container.dispose);

    final OnboardingAnswers answers = container.read(onboardingProvider);
    expect(answers.completed, isFalse);
    expect(answers.step, OnboardingStep.arrival);
    expect(answers.name, isEmpty);
    expect(container.read(homeVisitProvider), isFalse);
    expect(prefs.getKeys(), isEmpty);
  });

  test('finishing arrival keeps the name when memory was allowed', () async {
    final SharedPreferences prefs = await openMemory();
    final ProviderContainer container = ProviderContainer(
      overrides: memoryScope(prefs),
    );
    addTearDown(container.dispose);

    await _finish(container, remember: true);

    expect(prefs.getBool('completed'), isTrue);
    expect(prefs.getBool('mayRemember'), isTrue);
    expect(prefs.getString('name'), 'Avery');
    expect(prefs.getString('whatMatters'), 'Peace');
    expect(prefs.getString('currentLoop'), 'Work');
  });

  test(
    'a refusal keeps arrival finished and drops the personal answers',
    () async {
      final SharedPreferences prefs = await openMemory();
      final ProviderContainer container = ProviderContainer(
        overrides: memoryScope(prefs),
      );
      addTearDown(container.dispose);

      await _finish(container, remember: false);

      expect(container.read(onboardingProvider).name, 'Avery');
      expect(prefs.getBool('completed'), isTrue);
      expect(prefs.getBool('mayRemember'), isFalse);
      expect(prefs.getString('name'), isNull);
      expect(prefs.getString('whatMatters'), isNull);
      expect(prefs.getString('currentLoop'), isNull);
    },
  );

  test('a restart restores only what was kept', () async {
    final SharedPreferences prefs = await openMemory();
    final ProviderContainer first = ProviderContainer(
      overrides: memoryScope(prefs),
    );
    await _finish(first, remember: true);
    await first.read(homeVisitProvider.notifier).mark();
    first.dispose();

    final ProviderContainer second = ProviderContainer(
      overrides: memoryScope(prefs),
    );
    addTearDown(second.dispose);

    final OnboardingAnswers restored = second.read(onboardingProvider);
    expect(restored.completed, isTrue);
    expect(restored.step, OnboardingStep.complete);
    expect(restored.mayRemember, isTrue);
    expect(restored.name, 'Avery');
    expect(restored.whatMatters, 'Peace');
    expect(restored.currentLoop, 'Work');
    expect(second.read(homeVisitProvider), isTrue);
  });

  test('a refusal is still finished tomorrow, without the name', () async {
    final SharedPreferences prefs = await openMemory();
    final ProviderContainer first = ProviderContainer(
      overrides: memoryScope(prefs),
    );
    await _finish(first, remember: false);
    await first.read(homeVisitProvider.notifier).mark();
    first.dispose();

    final ProviderContainer second = ProviderContainer(
      overrides: memoryScope(prefs),
    );
    addTearDown(second.dispose);

    final OnboardingAnswers restored = second.read(onboardingProvider);
    expect(restored.completed, isTrue);
    expect(restored.mayRemember, isFalse);
    expect(restored.name, isEmpty);
    expect(restored.whatMatters, isEmpty);
    expect(restored.currentLoop, isEmpty);
    expect(second.read(homeVisitProvider), isTrue);
  });

  testWidgets('the first launch opens on arrival', (WidgetTester tester) async {
    final ProviderContainer container = ProviderContainer(
      overrides: memoryScope(await openMemory()),
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const InnerloomApp(),
      ),
    );

    expect(find.text("I'm here."), findsOneWidget);
    expect(find.text(HomeScript.question), findsNothing);
    expect(container.read(routerProvider).state.uri.path, '/');
  });

  testWidgets('a completed launch opens on home, and later visits are short', (
    WidgetTester tester,
  ) async {
    final SharedPreferences prefs = await openMemory(<String, Object>{
      'completed': true,
      'mayRemember': true,
      'name': 'Avery',
      'whatMatters': 'Peace',
      'currentLoop': 'Work',
      'homeSeen': true,
    });
    final ProviderContainer container = ProviderContainer(
      overrides: memoryScope(prefs),
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const InnerloomApp(),
      ),
    );

    expect(find.text("I'm here."), findsNothing);
    expect(find.textContaining('Avery'), findsOneWidget);
    expect(find.text(HomeScript.question), findsNothing);
    expect(find.text('Calm'), findsNothing);
    expect(container.read(routerProvider).canPop(), isFalse);

    await tester.pump(HomeScript.returnDelay);
    expect(find.text(HomeScript.presence), findsOneWidget);
    expect(find.text(HomeScript.question), findsOneWidget);
    expect(find.text('Calm'), findsOneWidget);

    container.read(routerProvider).go('/');
    await tester.pump();
    expect(find.text("I'm here."), findsNothing);
    expect(find.textContaining('Avery'), findsOneWidget);
    expect(container.read(routerProvider).canPop(), isFalse);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('home without memory does not invent a name', (
    WidgetTester tester,
  ) async {
    final SharedPreferences prefs = await openMemory(<String, Object>{
      'completed': true,
      'mayRemember': false,
      'name': 'Avery',
      'whatMatters': 'Peace',
      'currentLoop': 'Work',
      'homeSeen': true,
    });
    final ProviderContainer container = ProviderContainer(
      overrides: memoryScope(prefs),
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const InnerloomApp(),
      ),
    );

    expect(find.text("I'm here."), findsNothing);
    expect(find.textContaining('Avery'), findsNothing);
    expect(find.textContaining(','), findsNothing);
    expect(find.textContaining('Good '), findsOneWidget);
    expect(container.read(routerProvider).state.uri.path, '/home');

    container.read(routerProvider).go('/home');
    await tester.pump();
    expect(find.textContaining('Avery'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('home stays closed, and back does not reopen arrival', (
    WidgetTester tester,
  ) async {
    final SharedPreferences prefs = await openMemory();
    final ProviderContainer container = ProviderContainer(
      overrides: memoryScope(prefs),
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const InnerloomApp(),
      ),
    );
    container.read(routerProvider).go('/home');
    await tester.pump();
    expect(find.text("I'm here."), findsOneWidget);
    expect(find.text(HomeScript.question), findsNothing);

    await _finish(container, remember: true);
    container.read(routerProvider).go('/home');
    await tester.pump();

    expect(find.text("I'm here."), findsNothing);
    expect(find.textContaining('Avery'), findsOneWidget);
    expect(container.read(routerProvider).canPop(), isFalse);

    final bool popped = await tester.binding.handlePopRoute();
    expect(popped, isFalse);
    await tester.pump();
    expect(find.text("I'm here."), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}

Future<void> _finish(
  ProviderContainer container, {
  required bool remember,
}) async {
  final OnboardingController controller = container.read(
    onboardingProvider.notifier,
  );
  controller.advance();
  controller.advance();
  controller.submitName('Avery');
  controller.submitWhatMatters('Peace');
  controller.submitCurrentLoop('Work');
  controller.advance();
  controller.chooseMemory(remember);
  expect(await controller.beginToday(), isTrue);
}
