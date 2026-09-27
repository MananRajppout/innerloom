import 'package:flutter/material.dart';

import 'core/constants/app_info.dart';
import 'routing/app_router.dart';
import 'theme/app_theme.dart';

class LoopBreakApp extends StatelessWidget {
  const LoopBreakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppInfo.name,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      scrollBehavior: AppTheme.scrollBehavior,
      routerConfig: appRouter,
    );
  }
}
