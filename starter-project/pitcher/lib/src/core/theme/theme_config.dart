import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_theme_extension.dart';

abstract final class AppThemeConfig {
  AppThemeConfig._();

  static ThemeData get darkTheme {
    const seedColor = AppColors.primaryIndigo;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.bgDark,

      // Text theme with consistent typography
      textTheme: TextTheme(
        displayLarge: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        displayMedium: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        displaySmall: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineLarge: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineMedium: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        headlineSmall: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleLarge: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleMedium: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleSmall: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: Colors.white,
        ),
        bodyMedium: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: Colors.white,
        ),
        bodySmall: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: Colors.white70,
        ),
        labelLarge: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        labelMedium: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        labelSmall: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),

      // Custom theme extension
      extensions: [_buildAppThemeExtension(colorScheme)],
    );
  }

  static AppThemeExtension _buildAppThemeExtension(ColorScheme colorScheme) {
    return AppThemeExtension(
      opacityHigh: 0.5,
      opacityMedium: 0.3,
      opacityLow: 0.15,
      opacityVeryLow: 0.1,
      opacityMinimal: 0.05,
      paddingXSmall: 4,
      paddingSmall: 8,
      paddingMedium: 12,
      paddingLarge: 16,
      paddingXLarge: 20,
      paddingXXLarge: 24,
      paddingHuge: 40,
      radiusSmall: 8,
      radiusMedium: 10,
      radiusLarge: 12,
      radiusXLarge: 16,
      radiusXXLarge: 24,
      iconSmall: 16,
      iconMedium: 18,
      iconLarge: 20,
      iconXLarge: 24,
      iconXXLarge: 32,
      iconHuge: 80,
      playButtonSize: 64,
      mediaPreviewHeight: 160,
      progressBarHeight: 16,
      backgroundGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.bgDark, AppColors.bgDarkSecondary.fade(0.8)],
      ),
      cardGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.primaryIndigo.fade(0.3),
          AppColors.primaryPurple.fade(0.1),
        ],
      ),
      secondaryButtonDecoration: BoxDecoration(
        color: Colors.white.fade(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.fade(0.1)),
      ),
      playButtonDecoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryIndigo,
        boxShadow: [
          BoxShadow(color: AppColors.primaryIndigo.fade(0.3), blurRadius: 16),
        ],
      ),
    );
  }
}
