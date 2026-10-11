import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loop_break/app.dart';
import 'package:loop_break/features/home/day_clock.dart';
import 'package:loop_break/features/home/home_script.dart';
import 'package:loop_break/features/home/screens/home_screen.dart';
import 'package:loop_break/features/onboarding/providers/onboarding_controller.dart';
import 'package:loop_break/features/reflection/reflection_script.dart';
import 'package:loop_break/routing/app_router.dart';
import 'package:loop_break/theme/app_durations.dart';
import 'package:loop_break/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/memory_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('the question stays true from morning through the afternoon', () {
    expect(ReflectionScript.question, 'What is true for you today?');
    expect(ReflectionScript.question.contains('this morning'), isFalse);
    expect(ReflectionScript.question.contains('?'), isTrue);
    expect('?'.allMatches(ReflectionScript.question).length, 1);
    expect(
      ReflectionScript.response,
      'I heard you. Nothing else is asked of you.',
    );
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

  testWidgets('afternoon asks about today', (WidgetTester tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    final ProviderContainer container = await _named();
    addTearDown(container.dispose);

    await _pumpHome(tester, container, DateTime(2026, 10, 11, 15));
    await tester.scrollUntilVisible(find.text('Morning Reflection'), 200);
    await tester.tap(find.text('Morning Reflection'));
    await tester.pump();

    expect(find.text(ReflectionScript.question), findsOneWidget);
    expect(find.textContaining('this morning'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a reply is shown once, then the door stays closed', (
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

    expect(find.text(ReflectionScript.offer), findsNothing);
    await tester.enterText(find.byType(TextField), '   ');
    await tester.pump();
    expect(find.text(ReflectionScript.offer), findsNothing);

    await tester.enterText(find.byType(TextField), 'The morning is quiet.');
    await tester.pump();
    await tester.tap(find.text(ReflectionScript.offer));
    await tester.pump();
    await tester.pump();

    expect(find.text('The morning is quiet.'), findsOneWidget);
    expect(find.text(ReflectionScript.response), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.text(ReflectionScript.question), findsOneWidget);
    expect(_replyIsVisible(tester), isTrue);

    await tester.tap(find.text(ReflectionScript.leave));
    await tester.pump();

    expect(find.text('Good morning, Avery.'), findsOneWidget);
    expect(find.text(ReflectionScript.question), findsNothing);
    expect(find.text('Morning Reflection'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    final ProviderContainer tomorrow = await _named();
    addTearDown(tomorrow.dispose);
    await _pumpHome(tester, tomorrow, DateTime(2026, 10, 11, 9));
    expect(find.text('Morning Reflection'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a long answer still ends on the reply', (
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

    final ScrollableState scrollable = Scrollable.of(
      tester.element(find.text(ReflectionScript.question)),
    );
    await tester.tap(find.byType(TextField));
    await tester.pump();
    await tester.pump(AppDurations.fade);
    expect(scrollable.position.pixels, 0);

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
    await tester.pump(AppDurations.fade);
    expect(scrollable.position.pixels, 0);
    expect(find.text(ReflectionScript.response), findsNothing);

    await tester.tap(find.text(ReflectionScript.offer));
    await tester.pump();
    await tester.pump();

    expect(find.text(ReflectionScript.response), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(_replyIsVisible(tester), isTrue);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('back keeps the draft until the app is closed', (
    WidgetTester tester,
  ) async {
    final SharedPreferences prefs = await openMemory();
    final ProviderContainer container = ProviderContainer(
      overrides: memoryScope(prefs),
    );
    addTearDown(container.dispose);
    final OnboardingController controller = container.read(
      onboardingProvider.notifier,
    );
    controller.advance();
    controller.advance();
    controller.submitName('Avery');

    await _pumpHome(tester, container, DateTime(2026, 10, 11, 9));
    await tester.pump(HomeScript.cardsDelay + (HomeScript.cardStagger * 6));
    await tester.scrollUntilVisible(find.text('Morning Reflection'), 200);
    await tester.tap(find.text('Morning Reflection'));
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'Still here.');
    await tester.pump();

    final bool popped = await tester.binding.handlePopRoute();
    expect(popped, isTrue);
    await tester.pump();

    expect(find.text('Good morning, Avery.'), findsOneWidget);
    expect(find.text('Morning Reflection'), findsOneWidget);
    expect(find.text(ReflectionScript.response), findsNothing);
    for (final String key in prefs.getKeys()) {
      expect('${prefs.get(key)}'.contains('Still here'), isFalse);
    }

    await tester.scrollUntilVisible(find.text('Morning Reflection'), 200);
    await tester.tap(find.text('Morning Reflection'));
    await tester.pump();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      'Still here.',
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('the reply waits one breath', (WidgetTester tester) async {
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
    await tester.pump(AppDurations.fade);
    expect(find.text(ReflectionScript.response), findsOneWidget);
    expect(_replyIsVisible(tester), isTrue);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a small morning can find the door after arriving', (
    WidgetTester tester,
  ) async {
    await _loadFonts();
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

    expect(_onScreen(tester, 'Good morning, Avery.'), isTrue);
    expect(_onScreen(tester, 'Calm'), isTrue);

    await tester.tap(find.text('Calm'));
    await tester.pump();
    await tester.pump();

    expect(_onScreen(tester, HomeScript.response(Arrival.calm)), isTrue);
    expect(_onScreen(tester, 'Morning Reflection'), isTrue);
    final Rect reply = tester.getRect(
      find.text(HomeScript.response(Arrival.calm)),
    );
    final Rect door = tester.getRect(find.text('Morning Reflection'));
    expect(reply.bottom, lessThanOrEqualTo(door.top));
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Morning Reflection'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'Tea first.');
    await tester.pump();
    await tester.tap(find.text(ReflectionScript.offer));
    await tester.pump();
    await tester.pump();

    expect(_replyIsVisible(tester), isTrue);
    await tester.tap(find.text(ReflectionScript.leave));
    await tester.pump();
    expect(find.text('Morning Reflection'), findsNothing);
    expect(container.read(routerProvider).canPop(), isFalse);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}

bool _replyIsVisible(WidgetTester tester) {
  final Rect reply = tester.getRect(find.text(ReflectionScript.response));
  final Rect leave = tester.getRect(find.text(ReflectionScript.leave));
  final Size view = tester.view.physicalSize / tester.view.devicePixelRatio;
  return reply.top >= 0 &&
      reply.bottom <= leave.top + 1 &&
      reply.bottom <= view.height;
}

bool _onScreen(WidgetTester tester, String text) {
  final Rect rect = tester.getRect(find.text(text));
  final Size view = tester.view.physicalSize / tester.view.devicePixelRatio;
  return rect.top >= 24 && rect.bottom <= view.height - 48;
}

Future<void> _loadFonts() async {
  final FontLoader fraunces = FontLoader('Fraunces')
    ..addFont(rootBundle.load('assets/fonts/Fraunces.ttf'));
  final FontLoader nunito = FontLoader('NunitoSans')
    ..addFont(rootBundle.load('assets/fonts/NunitoSans.ttf'));
  await fraunces.load();
  await nunito.load();
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
