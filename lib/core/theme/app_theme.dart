import 'package:flutter/material.dart';

/// Light/dark ThemeData. Kept in one place so every screen shares the same
/// tokens instead of inventing its own styling (docs/system_requirements.md,
/// Section 4 - Consistency).
abstract final class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: const Color(0xFF3762F2),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF3762F2),
      );
}
