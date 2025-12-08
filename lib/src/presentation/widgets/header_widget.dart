import 'package:flutter/material.dart';

import '../constants/strings.dart';
import '../controllers/casting_controller_scope.dart';
import '../theme/theme.dart';
import 'device_selector_widget.dart';

/// Header widget displaying app title and cast button.
///
/// Shows the app branding on the left and a cast button on the right.
/// Tapping the cast button opens the device selector bottom sheet.
class HeaderWidget extends StatelessWidget {
  /// Whether a device is currently connected.
  final bool isDeviceSelected;

  const HeaderWidget({super.key, required this.isDeviceSelected});

  Future<void> _showDeviceSelector(BuildContext context) async {
    final controller = CastingControllerScope.of(context);
    await controller.startDiscovery();

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => CastingControllerScope(
        controller: controller,
        child: const DeviceSelectorWidget(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.paddingXLarge,
        vertical: AppSpacing.paddingLarge,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const _AppBranding(),
          _CastButton(
            onTap: () => _showDeviceSelector(context),
            isSelected: isDeviceSelected,
          ),
        ],
      ),
    );
  }
}

class _AppBranding extends StatelessWidget {
  const _AppBranding();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppConfig.appTitle,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          AppConfig.appSubtitle,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[400]),
        ),
      ],
    );
  }
}

class _CastButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isSelected;

  const _CastButton({required this.onTap, required this.isSelected});

  Color get _iconColor => isSelected ? AppColors.primaryIndigo : Colors.white;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.paddingMedium),
        decoration: AppDecorations.selectable(isSelected: isSelected),
        child: Icon(Icons.cast, color: _iconColor, size: AppSpacing.iconLarge),
      ),
    );
  }
}
