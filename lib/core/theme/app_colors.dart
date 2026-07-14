import 'package:flutter/material.dart';

/// Semantic color tokens shared across the app, tuned separately for light
/// and dark mode so badges/chips built from them stay readable in both -
/// see docs/system_requirements.md, Section 4 (Accessibility) and Section 4
/// (Consistency: one shared palette, not one-off styling per screen).
abstract final class AppColors {
  // info/warning/success are darkened from the raw seed/brand hues - at their
  // original values the badge text (drawn at full color, on a 15%-alpha tint
  // of the same color) landed at ~4.0:1 against the light background, just
  // under the 4.5:1 WCAG AA threshold for 12px text. neutral/danger already
  // cleared 4.5:1 and are unchanged. See docs/system_requirements.md,
  // Section 4 (Accessibility).
  static const _light = _Palette(
    info: Color(0xFF2A4FCC),
    neutral: Color(0xFF57606A),
    warning: Color(0xFF8A3F07),
    success: Color(0xFF0F6B32),
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
