import 'package:dart_mappable/dart_mappable.dart';
import 'package:fpdart/fpdart.dart';

import '../data/cast_api.g.dart';

part 'cast_state.mapper.dart';

typedef CastResult<T> = Either<CastError, T>;

Future<CastResult<Unit>> tryCatch(
  Future<void> Function() operation,
  CastError Function(Object error) onError,
) async {
  try {
    await operation();
    return right(unit);
  } catch (e) {
    return left(onError(e));
  }
}

@MappableClass()
sealed class CastError with CastErrorMappable {
  const CastError(this.message, [this.cause]);

  final String message;
  final Object? cause;
}

@MappableClass()
final class DiscoveryError extends CastError with DiscoveryErrorMappable {
  const DiscoveryError(super.message, [super.cause]);
}

@MappableClass()
final class ConnectionError extends CastError with ConnectionErrorMappable {
  const ConnectionError(super.message, [super.cause]);
}

@MappableClass()
final class MediaError extends CastError with MediaErrorMappable {
  const MediaError(super.message, [super.cause]);
}

@MappableClass()
final class DisposedError extends CastError with DisposedErrorMappable {
  const DisposedError() : super('CastService has been disposed');
}

@MappableClass()
sealed class CastState with CastStateMappable {
  const CastState({required this.devices});

  final List<CastDevice> devices;

  factory CastState.fromSession(
    CastSessionState session,
    List<CastDevice> devices,
  ) {
    final connectedDevice = session.connectedDevice;

    return switch (session.connectionState) {
      CastConnectionState.disconnected => DisconnectedState(devices: devices),
      CastConnectionState.connecting =>
        connectedDevice != null
            ? ConnectingState(devices: devices, device: connectedDevice)
            : DisconnectedState(devices: devices),
      CastConnectionState.connected =>
        connectedDevice != null
            ? ConnectedState(
                devices: devices,
                device: connectedDevice,
                playback: _buildPlaybackInfo(session),
              )
            : DisconnectedState(devices: devices),
    };
  }

  static PlaybackInfo _buildPlaybackInfo(CastSessionState session) {
    final media = session.currentMedia;
    final position = Duration(milliseconds: session.positionMs ?? 0);
    final duration = Duration(milliseconds: session.durationMs ?? 0);

    return switch (session.playbackState) {
      CastPlaybackState.idle => const PlaybackInfo(),
      CastPlaybackState.loading => PlaybackInfo(
        status: PlaybackStatus.loading,
        media: media,
      ),
      CastPlaybackState.playing => PlaybackInfo(
        status: PlaybackStatus.playing,
        media: media,
        position: position,
        duration: duration,
      ),
      CastPlaybackState.paused => PlaybackInfo(
        status: PlaybackStatus.paused,
        media: media,
        position: position,
        duration: duration,
      ),
      CastPlaybackState.ended => PlaybackInfo(
        status: PlaybackStatus.ended,
        media: media,
      ),
      CastPlaybackState.error => PlaybackInfo(
        status: PlaybackStatus.error,
        media: media,
        errorMessage: session.errorMessage,
      ),
    };
  }
}

@MappableClass()
final class DisconnectedState extends CastState with DisconnectedStateMappable {
  const DisconnectedState({required super.devices});
}

@MappableClass()
final class ConnectingState extends CastState with ConnectingStateMappable {
  const ConnectingState({required super.devices, required this.device});

  final CastDevice device;
}

@MappableClass()
final class ConnectedState extends CastState with ConnectedStateMappable {
  const ConnectedState({
    required super.devices,
    required this.device,
    required this.playback,
  });

  final CastDevice device;
  final PlaybackInfo playback;
}

enum PlaybackStatus { idle, loading, playing, paused, ended, error }

@MappableClass()
final class PlaybackInfo with PlaybackInfoMappable {
  const PlaybackInfo({
    this.status = PlaybackStatus.idle,
    this.media,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.errorMessage,
  });

  final PlaybackStatus status;
  final MediaInfo? media;
  final Duration position;
  final Duration duration;
  final String? errorMessage;

  double get progress => duration.inMilliseconds > 0
      ? position.inMilliseconds / duration.inMilliseconds
      : 0.0;

  bool get isActive =>
      status == PlaybackStatus.playing || status == PlaybackStatus.paused;
}
