# Pitcher (Fluttercon India 2025)

A Flutter app for casting media to Chromecast and AirPlay devices. Discover devices, connect, and control playback with a simple media player UI.

## Features

- **Device Discovery** - Scan for Chromecast and AirPlay devices on your network
- **Chromecast Support** - Full Google Cast SDK integration (Android & iOS)
- **AirPlay Support** - Native AVPlayer-based AirPlay streaming (iOS)
- **Audio/Video** - Toggle between audio and video casting modes
- **Transport Controls** - Play, pause, seek, skip, and volume control

## 📋 TODOs Checklist

Complete these 11 TODOs to build a fully functional casting app:
|  | Platform | File | Description |
|---|----------|------|-------------|
| 1 | Flutter | `cast_repository.dart` | Register this class to receive native callbacks |
| 2 | iOS | `AppDelegate.swift` | Complete the Pigeon bridge setup |
| 3 | Android | `MainActivity.kt` | Complete the Pigeon bridge setup |
| 4 | iOS | `AirPlayProvider.swift` | Enable AirPlay route detection |
| 5 | Android | `GoogleCastProvider.kt` | Notify Flutter when Chromecast devices are discovered |
| 6 | iOS | `GoogleCastProvider.swift` | Notify Flutter when Chromecast devices are discovered |
| 7 | Android | `GoogleCastProvider.kt` | Handle successful Chromecast connection |
| 8 | iOS | `GoogleCastProvider.swift` | Handle successful Chromecast connection |
| 9 | iOS | `AirPlayProvider.swift` | Enable AirPlay on AVPlayer |
| 10 | Android | `GoogleCastProvider.kt` | Load media onto the Chromecast |
| 11 | iOS | `GoogleCastProvider.swift` | Load media onto the Chromecast |


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
