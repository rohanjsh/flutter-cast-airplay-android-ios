import 'package:flutter/material.dart';

class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final double opacityHigh;
  final double opacityMedium;
  final double opacityLow;
  final double opacityVeryLow;
  final double opacityMinimal;

  final double paddingXSmall;
  final double paddingSmall;
  final double paddingMedium;
  final double paddingLarge;
  final double paddingXLarge;
  final double paddingXXLarge;
  final double paddingHuge;

  final double radiusSmall;
  final double radiusMedium;
  final double radiusLarge;
  final double radiusXLarge;
  final double radiusXXLarge;

  final double iconSmall;
  final double iconMedium;
  final double iconLarge;
  final double iconXLarge;
  final double iconXXLarge;
  final double iconHuge;

  final double playButtonSize;
  final double mediaPreviewHeight;
  final double progressBarHeight;

  final LinearGradient backgroundGradient;
  final LinearGradient cardGradient;

  final BoxDecoration secondaryButtonDecoration;
  final BoxDecoration playButtonDecoration;

  const AppThemeExtension({
    required this.opacityHigh,
    required this.opacityMedium,
    required this.opacityLow,
    required this.opacityVeryLow,
    required this.opacityMinimal,
    required this.paddingXSmall,
    required this.paddingSmall,
    required this.paddingMedium,
    required this.paddingLarge,
    required this.paddingXLarge,
    required this.paddingXXLarge,
    required this.paddingHuge,
    required this.radiusSmall,
    required this.radiusMedium,
    required this.radiusLarge,
    required this.radiusXLarge,
    required this.radiusXXLarge,
    required this.iconSmall,
    required this.iconMedium,
    required this.iconLarge,
    required this.iconXLarge,
    required this.iconXXLarge,
    required this.iconHuge,
    required this.playButtonSize,
    required this.mediaPreviewHeight,
    required this.progressBarHeight,
    required this.backgroundGradient,
    required this.cardGradient,
    required this.secondaryButtonDecoration,
    required this.playButtonDecoration,
  });

  @override
  ThemeExtension<AppThemeExtension> copyWith({
    double? opacityHigh,
    double? opacityMedium,
    double? opacityLow,
    double? opacityVeryLow,
    double? opacityMinimal,
    double? paddingXSmall,
    double? paddingSmall,
    double? paddingMedium,
    double? paddingLarge,
    double? paddingXLarge,
    double? paddingXXLarge,
    double? paddingHuge,
    double? radiusSmall,
    double? radiusMedium,
    double? radiusLarge,
    double? radiusXLarge,
    double? radiusXXLarge,
    double? iconSmall,
    double? iconMedium,
    double? iconLarge,
    double? iconXLarge,
    double? iconXXLarge,
    double? iconHuge,
    double? playButtonSize,
    double? mediaPreviewHeight,
    double? progressBarHeight,
    LinearGradient? backgroundGradient,
    LinearGradient? cardGradient,
    BoxDecoration? secondaryButtonDecoration,
    BoxDecoration? playButtonDecoration,
  }) {
    return AppThemeExtension(
      opacityHigh: opacityHigh ?? this.opacityHigh,
      opacityMedium: opacityMedium ?? this.opacityMedium,
      opacityLow: opacityLow ?? this.opacityLow,
      opacityVeryLow: opacityVeryLow ?? this.opacityVeryLow,
      opacityMinimal: opacityMinimal ?? this.opacityMinimal,
      paddingXSmall: paddingXSmall ?? this.paddingXSmall,
      paddingSmall: paddingSmall ?? this.paddingSmall,
      paddingMedium: paddingMedium ?? this.paddingMedium,
      paddingLarge: paddingLarge ?? this.paddingLarge,
      paddingXLarge: paddingXLarge ?? this.paddingXLarge,
      paddingXXLarge: paddingXXLarge ?? this.paddingXXLarge,
      paddingHuge: paddingHuge ?? this.paddingHuge,
      radiusSmall: radiusSmall ?? this.radiusSmall,
      radiusMedium: radiusMedium ?? this.radiusMedium,
      radiusLarge: radiusLarge ?? this.radiusLarge,
      radiusXLarge: radiusXLarge ?? this.radiusXLarge,
      radiusXXLarge: radiusXXLarge ?? this.radiusXXLarge,
      iconSmall: iconSmall ?? this.iconSmall,
      iconMedium: iconMedium ?? this.iconMedium,
      iconLarge: iconLarge ?? this.iconLarge,
      iconXLarge: iconXLarge ?? this.iconXLarge,
      iconXXLarge: iconXXLarge ?? this.iconXXLarge,
      iconHuge: iconHuge ?? this.iconHuge,
      playButtonSize: playButtonSize ?? this.playButtonSize,
      mediaPreviewHeight: mediaPreviewHeight ?? this.mediaPreviewHeight,
      progressBarHeight: progressBarHeight ?? this.progressBarHeight,
      backgroundGradient: backgroundGradient ?? this.backgroundGradient,
      cardGradient: cardGradient ?? this.cardGradient,
      secondaryButtonDecoration:
          secondaryButtonDecoration ?? this.secondaryButtonDecoration,
      playButtonDecoration: playButtonDecoration ?? this.playButtonDecoration,
    );
  }

  @override
  ThemeExtension<AppThemeExtension> lerp(
    ThemeExtension<AppThemeExtension>? other,
    double t,
  ) {
    if (other is! AppThemeExtension) {
      return this;
    }
    return this;
  }
}
