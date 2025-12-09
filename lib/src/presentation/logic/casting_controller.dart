import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pitcher/src/casting/casting_api.g.dart' as api;
import 'package:pitcher/src/casting/casting_service.dart';
import 'package:pitcher/src/casting/sample_media.dart';

import 'casting_controller_state.dart';

typedef ErrorCallback = void Function(String message);

class CastingController extends ChangeNotifier {
  CastingController({CastingService? service, this.onError})
    : _service = service ?? CastingService.instance {
    _subscribeToState();
  }

  final CastingService _service;
  final ErrorCallback? onError;
  StreamSubscription<UnifiedCastingState>? _subscription;

  CastingUiState _state = CastingUiState.initial;

  CastingUiState get state => _state;

  void _subscribeToState() {
    _subscription = _service.state.listen(_onCastingStateChanged);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _onCastingStateChanged(UnifiedCastingState castingState) {
    final newState = _mapToUiState(castingState);
    if (newState != _state) {
      _state = newState;
      notifyListeners();
    }
  }

  CastingUiState _mapToUiState(UnifiedCastingState castingState) {
    final devices = _mapDevices(castingState);

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

  void _handleError(String message) {
    debugPrint('[CastingController] Error: $message');
    onError?.call(message);
  }

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

  Future<void> stopDiscovery() async {
    _state = _state.copyWith(isDiscovering: false);
    notifyListeners();
    await _service.stopDiscovery();
  }

  Future<void> connect(String deviceId) async {
    final result = await _service.connect(deviceId);
    result.fold(
      (error) => _handleError('Connection failed: ${error.message}'),
      (_) => _loadSampleMedia(),
    );
  }

  Future<void> showAirPlayPicker() async {
    final result = await _service.showAirPlayPicker();
    result.fold(
      (error) => _handleError('AirPlay failed: ${error.message}'),
      (_) => debugPrint('[CastingController] AirPlay picker shown'),
    );
  }

  Future<void> disconnect() async {
    final result = await _service.disconnect();
    result.fold(
      (error) => _handleError('Disconnect failed: ${error.message}'),
      (_) => debugPrint('[CastingController] Disconnected'),
    );
  }

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

  void setCastingMode(CastingMode mode) {
    _state = _state.copyWith(castingMode: mode);
    notifyListeners();

    if (_service.isConnected) {
      _loadSampleMedia();
    }
  }

  Future<void> togglePlayPause() async {
    if (_state.isPlaying) {
      await _service.pause();
    } else {
      await _service.play();
    }
  }

  Future<void> play() async {
    await _service.play();
  }

  Future<void> pause() async {
    await _service.pause();
  }

  Future<void> seekToProgress(double progress) async {
    final positionMs = (progress * _state.totalDurationSeconds * 1000).toInt();
    await _service.seek(positionMs);
  }

  Future<void> skipBackward() async {
    final newPositionMs = ((_state.currentPositionSeconds - 15) * 1000).clamp(
      0,
      _state.totalDurationSeconds * 1000,
    );
    await _service.seek(newPositionMs);
  }

  Future<void> skipForward() async {
    final newPositionMs = ((_state.currentPositionSeconds + 15) * 1000).clamp(
      0,
      _state.totalDurationSeconds * 1000,
    );
    await _service.seek(newPositionMs);
  }
}
