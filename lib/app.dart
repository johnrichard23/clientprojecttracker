import 'package:flutter/material.dart';

import 'package:client_project_tracker/core/router/app_router.dart';
import 'package:client_project_tracker/core/theme/app_theme.dart';

class ClientProjectTrackerApp extends StatelessWidget {
  const ClientProjectTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Client Project Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      // TODO: swap ThemeMode.system for a persisted themeModeProvider once
      // shared_preferences wiring is in (docs/architecture.md, Section 10).
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
