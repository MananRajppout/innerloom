import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loop_break/app.dart';
import 'package:loop_break/theme/app_colors.dart';
import 'package:loop_break/widgets/future_self_orb.dart';

void main() {
  testWidgets('home holds a quiet presence', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: LoopBreakApp()));

    expect(find.text('Loop Break'), findsOneWidget);
    expect(find.text('Future Self'), findsOneWidget);
    expect(find.text("I'm with you."), findsOneWidget);
    expect(find.byType(FutureSelfOrb), findsOneWidget);

    final BuildContext context = tester.element(find.text('Future Self'));
    final ThemeData theme = Theme.of(context);
    expect(theme.brightness, Brightness.dark);
    expect(theme.scaffoldBackgroundColor, AppColors.background);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('reduced motion keeps the orb still', (WidgetTester tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    await tester.pumpWidget(const ProviderScope(child: LoopBreakApp()));
    await tester.pump();

    expect(find.text("I'm with you."), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
