import 'package:flutter/material.dart';

import '../constants/strings.dart';
import '../models/models.dart';
import '../theme/theme.dart';

/// Widget for selecting a cast device.
///
/// Displays a bottom sheet with available cast devices.
class DeviceSelectorWidget extends StatelessWidget {
  final List<CastDevice> availableDevices;
  final String? selectedDeviceId;
  final Function(String) onDeviceSelected;

  const DeviceSelectorWidget({
    super.key,
    required this.availableDevices,
    required this.selectedDeviceId,
    required this.onDeviceSelected,
  });

  @override
  Widget build(BuildContext context) {
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
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: availableDevices.length,
              itemBuilder: (context, index) => _DeviceItem(
                device: availableDevices[index],
                isSelected: selectedDeviceId == availableDevices[index].id,
                onTap: () {
                  onDeviceSelected(availableDevices[index].id);
                  Navigator.pop(context);
                },
              ),
            ),
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

  String get _statusText =>
      device.isConnected ? UIStrings.deviceConnected : UIStrings.deviceOffline;

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

