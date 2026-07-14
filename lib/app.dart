import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:client_project_tracker/core/di/providers.dart';
import 'package:client_project_tracker/core/router/app_router.dart';
import 'package:client_project_tracker/core/theme/app_theme.dart';
import 'package:client_project_tracker/core/theme/theme_mode_provider.dart';

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
    final themeMode = ref.watch(themeModeProvider);

    return startup.when(
      data: (_) => MaterialApp.router(
        title: 'Client Project Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        routerConfig: appRouter,
      ),
      loading: () => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stackTrace) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
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
