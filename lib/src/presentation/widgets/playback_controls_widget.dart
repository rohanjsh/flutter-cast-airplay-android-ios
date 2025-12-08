import 'package:flutter/material.dart';

import '../controllers/casting_controller_scope.dart';
import '../theme/theme.dart';

/// Widget displaying playback controls with play/pause, skip, and progress bar.
///
/// Accesses [CastingController] via [CastingControllerScope] - no prop drilling.
/// Works with both remote casting and local playback.
class PlaybackControlsWidget extends StatelessWidget {
  const PlaybackControlsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final state = CastingControllerScope.stateOf(context);
    final controller = CastingControllerScope.of(context);

    return Column(
      children: [
        _TransportControls(
          isPlaying: state.isPlaying,
          onPlayPause: controller.togglePlayPause,
          onSkipPrevious: controller.skipBackward,
          onSkipNext: controller.skipForward,
        ),
        const SizedBox(height: AppSpacing.paddingXLarge),
        _ProgressBar(
          progress: state.progress,
          currentPosition: state.currentPositionSeconds,
          totalDuration: state.totalDurationSeconds,
          onProgressChanged: controller.seekToProgress,
        ),
      ],
    );
  }
}

class _TransportControls extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onSkipPrevious;
  final VoidCallback onSkipNext;

  const _TransportControls({
    required this.isPlaying,
    required this.onPlayPause,
    required this.onSkipPrevious,
    required this.onSkipNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SkipButton(icon: Icons.skip_previous, onTap: onSkipPrevious),
        const SizedBox(width: AppSpacing.paddingLarge),
        _PlayPauseButton(isPlaying: isPlaying, onTap: onPlayPause),
        const SizedBox(width: AppSpacing.paddingLarge),
        _SkipButton(icon: Icons.skip_next, onTap: onSkipNext),
      ],
    );
  }
}

class _SkipButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SkipButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.paddingMedium),
        decoration: AppDecorations.secondaryButton,
        child: Icon(icon, color: Colors.white, size: AppSpacing.iconXLarge),
      ),
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onTap;

  const _PlayPauseButton({required this.isPlaying, required this.onTap});

  IconData get _icon => isPlaying ? Icons.pause : Icons.play_arrow;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppSpacing.playButtonSize,
        height: AppSpacing.playButtonSize,
        decoration: AppDecorations.playButton,
        child: Icon(_icon, color: Colors.white, size: AppSpacing.iconXXLarge),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double progress;
  final int currentPosition;
  final int totalDuration;
  final Function(double) onProgressChanged;

  static const double _progressBarOpacity = 0.8;

  const _ProgressBar({
    required this.progress,
    required this.currentPosition,
    required this.totalDuration,
    required this.onProgressChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onHorizontalDragUpdate: (details) =>
              _handleProgressDrag(context, details),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: AppSpacing.progressBarHeight,
              backgroundColor: Colors.white.fade(AppColors.opacityVeryLow),
              valueColor: AlwaysStoppedAnimation(
                AppColors.primaryIndigo.fade(_progressBarOpacity),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.paddingSmall),
        _TimeLabels(
          currentPosition: currentPosition,
          totalDuration: totalDuration,
        ),
      ],
    );
  }

  void _handleProgressDrag(BuildContext context, DragUpdateDetails details) {
    final box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);
    final newProgress = (localPosition.dx / box.size.width).clamp(0.0, 1.0);
    onProgressChanged(newProgress);
  }
}

class _TimeLabels extends StatelessWidget {
  final int currentPosition;
  final int totalDuration;

  const _TimeLabels({
    required this.currentPosition,
    required this.totalDuration,
  });

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final timeStyle = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: Colors.grey[400]);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(_formatTime(currentPosition), style: timeStyle),
        Text(_formatTime(totalDuration), style: timeStyle),
      ],
    );
  }
}
