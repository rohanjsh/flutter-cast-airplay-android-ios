part of 'media_player_page.dart';

extension on BuildContext {
  AppThemeExtension get appTheme =>
      Theme.of(this).extension<AppThemeExtension>()!;
}

class _CastScreenHeader extends StatelessWidget {
  const _CastScreenHeader();

  Future<void> _showDeviceSelector(BuildContext context) async {
    final controller = CastControllerScope.of(context);
    await controller.startDiscovery();

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => CastControllerScope(
        controller: controller,
        child: const _DeviceSelectionSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = CastControllerScope.stateOf(context);
    final theme = context.appTheme;
    final isConnected = state is ConnectedState || state is ConnectingState;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: theme.paddingXLarge,
        vertical: theme.paddingLarge,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const _CastHeaderTitle(),
          _CastConnectionButton(
            onTap: () => _showDeviceSelector(context),
            isSelected: isConnected,
          ),
        ],
      ),
    );
  }
}

class _CastConnectionButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isSelected;

  const _CastConnectionButton({required this.onTap, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = isSelected ? colorScheme.primary : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(theme.paddingMedium),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.fade(theme.opacityMedium)
              : Colors.white.fade(theme.opacityVeryLow),
          borderRadius: BorderRadius.circular(theme.radiusLarge),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary.fade(theme.opacityHigh)
                : Colors.white.fade(theme.opacityVeryLow),
          ),
        ),
        child: Icon(Icons.cast, color: iconColor, size: theme.iconLarge),
      ),
    );
  }
}

class _DeviceSelectionSheet extends StatelessWidget {
  const _DeviceSelectionSheet();

  @override
  Widget build(BuildContext context) {
    final state = CastControllerScope.stateOf(context);
    final controller = CastControllerScope.of(context);
    final theme = context.appTheme;

    final connectedDevice = switch (state) {
      ConnectedState(:final device) => device,
      ConnectingState(:final device) => device,
      DisconnectedState() => null,
    };
    final isConnected = connectedDevice != null;
    final showDisconnect =
        isConnected && connectedDevice.provider != CastProvider.airplay;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgDarkSecondary,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(theme.radiusXXLarge),
        ),
        border: Border(
          top: BorderSide(color: Colors.white.fade(theme.opacityVeryLow)),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(theme.paddingXLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SheetDragHandle(),
            SizedBox(height: theme.paddingXLarge),
            const _SheetTitle(title: Strings.selectDevice),
            SizedBox(height: theme.paddingLarge),

            if (Platform.isIOS) ...[
              _AirPlaySelectionTile(
                onTap: () {
                  controller.connect('airplay_available');
                  Navigator.pop(context);
                },
              ),
              SizedBox(height: theme.paddingSmall),
              const _ListSectionDivider(),
              SizedBox(height: theme.paddingSmall),
            ],

            const _AvailableDeviceList(),

            if (showDisconnect) ...[
              SizedBox(height: theme.paddingMedium),
              const _ListSectionDivider(),
              SizedBox(height: theme.paddingMedium),
              _DisconnectActionTile(
                onTap: () {
                  controller.disconnect();
                  Navigator.pop(context);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AvailableDeviceList extends StatelessWidget {
  const _AvailableDeviceList();

  @override
  Widget build(BuildContext context) {
    final state = CastControllerScope.stateOf(context);
    final controller = CastControllerScope.of(context);
    final isDiscovering = controller.isDiscovering;

    final connectedDeviceId = switch (state) {
      ConnectedState(:final device) => device.id,
      ConnectingState(:final device) => device.id,
      DisconnectedState() => null,
    };

    final chromecastDevices = state.devices
        .where((d) => d.provider != CastProvider.airplay)
        .toList();

    if (isDiscovering && chromecastDevices.isEmpty) {
      return const _DeviceScanningLoader();
    }

    if (chromecastDevices.isEmpty) {
      return const _NoDevicesFoundPlaceholder();
    }

    return Column(
      children: [
        if (isDiscovering) const _DeviceScanningLoader(),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: chromecastDevices.length,
          itemBuilder: (context, index) => _DeviceListTile(
            device: chromecastDevices[index],
            isSelected: connectedDeviceId == chromecastDevices[index].id,
            onTap: () => controller.connect(chromecastDevices[index].id),
          ),
        ),
      ],
    );
  }
}

class _CastModeSelector extends StatelessWidget {
  const _CastModeSelector();

  @override
  Widget build(BuildContext context) {
    final controller = CastControllerScope.watch(context);
    final theme = context.appTheme;
    final currentMode = controller.castMode;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.fade(theme.opacityMinimal),
        borderRadius: BorderRadius.circular(theme.radiusLarge),
        border: Border.all(color: Colors.white.fade(theme.opacityVeryLow)),
      ),
      padding: EdgeInsets.all(theme.paddingXSmall),
      child: Row(
        children: [
          Expanded(
            child: _ModeSelectionButton(
              icon: Icons.music_note,
              label: Strings.audioMode,
              isSelected: currentMode == CastMode.audio,
              onTap: () => controller.setCastMode(CastMode.audio),
            ),
          ),
          SizedBox(width: theme.paddingXSmall),
          Expanded(
            child: _ModeSelectionButton(
              icon: Icons.play_circle_filled,
              label: Strings.videoMode,
              isSelected: currentMode == CastMode.video,
              onTap: () => controller.setCastMode(CastMode.video),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransportActionButtons extends StatelessWidget {
  const _TransportActionButtons();

  @override
  Widget build(BuildContext context) {
    final state = CastControllerScope.stateOf(context);
    final controller = CastControllerScope.of(context);

    final (isPlaying, isLoading) = switch (state) {
      ConnectedState(:final playback) => (
        playback.status == PlaybackStatus.playing,
        playback.status == PlaybackStatus.loading,
      ),
      _ => (false, false),
    };

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SkipActionButton(
          icon: Icons.skip_previous,
          onTap: controller.skipBackward,
        ),
        const SizedBox(width: AppSpacing.paddingLarge),
        _PlayPauseActionButton(
          isPlaying: isPlaying,
          isLoading: isLoading,
          onTap: controller.togglePlayPause,
        ),
        const SizedBox(width: AppSpacing.paddingLarge),
        _SkipActionButton(icon: Icons.skip_next, onTap: controller.skipForward),
      ],
    );
  }
}

class _PlaybackProgressSlider extends StatefulWidget {
  const _PlaybackProgressSlider();

  @override
  State<_PlaybackProgressSlider> createState() =>
      _PlaybackProgressSliderState();
}

class _PlaybackProgressSliderState extends State<_PlaybackProgressSlider> {
  static const double _progressBarOpacity = 0.8;

  double _lastProgress = 0.0;
  int _lastPositionSecs = 0;
  int _lastDurationSecs = 0;

  @override
  Widget build(BuildContext context) {
    final state = CastControllerScope.stateOf(context);
    final controller = CastControllerScope.of(context);
    final theme = context.appTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final (progress, positionSecs, durationSecs) = switch (state) {
      ConnectedState(:final playback) => (
        playback.progress,
        playback.position.inSeconds,
        playback.duration.inSeconds,
      ),
      _ => (_lastProgress, _lastPositionSecs, _lastDurationSecs),
    };

    if (durationSecs > 0) {
      _lastProgress = progress;
      _lastPositionSecs = positionSecs;
      _lastDurationSecs = durationSecs;
    }

    final displayProgress = durationSecs > 0 ? progress : _lastProgress;
    final displayPosition = durationSecs > 0 ? positionSecs : _lastPositionSecs;
    final displayDuration = durationSecs > 0 ? durationSecs : _lastDurationSecs;

    return Column(
      children: [
        GestureDetector(
          onHorizontalDragUpdate: (details) =>
              _handleProgressDrag(context, details, controller),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(theme.radiusSmall),
            child: LinearProgressIndicator(
              value: displayProgress.clamp(0.0, 1.0),
              minHeight: theme.progressBarHeight,
              backgroundColor: Colors.white.withValues(
                alpha: theme.opacityVeryLow,
              ),
              valueColor: AlwaysStoppedAnimation(
                colorScheme.primary.fade(_progressBarOpacity),
              ),
            ),
          ),
        ),
        SizedBox(height: theme.paddingSmall),
        _PlaybackDurationLabels(
          currentPosition: displayPosition,
          totalDuration: displayDuration,
        ),
      ],
    );
  }

  void _handleProgressDrag(
    BuildContext context,
    DragUpdateDetails details,
    CastController controller,
  ) {
    final box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);
    final newProgress = (localPosition.dx / box.size.width).clamp(0.0, 1.0);
    controller.seekToProgress(newProgress);
  }
}

class _CastScreenBody extends StatelessWidget {
  const _CastScreenBody();

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Column(
      children: [
        const _CastScreenHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: theme.paddingXLarge),
            child: Column(
              children: [
                SizedBox(height: theme.paddingXLarge),
                const _MediaControlCard(),
                SizedBox(height: theme.paddingHuge),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CastScreenBackground extends StatelessWidget {
  const _CastScreenBackground();

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Container(
      decoration: BoxDecoration(gradient: theme.backgroundGradient),
    );
  }
}

class _CastHeaderTitle extends StatelessWidget {
  const _CastHeaderTitle();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Strings.appTitle,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          Strings.appSubtitle,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[400]),
        ),
      ],
    );
  }
}

class _SheetDragHandle extends StatelessWidget {
  static const double _width = 40;
  static const double _height = 4;

  const _SheetDragHandle();

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Center(
      child: Container(
        width: _width,
        height: _height,
        decoration: BoxDecoration(
          color: Colors.white.fade(theme.opacityLow),
          borderRadius: BorderRadius.circular(theme.radiusSmall),
        ),
      ),
    );
  }
}

class _SheetTitle extends StatelessWidget {
  final String title;

  const _SheetTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}

class _DeviceScanningLoader extends StatelessWidget {
  const _DeviceScanningLoader();

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(theme.paddingXLarge),
      margin: EdgeInsets.only(bottom: theme.paddingMedium),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(colorScheme.primary.fade(0.8)),
            ),
          ),
          SizedBox(width: theme.paddingMedium),
          Text(
            Strings.scanningDevices,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _NoDevicesFoundPlaceholder extends StatelessWidget {
  const _NoDevicesFoundPlaceholder();

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Container(
      padding: EdgeInsets.all(theme.paddingXLarge),
      child: Column(
        children: [
          Icon(Icons.cast, size: 48, color: Colors.grey[600]),
          SizedBox(height: theme.paddingMedium),
          Text(
            Strings.noDevicesFound,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _DeviceListTile extends StatelessWidget {
  final CastDevice device;
  final bool isSelected;
  final VoidCallback onTap;

  const _DeviceListTile({
    required this.device,
    required this.isSelected,
    required this.onTap,
  });

  IconData get _icon =>
      device.provider == CastProvider.chromecast ? Icons.cast : Icons.airplay;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = isSelected ? colorScheme.primary : Colors.grey;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: theme.paddingMedium),
        padding: EdgeInsets.all(theme.paddingLarge),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.fade(theme.opacityMedium)
              : Colors.white.fade(theme.opacityMinimal),
          borderRadius: BorderRadius.circular(theme.radiusLarge),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary.fade(theme.opacityHigh)
                : Colors.white.fade(theme.opacityVeryLow),
          ),
        ),
        child: Row(
          children: [
            Icon(_icon, color: iconColor),
            SizedBox(width: theme.paddingMedium),
            Expanded(
              child: _DeviceTileContent(
                device: device,
                isConnected: isSelected,
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: colorScheme.primary),
          ],
        ),
      ),
    );
  }
}

class _DeviceTileContent extends StatelessWidget {
  final CastDevice device;
  final bool isConnected;

  const _DeviceTileContent({required this.device, this.isConnected = false});

  String get _statusText =>
      isConnected ? Strings.deviceConnected : Strings.deviceAvailable;

  @override
  Widget build(BuildContext context) {
    final statusColor = isConnected ? AppColors.accentGreen : Colors.grey[500]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          device.name,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        Text(
          _statusText,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: statusColor),
        ),
      ],
    );
  }
}

class _ListSectionDivider extends StatelessWidget {
  const _ListSectionDivider();

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Container(height: 1, color: Colors.white.fade(theme.opacityVeryLow));
  }
}

class _AirPlaySelectionTile extends StatelessWidget {
  final VoidCallback onTap;

  const _AirPlaySelectionTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(theme.paddingLarge),
        decoration: BoxDecoration(
          color: Colors.white.fade(theme.opacityMinimal),
          borderRadius: BorderRadius.circular(theme.radiusLarge),
          border: Border.all(color: Colors.white.fade(theme.opacityVeryLow)),
        ),
        child: Row(
          children: [
            const Icon(Icons.airplay, color: Colors.white),
            SizedBox(width: theme.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Strings.airPlay,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    Strings.airPlayDescription,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _DisconnectActionTile extends StatelessWidget {
  final VoidCallback onTap;

  const _DisconnectActionTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final errorColor = colorScheme.error;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(theme.paddingLarge),
        decoration: BoxDecoration(
          color: errorColor.fade(0.1),
          borderRadius: BorderRadius.circular(theme.radiusMedium),
          border: Border.all(color: errorColor.fade(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.link_off, color: errorColor, size: 20),
            SizedBox(width: theme.paddingSmall),
            Text(
              Strings.disconnect,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: errorColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AudioArtworkPreview extends StatelessWidget {
  const _AudioArtworkPreview();

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      height: theme.mediaPreviewHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(theme.radiusXLarge),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.primary, AppColors.primaryPurple],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.music_note,
          size: theme.iconHuge,
          color: Colors.white.fade(theme.opacityMedium),
        ),
      ),
    );
  }
}

class _VideoThumbnailPreview extends StatelessWidget {
  const _VideoThumbnailPreview();

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Container(
      width: double.infinity,
      height: theme.mediaPreviewHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(theme.radiusXLarge),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.bgDarkTertiary, AppColors.bgDarkQuaternary],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(theme.radiusXLarge),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.fade(theme.opacityMedium),
              Colors.black.fade(0.7),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeSelectionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeSelectionButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final contentColor = isSelected ? Colors.white : Colors.grey[400];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: theme.paddingMedium,
          horizontal: theme.paddingLarge,
        ),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(theme.radiusMedium),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: theme.iconMedium, color: contentColor),
            SizedBox(width: theme.paddingSmall),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: contentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MediaControlCard extends StatelessWidget {
  const _MediaControlCard();

  @override
  Widget build(BuildContext context) {
    final state = CastControllerScope.stateOf(context);
    final controller = CastControllerScope.watch(context);
    final theme = context.appTheme;
    final isAudioMode = controller.castMode == CastMode.audio;

    final connectedDevice = switch (state) {
      ConnectedState(:final device) => device,
      ConnectingState(:final device) => device,
      DisconnectedState() => null,
    };

    return Container(
      decoration: BoxDecoration(
        gradient: theme.cardGradient,
        borderRadius: BorderRadius.circular(theme.radiusXXLarge),
        border: Border.all(color: Colors.white.fade(theme.opacityLow)),
      ),
      padding: EdgeInsets.all(theme.paddingXXLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CastModeSelector(),
          SizedBox(height: theme.paddingXLarge),
          isAudioMode
              ? const _AudioArtworkPreview()
              : const _VideoThumbnailPreview(),
          SizedBox(height: theme.paddingXLarge),
          const _MediaPlaybackControls(),
          SizedBox(height: theme.paddingXLarge),
          const _MediaMetadataDisplay(),
          if (connectedDevice != null) ...[
            SizedBox(height: theme.paddingXLarge),
            const _ActiveSessionIndicator(),
          ],
        ],
      ),
    );
  }
}

class _MediaMetadataDisplay extends StatelessWidget {
  const _MediaMetadataDisplay();

  @override
  Widget build(BuildContext context) {
    final controller = CastControllerScope.watch(context);
    final isAudioMode = controller.castMode == CastMode.audio;

    final title = isAudioMode ? Strings.audioTitle : Strings.videoTitle;
    final subtitle = isAudioMode ? Strings.audioArtist : Strings.videoChannel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: AppSpacing.paddingSmall),
        Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[400]),
        ),
      ],
    );
  }
}

class _ActiveSessionIndicator extends StatelessWidget {
  const _ActiveSessionIndicator();

  @override
  Widget build(BuildContext context) {
    final state = CastControllerScope.stateOf(context);
    final theme = context.appTheme;

    final deviceName = switch (state) {
      ConnectedState(:final device) => device.name,
      ConnectingState(:final device) => device.name,
      DisconnectedState() => '',
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: theme.paddingMedium,
        vertical: theme.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: AppColors.accentGreen.fade(theme.opacityLow),
        borderRadius: BorderRadius.circular(theme.radiusSmall),
        border: Border.all(
          color: AppColors.accentGreen.fade(theme.opacityMedium),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.cast_connected,
            size: theme.iconSmall,
            color: AppColors.accentGreen,
          ),
          SizedBox(width: theme.paddingSmall),
          Expanded(
            child: Text(
              '${Strings.castingStatusPrefix}$deviceName',
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

class _MediaPlaybackControls extends StatelessWidget {
  const _MediaPlaybackControls();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _TransportActionButtons(),
        SizedBox(height: AppSpacing.paddingXLarge),
        _PlaybackProgressSlider(),
      ],
    );
  }
}

class _SkipActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SkipActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(theme.paddingMedium),
        decoration: theme.secondaryButtonDecoration,
        child: Icon(icon, color: Colors.white, size: theme.iconXLarge),
      ),
    );
  }
}

class _PlayPauseActionButton extends StatelessWidget {
  final bool isPlaying;
  final bool isLoading;
  final VoidCallback onTap;

  const _PlayPauseActionButton({
    required this.isPlaying,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: theme.playButtonSize,
        height: theme.playButtonSize,
        decoration: theme.playButtonDecoration,
        child: isLoading
            ? Padding(
                padding: EdgeInsets.all(theme.paddingLarge),
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: theme.iconXXLarge,
              ),
      ),
    );
  }
}

class _PlaybackDurationLabels extends StatelessWidget {
  final int currentPosition;
  final int totalDuration;

  const _PlaybackDurationLabels({
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
    final timeStyle = Theme.of(context).textTheme.bodySmall;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(_formatTime(currentPosition), style: timeStyle),
        Text(_formatTime(totalDuration), style: timeStyle),
      ],
    );
  }
}
