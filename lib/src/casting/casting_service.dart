// =============================================================================
// CASTING SERVICE - Unified Flutter Interface for Chromecast & AirPlay
// =============================================================================
// This service provides a clean, reactive API for casting functionality.
// Native layer handles all provider logic (Chromecast + AirPlay discovery).
// Flutter side has a simple, clean API - no provider configuration needed.
//
// Design Patterns:
// 1. Sealed State Machine - Exhaustive pattern matching for UI state
// 2. Either Type (fpdart) - Compile-time safe error handling
// =============================================================================

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';

import 'casting_api.g.dart';
import 'casting_state.dart';

export 'casting_state.dart';

/// Unified casting service for Chromecast and AirPlay.
///
/// The native layer automatically discovers all available cast devices:
/// - Android: Chromecast devices
/// - iOS: Chromecast + AirPlay devices
///
/// ## Usage with Sealed State (Recommended)
///
/// ```dart
/// final casting = CastingService.instance;
///
/// // Listen to unified state stream
/// casting.state.listen((state) {
///   switch (state) {
///     case CastingDisconnected(:final devices):
///       showDevicePicker(devices);
///     case CastingConnecting(:final device):
///       showConnectingIndicator(device.name);
///     case CastingConnected(:final device, :final playback):
///       showPlaybackControls(device, playback);
///   }
/// });
///
/// // Start discovery
/// await casting.startDiscovery();
/// ```
///
/// ## Error Handling with Either Type (fpdart)
///
/// ```dart
/// final result = await casting.connect(deviceId);
/// result.fold(
///   (error) => showError(error.message),
///   (_) => print('Connected!'),
/// );
/// // Or use pattern matching:
/// switch (result) {
///   case Left(:final value): showError(value.message);
///   case Right(): print('Connected!');
/// }
/// ```
final class CastingService implements CastingFlutterApi {
  // ---------------------------------------------------------------------------
  // SINGLETON (Dart-idiomatic pattern using static final)
  // ---------------------------------------------------------------------------

  CastingService._() {
    CastingFlutterApi.setUp(this);
  }

  /// The singleton instance of [CastingService].
  ///
  /// This is the recommended way to access the casting service.
  static final CastingService instance = CastingService._();

  // ---------------------------------------------------------------------------
  // PRIVATE STATE
  // ---------------------------------------------------------------------------

  final CastingHostApi _hostApi = CastingHostApi();

  final StreamController<UnifiedCastingState> _stateController =
      StreamController<UnifiedCastingState>.broadcast();

  bool _isDiscovering = false;

  List<CastDevice> _currentDevices = [];
  CastingState _currentRawState = CastingState(
    connectionState: CastingConnectionState.disconnected,
    playbackState: CastingPlaybackState.idle,
  );

  // ---------------------------------------------------------------------------
  // STREAMS
  // ---------------------------------------------------------------------------

  /// Unified state stream with exhaustive pattern matching support.
  ///
  /// ```dart
  /// casting.state.listen((state) {
  ///   switch (state) {
  ///     case CastingDisconnected(:final devices):
  ///       // Show device list
  ///     case CastingConnecting(:final device):
  ///       // Show connecting...
  ///     case CastingConnected(:final device, :final playback):
  ///       // Show playback UI
  ///   }
  /// });
  /// ```
  Stream<UnifiedCastingState> get state => _stateController.stream;

  // ---------------------------------------------------------------------------
  // GETTERS
  // ---------------------------------------------------------------------------

  /// Current list of discovered devices.
  List<CastDevice> get devices => List.unmodifiable(_currentDevices);

  /// Current unified casting state.
  UnifiedCastingState get currentState => _buildUnifiedState();

  /// Whether discovery is active.
  bool get isDiscovering => _isDiscovering;

  /// Whether connected to a cast device.
  bool get isConnected =>
      _currentRawState.connectionState == CastingConnectionState.connected;

  /// Whether media is playing.
  bool get isPlaying =>
      _currentRawState.playbackState == CastingPlaybackState.playing;

  /// The connected device, if any.
  CastDevice? get connectedDevice => _currentRawState.connectedDevice;

  // ---------------------------------------------------------------------------
  // PRIVATE HELPERS
  // ---------------------------------------------------------------------------

  /// Builds the unified state from raw state.
  UnifiedCastingState _buildUnifiedState() {
    final devices = _currentDevices;
    final raw = _currentRawState;
    final connectedDevice = raw.connectedDevice;

    return switch (raw.connectionState) {
      CastingConnectionState.disconnected => CastingDisconnected(
        devices: devices,
      ),
      // If connecting but no device info yet, fall back to disconnected state
      CastingConnectionState.connecting when connectedDevice == null =>
        CastingDisconnected(devices: devices),
      CastingConnectionState.connecting => CastingConnecting(
        devices: devices,
        device: connectedDevice!,
      ),
      // If connected but no device info, fall back to disconnected state
      CastingConnectionState.connected when connectedDevice == null =>
        CastingDisconnected(devices: devices),
      CastingConnectionState.connected => CastingConnected(
        devices: devices,
        device: connectedDevice!,
        playback: _buildPlaybackInfo(raw),
      ),
    };
  }

  /// Builds playback info from raw state.
  PlaybackInfo _buildPlaybackInfo(CastingState raw) {
    final media = raw.currentMedia;

    return switch (raw.playbackState) {
      CastingPlaybackState.idle => const PlaybackIdle(),
      // If media is null when it shouldn't be, fall back to idle
      CastingPlaybackState.loading when media == null => const PlaybackIdle(),
      CastingPlaybackState.loading => PlaybackLoading(media: media!),
      CastingPlaybackState.playing when media == null => const PlaybackIdle(),
      CastingPlaybackState.playing => PlaybackPlaying(
        media: media!,
        position: Duration(milliseconds: raw.positionMs ?? 0),
        duration: Duration(milliseconds: raw.durationMs ?? 0),
      ),
      CastingPlaybackState.paused when media == null => const PlaybackIdle(),
      CastingPlaybackState.paused => PlaybackPaused(
        media: media!,
        position: Duration(milliseconds: raw.positionMs ?? 0),
        duration: Duration(milliseconds: raw.durationMs ?? 0),
      ),
      CastingPlaybackState.ended when media == null => const PlaybackIdle(),
      CastingPlaybackState.ended => PlaybackEnded(media: media!),
      CastingPlaybackState.error => PlaybackError(
        message: raw.errorMessage ?? 'Unknown error',
        media: media,
      ),
    };
  }

  CastResult<Unit> _checkDisposed() {
    if (_isDisposed) {
      return left(const DisposedError());
    }
    return right(unit);
  }

  // ---------------------------------------------------------------------------
  // DISCOVERY
  // ---------------------------------------------------------------------------

  /// Start discovering cast devices.
  ///
  /// On Android: Discovers Chromecast devices.
  /// On iOS: Discovers Chromecast + AirPlay devices.
  ///
  /// Returns [Right] on success or [Left] with [DiscoveryError].
  Future<CastResult<Unit>> startDiscovery() async {
    final check = _checkDisposed();
    if (check.isLeft()) return check;
    if (_isDiscovering) return right(unit);

    _isDiscovering = true;
    debugPrint('[CastingService] Starting discovery');

    final result = await tryCatch(
      () => _hostApi.startDiscovery(),
      (e) => DiscoveryError('Failed to start discovery', e),
    );
    if (result.isLeft()) _isDiscovering = false;
    return result;
  }

  /// Stop discovering cast devices.
  ///
  /// Returns [Right] on success or [Left] with [DiscoveryError].
  Future<CastResult<Unit>> stopDiscovery() async {
    final check = _checkDisposed();
    if (check.isLeft()) return check;
    if (!_isDiscovering) return right(unit);

    _isDiscovering = false;
    debugPrint('[CastingService] Stopping discovery');

    return tryCatch(
      () => _hostApi.stopDiscovery(),
      (e) => DiscoveryError('Failed to stop discovery', e),
    );
  }

  /// Get discovered devices from native layer.
  ///
  /// Returns an empty list on failure (non-critical operation).
  Future<List<CastDevice>> getDiscoveredDevices() async {
    try {
      return await _hostApi.getDiscoveredDevices();
    } catch (_) {
      return const [];
    }
  }

  // ---------------------------------------------------------------------------
  // CONNECTION
  // ---------------------------------------------------------------------------

  /// Connect to a Chromecast device by its ID.
  ///
  /// ⚠️ This only works for Chromecast devices! For AirPlay, use
  /// [showAirPlayPicker] instead.
  ///
  /// Returns [Right] on success or [Left] with [ConnectionError].
  ///
  /// Example:
  /// ```dart
  /// final device = casting.devices
  ///     .firstWhere((d) => d.provider == CastingProvider.chromecast);
  /// final result = await casting.connect(device.id);
  /// result.fold(
  ///   (error) => showSnackBar(error.message),
  ///   (_) => showSnackBar('Connected!'),
  /// );
  /// ```
  Future<CastResult<Unit>> connect(String deviceId) async {
    final check = _checkDisposed();
    if (check.isLeft()) return check;

    debugPrint('[CastingService] Connecting to device: $deviceId');

    return tryCatch(
      () => _hostApi.connect(deviceId),
      (e) => ConnectionError('Failed to connect: $deviceId', e),
    );
  }

  /// Disconnect from the current cast device.
  ///
  /// Works for both Chromecast and AirPlay.
  ///
  /// Returns [Right] on success or [Left] with [ConnectionError].
  Future<CastResult<Unit>> disconnect() async {
    final check = _checkDisposed();
    if (check.isLeft()) return check;

    debugPrint('[CastingService] Disconnecting');

    return tryCatch(
      () => _hostApi.disconnect(),
      (e) => ConnectionError('Failed to disconnect', e),
    );
  }

  /// Show the native AirPlay device picker (iOS only).
  ///
  /// Apple requires user interaction to select an AirPlay device - there's no
  /// programmatic way to connect. This presents the system UI where users can
  /// pick their AirPlay device.
  ///
  /// On Android: This is a no-op.
  ///
  /// Returns [Right] on success or [Left] with [ConnectionError].
  Future<CastResult<Unit>> showAirPlayPicker() async {
    final check = _checkDisposed();
    if (check.isLeft()) return check;

    debugPrint('[CastingService] Showing AirPlay picker');

    return tryCatch(
      () => _hostApi.showAirPlayPicker(),
      (e) => ConnectionError('Failed to show AirPlay picker', e),
    );
  }

  // ---------------------------------------------------------------------------
  // MEDIA CONTROL
  // ---------------------------------------------------------------------------

  /// Load and optionally start playing media on the connected device.
  ///
  /// [mediaInfo] - Information about the media to cast.
  /// [autoplay] - Whether to start playing immediately (default: true).
  /// [positionMs] - Starting position in milliseconds (default: 0).
  ///
  /// Returns [Right] on success or [Left] with [MediaError].
  ///
  /// Example:
  /// ```dart
  /// final result = await casting.loadMedia(SampleMedia.bigBuckBunny);
  /// result.fold(
  ///   (error) => showError(error.message),
  ///   (_) => debugPrint('Media loaded!'),
  /// );
  /// ```
  Future<CastResult<Unit>> loadMedia(
    MediaInfo mediaInfo, {
    bool autoplay = true,
    int positionMs = 0,
  }) async {
    final check = _checkDisposed();
    if (check.isLeft()) return check;

    debugPrint('[CastingService] Loading media: ${mediaInfo.title}');

    return tryCatch(
      () => _hostApi.loadMedia(mediaInfo, autoplay, positionMs),
      (e) => MediaError('Failed to load: ${mediaInfo.title}', e),
    );
  }

  /// Resume playback of paused media.
  ///
  /// Returns [Right] on success or [Left] with [MediaError].
  Future<CastResult<Unit>> play() async {
    final check = _checkDisposed();
    if (check.isLeft()) return check;

    debugPrint('[CastingService] Playing');

    return tryCatch(
      () => _hostApi.play(),
      (e) => MediaError('Failed to play', e),
    );
  }

  /// Pause playback.
  ///
  /// Returns [Right] on success or [Left] with [MediaError].
  Future<CastResult<Unit>> pause() async {
    final check = _checkDisposed();
    if (check.isLeft()) return check;

    debugPrint('[CastingService] Pausing');

    return tryCatch(
      () => _hostApi.pause(),
      (e) => MediaError('Failed to pause', e),
    );
  }

  /// Seek to a specific position in the current media.
  ///
  /// [positionMs] - Target position in milliseconds.
  ///
  /// Returns [Right] on success or [Left] with [MediaError].
  Future<CastResult<Unit>> seek(int positionMs) async {
    final check = _checkDisposed();
    if (check.isLeft()) return check;

    debugPrint('[CastingService] Seeking to $positionMs ms');

    return tryCatch(
      () => _hostApi.seek(positionMs),
      (e) => MediaError('Failed to seek', e),
    );
  }

  /// Stop playback and unload media.
  ///
  /// This does NOT disconnect from the device.
  ///
  /// Returns [Right] on success or [Left] with [MediaError].
  Future<CastResult<Unit>> stop() async {
    final check = _checkDisposed();
    if (check.isLeft()) return check;

    debugPrint('[CastingService] Stopping playback');

    return tryCatch(
      () => _hostApi.stop(),
      (e) => MediaError('Failed to stop', e),
    );
  }

  // ---------------------------------------------------------------------------
  // VOLUME
  // ---------------------------------------------------------------------------

  /// Set the playback volume on the receiver.
  ///
  /// [volume] - Volume level from 0.0 (muted) to 1.0 (max).
  ///
  /// Returns [Right] on success or [Left] with [MediaError].
  Future<CastResult<Unit>> setVolume(double volume) async {
    final check = _checkDisposed();
    if (check.isLeft()) return check;

    final clampedVolume = volume.clamp(0.0, 1.0);
    debugPrint('[CastingService] Setting volume to $clampedVolume');

    return tryCatch(
      () => _hostApi.setVolume(clampedVolume),
      (e) => MediaError('Failed to set volume', e),
    );
  }

  /// Set mute state on the receiver.
  ///
  /// Returns [Right] on success or [Left] with [MediaError].
  Future<CastResult<Unit>> setMuted(bool muted) async {
    final check = _checkDisposed();
    if (check.isLeft()) return check;

    debugPrint('[CastingService] Setting muted to $muted');

    return tryCatch(
      () => _hostApi.setMuted(muted),
      (e) => MediaError('Failed to set muted', e),
    );
  }

  // ---------------------------------------------------------------------------
  // FLUTTER API CALLBACKS (Called by native)
  // ---------------------------------------------------------------------------

  @override
  void onDevicesChanged(List<CastDevice> devices) {
    // Defensive copy to prevent external mutation
    _currentDevices = List.of(devices);
    _emitState();
    debugPrint('[CastingService] Devices updated: ${devices.length} found');
  }

  @override
  void onStateChanged(CastingState state) {
    _currentRawState = state;
    _emitState();
    debugPrint(
      '[CastingService] State changed: '
      'connection=${state.connectionState}, '
      'playback=${state.playbackState}',
    );
  }

  /// Emits the unified state to the stream.
  void _emitState() {
    if (!_stateController.isClosed) {
      _stateController.add(_buildUnifiedState());
    }
  }

  // ---------------------------------------------------------------------------
  // CLEANUP
  // ---------------------------------------------------------------------------

  bool _isDisposed = false;

  /// Whether this service has been disposed.
  bool get isDisposed => _isDisposed;

  /// Dispose of resources.
  ///
  /// Call this when the app is closing or casting is no longer needed.
  ///
  /// Note: Since this is a singleton, calling [dispose] will close the
  /// streams. The instance remains accessible but should not be used
  /// after disposal.
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;

    await stopDiscovery();
    await _stateController.close();

    debugPrint('[CastingService] Disposed');
  }
}
