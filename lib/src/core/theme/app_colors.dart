import 'package:flutter/material.dart';

abstract final class AppColors {
  AppColors._();

  static const Color primaryIndigo = Color(0xFF6366F1);
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color accentGreen = Color(0xFF10B981);

  static const Color bgDark = Color(0xFF0F172A);
  static const Color bgDarkSecondary = Color(0xFF1E293B);
  static const Color bgDarkTertiary = Color(0xFF1F2937);
  static const Color bgDarkQuaternary = Color(0xFF111827);

  static const double opacityHigh = 0.5;
  static const double opacityMedium = 0.3;
  static const double opacityLow = 0.15;
  static const double opacityVeryLow = 0.1;
  static const double opacityMinimal = 0.05;
}

extension ColorExt on Color {
  Color fade(double opacity) => withValues(alpha: opacity);
}
