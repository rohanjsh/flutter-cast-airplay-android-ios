import 'dart:async';

import 'package:fpdart/fpdart.dart';

import 'data/cast_api.g.dart';
import 'data/cast_repository.dart';
import 'domain/cast_state.dart';

export 'data/cast_api.g.dart'
    show CastDevice, MediaInfo, CastProvider, MediaType;
export 'domain/cast_state.dart';

final class CastService {
  CastService({CastRepository? repository})
    : _repository = repository ?? CastRepository() {
    _repository.devices.listen((devices) {
      _currentDevices = List.of(devices);
      _emitState();
    });

    _repository.state.listen((state) {
      _currentRawState = state;
      _emitState();
    });
  }

  final CastRepository _repository;

  final _stateController = StreamController<CastState>.broadcast();

  bool _isDiscovering = false;
  bool _isDisposed = false;

  List<CastDevice> _currentDevices = [];
  CastSessionState _currentRawState = CastSessionState(
    connectionState: CastConnectionState.disconnected,
    playbackState: CastPlaybackState.idle,
  );

  Stream<CastState> get state => _stateController.stream;
  List<CastDevice> get devices => List.unmodifiable(_currentDevices);
  CastState get currentState =>
      CastState.fromSession(_currentRawState, _currentDevices);
  CastDevice? get connectedDevice => _currentRawState.connectedDevice;

  bool get isDiscovering => _isDiscovering;
  bool get isDisposed => _isDisposed;
  bool get isConnected =>
      _currentRawState.connectionState == CastConnectionState.connected;
  bool get isPlaying =>
      _currentRawState.playbackState == CastPlaybackState.playing;

  Future<CastResult<Unit>> startDiscovery() => _guard(() async {
    if (_isDiscovering) return right(unit);
    _isDiscovering = true;
    final result = await _repository.startDiscovery();
    if (result.isLeft()) _isDiscovering = false;
    return result;
  });

  Future<CastResult<Unit>> stopDiscovery() => _guard(() async {
    if (!_isDiscovering) return right(unit);
    _isDiscovering = false;
    return _repository.stopDiscovery();
  });

  Future<List<CastDevice>> getDiscoveredDevices() =>
      _repository.getDiscoveredDevices();

  Future<CastResult<Unit>> connect(String deviceId) =>
      _guard(() => _repository.connect(deviceId));

  Future<CastResult<Unit>> disconnect() =>
      _guard(() => _repository.disconnect());

  Future<CastResult<Unit>> loadMedia(
    MediaInfo mediaInfo, {
    bool autoplay = true,
    int positionMs = 0,
  }) => _guard(
    () => _repository.loadMedia(
      mediaInfo,
      autoplay: autoplay,
      positionMs: positionMs,
    ),
  );

  Future<CastResult<Unit>> play() => _guard(() => _repository.play());
  Future<CastResult<Unit>> pause() => _guard(() => _repository.pause());
  Future<CastResult<Unit>> stop() => _guard(() => _repository.stop());
  Future<CastResult<Unit>> seek(int positionMs) =>
      _guard(() => _repository.seek(positionMs));

  Future<CastResult<Unit>> setVolume(double volume) =>
      _guard(() => _repository.setVolume(volume));

  Future<CastResult<Unit>> setMuted(bool muted) =>
      _guard(() => _repository.setMuted(muted));

  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;

    await stopDiscovery();
    await _stateController.close();
    _repository.dispose();
  }

  Future<CastResult<Unit>> _guard(
    Future<CastResult<Unit>> Function() operation,
  ) async {
    if (_isDisposed) return left(const DisposedError());
    return operation();
  }

  void _emitState() {
    if (_stateController.isClosed) return;
    _stateController.add(
      CastState.fromSession(_currentRawState, _currentDevices),
    );
  }
}
