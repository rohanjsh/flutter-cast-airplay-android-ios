import 'package:flutter/material.dart';

import '../constants/strings.dart';
import '../controllers/casting_controller_scope.dart';
import '../models/models.dart';
import '../theme/theme.dart';
import 'media_preview_widgets.dart';
import 'mode_toggle_widget.dart';
import 'playback_controls_widget.dart';

/// Main now playing card widget combining all playback UI elements.
///
/// Accesses [CastingController] via [CastingControllerScope] - no prop drilling.
class NowPlayingCardWidget extends StatelessWidget {
  const NowPlayingCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final state = CastingControllerScope.stateOf(context);
    final isAudioMode = state.castingMode == CastingMode.audio;
    final hasSelectedDevice = state.selectedDeviceId != null;

    return Container(
      decoration: AppDecorations.cardGradient,
      padding: const EdgeInsets.all(AppSpacing.paddingXXLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ModeToggleWidget(),
          const SizedBox(height: AppSpacing.paddingXLarge),
          isAudioMode ? const AudioPreviewWidget() : const VideoPreviewWidget(),
          const SizedBox(height: AppSpacing.paddingXLarge),
          const PlaybackControlsWidget(),
          const SizedBox(height: AppSpacing.paddingXLarge),
          _MediaInfo(isAudioMode: isAudioMode),
          if (hasSelectedDevice && state.selectedDeviceName != null) ...[
            const SizedBox(height: AppSpacing.paddingXLarge),
            _CastingStatus(deviceName: state.selectedDeviceName!),
          ],
        ],
      ),
    );
  }
}

class _MediaInfo extends StatelessWidget {
  final bool isAudioMode;

  const _MediaInfo({required this.isAudioMode});

  String get _title =>
      isAudioMode ? MediaContent.audioTitle : MediaContent.videoTitle;

  String get _subtitle =>
      isAudioMode ? MediaContent.audioArtist : MediaContent.videoChannel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: AppSpacing.paddingSmall),
        Text(
          _subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[400]),
        ),
      ],
    );
  }
}

class _CastingStatus extends StatelessWidget {
  final String deviceName;

  const _CastingStatus({required this.deviceName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.paddingMedium,
        vertical: AppSpacing.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: AppColors.accentGreen.fade(AppColors.opacityLow),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        border: Border.all(
          color: AppColors.accentGreen.fade(AppColors.opacityMedium),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.cast_connected,
            size: AppSpacing.iconSmall,
            color: AppColors.accentGreen,
          ),
          const SizedBox(width: AppSpacing.paddingSmall),
          Expanded(
            child: Text(
              '${UIStrings.castingStatusPrefix}$deviceName',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.accentGreen,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
