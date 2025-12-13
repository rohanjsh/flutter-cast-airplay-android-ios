import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';

import '../domain/cast_state.dart';
import 'cast_api.g.dart';

class CastRepository implements CastFlutterApi {
  CastRepository() {
    // ╔═══════════════════════════════════════════════════════════════════════╗
    // ║  TODO 1: Register this class to receive native callbacks (1 line)     ║
    // ╚═══════════════════════════════════════════════════════════════════════╝
    //
    // 👉 ADD: CastFlutterApi.setUp(this);
    //
    // ───────────────────────────────────────────────────────────────────────────
    // 📚 CONCEPT: Pigeon's Bidirectional Communication
    // ───────────────────────────────────────────────────────────────────────────
    // Pigeon generates TWO API classes from the same .dart definition:
    //
    //   ┌─────────────────┐                    ┌─────────────────┐
    //   │  CastHostApi    │  Flutter → Native  │  CastFlutterApi │
    //   │  (we call it)   │ =================> │  (native calls) │
    //   └─────────────────┘                    └─────────────────┘
    //
    // CastFlutterApi.setUp() registers a Dart object as the "receiver" for
    // method channel calls coming FROM native code. It wires up a
    // MethodChannel listener that deserializes incoming messages and routes
    // them to your callback implementations (onDevicesChanged, onStateChanged).
    //
    // ───────────────────────────────────────────────────────────────────────────
    // ⚠️ COMMON PITFALL: "My callbacks never fire!"
    // ───────────────────────────────────────────────────────────────────────────
    // If you forget this line, native code will invoke methods on the channel
    // but there's no listener on the Dart side. The calls silently succeed
    // from native's perspective but no Dart code ever executes.
    //
    // 🔍 DEBUGGING: Add a breakpoint in onDevicesChanged(). If it never hits
    //    after native calls notifyDevicesChanged(), you forgot this setUp().
    //
    // ───────────────────────────────────────────────────────────────────────────
    // 🏭 PRODUCTION NOTE: Singleton Pattern
    // ───────────────────────────────────────────────────────────────────────────
    // In production, CastRepository should be a singleton (via get_it/injectable).
    // Calling setUp() multiple times with different instances will override
    // the previous handler - only the LAST registered instance receives calls.
    //
    // ───────────────────────────────────────────────────────────────────────────
    // ✅ RESULT: After this TODO, native callbacks will reach Flutter.
    //    The device list and connection state will update in real-time.
    // ───────────────────────────────────────────────────────────────────────────
    throw UnimplementedError('TODO 1: CastFlutterApi.setUp(this)');
  }

  final CastHostApi _hostApi = CastHostApi();

  final StreamController<List<CastDevice>> _devicesController =
      StreamController<List<CastDevice>>.broadcast();

  final StreamController<CastSessionState> _stateController =
      StreamController<CastSessionState>.broadcast();

  Stream<List<CastDevice>> get devices => _devicesController.stream;
  Stream<CastSessionState> get state => _stateController.stream;

  // These callbacks are invoked by native code via Pigeon.
  // Forward events to streams so CastService can react to state changes.
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
