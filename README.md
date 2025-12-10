# Pitcher

A Flutter app for casting media to Chromecast and AirPlay devices. Discover devices, connect, and control playback with a simple media player UI.

## Features

- 🔍 **Device Discovery** - Scan for Chromecast and AirPlay devices on your network
- 📺 **Chromecast Support** - Full Google Cast SDK integration (Android & iOS)
- 🍎 **AirPlay Support** - Native AVPlayer-based AirPlay streaming (iOS)
- 🎵 **Audio/Video** - Toggle between audio and video casting modes
- ▶️ **Transport Controls** - Play, pause, seek, skip, and volume control

## Architecture

The app uses **Pigeon** for type-safe Flutter ↔ Native communication with layered architecture.

### Android Native Layer
![Android Architecture](docs/art/android-layer.png)

### iOS Native Layer  
![iOS Architecture](docs/art/ios-layer.png)

### Flutter & Pigeon Communication
![Flutter Pigeon Architecture](docs/art/flutter-layer.png)

## Getting Started

```bash
# Install dependencies
flutter pub get

# Run on device (requires physical device for cast)
flutter run
```

## Project Structure

```
lib/
├── main.dart                    # App entry point
└── src/
    ├── cast/                    # Cast domain & data layer
    │   ├── data/                # Repository + Pigeon API
    │   └── domain/              # State models + errors
    ├── core/                    # Shared utilities
    └── presentation/            # UI + Controller

android/.../cast/                # Kotlin Cast implementation
ios/Runner/Cast/                 # Swift Cast implementation
pigeons/cast_api.dart            # Pigeon interface definition
```
