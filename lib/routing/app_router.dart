import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/future_self/widgets/presence_shell.dart';
import '../features/home/home_day.dart';
import '../features/onboarding/onboarding_flow.dart';
import '../features/onboarding/providers/onboarding_controller.dart';

/// One router for this launch.
///
/// Completion is already restored, so the first location is home or arrival.
/// Home stays closed until then, and a finished arrival does not return there.
final Provider<GoRouter> routerProvider = Provider<GoRouter>((Ref ref) {
  final ValueNotifier<int> refresh = ValueNotifier<int>(0);
  ref.listen<bool>(
    onboardingProvider.select((answers) => answers.completed),
    (bool? previous, bool next) => refresh.value++,
  );

  final bool completed = ref.read(onboardingProvider).completed;
  final GoRouter router = GoRouter(
    initialLocation: completed ? '/home' : '/',
    refreshListenable: refresh,
    redirect: (context, GoRouterState state) {
      final bool done = ref.read(onboardingProvider).completed;
      final String path = state.uri.path;
      if (path == '/home' && !done) {
        return '/';
      }
      if (path == '/' && done) {
        return '/home';
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
            builder: (context, state) => const HomeDay(),
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
