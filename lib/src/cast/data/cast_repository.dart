import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';

import '../domain/cast_state.dart';
import 'cast_api.g.dart';

class CastRepository implements CastFlutterApi {
  CastRepository() {
    CastFlutterApi.setUp(this);
  }

  final CastHostApi _hostApi = CastHostApi();

  final StreamController<List<CastDevice>> _devicesController =
      StreamController<List<CastDevice>>.broadcast();

  final StreamController<CastSessionState> _stateController =
      StreamController<CastSessionState>.broadcast();

  Stream<List<CastDevice>> get devices => _devicesController.stream;
  Stream<CastSessionState> get state => _stateController.stream;

  @override
  void onDevicesChanged(List<CastDevice> devices) {
    _devicesController.add(devices);
    debugPrint('[CastRepository] Devices updated: ${devices.length} found');
  }

  @override
  void onStateChanged(CastSessionState state) {
    _stateController.add(state);
    debugPrint(
      '[CastRepository] State changed: '
      'connection=${state.connectionState}, '
      'playback=${state.playbackState}',
    );
  }

  Future<CastResult<Unit>> startDiscovery() {
    return tryCatch(
      () => _hostApi.startDiscovery(),
      (e) => DiscoveryError('Failed to start discovery', e),
    );
  }

  Future<CastResult<Unit>> stopDiscovery() {
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

  Future<CastResult<Unit>> connect(String deviceId) {
    return tryCatch(
      () => _hostApi.connect(deviceId),
      (e) => ConnectionError('Failed to connect: $deviceId', e),
    );
  }

  Future<CastResult<Unit>> disconnect() {
    return tryCatch(
      () => _hostApi.disconnect(),
      (e) => ConnectionError('Failed to disconnect', e),
    );
  }

  Future<CastResult<Unit>> loadMedia(
    MediaInfo mediaInfo, {
    bool autoplay = true,
    int positionMs = 0,
  }) {
    return tryCatch(
      () => _hostApi.loadMedia(mediaInfo, autoplay, positionMs),
      (e) => MediaError('Failed to load: ${mediaInfo.title}', e),
    );
  }

  Future<CastResult<Unit>> play() {
    return tryCatch(
      () => _hostApi.play(),
      (e) => MediaError('Failed to play', e),
    );
  }

  Future<CastResult<Unit>> pause() {
    return tryCatch(
      () => _hostApi.pause(),
      (e) => MediaError('Failed to pause', e),
    );
  }

  Future<CastResult<Unit>> seek(int positionMs) {
    return tryCatch(
      () => _hostApi.seek(positionMs),
      (e) => MediaError('Failed to seek', e),
    );
  }

  Future<CastResult<Unit>> stop() {
    return tryCatch(
      () => _hostApi.stop(),
      (e) => MediaError('Failed to stop', e),
    );
  }

  Future<CastResult<Unit>> setVolume(double volume) {
    final clampedVolume = volume.clamp(0.0, 1.0);
    return tryCatch(
      () => _hostApi.setVolume(clampedVolume),
      (e) => MediaError('Failed to set volume', e),
    );
  }

  Future<CastResult<Unit>> setMuted(bool muted) {
    return tryCatch(
      () => _hostApi.setMuted(muted),
      (e) => MediaError('Failed to set muted', e),
    );
  }

  void dispose() {
    _devicesController.close();
    _stateController.close();
  }
}
