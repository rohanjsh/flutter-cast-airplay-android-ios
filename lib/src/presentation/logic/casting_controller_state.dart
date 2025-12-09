import 'package:equatable/equatable.dart';

import '../../casting/casting_api.g.dart' as api;

enum PlaybackTarget { none, remote, local }

class CastingUiState extends Equatable {
  const CastingUiState({
    required this.target,
    required this.devices,
    required this.castingMode,
    this.selectedDeviceId,
    this.selectedDeviceName,
    this.currentMedia,
    this.isDiscovering = false,
    this.isLoading = false,
    this.isPlaying = false,
    this.progress = 0.0,
    this.currentPositionSeconds = 0,
    this.totalDurationSeconds = 0,
    this.errorMessage,
  });

  final PlaybackTarget target;

  final List<CastDevice> devices;

  final String? selectedDeviceId;
  final String? selectedDeviceName;

  final bool isDiscovering;
  final CastingMode castingMode;

  final api.MediaInfo? currentMedia;

  final bool isLoading;

  final bool isPlaying;

  final double progress;

  final int currentPositionSeconds;
  final int totalDurationSeconds;

  final String? errorMessage;

  bool get isConnected => selectedDeviceId != null;

  bool get hasError => errorMessage != null;

  bool get canControl => isConnected && currentMedia != null && !isLoading;

  static const initial = CastingUiState(
    target: PlaybackTarget.none,
    devices: [],
    castingMode: CastingMode.video,
  );

  @override
  List<Object?> get props => [
    target,
    devices,
    castingMode,
    selectedDeviceId,
    selectedDeviceName,
    currentMedia?.contentUrl,
    isDiscovering,
    isLoading,
    isPlaying,
    progress,
    currentPositionSeconds,
    totalDurationSeconds,
    errorMessage,
  ];

  CastingUiState copyWith({
    PlaybackTarget? target,
    List<CastDevice>? devices,
    CastingMode? castingMode,
    String? selectedDeviceId,
    String? selectedDeviceName,
    api.MediaInfo? currentMedia,
    bool? isDiscovering,
    bool? isLoading,
    bool? isPlaying,
    double? progress,
    int? currentPositionSeconds,
    int? totalDurationSeconds,
    String? errorMessage,
    // Clear flags for nullable fields
    bool clearDevice = false,
    bool clearMedia = false,
    bool clearError = false,
  }) {
    return CastingUiState(
      target: target ?? this.target,
      devices: devices ?? this.devices,
      castingMode: castingMode ?? this.castingMode,
      selectedDeviceId: clearDevice
          ? null
          : (selectedDeviceId ?? this.selectedDeviceId),
      selectedDeviceName: clearDevice
          ? null
          : (selectedDeviceName ?? this.selectedDeviceName),
      currentMedia: clearMedia ? null : (currentMedia ?? this.currentMedia),
      isDiscovering: isDiscovering ?? this.isDiscovering,
      isLoading: isLoading ?? this.isLoading,
      isPlaying: isPlaying ?? this.isPlaying,
      progress: progress ?? this.progress,
      currentPositionSeconds:
          currentPositionSeconds ?? this.currentPositionSeconds,
      totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

enum CastingMode { audio, video }

enum DeviceType { chromecast, airplay }

extension CastingProviderToDeviceType on api.CastingProvider {
  DeviceType toDeviceType() => switch (this) {
    api.CastingProvider.chromecast => DeviceType.chromecast,
    api.CastingProvider.airplay => DeviceType.airplay,
  };
}

extension ApiCastDeviceToUi on api.CastDevice {
  CastDevice toUiDevice({bool isConnected = false}) => CastDevice(
    id: id,
    name: name,
    type: provider.toDeviceType(),
    isConnected: isConnected,
  );
}

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
