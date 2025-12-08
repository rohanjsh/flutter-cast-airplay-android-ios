// =============================================================================
// CASTING UI STATE - Immutable state for the casting UI
// =============================================================================
// This state class represents everything the UI needs to render.
// It supports both remote casting (Chromecast/AirPlay) and future local
// playback modes through the PlaybackTarget enum.
//
// Design Principles:
// 1. Immutable - All state changes create new instances via copyWith
// 2. Single Source of Truth - One state class for the entire casting UI
// 3. Extensible - PlaybackTarget allows adding local playback without changes
// 4. Equatable - Prevents unnecessary rebuilds when state hasn't changed
// =============================================================================

import 'package:equatable/equatable.dart';

import '../../casting/casting_api.g.dart' as api;
import '../models/models.dart';

// =============================================================================
// PLAYBACK TARGET - Where media is being played
// =============================================================================

/// Represents where media playback is occurring.
///
/// This enum enables future extension to local playback without changing
/// the UI architecture. Widgets can check this to adapt their behavior.
enum PlaybackTarget {
  /// No active playback - idle state.
  none,

  /// Playing on a remote device (Chromecast, AirPlay).
  remote,

  /// Playing locally on the mobile device (future feature).
  local,
}

// =============================================================================
// CASTING UI STATE - Single immutable state for UI
// =============================================================================

/// Immutable state class representing the entire casting UI state.
///
/// Extends [Equatable] to enable efficient state comparison and prevent
/// unnecessary widget rebuilds when the state hasn't actually changed.
///
/// ## Usage
/// ```dart
/// final state = CastingUiState.initial;
///
/// // Check playback target
/// if (state.target == PlaybackTarget.remote) {
///   showCastingIndicator();
/// }
///
/// // Check if playing
/// if (state.isPlaying) {
///   showPauseButton();
/// }
/// ```
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

  // ---------------------------------------------------------------------------
  // PLAYBACK TARGET
  // ---------------------------------------------------------------------------

  /// Where playback is occurring (none, remote, or local).
  final PlaybackTarget target;

  // ---------------------------------------------------------------------------
  // DEVICE STATE
  // ---------------------------------------------------------------------------

  /// List of discovered cast devices.
  final List<CastDevice> devices;

  /// ID of the currently selected/connected device (null if disconnected).
  final String? selectedDeviceId;

  /// Name of the currently selected/connected device.
  final String? selectedDeviceName;

  // ---------------------------------------------------------------------------
  // DISCOVERY STATE
  // ---------------------------------------------------------------------------

  /// Whether device discovery is in progress.
  final bool isDiscovering;

  // ---------------------------------------------------------------------------
  // PLAYBACK STATE
  // ---------------------------------------------------------------------------

  /// Current casting mode (audio or video).
  final CastingMode castingMode;

  /// Currently loaded media information.
  final api.MediaInfo? currentMedia;

  /// Whether media is currently loading.
  final bool isLoading;

  /// Whether media is currently playing.
  final bool isPlaying;

  /// Playback progress (0.0 to 1.0).
  final double progress;

  /// Current playback position in seconds.
  final int currentPositionSeconds;

  /// Total media duration in seconds.
  final int totalDurationSeconds;

  // ---------------------------------------------------------------------------
  // ERROR STATE
  // ---------------------------------------------------------------------------

  /// Error message to display (null if no error).
  final String? errorMessage;

  // ---------------------------------------------------------------------------
  // COMPUTED PROPERTIES
  // ---------------------------------------------------------------------------

  /// Whether connected to a remote device.
  bool get isConnected => selectedDeviceId != null;

  /// Whether there's an active error.
  bool get hasError => errorMessage != null;

  /// Whether playback controls should be enabled.
  bool get canControl => isConnected && currentMedia != null && !isLoading;

  // ---------------------------------------------------------------------------
  // FACTORY CONSTRUCTORS
  // ---------------------------------------------------------------------------

  /// Initial idle state.
  static const initial = CastingUiState(
    target: PlaybackTarget.none,
    devices: [],
    castingMode: CastingMode.video,
  );

  // ---------------------------------------------------------------------------
  // EQUATABLE
  // ---------------------------------------------------------------------------

  @override
  List<Object?> get props => [
    target,
    devices,
    castingMode,
    selectedDeviceId,
    selectedDeviceName,
    currentMedia
        ?.contentUrl, // Compare by URL since MediaInfo may not be Equatable
    isDiscovering,
    isLoading,
    isPlaying,
    progress,
    currentPositionSeconds,
    totalDurationSeconds,
    errorMessage,
  ];

  // ---------------------------------------------------------------------------
  // COPY WITH
  // ---------------------------------------------------------------------------

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
