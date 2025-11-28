import 'package:flutter/material.dart';

/// Color Palette for the Cast n Play app.
///
/// Provides consistent colors across the app following Material Design principles.
class AppColors {
  AppColors._();

  // Primary colors
  static const Color primaryIndigo = Color(0xFF6366F1);
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color accentGreen = Color(0xFF10B981);

  // Background colors
  static const Color bgDark = Color(0xFF0F172A);
  static const Color bgDarkSecondary = Color(0xFF1E293B);
  static const Color bgDarkTertiary = Color(0xFF1F2937);
  static const Color bgDarkQuaternary = Color(0xFF111827);

  // Opacity variants (used with ColorExt.fade)
  static const double opacityHigh = 0.5;
  static const double opacityMedium = 0.3;
  static const double opacityLow = 0.15;
  static const double opacityVeryLow = 0.1;
  static const double opacityMinimal = 0.05;
}

/// Extension to replace deprecated withOpacity (Flutter 3.27+).
///
/// Usage: `Colors.white.fade(0.5)` instead of `Colors.white.withOpacity(0.5)`
extension ColorExt on Color {
  /// Creates a new color with the given alpha value (0.0 to 1.0).
  Color fade(double opacity) => withValues(alpha: opacity);
}

