import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';

import 'casting_api.g.dart';
import 'casting_state.dart';

export 'casting_state.dart';

final class CastingService implements CastingFlutterApi {
  CastingService._() {
    CastingFlutterApi.setUp(this);
  }

  static final CastingService instance = CastingService._();

  final CastingHostApi _hostApi = CastingHostApi();

  final StreamController<UnifiedCastingState> _stateController =
      StreamController<UnifiedCastingState>.broadcast();

  bool _isDiscovering = false;

  List<CastDevice> _currentDevices = [];
  CastingState _currentRawState = CastingState(
    connectionState: CastingConnectionState.disconnected,
    playbackState: CastingPlaybackState.idle,
  );

  Stream<UnifiedCastingState> get state => _stateController.stream;

  List<CastDevice> get devices => List.unmodifiable(_currentDevices);

  UnifiedCastingState get currentState => _buildUnifiedState();

  bool get isDiscovering => _isDiscovering;

  bool get isConnected =>
      _currentRawState.connectionState == CastingConnectionState.connected;

  bool get isPlaying =>
      _currentRawState.playbackState == CastingPlaybackState.playing;

  CastDevice? get connectedDevice => _currentRawState.connectedDevice;

  UnifiedCastingState _buildUnifiedState() {
    final devices = _currentDevices;
    final raw = _currentRawState;
    final connectedDevice = raw.connectedDevice;

    return switch (raw.connectionState) {
      CastingConnectionState.disconnected => CastingDisconnected(
        devices: devices,
      ),
      CastingConnectionState.connecting when connectedDevice == null =>
        CastingDisconnected(devices: devices),
      CastingConnectionState.connecting => CastingConnecting(
        devices: devices,
        device: connectedDevice!,
      ),
      CastingConnectionState.connected when connectedDevice == null =>
        CastingDisconnected(devices: devices),
      CastingConnectionState.connected => CastingConnected(
        devices: devices,
        device: connectedDevice!,
        playback: _buildPlaybackInfo(raw),
      ),
    };
  }

  PlaybackInfo _buildPlaybackInfo(CastingState raw) {
    final media = raw.currentMedia;

    return switch (raw.playbackState) {
      CastingPlaybackState.idle => const PlaybackIdle(),
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

  Future<List<CastDevice>> getDiscoveredDevices() async {
    try {
      return await _hostApi.getDiscoveredDevices();
    } catch (_) {
      return const [];
    }
  }

  Future<CastResult<Unit>> connect(String deviceId) async {
    final check = _checkDisposed();
    if (check.isLeft()) return check;

    debugPrint('[CastingService] Connecting to device: $deviceId');

    return tryCatch(
      () => _hostApi.connect(deviceId),
      (e) => ConnectionError('Failed to connect: $deviceId', e),
    );
  }

  Future<CastResult<Unit>> disconnect() async {
    final check = _checkDisposed();
    if (check.isLeft()) return check;

    debugPrint('[CastingService] Disconnecting');

    return tryCatch(
      () => _hostApi.disconnect(),
      (e) => ConnectionError('Failed to disconnect', e),
    );
  }

  Future<CastResult<Unit>> showAirPlayPicker() async {
    final check = _checkDisposed();
    if (check.isLeft()) return check;

    debugPrint('[CastingService] Showing AirPlay picker');

    return tryCatch(
      () => _hostApi.showAirPlayPicker(),
      (e) => ConnectionError('Failed to show AirPlay picker', e),
    );
  }

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

  Future<CastResult<Unit>> play() async {
    final check = _checkDisposed();
    if (check.isLeft()) return check;

    debugPrint('[CastingService] Playing');

    return tryCatch(
      () => _hostApi.play(),
      (e) => MediaError('Failed to play', e),
    );
  }

  Future<CastResult<Unit>> pause() async {
    final check = _checkDisposed();
    if (check.isLeft()) return check;

    debugPrint('[CastingService] Pausing');

    return tryCatch(
      () => _hostApi.pause(),
      (e) => MediaError('Failed to pause', e),
    );
  }

  Future<CastResult<Unit>> seek(int positionMs) async {
    final check = _checkDisposed();
    if (check.isLeft()) return check;

    debugPrint('[CastingService] Seeking to $positionMs ms');

    return tryCatch(
      () => _hostApi.seek(positionMs),
      (e) => MediaError('Failed to seek', e),
    );
  }

  Future<CastResult<Unit>> stop() async {
    final check = _checkDisposed();
    if (check.isLeft()) return check;

    debugPrint('[CastingService] Stopping playback');

    return tryCatch(
      () => _hostApi.stop(),
      (e) => MediaError('Failed to stop', e),
    );
  }

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

  Future<CastResult<Unit>> setMuted(bool muted) async {
    final check = _checkDisposed();
    if (check.isLeft()) return check;

    debugPrint('[CastingService] Setting muted to $muted');

    return tryCatch(
      () => _hostApi.setMuted(muted),
      (e) => MediaError('Failed to set muted', e),
    );
  }

  @override
  void onDevicesChanged(List<CastDevice> devices) {
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

  void _emitState() {
    if (!_stateController.isClosed) {
      _stateController.add(_buildUnifiedState());
    }
  }

  bool _isDisposed = false;

  bool get isDisposed => _isDisposed;

  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;

    await stopDiscovery();
    await _stateController.close();

    debugPrint('[CastingService] Disposed');
  }
}
