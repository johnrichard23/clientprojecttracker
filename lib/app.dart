import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:client_project_tracker/core/di/providers.dart';
import 'package:client_project_tracker/core/router/app_router.dart';
import 'package:client_project_tracker/core/theme/app_theme.dart';

/// Root widget. Gates the real app behind [appStartupProvider] (currently:
/// seeding the database on first run) so nothing reads from an empty table
/// during the brief window before seeding completes. The provider's future
/// is cached for the container's lifetime, so this only runs once per app
/// launch - not on every rebuild of this widget.
class ClientProjectTrackerApp extends ConsumerWidget {
  const ClientProjectTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startup = ref.watch(appStartupProvider);

    return startup.when(
      data: (_) => MaterialApp.router(
        title: 'Client Project Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        // TODO: swap ThemeMode.system for a persisted themeModeProvider once
        // shared_preferences wiring is in (docs/architecture.md, Section 10).
        themeMode: ThemeMode.system,
        routerConfig: appRouter,
      ),
      loading: () => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stackTrace) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Something went wrong starting the app. Please restart.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
