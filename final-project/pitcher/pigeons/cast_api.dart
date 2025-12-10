import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/cast/data/cast_api.g.dart',
    dartPackageName: 'pitcher',
    kotlinOut:
        'android/app/src/main/kotlin/dev/rohanjsh/pitcher/cast/CastApi.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'dev.rohanjsh.pitcher.cast',
      errorClassName: 'CastApiError',
    ),
    swiftOut: 'ios/Runner/Cast/CastApi.g.swift',
    swiftOptions: SwiftOptions(errorClassName: 'CastApiError'),
  ),
)
enum CastProvider { chromecast, airplay }

enum CastConnectionState { disconnected, connecting, connected }

enum CastPlaybackState { idle, loading, playing, paused, ended, error }

enum MediaType { video, audio }

class CastDevice {
  CastDevice({
    required this.id,
    required this.name,
    required this.provider,
    this.modelName,
  });

  final String id;
  final String name;
  final CastProvider provider;
  final String? modelName;
}

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

  final String contentUrl;
  final String title;
  final MediaType mediaType;
  final String? subtitle;
  final String? imageUrl;
  final String? contentType;
  final int? duration;
}

class CastSessionState {
  CastSessionState({
    required this.connectionState,
    required this.playbackState,
    this.connectedDevice,
    this.currentMedia,
    this.positionMs,
    this.durationMs,
    this.errorMessage,
  });

  final CastConnectionState connectionState;
  final CastPlaybackState playbackState;
  final CastDevice? connectedDevice;
  final MediaInfo? currentMedia;
  final int? positionMs;
  final int? durationMs;
  final String? errorMessage;
}

@HostApi()
abstract class CastHostApi {
  void startDiscovery();
  void stopDiscovery();
  List<CastDevice> getDiscoveredDevices();
  void connect(String deviceId);
  void disconnect();
  void loadMedia(MediaInfo mediaInfo, bool autoplay, int positionMs);
  void play();
  void pause();
  void seek(int positionMs);
  void stop();
  void setVolume(double volume);
  void setMuted(bool muted);
}

@FlutterApi()
abstract class CastFlutterApi {
  void onDevicesChanged(List<CastDevice> devices);
  void onStateChanged(CastSessionState state);
}
