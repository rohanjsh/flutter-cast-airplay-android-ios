// =============================================================================
// UI MODELS - Presentation layer models
// =============================================================================
// These models adapt the Pigeon-generated types for UI consumption.
// We keep UI models separate to:
// 1. Decouple UI from generated code
// 2. Add UI-specific computed properties
// 3. Make widgets easier to test with mock data
// 4. Support equality comparison for state diffing
// =============================================================================

import 'package:equatable/equatable.dart';

import '../../casting/casting_api.g.dart' as api;

// =============================================================================
// ENUMS
// =============================================================================

/// Casting mode enum for audio and video content.
enum CastingMode { audio, video }

/// Device type enum for Chromecast and AirPlay.
enum DeviceType { chromecast, airplay }

// =============================================================================
// EXTENSIONS - Map Pigeon types to UI types
// =============================================================================

extension CastingProviderToDeviceType on api.CastingProvider {
  DeviceType toDeviceType() => switch (this) {
    api.CastingProvider.chromecast => DeviceType.chromecast,
    api.CastingProvider.airplay => DeviceType.airplay,
  };
}

extension ApiCastDeviceToUi on api.CastDevice {
  /// Convert Pigeon CastDevice to UI CastDevice.
  CastDevice toUiDevice({bool isConnected = false}) => CastDevice(
    id: id,
    name: name,
    type: provider.toDeviceType(),
    isConnected: isConnected,
  );
}

// =============================================================================
// CAST DEVICE - UI-friendly device model
// =============================================================================

/// Model representing a cast device.
///
/// Used to display available devices in the device selector.
/// This is a UI-only model that wraps the Pigeon-generated [api.CastDevice].
/// Extends [Equatable] to enable state comparison in [CastingUiState].
class CastDevice extends Equatable {
  final String id;
  final String name;
  final DeviceType type;
  final bool isConnected;

  const CastDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.isConnected,
  });

  @override
  List<Object?> get props => [id, name, type, isConnected];
}
