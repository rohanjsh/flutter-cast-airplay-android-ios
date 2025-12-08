import 'package:flutter/material.dart';

import '../constants/strings.dart';
import '../controllers/casting_controller_scope.dart';
import '../models/models.dart';
import '../theme/theme.dart';

/// Widget for toggling between audio and video modes.
///
/// Displays a segmented control with audio and video options.
/// Accesses [CastingController] via [CastingControllerScope].
class ModeToggleWidget extends StatelessWidget {
  const ModeToggleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final state = CastingControllerScope.stateOf(context);
    final controller = CastingControllerScope.of(context);
    final currentMode = state.castingMode;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.fade(AppColors.opacityMinimal),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(color: Colors.white.fade(AppColors.opacityVeryLow)),
      ),
      padding: const EdgeInsets.all(AppSpacing.paddingXSmall),
      child: Row(
        children: [
          Expanded(
            child: _ModeButton(
              icon: Icons.music_note,
              label: UIStrings.audioMode,
              isSelected: currentMode == CastingMode.audio,
              onTap: () => controller.setCastingMode(CastingMode.audio),
            ),
          ),
          const SizedBox(width: AppSpacing.paddingXSmall),
          Expanded(
            child: _ModeButton(
              icon: Icons.play_circle_filled,
              label: UIStrings.videoMode,
              isSelected: currentMode == CastingMode.video,
              onTap: () => controller.setCastingMode(CastingMode.video),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  Color? get _contentColor => isSelected ? Colors.white : Colors.grey[400];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.paddingMedium,
          horizontal: AppSpacing.paddingLarge,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryIndigo : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: AppSpacing.iconMedium, color: _contentColor),
            const SizedBox(width: AppSpacing.paddingSmall),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: _contentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
