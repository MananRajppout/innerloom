import 'package:go_router/go_router.dart';

import '../features/home/screens/home_screen.dart';
import '../features/onboarding/onboarding_flow.dart';

/// Arrival is the front door. Today is the room it opens into.
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: 'onboarding',
      builder: (context, state) => const OnboardingFlow(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);
