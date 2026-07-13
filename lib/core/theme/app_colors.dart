import 'package:flutter/material.dart';

/// Semantic color tokens shared across the app, tuned separately for light
/// and dark mode so badges/chips built from them stay readable in both -
/// see docs/system_requirements.md, Section 4 (Accessibility) and Section 4
/// (Consistency: one shared palette, not one-off styling per screen).
abstract final class AppColors {
  static const _light = _Palette(
    info: Color(0xFF3762F2),
    neutral: Color(0xFF57606A),
    warning: Color(0xFFB45309),
    success: Color(0xFF15803D),
    danger: Color(0xFFB91C1C),
  );

  static const _dark = _Palette(
    info: Color(0xFF9DB8FF),
    neutral: Color(0xFFC3C9D1),
    warning: Color(0xFFFBBF24),
    success: Color(0xFF6EE7A0),
    danger: Color(0xFFF87171),
  );

  static Color info(Brightness brightness) => _palette(brightness).info;
  static Color neutral(Brightness brightness) => _palette(brightness).neutral;
  static Color warning(Brightness brightness) => _palette(brightness).warning;
  static Color success(Brightness brightness) => _palette(brightness).success;
  static Color danger(Brightness brightness) => _palette(brightness).danger;

  static _Palette _palette(Brightness brightness) =>
      brightness == Brightness.dark ? _dark : _light;
}

class _Palette {
  final Color info;
  final Color neutral;
  final Color warning;
  final Color success;
  final Color danger;

  const _Palette({
    required this.info,
    required this.neutral,
    required this.warning,
    required this.success,
    required this.danger,
  });
}
