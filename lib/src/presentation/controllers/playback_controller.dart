import 'package:flutter/foundation.dart';

import '../models/models.dart';

/// Controller for managing playback state and logic.
///
/// Uses a simple listener pattern for state updates.
/// For production apps, consider using flutter_bloc or riverpod.
class PlaybackController {
  PlaybackState _state;
  final List<VoidCallback> _listeners = [];

  PlaybackController(this._state);

  PlaybackState get state => _state;

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  void togglePlayPause() {
    _state = _state.copyWith(isPlaying: !_state.isPlaying);
    _notifyListeners();
  }

  void updateProgress(double newProgress) {
    final newPosition = (newProgress * _state.totalDuration).toInt();
    _state = _state.copyWith(
      progress: newProgress,
      currentPosition: newPosition,
    );
    _notifyListeners();
  }

  void skipPrevious() {
    final newPosition = (_state.currentPosition - 15).clamp(
      0,
      _state.totalDuration,
    );
    _state = _state.copyWith(
      currentPosition: newPosition,
      progress: newPosition / _state.totalDuration,
    );
    _notifyListeners();
  }

  void skipNext() {
    final newPosition = (_state.currentPosition + 15).clamp(
      0,
      _state.totalDuration,
    );
    _state = _state.copyWith(
      currentPosition: newPosition,
      progress: newPosition / _state.totalDuration,
    );
    _notifyListeners();
  }

  void switchMode(CastingMode mode) {
    _state = _state.copyWith(castingMode: mode);
    _notifyListeners();
  }

  void selectDevice(String deviceId) {
    _state = _state.copyWith(selectedDevice: deviceId);
    _notifyListeners();
  }

  void dispose() {
    _listeners.clear();
  }
}

