import 'package:dart_mappable/dart_mappable.dart';
import 'package:fpdart/fpdart.dart';

import 'casting_api.g.dart';

part 'casting_state.mapper.dart';

typedef CastResult<T> = Either<CastingError, T>;

Future<CastResult<Unit>> tryCatch(
  Future<void> Function() operation,
  CastingError Function(Object error) onError,
) async {
  try {
    await operation();
    return right(unit);
  } catch (e) {
    return left(onError(e));
  }
}

@MappableClass()
sealed class CastingError with CastingErrorMappable {
  const CastingError(this.message, [this.cause]);

  final String message;
  final Object? cause;
}

@MappableClass()
final class DiscoveryError extends CastingError with DiscoveryErrorMappable {
  const DiscoveryError(super.message, [super.cause]);
}

@MappableClass()
final class ConnectionError extends CastingError with ConnectionErrorMappable {
  const ConnectionError(super.message, [super.cause]);
}

@MappableClass()
final class MediaError extends CastingError with MediaErrorMappable {
  const MediaError(super.message, [super.cause]);
}

@MappableClass()
final class DisposedError extends CastingError with DisposedErrorMappable {
  const DisposedError() : super('CastingService has been disposed');
}

@MappableClass()
sealed class UnifiedCastingState with UnifiedCastingStateMappable {
  const UnifiedCastingState({required this.devices});

  final List<CastDevice> devices;
}

@MappableClass()
final class CastingDisconnected extends UnifiedCastingState
    with CastingDisconnectedMappable {
  const CastingDisconnected({required super.devices});
}

@MappableClass()
final class CastingConnecting extends UnifiedCastingState
    with CastingConnectingMappable {
  const CastingConnecting({required super.devices, required this.device});

  final CastDevice device;
}

@MappableClass()
final class CastingConnected extends UnifiedCastingState
    with CastingConnectedMappable {
  const CastingConnected({
    required super.devices,
    required this.device,
    required this.playback,
  });

  final CastDevice device;
  final PlaybackInfo playback;
}

mixin PlaybackPosition {
  MediaInfo get media;
  Duration get position;
  Duration get duration;

  double get progress => duration.inMilliseconds > 0
      ? position.inMilliseconds / duration.inMilliseconds
      : 0.0;
}

@MappableClass()
sealed class PlaybackInfo with PlaybackInfoMappable {
  const PlaybackInfo();
}

@MappableClass()
final class PlaybackIdle extends PlaybackInfo with PlaybackIdleMappable {
  const PlaybackIdle();
}

@MappableClass()
final class PlaybackLoading extends PlaybackInfo with PlaybackLoadingMappable {
  const PlaybackLoading({required this.media});

  final MediaInfo media;
}

@MappableClass()
final class PlaybackPlaying extends PlaybackInfo
    with PlaybackPlayingMappable, PlaybackPosition {
  const PlaybackPlaying({
    required this.media,
    required this.position,
    required this.duration,
  });

  @override
  final MediaInfo media;
  @override
  final Duration position;
  @override
  final Duration duration;
}

@MappableClass()
final class PlaybackPaused extends PlaybackInfo
    with PlaybackPausedMappable, PlaybackPosition {
  const PlaybackPaused({
    required this.media,
    required this.position,
    required this.duration,
  });

  @override
  final MediaInfo media;
  @override
  final Duration position;
  @override
  final Duration duration;
}

@MappableClass()
final class PlaybackEnded extends PlaybackInfo with PlaybackEndedMappable {
  const PlaybackEnded({required this.media});

  final MediaInfo media;
}

@MappableClass()
final class PlaybackError extends PlaybackInfo with PlaybackErrorMappable {
  const PlaybackError({required this.message, this.media});

  final String message;
  final MediaInfo? media;
}
