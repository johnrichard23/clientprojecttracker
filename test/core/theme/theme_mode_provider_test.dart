import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:client_project_tracker/core/di/providers.dart';
import 'package:client_project_tracker/core/theme/theme_mode_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
    );
    addTearDown(container.dispose);
  });

  test('defaults to ThemeMode.system when nothing persisted', () {
    expect(container.read(themeModeProvider), ThemeMode.system);
  });

  test('setThemeMode updates state and persists it', () {
    container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);

    expect(container.read(themeModeProvider), ThemeMode.dark);
    final prefs = container.read(sharedPreferencesProvider);
    expect(prefs.getString('theme_mode'), 'dark');
  });

  test('reads a persisted theme mode on initial build', () async {
    SharedPreferences.setMockInitialValues({'theme_mode': 'light'});
    final prefs = await SharedPreferences.getInstance();
    final freshContainer = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
    );
    addTearDown(freshContainer.dispose);

    expect(freshContainer.read(themeModeProvider), ThemeMode.light);
  });

  test('setThemeMode back to system persists and is re-read on next build',
      () async {
    container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
    container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system);

    expect(container.read(themeModeProvider), ThemeMode.system);
    final prefs = container.read(sharedPreferencesProvider);
    expect(prefs.getString('theme_mode'), 'system');
  });
}
