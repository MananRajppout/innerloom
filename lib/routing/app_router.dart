import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/future_self/widgets/presence_shell.dart';
import '../features/home/screens/home_screen.dart';
import '../features/onboarding/onboarding_flow.dart';
import '../features/onboarding/providers/onboarding_controller.dart';

/// One router for this session.
///
/// [OnboardingController] keeps completion in memory. A later restore can set
/// that same flag, and this redirect will still refuse /home until arrival ends.
final Provider<GoRouter> routerProvider = Provider<GoRouter>((Ref ref) {
  final ValueNotifier<int> refresh = ValueNotifier<int>(0);
  ref.listen<bool>(
    onboardingProvider.select((answers) => answers.completed),
    (bool? previous, bool next) => refresh.value++,
  );

  final GoRouter router = GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, GoRouterState state) {
      final bool completed = ref.read(onboardingProvider).completed;
      if (state.uri.path == '/home' && !completed) {
        return '/';
      }
      return null;
    },
    routes: <RouteBase>[
      ShellRoute(
        builder: (context, state, child) {
          return PresenceShell(child: child);
        },
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
      ),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});
