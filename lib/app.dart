import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_info.dart';
import 'routing/app_router.dart';
import 'theme/app_theme.dart';

class InnerloomApp extends ConsumerWidget {
  const InnerloomApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: AppInfo.name,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      scrollBehavior: AppTheme.scrollBehavior,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
