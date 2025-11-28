import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

/// Common decoration patterns used throughout the app.
///
/// Extracted to reduce code duplication and improve maintainability.
class AppDecorations {
  AppDecorations._();

  /// Standard rounded border radius used across the app.
  static final BorderRadius standardRadius = BorderRadius.circular(
    AppSpacing.radiusLarge,
  );

  /// Large rounded border radius for cards.
  static final BorderRadius cardRadius = BorderRadius.circular(
    AppSpacing.radiusXXLarge,
  );

  /// Subtle border used for unselected/inactive states.
  static Border subtleBorder = Border.all(
    color: Colors.white.fade(AppColors.opacityVeryLow),
  );

  /// Highlighted border used for selected/active states.
  static Border highlightedBorder = Border.all(
    color: AppColors.primaryIndigo.fade(AppColors.opacityHigh),
  );

  /// Decoration for secondary/ghost buttons (skip buttons, etc.).
  static BoxDecoration secondaryButton = BoxDecoration(
    color: Colors.white.fade(AppColors.opacityVeryLow),
    borderRadius: standardRadius,
    border: subtleBorder,
  );

  /// Creates a selection-aware decoration for list items and buttons.
  static BoxDecoration selectable({required bool isSelected}) {
    return BoxDecoration(
      color: isSelected
          ? AppColors.primaryIndigo.fade(AppColors.opacityMedium)
          : Colors.white.fade(AppColors.opacityVeryLow),
      borderRadius: standardRadius,
      border: isSelected ? highlightedBorder : subtleBorder,
    );
  }

  /// Creates a selection-aware decoration for list items with minimal opacity.
  static BoxDecoration selectableMinimal({required bool isSelected}) {
    return BoxDecoration(
      color: isSelected
          ? AppColors.primaryIndigo.fade(AppColors.opacityMedium)
          : Colors.white.fade(AppColors.opacityMinimal),
      borderRadius: standardRadius,
      border: isSelected ? highlightedBorder : subtleBorder,
    );
  }

  /// Gradient decoration for the main card.
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

  /// Play button decoration with glow effect.
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
}

