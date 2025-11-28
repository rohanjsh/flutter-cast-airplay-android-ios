import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Widget displaying audio preview with gradient background.
class AudioPreviewWidget extends StatelessWidget {
  const AudioPreviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: AppSpacing.mediaPreviewHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryIndigo, AppColors.primaryPurple],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.music_note,
          size: AppSpacing.iconHuge,
          color: Colors.white.fade(AppColors.opacityMedium),
        ),
      ),
    );
  }
}

/// Widget displaying video preview with dark gradient overlay.
class VideoPreviewWidget extends StatelessWidget {
  const VideoPreviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: AppSpacing.mediaPreviewHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.bgDarkTertiary, AppColors.bgDarkQuaternary],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.fade(AppColors.opacityMedium),
              Colors.black.fade(0.7),
            ],
          ),
        ),
      ),
    );
  }
}

