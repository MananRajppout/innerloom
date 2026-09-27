import 'package:go_router/go_router.dart';

import '../features/home/screens/home_screen.dart';

/// One room for now. Later rituals get their own routes.
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);
