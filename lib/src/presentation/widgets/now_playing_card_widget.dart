import 'package:flutter/material.dart';

import '../constants/strings.dart';
import '../models/models.dart';
import '../theme/theme.dart';
import 'media_preview_widgets.dart';
import 'mode_toggle_widget.dart';
import 'playback_controls_widget.dart';

/// Main now playing card widget combining all playback UI elements.
class NowPlayingCardWidget extends StatelessWidget {
  final PlaybackState state;
  final List<CastDevice> availableDevices;
  final Function(CastingMode) onModeChanged;
  final VoidCallback onPlayPause;
  final VoidCallback onSkipPrevious;
  final VoidCallback onSkipNext;
  final Function(double) onProgressChanged;

  const NowPlayingCardWidget({
    super.key,
    required this.state,
    required this.availableDevices,
    required this.onModeChanged,
    required this.onPlayPause,
    required this.onSkipPrevious,
    required this.onSkipNext,
    required this.onProgressChanged,
  });

  bool get _isAudioMode => state.castingMode == CastingMode.audio;
  bool get _hasSelectedDevice => state.selectedDevice != null;

  String _getDeviceName(String? deviceId) {
    final device = availableDevices.firstWhere(
      (d) => d.id == deviceId,
      orElse: () => availableDevices.first,
    );
    return device.name;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.cardGradient,
      padding: const EdgeInsets.all(AppSpacing.paddingXXLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ModeToggleWidget(
            currentMode: state.castingMode,
            onModeChanged: onModeChanged,
          ),
          const SizedBox(height: AppSpacing.paddingXLarge),
          _isAudioMode
              ? const AudioPreviewWidget()
              : const VideoPreviewWidget(),
          const SizedBox(height: AppSpacing.paddingXLarge),
          PlaybackControlsWidget(
            state: state,
            onPlayPause: onPlayPause,
            onSkipPrevious: onSkipPrevious,
            onSkipNext: onSkipNext,
            onProgressChanged: onProgressChanged,
          ),
          const SizedBox(height: AppSpacing.paddingXLarge),
          _MediaInfo(isAudioMode: _isAudioMode),
          if (_hasSelectedDevice) ...[
            const SizedBox(height: AppSpacing.paddingXLarge),
            _CastingStatus(deviceName: _getDeviceName(state.selectedDevice)),
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

