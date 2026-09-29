import 'package:go_router/go_router.dart';

import '../features/onboarding/onboarding_flow.dart';

/// Arrival is the front door. Later rooms get their own routes.
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: 'onboarding',
      builder: (context, state) => const OnboardingFlow(),
    ),
  ],
);
