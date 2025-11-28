/// Casting mode enum for audio and video.
enum CastingMode { audio, video }

/// Device type enum for Chromecast and AirPlay.
enum DeviceType { chromecast, airplay }

/// Model representing a cast device.
///
/// Used to display available devices in the device selector.
class CastDevice {
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
}

/// Immutable state class for playback.
///
/// Uses copyWith pattern for safe state updates.
class PlaybackState {
  final double progress;
  final bool isPlaying;
  final int currentPosition;
  final int totalDuration;
  final CastingMode castingMode;
  final String? selectedDevice;

  const PlaybackState({
    required this.progress,
    required this.isPlaying,
    required this.currentPosition,
    required this.totalDuration,
    required this.castingMode,
    required this.selectedDevice,
  });

  PlaybackState copyWith({
    double? progress,
    bool? isPlaying,
    int? currentPosition,
    int? totalDuration,
    CastingMode? castingMode,
    String? selectedDevice,
  }) {
    return PlaybackState(
      progress: progress ?? this.progress,
      isPlaying: isPlaying ?? this.isPlaying,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
      castingMode: castingMode ?? this.castingMode,
      selectedDevice: selectedDevice ?? this.selectedDevice,
    );
  }
}

