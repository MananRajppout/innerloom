import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loop_break/app.dart';
import 'package:loop_break/features/future_self/widgets/future_self_orb.dart';
import 'package:loop_break/features/onboarding/models/onboarding_answers.dart';
import 'package:loop_break/features/onboarding/providers/onboarding_controller.dart';
import 'package:loop_break/theme/app_colors.dart';
import 'package:loop_break/theme/app_durations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> settlePage(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(AppDurations.fade);
    await tester.pump(AppDurations.fade);
  }

  Future<void> skipSpeech(WidgetTester tester) async {
    await settlePage(tester);
    await tester.tap(find.text('Skip'));
    await tester.pump();
    await tester.pump(AppDurations.fade);
    await tester.pump();
  }

  testWidgets('arrival waits, then offers Begin', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: InnerloomApp()));

    expect(find.text('Future Self'), findsOneWidget);
    expect(find.text("I'm here."), findsOneWidget);
    expect(find.text('Innerloom'), findsNothing);
    expect(find.text('Loop Break'), findsNothing);
    expect(find.text('Begin'), findsNothing);
    expect(find.byType(FutureSelfOrb), findsOneWidget);

    final BuildContext context = tester.element(find.text("I'm here."));
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(Theme.of(context).scaffoldBackgroundColor, AppColors.background);

    await tester.pump(AppDurations.reveal);
    await tester.pump(AppDurations.fade);

    expect(find.text('Begin'), findsOneWidget);
    expect(find.byType(FutureSelfOrb), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('reduced motion shows Begin immediately', (WidgetTester tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    await tester.pumpWidget(const ProviderScope(child: InnerloomApp()));
    await tester.pump();

    expect(find.text('Begin'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('onboarding stores a name, a loop, and a refusal to remember', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const InnerloomApp(),
      ),
    );

    await tester.pump(AppDurations.reveal);
    await tester.pump(AppDurations.fade);
    await tester.tap(find.text('Begin'));
    await skipSpeech(tester);

    expect(find.text("I'm here to walk beside you."), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await settlePage(tester);

    expect(find.text('What should I call you?'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pump();
    expect(find.text('What should I call you?'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '  Avery  ');
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await settlePage(tester);

    expect(find.text('What matters most to you right now?'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pump();
    expect(find.text('What matters most to you right now?'), findsOneWidget);

    await tester.tap(find.text('Peace'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await settlePage(tester);

    expect(find.text('What keeps pulling you back?'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'The long evenings');
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await skipSpeech(tester);

    expect(
      find.text("So you don't have to carry everything alone."),
      findsOneWidget,
    );
    await tester.tap(find.text('Continue'));
    await skipSpeech(tester);

    expect(find.text('Not yet'), findsOneWidget);
    expect(find.text('Yes'), findsOneWidget);
    await tester.tap(find.text('Not yet'));
    await skipSpeech(tester);

    expect(find.text("I'll remember today."), findsOneWidget);
    await tester.tap(find.text('Begin Today'));
    await tester.pump();

    final OnboardingAnswers answers = container.read(onboardingProvider);
    expect(answers.name, 'Avery');
    expect(answers.whatMatters, 'Peace');
    expect(answers.currentLoop, 'The long evenings');
    expect(answers.mayRemember, isFalse);
    expect(answers.completed, isTrue);
    expect(find.byType(FutureSelfOrb), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
