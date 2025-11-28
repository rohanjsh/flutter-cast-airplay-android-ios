/// App Configuration constants.
class AppConfig {
  AppConfig._();

  static const String appTitle = 'Cast n Play';
  static const String appSubtitle = 'Stream anywhere';
  static const bool debugShowBanner = false;
}

/// Animation & Duration constants.
class AppDurations {
  AppDurations._();

  static const Duration animationDuration = Duration(milliseconds: 1500);
  static const int skipDuration = 15; // seconds
}

/// Demo device names for the workshop.
class DeviceNames {
  DeviceNames._();

  static const String livingRoomTV = 'Living Room TV';
  static const String bedroomSpeaker = 'Bedroom Speaker';
  static const String kitchenDisplay = 'Kitchen Display';
  static const String patioSpeaker = 'Patio Speaker';
}

/// Demo media content for the workshop.
class MediaContent {
  MediaContent._();

  // Audio
  static const String audioTitle = 'Midnight Dreams';
  static const String audioArtist = 'Luna Echo';

  // Video
  static const String videoTitle = 'Summer Vibes - Travel Vlog';
  static const String videoChannel = 'Adventure Channel';

  // Playback
  static const int totalDuration = 225; // 3:45 in seconds
  static const double initialProgress = 0.35;
  static const int initialPosition = 84; // seconds
}

/// UI Strings for localization readiness.
class UIStrings {
  UIStrings._();

  static const String castingStatusPrefix = 'Casting on ';
  static const String audioMode = 'Audio';
  static const String videoMode = 'Video';
  static const String selectDevice = 'Select Device';
  static const String deviceConnected = 'Connected';
  static const String deviceOffline = 'Offline';
}
