// =============================================================================
// CASTING CONTROLLER - Business Logic for Casting UI
// =============================================================================
// This controller separates business logic from UI. It:
// 1. Subscribes to CastingService.state stream
// 2. Maps UnifiedCastingState → CastingUiState for UI consumption
// 3. Provides action methods (connect, disconnect, play, pause, seek, etc.)
// 4. Notifies listeners when state changes
//
// Design Principles:
// 1. Single Responsibility - Only handles casting business logic
// 2. Separation of Concerns - UI knows nothing about CastingService internals
// 3. Testable - Can be unit tested without UI
// 4. Extensible - LocalPlaybackController could be added alongside this
// =============================================================================

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../casting/casting_api.g.dart' as api;
import '../../casting/casting_service.dart';
import '../../casting/sample_media.dart';
import '../models/models.dart';
import '../state/casting_ui_state.dart';

/// Callback type for error notifications.
///
/// The UI can provide this callback to show errors (e.g., via SnackBar).
typedef ErrorCallback = void Function(String message);

/// Controller for casting functionality.
///
/// ## Usage
/// ```dart
/// final controller = CastingController(
///   onError: (msg) => showSnackBar(msg),
/// );
///
/// // Listen to state changes
/// ListenableBuilder(
///   listenable: controller,
///   builder: (context, child) {
///     final state = controller.state;
///     return YourWidget(state: state);
///   },
/// );
///
/// // Trigger actions
/// await controller.connect(deviceId);
/// await controller.play();
/// ```
class CastingController extends ChangeNotifier {
  CastingController({CastingService? service, this.onError})
    : _service = service ?? CastingService.instance {
    _subscribeToState();
  }

  // ---------------------------------------------------------------------------
  // DEPENDENCIES
  // ---------------------------------------------------------------------------

  final CastingService _service;
  final ErrorCallback? onError;
  StreamSubscription<UnifiedCastingState>? _subscription;

  // ---------------------------------------------------------------------------
  // STATE
  // ---------------------------------------------------------------------------

  CastingUiState _state = CastingUiState.initial;

  /// The current UI state. Use this in ListenableBuilder to build UI.
  CastingUiState get state => _state;

  // ---------------------------------------------------------------------------
  // LIFECYCLE
  // ---------------------------------------------------------------------------

  void _subscribeToState() {
    _subscription = _service.state.listen(_onCastingStateChanged);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // STATE MAPPING
  // ---------------------------------------------------------------------------

  /// Maps CastingService state to UI state.
  ///
  /// Only calls [notifyListeners] if the new state differs from the current
  /// state. This prevents unnecessary widget rebuilds when the stream emits
  /// identical state (e.g., same playback position during polling).
  void _onCastingStateChanged(UnifiedCastingState castingState) {
    final newState = _mapToUiState(castingState);
    if (newState != _state) {
      _state = newState;
      notifyListeners();
    }
  }

  CastingUiState _mapToUiState(UnifiedCastingState castingState) {
    final devices = _mapDevices(castingState);

    // Stop discovery indicator when devices are found or connection changes
    final stopDiscovering =
        devices.isNotEmpty ||
        castingState is CastingConnecting ||
        castingState is CastingConnected;

    return switch (castingState) {
      CastingDisconnected() => _state.copyWith(
        target: PlaybackTarget.none,
        devices: devices,
        isDiscovering: stopDiscovering ? false : _state.isDiscovering,
        clearDevice: true,
        clearMedia: true,
        isLoading: false,
        isPlaying: false,
        progress: 0,
        currentPositionSeconds: 0,
        totalDurationSeconds: 0,
      ),
      CastingConnecting(:final device) => _state.copyWith(
        target: PlaybackTarget.remote,
        devices: devices,
        isDiscovering: false,
        selectedDeviceId: device.id,
        selectedDeviceName: device.name,
        isLoading: true,
      ),
      CastingConnected(:final device, :final playback) => _mapConnectedState(
        devices: devices,
        device: device,
        playback: playback,
      ),
    };
  }

  List<CastDevice> _mapDevices(UnifiedCastingState state) {
    final connectedDeviceId = switch (state) {
      CastingConnecting(:final device) => device.id,
      CastingConnected(:final device) => device.id,
      CastingDisconnected() => null,
    };

    return state.devices
        .map((d) => d.toUiDevice(isConnected: d.id == connectedDeviceId))
        .toList();
  }

  CastingUiState _mapConnectedState({
    required List<CastDevice> devices,
    required api.CastDevice device,
    required PlaybackInfo playback,
  }) {
    final base = _state.copyWith(
      target: PlaybackTarget.remote,
      devices: devices,
      isDiscovering: false,
      selectedDeviceId: device.id,
      selectedDeviceName: device.name,
      isLoading: false,
    );

    return switch (playback) {
      PlaybackIdle() => base.copyWith(
        clearMedia: true,
        isPlaying: false,
        progress: 0,
        currentPositionSeconds: 0,
        totalDurationSeconds: 0,
      ),
      PlaybackLoading(:final media) => base.copyWith(
        currentMedia: media,
        isLoading: true,
      ),
      PlaybackPlaying(:final media, :final position, :final duration) =>
        base.copyWith(
          currentMedia: media,
          isPlaying: true,
          currentPositionSeconds: position.inSeconds,
          totalDurationSeconds: duration.inSeconds,
          progress: duration.inMilliseconds > 0
              ? position.inMilliseconds / duration.inMilliseconds
              : 0,
        ),
      PlaybackPaused(:final media, :final position, :final duration) =>
        base.copyWith(
          currentMedia: media,
          isPlaying: false,
          currentPositionSeconds: position.inSeconds,
          totalDurationSeconds: duration.inSeconds,
          progress: duration.inMilliseconds > 0
              ? position.inMilliseconds / duration.inMilliseconds
              : 0,
        ),
      PlaybackEnded(:final media) => base.copyWith(
        currentMedia: media,
        isPlaying: false,
        progress: 1.0,
      ),
      PlaybackError(:final message) => base.copyWith(
        errorMessage: message,
        isPlaying: false,
      ),
    };
  }

  // ---------------------------------------------------------------------------
  // ERROR HANDLING
  // ---------------------------------------------------------------------------

  void _handleError(String message) {
    debugPrint('[CastingController] Error: $message');
    onError?.call(message);
  }

  // ---------------------------------------------------------------------------
  // DISCOVERY ACTIONS
  // ---------------------------------------------------------------------------

  /// Start discovering cast devices.
  ///
  /// Sets [CastingUiState.isDiscovering] to true while scanning.
  /// Discovery automatically stops when a device connects or after timeout.
  Future<void> startDiscovery() async {
    _state = _state.copyWith(isDiscovering: true);
    notifyListeners();

    final result = await _service.startDiscovery();
    result.fold((error) {
      _state = _state.copyWith(isDiscovering: false);
      notifyListeners();
      _handleError('Discovery failed: ${error.message}');
    }, (_) => debugPrint('[CastingController] Discovery started'));
  }

  /// Stop discovering cast devices.
  Future<void> stopDiscovery() async {
    _state = _state.copyWith(isDiscovering: false);
    notifyListeners();
    await _service.stopDiscovery();
  }

  // ---------------------------------------------------------------------------
  // CONNECTION ACTIONS
  // ---------------------------------------------------------------------------

  /// Connect to a Chromecast device and load sample media.
  Future<void> connect(String deviceId) async {
    final result = await _service.connect(deviceId);
    result.fold(
      (error) => _handleError('Connection failed: ${error.message}'),
      (_) => _loadSampleMedia(),
    );
  }

  /// Show native AirPlay picker (iOS only).
  Future<void> showAirPlayPicker() async {
    final result = await _service.showAirPlayPicker();
    result.fold(
      (error) => _handleError('AirPlay failed: ${error.message}'),
      (_) => debugPrint('[CastingController] AirPlay picker shown'),
    );
  }

  /// Disconnect from the current device.
  Future<void> disconnect() async {
    final result = await _service.disconnect();
    result.fold(
      (error) => _handleError('Disconnect failed: ${error.message}'),
      (_) => debugPrint('[CastingController] Disconnected'),
    );
  }

  // ---------------------------------------------------------------------------
  // MEDIA ACTIONS
  // ---------------------------------------------------------------------------

  /// Load sample media based on current casting mode.
  Future<void> _loadSampleMedia() async {
    final media = _state.castingMode == CastingMode.video
        ? SampleMedia.bigBuckBunny
        : SampleMedia.audioSample1;

    final result = await _service.loadMedia(media);
    result.fold(
      (error) => _handleError('Failed to load media: ${error.message}'),
      (_) => debugPrint('[CastingController] Media loaded'),
    );
  }

  /// Change casting mode (audio/video) and reload media if connected.
  void setCastingMode(CastingMode mode) {
    _state = _state.copyWith(castingMode: mode);
    notifyListeners();

    if (_service.isConnected) {
      _loadSampleMedia();
    }
  }

  // ---------------------------------------------------------------------------
  // PLAYBACK ACTIONS
  // ---------------------------------------------------------------------------

  /// Toggle play/pause.
  Future<void> togglePlayPause() async {
    if (_state.isPlaying) {
      await _service.pause();
    } else {
      await _service.play();
    }
  }

  /// Play media.
  Future<void> play() async {
    await _service.play();
  }

  /// Pause media.
  Future<void> pause() async {
    await _service.pause();
  }

  /// Seek to a specific progress (0.0 to 1.0).
  Future<void> seekToProgress(double progress) async {
    final positionMs = (progress * _state.totalDurationSeconds * 1000).toInt();
    await _service.seek(positionMs);
  }

  /// Skip backward by 15 seconds.
  Future<void> skipBackward() async {
    final newPositionMs = ((_state.currentPositionSeconds - 15) * 1000).clamp(
      0,
      _state.totalDurationSeconds * 1000,
    );
    await _service.seek(newPositionMs);
  }

  /// Skip forward by 15 seconds.
  Future<void> skipForward() async {
    final newPositionMs = ((_state.currentPositionSeconds + 15) * 1000).clamp(
      0,
      _state.totalDurationSeconds * 1000,
    );
    await _service.seek(newPositionMs);
  }
}
