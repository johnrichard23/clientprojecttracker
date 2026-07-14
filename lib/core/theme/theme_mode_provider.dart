import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:client_project_tracker/core/di/providers.dart';

/// Display label/icon for each [ThemeMode] option, shown in the app bar
/// theme menu. See docs/system_requirements.md, Section 5 (Dark Mode).
extension ThemeModeLabel on ThemeMode {
  String get label => switch (this) {
        ThemeMode.system => 'System',
        ThemeMode.light => 'Light',
        ThemeMode.dark => 'Dark',
      };

  IconData get icon => switch (this) {
        ThemeMode.system => Icons.brightness_auto,
        ThemeMode.light => Icons.light_mode,
        ThemeMode.dark => Icons.dark_mode,
      };
}

/// The user's manual light/dark/system override, persisted via
/// `shared_preferences` so it survives an app restart - same persistence
/// pattern as `ProjectFilterNotifier` (project_list_provider.dart). See
/// docs/architecture.md, Section 10 (State Persistence).
class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _themeModeKey = 'theme_mode';

  @override
  ThemeMode build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final stored = prefs.getString(_themeModeKey);
    return stored == null ? ThemeMode.system : ThemeMode.values.byName(stored);
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
    ref.read(sharedPreferencesProvider).setString(_themeModeKey, mode.name);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
