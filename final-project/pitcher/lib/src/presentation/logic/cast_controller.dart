import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:pitcher/src/cast/cast_service.dart';
import 'package:pitcher/src/cast/domain/sample_media.dart';

export 'package:pitcher/src/cast/cast_service.dart';

enum CastMode { audio, video }

typedef ErrorCallback = void Function(String message);

class CastController extends ChangeNotifier {
  CastController({CastService? service, this.onError})
    : _service = service ?? CastService() {
    _subscription = _service.state.listen(_onStateChanged);
  }

  final CastService _service;
  final ErrorCallback? onError;
  StreamSubscription<CastState>? _subscription;

  CastMode _castMode = CastMode.video;
  bool _pendingMediaLoad = false;

  CastState get state => _service.currentState;
  bool get isDiscovering => _service.isDiscovering;
  bool get isConnected => _service.isConnected;
  bool get isPlaying => _service.isPlaying;
  CastMode get castMode => _castMode;

  Future<void> startDiscovery() async {
    final result = await _service.startDiscovery();
    result.fold(
      (error) => _handleError('Discovery failed: ${error.message}'),
      (_) {},
    );
  }

  Future<void> stopDiscovery() => _service.stopDiscovery();

  Future<void> connect(String deviceId) async {
    _pendingMediaLoad = true;
    final result = await _service.connect(deviceId);
    result.fold((error) {
      _pendingMediaLoad = false;
      _handleError('Connection failed: ${error.message}');
    }, (_) {});
  }

  Future<void> disconnect() async {
    _pendingMediaLoad = false;
    final result = await _service.disconnect();
    result.fold(
      (error) => _handleError('Disconnect failed: ${error.message}'),
      (_) {},
    );
  }

  Future<void> togglePlayPause() async {
    if (_service.isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> play() async {
    final state = _service.currentState;

    if (state is ConnectedState &&
        state.playback.status == PlaybackStatus.idle) {
      await _loadSampleMedia();
      return;
    }

    await _service.play();
  }

  Future<void> pause() => _service.pause();

  Future<void> seekToProgress(double progress) async {
    final state = _service.currentState;
    if (state is! ConnectedState) return;

    final durationMs = state.playback.duration.inMilliseconds;
    final positionMs = (progress * durationMs).toInt();
    await _service.seek(positionMs);
  }

  Future<void> skipBackward() async {
    final state = _service.currentState;
    if (state is! ConnectedState) return;

    final currentMs = state.playback.position.inMilliseconds;
    final newPositionMs = (currentMs - 15000).clamp(
      0,
      state.playback.duration.inMilliseconds,
    );
    await _service.seek(newPositionMs);
  }

  Future<void> skipForward() async {
    final state = _service.currentState;
    if (state is! ConnectedState) return;

    final currentMs = state.playback.position.inMilliseconds;
    final newPositionMs = (currentMs + 15000).clamp(
      0,
      state.playback.duration.inMilliseconds,
    );
    await _service.seek(newPositionMs);
  }

  void setCastMode(CastMode mode) {
    _castMode = mode;
    notifyListeners();

    if (_service.isConnected) {
      _loadSampleMedia();
    }
  }

  void _onStateChanged(CastState newState) {
    notifyListeners();

    if (_pendingMediaLoad && newState is ConnectedState) {
      _pendingMediaLoad = false;
      _loadSampleMedia();
    }
  }

  Future<void> _loadSampleMedia() async {
    final media = _castMode == CastMode.video
        ? SampleMedia.bigBuckBunny
        : SampleMedia.audioSample1;

    final result = await _service.loadMedia(media);
    result.fold(
      (error) => _handleError('Failed to load media: ${error.message}'),
      (_) {},
    );
  }

  void _handleError(String message) {
    debugPrint('[CastController] Error: $message');
    onError?.call(message);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
