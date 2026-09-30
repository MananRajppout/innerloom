import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loop_break/features/home/home_script.dart';
import 'package:loop_break/features/home/screens/home_screen.dart';
import 'package:loop_break/features/onboarding/providers/onboarding_controller.dart';
import 'package:loop_break/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('greeting follows the day, and reflection turns at evening', () {
    expect(HomeScript.greeting(DateTime(2026, 1, 1, 5)), 'Good morning');
    expect(HomeScript.greeting(DateTime(2026, 1, 1, 11, 59)), 'Good morning');
    expect(HomeScript.greeting(DateTime(2026, 1, 1, 12)), 'Good afternoon');
    expect(HomeScript.greeting(DateTime(2026, 1, 1, 16, 59)), 'Good afternoon');
    expect(HomeScript.greeting(DateTime(2026, 1, 1, 17)), 'Good evening');
    expect(HomeScript.greeting(DateTime(2026, 1, 1, 2)), 'Good evening');

    expect(
      HomeScript.reflection(DateTime(2026, 1, 1, 9)),
      'Morning Reflection',
    );
    expect(
      HomeScript.reflection(DateTime(2026, 1, 1, 16)),
      'Morning Reflection',
    );
    expect(HomeScript.reflection(DateTime(2026, 1, 1, 17)), 'Night Reflection');
    expect(HomeScript.reflection(DateTime(2026, 1, 1, 0)), 'Night Reflection');
  });

  testWidgets('the first moments are a greeting and one sentence', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = _named('Manan');
    addTearDown(container.dispose);

    await _pumpHome(
      tester,
      container: container,
      now: DateTime(2026, 9, 30, 21),
    );

    expect(find.text('Good evening, Manan.'), findsOneWidget);
    expect(find.text(HomeScript.presence), findsNothing);
    expect(find.text(HomeScript.question), findsNothing);
    expect(find.text('Calm'), findsNothing);
    expect(find.text('Night Reflection'), findsNothing);

    await tester.pump(HomeScript.sentenceDelay);
    expect(find.text(HomeScript.presence), findsOneWidget);
    expect(find.text(HomeScript.question), findsNothing);

    await tester.pump(HomeScript.questionDelay - HomeScript.sentenceDelay);
    expect(find.text(HomeScript.question), findsOneWidget);
    expect(find.text('Calm'), findsNothing);

    await tester.pump(HomeScript.cardsDelay - HomeScript.questionDelay);
    expect(find.text('Calm'), findsOneWidget);
    expect(find.text('Heavy'), findsNothing);

    await tester.pump(HomeScript.cardStagger);
    expect(find.text('Heavy'), findsOneWidget);
    expect(find.text('Curious'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a choice is answered, then the evening door appears', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = _named('Manan');
    addTearDown(container.dispose);

    await _pumpHome(
      tester,
      container: container,
      now: DateTime(2026, 9, 30, 21),
      size: const Size(390, 1600),
    );
    await tester.pump(HomeScript.cardsDelay + (HomeScript.cardStagger * 6));

    await tester.tap(find.text('Heavy'));
    expect(find.text(HomeScript.response(Arrival.heavy)), findsNothing);

    await tester.pump(HomeScript.responseDelay);
    expect(find.text(HomeScript.response(Arrival.heavy)), findsOneWidget);
    expect(find.text('Night Reflection'), findsNothing);
    expect(find.textContaining('Manan'), findsOneWidget);

    await tester.pump(HomeScript.actionDelay);
    expect(find.text('Night Reflection'), findsOneWidget);

    await tester.tap(find.text('Hopeful'));
    await tester.pump();

    expect(find.text(HomeScript.response(Arrival.hopeful)), findsOneWidget);
    expect(find.text(HomeScript.response(Arrival.heavy)), findsNothing);
    expect(find.text('Night Reflection'), findsOneWidget);

    await tester.tap(find.text('Night Reflection'));
    await tester.pump();
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('reduced motion settles the words, and morning keeps its door', (
    WidgetTester tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    final ProviderContainer container = _named('Avery');
    addTearDown(container.dispose);

    await _pumpHome(
      tester,
      container: container,
      now: DateTime(2026, 9, 30, 9),
    );

    expect(find.text('Good morning, Avery.'), findsOneWidget);
    expect(find.text(HomeScript.presence), findsOneWidget);
    expect(find.text(HomeScript.question), findsOneWidget);
    expect(find.text('Curious'), findsOneWidget);
    expect(find.text('Morning Reflection'), findsNothing);

    await tester.tap(find.text('Restless'));
    await tester.pump();

    expect(find.text(HomeScript.response(Arrival.restless)), findsOneWidget);
    expect(find.text('Morning Reflection'), findsOneWidget);
    expect(find.text('Night Reflection'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a small screen can hold the arrival without overflow', (
    WidgetTester tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    await _pumpHome(
      tester,
      container: container,
      now: DateTime(2026, 9, 30, 15),
      size: const Size(360, 640),
    );

    expect(find.text('Good afternoon.'), findsOneWidget);
    expect(find.textContaining(','), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(find.text('Drained'), 200);
    await tester.tap(find.text('Drained'));
    await tester.pump();

    expect(find.text(HomeScript.response(Arrival.drained)), findsOneWidget);
    expect(find.text('Morning Reflection'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}

ProviderContainer _named(String name) {
  final ProviderContainer container = ProviderContainer();
  final OnboardingController controller = container.read(
    onboardingProvider.notifier,
  );
  controller.advance();
  controller.advance();
  controller.submitName(name);
  return container;
}

Future<void> _pumpHome(
  WidgetTester tester, {
  required ProviderContainer container,
  required DateTime now,
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

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
