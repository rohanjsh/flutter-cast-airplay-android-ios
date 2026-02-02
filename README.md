# Pitcher

A Flutter app for casting media to Chromecast and AirPlay devices. Discover devices, connect, and control playback with a simple media player UI.

## Features

- **Device Discovery** - Scan for Chromecast and AirPlay devices on your network
- **Chromecast Support** - Full Google Cast SDK integration (Android & iOS)
- **AirPlay Support** - Native AVPlayer-based AirPlay streaming (iOS)
- **Audio/Video** - Toggle between audio and video casting modes
- **Transport Controls** - Play, pause, seek, skip, and volume control

## Architecture

The app uses **Pigeon** for type-safe Flutter ↔ Native communication with layered architecture.

### Android Native Layer
<img width="17051" height="10395" alt="android-layer" src="https://github.com/user-attachments/assets/6c98a8d4-141d-439b-b7cb-c8062dd105c8" />


### iOS Native Layer  
<img width="17051" height="13866" alt="ios-layer" src="https://github.com/user-attachments/assets/b1d0f448-6582-4959-a46a-82bff40828c5" />


### Flutter & Pigeon Communication
<img width="21178" height="11380" alt="flutter-layer" src="https://github.com/user-attachments/assets/4f0d0670-81bc-4dc8-9c63-5eed21668767" />


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
