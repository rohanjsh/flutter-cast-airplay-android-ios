// =============================================================================
// CASTING STATE - Using fpdart + dart_mappable
// =============================================================================

import 'package:dart_mappable/dart_mappable.dart';
import 'package:fpdart/fpdart.dart';

import 'casting_api.g.dart';

part 'casting_state.mapper.dart';

// =============================================================================
// TYPE ALIASES - Clean API surface
// =============================================================================

/// Result type for casting operations.
/// Right = Success, Left = Error (fpdart convention).
typedef CastResult<T> = Either<CastingError, T>;

// =============================================================================
// HELPER - Simplifies try-catch to Either
// =============================================================================

/// Wraps an async operation and converts exceptions to [CastResult].
///
/// ```dart
/// return tryCatch(
///   () => _hostApi.play(),
///   (e) => MediaError('Failed to play', e),
/// );
/// ```
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

// =============================================================================
// CASTING ERROR - Typed Error Hierarchy
// =============================================================================

/// Base class for all casting errors.
@MappableClass()
sealed class CastingError with CastingErrorMappable {
  const CastingError(this.message, [this.cause]);

  final String message;
  final Object? cause;
}

/// Error during device discovery.
@MappableClass()
final class DiscoveryError extends CastingError with DiscoveryErrorMappable {
  const DiscoveryError(super.message, [super.cause]);
}

/// Error during connection to a device.
@MappableClass()
final class ConnectionError extends CastingError with ConnectionErrorMappable {
  const ConnectionError(super.message, [super.cause]);
}

/// Error during media loading or playback.
@MappableClass()
final class MediaError extends CastingError with MediaErrorMappable {
  const MediaError(super.message, [super.cause]);
}

/// Error when service is used after disposal.
@MappableClass()
final class DisposedError extends CastingError with DisposedErrorMappable {
  const DisposedError() : super('CastingService has been disposed');
}

// =============================================================================
// UNIFIED CASTING STATE - Sealed State Machine
// =============================================================================

/// Represents the complete state of the casting service.
///
/// ```dart
/// switch (state) {
///   case CastingDisconnected(:final devices):
///     showDevicePicker(devices);
///   case CastingConnecting(:final device):
///     showLoader('Connecting to ${device.name}...');
///   case CastingConnected(:final device, :final playback):
///     showPlaybackControls(device, playback);
/// }
/// ```
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

// =============================================================================
// PLAYBACK INFO - Detailed playback state
// =============================================================================

/// Mixin for playback states that have position tracking.
///
/// Provides [media], [position], [duration], and computed [progress].
mixin PlaybackPosition {
  MediaInfo get media;
  Duration get position;
  Duration get duration;

  /// Progress as a value between 0.0 and 1.0.
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
