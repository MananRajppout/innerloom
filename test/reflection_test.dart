import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loop_break/app.dart';
import 'package:loop_break/features/home/day_clock.dart';
import 'package:loop_break/features/home/home_script.dart';
import 'package:loop_break/features/home/screens/home_screen.dart';
import 'package:loop_break/features/onboarding/providers/onboarding_controller.dart';
import 'package:loop_break/features/reflection/reflection_script.dart';
import 'package:loop_break/routing/app_router.dart';
import 'package:loop_break/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/memory_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('the morning ritual is one question and one reply', () {
    expect(ReflectionScript.question, 'What is true for you this morning?');
    expect(
      ReflectionScript.response,
      'I heard you. Nothing else is asked of you.',
    );
    expect(ReflectionScript.question.contains('?'), isTrue);
    expect('?'.allMatches(ReflectionScript.question).length, 1);
    expect('?'.allMatches(ReflectionScript.response).length, 0);
  });

  testWidgets('the door waits until the morning room is open', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = await _named();
    addTearDown(container.dispose);

    await _pumpHome(tester, container, DateTime(2026, 10, 11, 9));

    expect(find.text('Morning Reflection'), findsNothing);
    expect(find.text(ReflectionScript.question), findsNothing);

    await tester.pump(HomeScript.cardsDelay + (HomeScript.cardStagger * 6));
    expect(find.text('Morning Reflection'), findsOneWidget);
    expect(find.text('Night Reflection'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('evening keeps the arrival room', (WidgetTester tester) async {
    final ProviderContainer container = await _named();
    addTearDown(container.dispose);

    await _pumpHome(tester, container, DateTime(2026, 10, 11, 21));
    await tester.pump(HomeScript.cardsDelay + (HomeScript.cardStagger * 6));

    expect(find.text('Curious'), findsOneWidget);
    expect(find.text('Night Reflection'), findsNothing);
    expect(find.text('Morning Reflection'), findsNothing);
    expect(find.text(ReflectionScript.question), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a sentence and a page both end after one reply', (
    WidgetTester tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    final ProviderContainer container = await _named();
    addTearDown(container.dispose);

    await _pumpHome(tester, container, DateTime(2026, 10, 11, 9));
    await tester.scrollUntilVisible(find.text('Morning Reflection'), 200);
    await tester.tap(find.text('Morning Reflection'));
    await tester.pump();

    expect(find.text(ReflectionScript.question), findsOneWidget);
    expect(find.text(HomeScript.question), findsNothing);
    expect(find.text(ReflectionScript.offer), findsNothing);
    expect(find.byType(TextField), findsOneWidget);

    await tester.enterText(find.byType(TextField), '   ');
    await tester.pump();
    expect(find.text(ReflectionScript.offer), findsNothing);

    await tester.enterText(find.byType(TextField), 'The morning is quiet.');
    await tester.pump();
    await tester.tap(find.text(ReflectionScript.offer));
    await tester.pump();

    expect(find.text('The morning is quiet.'), findsOneWidget);
    expect(find.text(ReflectionScript.response), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.text(ReflectionScript.offer), findsNothing);
    expect(find.text(ReflectionScript.question), findsOneWidget);

    await tester.tap(find.text(ReflectionScript.leave));
    await tester.pump();

    expect(find.text('Good morning, Avery.'), findsOneWidget);
    expect(find.text(ReflectionScript.question), findsNothing);
    expect(find.text(ReflectionScript.response), findsNothing);

    await tester.scrollUntilVisible(find.text('Morning Reflection'), 200);
    await tester.tap(find.text('Morning Reflection'));
    await tester.pump();
    await tester.enterText(
      find.byType(TextField),
      'I slept badly. '
      'The kitchen was already loud. '
      'I kept the small plan I made last night. '
      'I want breakfast before I answer anyone. '
      'The walk can wait until the light is up. '
      'I am tired and still here. '
      'Nothing needs solving before tea. '
      'I can leave the list on the table. '
      'One kind thing is enough. '
      'Then I can begin.',
    );
    await tester.pump();
    await tester.tap(find.text(ReflectionScript.offer));
    await tester.pump();

    expect(find.text(ReflectionScript.response), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.text(ReflectionScript.question), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('the reply waits one breath, and back leaves the ritual', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = await _named();
    addTearDown(container.dispose);

    await _pumpHome(tester, container, DateTime(2026, 10, 11, 9));
    await tester.pump(HomeScript.cardsDelay + (HomeScript.cardStagger * 6));
    await tester.scrollUntilVisible(find.text('Morning Reflection'), 200);
    await tester.tap(find.text('Morning Reflection'));
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'I am here.');
    await tester.pump();
    await tester.tap(find.text(ReflectionScript.offer));
    await tester.pump();

    expect(find.text(ReflectionScript.response), findsNothing);
    expect(find.byType(TextField), findsNothing);

    await tester.pump(ReflectionScript.replyDelay);
    expect(find.text(ReflectionScript.response), findsOneWidget);
    expect(find.text(ReflectionScript.leave), findsOneWidget);

    await tester.tap(find.text(ReflectionScript.leave));
    await tester.pump();
    await tester.scrollUntilVisible(find.text('Morning Reflection'), 200);
    await tester.tap(find.text('Morning Reflection'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'Still here.');
    await tester.pump();

    final bool popped = await tester.binding.handlePopRoute();
    expect(popped, isTrue);
    await tester.pump();

    expect(find.text('Good morning, Avery.'), findsOneWidget);
    expect(find.text(ReflectionScript.response), findsNothing);
    expect(find.text('Still here.'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a returning morning can finish inside the room', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 24, bottom: 48);
    tester.view.viewPadding = const FakeViewPadding(top: 24, bottom: 48);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    final SharedPreferences prefs = await openMemory(<String, Object>{
      'completed': true,
      'mayRemember': true,
      'name': 'Avery',
      'whatMatters': 'Peace',
      'currentLoop': 'Work',
      'homeSeen': true,
    });
    final ProviderContainer container = ProviderContainer(
      overrides: [
        ...memoryScope(prefs),
        clockProvider.overrideWithValue(() => DateTime(2026, 10, 11, 9)),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const InnerloomApp(),
      ),
    );

    expect(find.text("I'm here."), findsNothing);
    await tester.scrollUntilVisible(find.text('Morning Reflection'), 200);
    await tester.tap(find.text('Morning Reflection'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'Tea first.');
    await tester.pump();
    await tester.tap(find.text(ReflectionScript.offer));
    await tester.pump();

    expect(find.text(ReflectionScript.response), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text(ReflectionScript.leave));
    await tester.pump();
    expect(find.textContaining('Avery'), findsOneWidget);
    expect(find.text(ReflectionScript.question), findsNothing);
    expect(container.read(routerProvider).canPop(), isFalse);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}

Future<ProviderContainer> _named() async {
  final ProviderContainer container = ProviderContainer(
    overrides: memoryScope(await openMemory()),
  );
  final OnboardingController controller = container.read(
    onboardingProvider.notifier,
  );
  controller.advance();
  controller.advance();
  controller.submitName('Avery');
  return container;
}

Future<void> _pumpHome(
  WidgetTester tester,
  ProviderContainer container,
  DateTime now,
) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.dark,
        scrollBehavior: AppTheme.scrollBehavior,
        home: Scaffold(body: HomeScreen(now: () => now)),
      ),
    ),
  );
}
