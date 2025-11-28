// =============================================================================
// CASTING API - Pigeon Schema for Chromecast & AirPlay
// =============================================================================
// This file defines the type-safe platform channel interface between Flutter
// and native platforms (Android/iOS). Run `dart run pigeon` to generate code.
//
// Design Philosophy (Inspired by react-native-google-cast):
// 1. Unified device abstraction - CastDevice works for both Chromecast & AirPlay
// 2. Event-driven state updates - Native pushes state changes to Flutter
// 3. Simple, focused API - Only core functionality needed for workshop
// 4. Platform-aware providers - Each device knows its casting technology
// =============================================================================

import 'package:pigeon/pigeon.dart';

// =============================================================================
// CONFIGURATION
// =============================================================================

@ConfigurePigeon(
  PigeonOptions(
    // Dart
    dartOut: 'lib/src/casting/casting_api.g.dart',
    dartPackageName: 'pitcher',

    // Android (Kotlin)
    kotlinOut:
        'android/app/src/main/kotlin/dev/rohanjsh/pitcher/casting/CastingApi.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'dev.rohanjsh.pitcher.casting',
      // Custom error class name for cleaner native code
      errorClassName: 'CastingApiError',
    ),

    // iOS (Swift)
    swiftOut: 'ios/Runner/Casting/CastingApi.g.swift',
    swiftOptions: SwiftOptions(
      // Custom error class name for cleaner native code
      errorClassName: 'CastingApiError',
    ),
  ),
)
// =============================================================================
// ENUMS
// =============================================================================
/// The casting technology/provider type.
///
/// This enum allows the Flutter layer to understand which technology is being
/// used, while keeping the API unified. The native layer handles the specifics.
enum CastingProvider {
  /// Google Cast (Chromecast, Android TV, Nest devices)
  /// Available on: Android, iOS
  chromecast,

  /// Apple AirPlay (Apple TV, AirPlay 2 speakers, AirPlay-enabled TVs)
  /// Available on: iOS only
  airplay,
}

/// The current state of the casting connection.
///
/// Modeled after session states from Google Cast SDK.
enum CastingConnectionState {
  /// No casting session, not connected to any device
  disconnected,

  /// Attempting to connect to a cast device
  connecting,

  /// Connected to a cast device, ready to load media
  connected,
}

/// The current playback state on the remote device.
enum CastingPlaybackState {
  /// No media loaded
  idle,

  /// Media is loading/buffering
  loading,

  /// Media is playing
  playing,

  /// Media is paused
  paused,

  /// Playback has ended
  ended,

  /// An error occurred during playback
  error,
}

/// Media content type for proper receiver handling.
enum MediaType {
  /// Video content (movies, TV shows, video clips)
  video,

  /// Audio content (music, podcasts, audiobooks)
  audio,
}

// =============================================================================
// DATA TRANSFER OBJECTS (DTOs)
// =============================================================================

/// Represents a discovered cast-capable device.
///
/// This is a unified representation that works for both Chromecast and AirPlay
/// devices. The [provider] field indicates which technology is being used.
class CastDevice {
  CastDevice({
    required this.id,
    required this.name,
    required this.provider,
    this.modelName,
  });

  /// Unique identifier for the device.
  /// - Chromecast: Route ID from MediaRouter
  /// - AirPlay: UID from AVRouteDetector
  final String id;

  /// Human-readable device name (e.g., "Living Room TV")
  final String name;

  /// The casting technology this device uses
  final CastingProvider provider;

  /// Device model name if available (e.g., "Chromecast Ultra", "Apple TV 4K")
  final String? modelName;
}

/// Information about the media to be cast.
///
/// Modeled after MediaInfo from Google Cast SDK.
/// @see https://developers.google.com/cast/docs/reference/android/com/google/android/gms/cast/MediaInfo
class MediaInfo {
  MediaInfo({
    required this.contentUrl,
    required this.title,
    required this.mediaType,
    this.subtitle,
    this.imageUrl,
    this.contentType,
    this.duration,
  });

  /// URL of the media content.
  /// Must be accessible by the receiver device (not localhost).
  final String contentUrl;

  /// Title displayed on the receiver (e.g., "Big Buck Bunny")
  final String title;

  /// Type of media content
  final MediaType mediaType;

  /// Subtitle/artist displayed on the receiver
  final String? subtitle;

  /// URL of the thumbnail/poster image
  final String? imageUrl;

  /// MIME type of the content (e.g., "video/mp4", "audio/mpeg")
  /// If not provided, the receiver will try to detect it.
  final String? contentType;

  /// Duration in milliseconds (optional, receiver can detect)
  final int? duration;
}

/// Current state of the casting session and playback.
///
/// Sent from native to Flutter via CastingFlutterApi.onStateChanged
class CastingState {
  CastingState({
    required this.connectionState,
    required this.playbackState,
    this.connectedDevice,
    this.currentMedia,
    this.positionMs,
    this.durationMs,
    this.errorMessage,
  });

  /// Current connection state
  final CastingConnectionState connectionState;

  /// Current playback state
  final CastingPlaybackState playbackState;

  /// Currently connected device (null if disconnected)
  final CastDevice? connectedDevice;

  /// Currently loaded media (null if no media loaded)
  final MediaInfo? currentMedia;

  /// Current playback position in milliseconds
  final int? positionMs;

  /// Total duration in milliseconds
  final int? durationMs;

  /// Error message if playbackState is error
  final String? errorMessage;
}

// =============================================================================
// HOST API - Flutter calls Native
// =============================================================================

/// API for Flutter to call native platform code.
///
/// This is the main interface for controlling casting from Dart.
/// Implementations exist for:
/// - Android: Chromecast via Cast SDK + MediaRouter
/// - iOS: Chromecast via Cast SDK + AirPlay via AVFoundation
@HostApi()
abstract class CastingHostApi {
  // ---------------------------------------------------------------------------
  // DISCOVERY
  // ---------------------------------------------------------------------------

  /// Start discovering all available cast devices.
  ///
  /// On Android: Discovers Chromecast devices via MediaRouter.
  /// On iOS: Discovers Chromecast (GCKDiscoveryManager) + AirPlay (AVRouteDetector).
  ///
  /// Results are delivered via [CastingFlutterApi.onDevicesChanged].
  void startDiscovery();

  /// Stop all device discovery.
  void stopDiscovery();

  /// Get all currently discovered devices.
  List<CastDevice> getDiscoveredDevices();

  // ---------------------------------------------------------------------------
  // CONNECTION
  // ---------------------------------------------------------------------------

  /// Connect to a specific Chromecast device.
  ///
  /// ⚠️ IMPORTANT: This method only works for Chromecast devices!
  ///
  /// For AirPlay devices, use [showAirPlayPicker] instead - Apple requires
  /// user interaction via their system UI (AVRoutePickerView).
  ///
  /// @param deviceId The unique ID of the Chromecast device to connect to.
  ///
  /// Connection state changes are delivered via CastingFlutterApi.onStateChanged.
  void connect(String deviceId);

  /// Disconnect from the current cast device.
  ///
  /// This will stop any playing media and end the casting session.
  /// Works for both Chromecast and AirPlay.
  void disconnect();

  /// Show the native AirPlay device picker (iOS only).
  ///
  /// This presents a system UI (AVRoutePickerView) where the user can select
  /// an AirPlay device. Apple does not allow programmatic device selection.
  ///
  /// On Android: This is a no-op (AirPlay not available).
  ///
  /// After the user selects a device, the connection state will be updated
  /// via CastingFlutterApi.onStateChanged.
  void showAirPlayPicker();

  // ---------------------------------------------------------------------------
  // MEDIA CONTROL
  // ---------------------------------------------------------------------------

  /// Load and start playing media on the connected device.
  ///
  /// @param mediaInfo Information about the media to play.
  /// @param autoplay Whether to start playing immediately (default: true).
  /// @param positionMs Starting position in milliseconds (default: 0).
  ///
  /// For Chromecast: Uses RemoteMediaClient.load()
  /// For AirPlay: Configures AVPlayer with the URL
  void loadMedia(MediaInfo mediaInfo, bool autoplay, int positionMs);

  /// Resume playback of paused media.
  void play();

  /// Pause playback.
  void pause();

  /// Seek to a specific position.
  ///
  /// @param positionMs Target position in milliseconds.
  void seek(int positionMs);

  /// Stop playback and unload media.
  ///
  /// This does NOT disconnect from the device.
  void stop();

  // ---------------------------------------------------------------------------
  // VOLUME
  // ---------------------------------------------------------------------------

  /// Set the playback volume on the receiver.
  ///
  /// @param volume Volume level from 0.0 to 1.0.
  void setVolume(double volume);

  /// Set mute state on the receiver.
  void setMuted(bool muted);
}

// =============================================================================
// FLUTTER API - Native calls Flutter
// =============================================================================

/// API for native platform code to call Flutter.
///
/// This enables the native layer to push updates to the Dart layer,
/// following an event-driven architecture pattern.
@FlutterApi()
abstract class CastingFlutterApi {
  /// Called when the list of discovered devices changes.
  ///
  /// This is triggered when:
  /// - A new device is discovered
  /// - A device disappears (goes offline)
  /// - Device properties change
  void onDevicesChanged(List<CastDevice> devices);

  /// Called when the casting state changes.
  ///
  /// This includes:
  /// - Connection state changes (connecting, connected, disconnected)
  /// - Playback state changes (loading, playing, paused, ended)
  /// - Position updates during playback
  /// - Error events
  void onStateChanged(CastingState state);
}
