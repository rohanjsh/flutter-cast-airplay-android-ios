import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

abstract final class AppDecorations {
  AppDecorations._();

  static final BorderRadius standardRadius = BorderRadius.circular(
    AppSpacing.radiusLarge,
  );

  static final BorderRadius cardRadius = BorderRadius.circular(
    AppSpacing.radiusXXLarge,
  );

  static Border subtleBorder = Border.all(
    color: Colors.white.fade(AppColors.opacityVeryLow),
  );

  static Border highlightedBorder = Border.all(
    color: AppColors.primaryIndigo.fade(AppColors.opacityHigh),
  );

  static BoxDecoration secondaryButton = BoxDecoration(
    color: Colors.white.fade(AppColors.opacityVeryLow),
    borderRadius: standardRadius,
    border: subtleBorder,
  );

  static BoxDecoration selectable({required bool isSelected}) {
    return BoxDecoration(
      color: isSelected
          ? AppColors.primaryIndigo.fade(AppColors.opacityMedium)
          : Colors.white.fade(AppColors.opacityVeryLow),
      borderRadius: standardRadius,
      border: isSelected ? highlightedBorder : subtleBorder,
    );
  }

  static BoxDecoration selectableMinimal({required bool isSelected}) {
    return BoxDecoration(
      color: isSelected
          ? AppColors.primaryIndigo.fade(AppColors.opacityMedium)
          : Colors.white.fade(AppColors.opacityMinimal),
      borderRadius: standardRadius,
      border: isSelected ? highlightedBorder : subtleBorder,
    );
  }

  static BoxDecoration cardGradient = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.primaryIndigo.fade(AppColors.opacityMedium),
        AppColors.primaryPurple.fade(AppColors.opacityVeryLow),
      ],
    ),
    borderRadius: cardRadius,
    border: Border.all(color: Colors.white.fade(AppColors.opacityLow)),
  );

  static BoxDecoration playButton = BoxDecoration(
    shape: BoxShape.circle,
    color: AppColors.primaryIndigo,
    boxShadow: [
      BoxShadow(
        color: AppColors.primaryIndigo.fade(AppColors.opacityMedium),
        blurRadius: 16,
      ),
    ],
  );

  static const double bgGradientSecondaryOpacity = 0.8;

  static BoxDecoration backgroundGradient = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.bgDark,
        AppColors.bgDarkSecondary.fade(bgGradientSecondaryOpacity),
      ],
    ),
  );
}
