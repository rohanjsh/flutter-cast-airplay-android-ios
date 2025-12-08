import 'dart:io' show Platform;

import 'package:flutter/material.dart';

import '../constants/strings.dart';
import '../controllers/casting_controller_scope.dart';
import '../models/models.dart';
import '../theme/theme.dart';

/// Widget for selecting a cast device.
///
/// Displays a bottom sheet with available cast devices.
/// On iOS, includes an AirPlay option at the top.
/// Shows a disconnect button when a device is connected.
/// Shows a scanning indicator when discovering devices.
/// Accesses [CastingController] via [CastingControllerScope].
class DeviceSelectorWidget extends StatelessWidget {
  const DeviceSelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final state = CastingControllerScope.stateOf(context);
    final controller = CastingControllerScope.of(context);
    final isConnected = state.selectedDeviceId != null;

    final connectedDevice = state.devices
        .where((d) => d.id == state.selectedDeviceId)
        .firstOrNull;
    final showDisconnect =
        isConnected && connectedDevice?.type != DeviceType.airplay;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgDarkSecondary,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXXLarge),
        ),
        border: Border(
          top: BorderSide(color: Colors.white.fade(AppColors.opacityVeryLow)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.paddingXLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _DragHandle(),
            const SizedBox(height: AppSpacing.paddingXLarge),
            const _SheetTitle(title: UIStrings.selectDevice),
            const SizedBox(height: AppSpacing.paddingLarge),

            // AirPlay option (iOS only)
            if (Platform.isIOS) ...[
              _AirPlayItem(
                onTap: () {
                  controller.showAirPlayPicker();
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: AppSpacing.paddingSmall),
              const _SectionDivider(),
              const SizedBox(height: AppSpacing.paddingSmall),
            ],

            // Chromecast devices or scanning state
            _DeviceListSection(
              devices: state.devices,
              selectedDeviceId: state.selectedDeviceId,
              isDiscovering: state.isDiscovering,
              onDeviceSelected: (deviceId) {
                controller.connect(deviceId);
                Navigator.pop(context);
              },
            ),

            if (showDisconnect) ...[
              const SizedBox(height: AppSpacing.paddingMedium),
              const _SectionDivider(),
              const SizedBox(height: AppSpacing.paddingMedium),
              _DisconnectButton(
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

class _DragHandle extends StatelessWidget {
  static const double _width = 40;
  static const double _height = 4;

  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: _width,
        height: _height,
        decoration: BoxDecoration(
          color: Colors.white.fade(AppColors.opacityLow),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
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

/// Section showing device list or scanning indicator.
class _DeviceListSection extends StatelessWidget {
  final List<CastDevice> devices;
  final String? selectedDeviceId;
  final bool isDiscovering;
  final Function(String) onDeviceSelected;

  const _DeviceListSection({
    required this.devices,
    required this.selectedDeviceId,
    required this.isDiscovering,
    required this.onDeviceSelected,
  });

  @override
  Widget build(BuildContext context) {
    final chromecastDevices = devices
        .where((d) => d.type != DeviceType.airplay)
        .toList();

    // Show scanning indicator
    if (isDiscovering && chromecastDevices.isEmpty) {
      return const _ScanningIndicator();
    }

    // Show empty state
    if (chromecastDevices.isEmpty) {
      return const _EmptyDeviceState();
    }

    // Show device list
    return Column(
      children: [
        if (isDiscovering) const _ScanningIndicator(),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: chromecastDevices.length,
          itemBuilder: (context, index) => _DeviceItem(
            device: chromecastDevices[index],
            isSelected: selectedDeviceId == chromecastDevices[index].id,
            onTap: () => onDeviceSelected(chromecastDevices[index].id),
          ),
        ),
      ],
    );
  }
}

/// Scanning indicator with animation.
class _ScanningIndicator extends StatelessWidget {
  const _ScanningIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.paddingXLarge),
      margin: const EdgeInsets.only(bottom: AppSpacing.paddingMedium),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(
                AppColors.primaryIndigo.fade(0.8),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.paddingMedium),
          Text(
            UIStrings.scanningDevices,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}

/// Empty state when no devices are found.
class _EmptyDeviceState extends StatelessWidget {
  const _EmptyDeviceState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.paddingXLarge),
      child: Column(
        children: [
          Icon(Icons.cast, size: 48, color: Colors.grey[600]),
          const SizedBox(height: AppSpacing.paddingMedium),
          Text(
            UIStrings.noDevicesFound,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _DeviceItem extends StatelessWidget {
  final CastDevice device;
  final bool isSelected;
  final VoidCallback onTap;

  const _DeviceItem({
    required this.device,
    required this.isSelected,
    required this.onTap,
  });

  IconData get _icon =>
      device.type == DeviceType.chromecast ? Icons.cast : Icons.airplay;

  Color get _iconColor =>
      device.isConnected ? AppColors.primaryIndigo : Colors.grey;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.paddingMedium),
        padding: const EdgeInsets.all(AppSpacing.paddingLarge),
        decoration: AppDecorations.selectableMinimal(isSelected: isSelected),
        child: Row(
          children: [
            Icon(_icon, color: _iconColor),
            const SizedBox(width: AppSpacing.paddingMedium),
            Expanded(child: _DeviceInfo(device: device)),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primaryIndigo),
          ],
        ),
      ),
    );
  }
}

class _DeviceInfo extends StatelessWidget {
  final CastDevice device;

  const _DeviceInfo({required this.device});

  String get _statusText => device.isConnected
      ? UIStrings.deviceConnected
      : UIStrings.deviceAvailable;

  Color get _statusColor =>
      device.isConnected ? AppColors.accentGreen : Colors.grey[500]!;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          device.name,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        Text(
          _statusText,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: _statusColor),
        ),
      ],
    );
  }
}

/// Divider between sections.
class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: Colors.white.fade(AppColors.opacityVeryLow),
    );
  }
}

/// AirPlay item shown at the top on iOS.
class _AirPlayItem extends StatelessWidget {
  final VoidCallback onTap;

  const _AirPlayItem({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.paddingLarge),
        decoration: AppDecorations.selectableMinimal(isSelected: false),
        child: Row(
          children: [
            const Icon(Icons.airplay, color: Colors.white),
            const SizedBox(width: AppSpacing.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    UIStrings.airPlay,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    UIStrings.airPlayDescription,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[400]),
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

/// Disconnect button shown when a device is connected.
class _DisconnectButton extends StatelessWidget {
  final VoidCallback onTap;

  const _DisconnectButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.paddingLarge),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.link_off, color: Colors.red, size: 20),
            const SizedBox(width: AppSpacing.paddingSmall),
            Text(
              UIStrings.disconnect,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
