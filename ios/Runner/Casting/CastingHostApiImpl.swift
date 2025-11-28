import Foundation
import GoogleCast
import os.log

// MARK: - CastingHostApiImpl

/// iOS implementation of `CastingHostApi` using Google Cast SDK.
///
/// ## Architecture
/// This implementation follows the **Observer Pattern** with three delegate layers:
/// 1. `GCKDiscoveryManagerListener` - Device discovery events
/// 2. `GCKSessionManagerListener` - Connection lifecycle events
/// 3. `GCKRemoteMediaClientListener` - Playback state events
///
/// All state changes flow unidirectionally to Flutter via `CastingFlutterApi`.
///
/// ## Threading
/// - All Cast SDK delegates run on the main thread
/// - All `CastingHostApi` methods are called from Flutter on the main thread
/// - No additional synchronization needed (single-threaded access)
///
/// ## 2025 Swift Best Practices
/// - Uses `os.log` for structured logging (not `print`)
/// - Uses `weak self` in closures to prevent retain cycles
/// - Uses Swift's type-safe enums with exhaustive switches
/// - Uses extensions for clean type conversions
/// - Follows Swift API Design Guidelines naming conventions
///
final class CastingHostApiImpl: NSObject, CastingHostApi {

    // ════════════════════════════════════════════════════════════════════════════
    // MARK: - Dependencies (initialized once, never change)
    // ════════════════════════════════════════════════════════════════════════════

    private let flutterApi: CastingFlutterApi
    private let castContext: GCKCastContext
    private let discoveryManager: GCKDiscoveryManager
    private let sessionManager: GCKSessionManager

    // ════════════════════════════════════════════════════════════════════════════
    // MARK: - State (mutable, single source of truth)
    // ════════════════════════════════════════════════════════════════════════════

    private var isDiscovering = false
    private var currentMedia: MediaInfo?
    private var devices: [CastDevice] = []

    // ════════════════════════════════════════════════════════════════════════════
    // MARK: - Initialization
    // ════════════════════════════════════════════════════════════════════════════

    /// Creates a new `CastingHostApiImpl`.
    ///
    /// - Parameters:
    ///   - flutterApi: Pigeon-generated API for sending events to Flutter
    ///   - castContext: Pre-initialized `GCKCastContext` (setup in AppDelegate)
    ///
    /// - Important: `GCKCastContext` must be initialized in `AppDelegate` before
    ///   creating this instance.
    init(flutterApi: CastingFlutterApi, castContext: GCKCastContext) {
        self.flutterApi = flutterApi
        self.castContext = castContext
        self.discoveryManager = castContext.discoveryManager
        self.sessionManager = castContext.sessionManager
        super.init()

        // Register session listener immediately (connection events)
        sessionManager.add(self)

        log("Initialized")
    }

    deinit {
        dispose()
    }

    // ════════════════════════════════════════════════════════════════════════════
    // MARK: - CastingHostApi Protocol Implementation
    // ════════════════════════════════════════════════════════════════════════════

    func startDiscovery() throws {
        guard !isDiscovering else {
            log("Discovery already active")
            return
        }

        log("Starting discovery...")
        isDiscovering = true

        // Add discovery listener
        discoveryManager.add(self)

        // Start passive scan (active scan drains battery)
        discoveryManager.passiveScan = true
        discoveryManager.startDiscovery()

        refreshDiscoveredDevices()
    }

    func stopDiscovery() throws {
        guard isDiscovering else { return }

        log("Stopping discovery...")
        isDiscovering = false

        discoveryManager.stopDiscovery()
        discoveryManager.remove(self)
    }

    func getDiscoveredDevices() throws -> [CastDevice] {
        return devices
    }

    func connect(deviceId: String) throws {
        guard let device = discoveryManager.device(withUniqueID: deviceId) else {
            log("Device not found: \(deviceId)")
            notifyState(
                connectionState: .disconnected,
                playbackState: .error,
                errorMessage: "Device not found: \(deviceId)"
            )
            return
        }

        log("Connecting to: \(device.friendlyName ?? deviceId)")
        sessionManager.startSession(with: device)
    }

    func disconnect() throws {
        guard sessionManager.hasConnectedSession() else {
            log("No active session to disconnect")
            return
        }

        log("Disconnecting...")
        sessionManager.endSessionAndStopCasting(true)
    }

    func showAirPlayPicker() throws {
        // AirPlay implementation will be added separately
        // This is intentionally a no-op for Chromecast-only workshop
        log("showAirPlayPicker called (AirPlay not yet implemented)")
    }

    func loadMedia(mediaInfo: MediaInfo, autoplay: Bool, positionMs: Int64) throws {
        guard let remoteMediaClient = remoteMediaClient else {
            log("Cannot load media: no active session")
            return
        }

        log("Loading media: \(mediaInfo.title)")
        currentMedia = mediaInfo

        let castMediaInfo = mediaInfo.toCastMediaInfo()
        let mediaLoadOptions = GCKMediaLoadOptions()
        mediaLoadOptions.autoplay = autoplay
        mediaLoadOptions.playPosition = TimeInterval(positionMs) / 1000.0

        remoteMediaClient.loadMedia(castMediaInfo, with: mediaLoadOptions)
    }

    func play() throws {
        log("Play")
        remoteMediaClient?.play()
    }

    func pause() throws {
        log("Pause")
        remoteMediaClient?.pause()
    }

    func seek(positionMs: Int64) throws {
        log("Seek to \(positionMs)ms")
        let seekOptions = GCKMediaSeekOptions()
        seekOptions.interval = TimeInterval(positionMs) / 1000.0
        remoteMediaClient?.seek(with: seekOptions)
    }

    func stop() throws {
        log("Stop")
        remoteMediaClient?.stop()
        currentMedia = nil
    }

    func setVolume(volume: Double) throws {
        log("Set volume: \(volume)")
        remoteMediaClient?.setStreamVolume(Float(volume))
    }

    func setMuted(muted: Bool) throws {
        log("Set muted: \(muted)")
        remoteMediaClient?.setStreamMuted(muted)
    }

    // ════════════════════════════════════════════════════════════════════════════
    // MARK: - Lifecycle
    // ════════════════════════════════════════════════════════════════════════════

    /// Call from `AppDelegate.applicationWillTerminate()` to release resources.
    func dispose() {
        log("Disposing...")
        try? stopDiscovery()
        sessionManager.remove(self)
        remoteMediaClient?.remove(self)
    }

    // ════════════════════════════════════════════════════════════════════════════
    // MARK: - Private Helpers
    // ════════════════════════════════════════════════════════════════════════════

    /// Convenience accessor for the current session's media client.
    private var remoteMediaClient: GCKRemoteMediaClient? {
        return sessionManager.currentCastSession?.remoteMediaClient
    }

    /// Refresh the device list and notify Flutter.
    private func refreshDiscoveredDevices() {
        devices.removeAll()

        let deviceCount = discoveryManager.deviceCount
        for index in 0..<deviceCount {
            let gckDevice = discoveryManager.device(at: index)
            let castDevice = CastDevice(
                id: gckDevice.uniqueID,
                name: gckDevice.friendlyName ?? gckDevice.uniqueID,
                provider: .chromecast,
                modelName: gckDevice.modelName
            )
            devices.append(castDevice)
        }

        log("Discovered \(devices.count) device(s)")
        flutterApi.onDevicesChanged(devices: devices) { _ in }
    }

    /// Build and send state update to Flutter.
    private func notifyState(
        connectionState: CastingConnectionState,
        playbackState: CastingPlaybackState,
        positionMs: Int64? = nil,
        durationMs: Int64? = nil,
        errorMessage: String? = nil
    ) {
        var connectedDevice: CastDevice? = nil
        if let device = sessionManager.currentCastSession?.device {
            connectedDevice = CastDevice(
                id: device.uniqueID,
                name: device.friendlyName ?? device.uniqueID,
                provider: .chromecast,
                modelName: device.modelName
            )
        }

        let state = CastingState(
            connectionState: connectionState,
            playbackState: playbackState,
            connectedDevice: connectedDevice,
            currentMedia: currentMedia,
            positionMs: positionMs,
            durationMs: durationMs,
            errorMessage: errorMessage
        )

        flutterApi.onStateChanged(state: state) { _ in }
    }

    /// Structured logging using os.log (2025 Swift best practice).
    private func log(_ message: String) {
        os_log("[CastingHostApi] %{public}@", log: .default, type: .debug, message)
    }
}



// ════════════════════════════════════════════════════════════════════════════════
// MARK: - GCKDiscoveryManagerListener (Layer 1: Device Discovery)
// ════════════════════════════════════════════════════════════════════════════════

extension CastingHostApiImpl: GCKDiscoveryManagerListener {

    func didInsert(_ device: GCKDevice, at index: UInt) {
        log("Device added: \(device.friendlyName ?? device.uniqueID)")
        refreshDiscoveredDevices()
    }

    func didRemove(_ device: GCKDevice, at index: UInt) {
        log("Device removed: \(device.friendlyName ?? device.uniqueID)")
        refreshDiscoveredDevices()
    }

    func didUpdate(_ device: GCKDevice, at index: UInt) {
        log("Device updated: \(device.friendlyName ?? device.uniqueID)")
        refreshDiscoveredDevices()
    }
}

// ════════════════════════════════════════════════════════════════════════════════
// MARK: - GCKSessionManagerListener (Layer 2: Session Management)
// ════════════════════════════════════════════════════════════════════════════════

extension CastingHostApiImpl: GCKSessionManagerListener {

    func sessionManager(_ sessionManager: GCKSessionManager, willStart session: GCKSession) {
        log("Session starting...")
        notifyState(connectionState: .connecting, playbackState: .idle)
    }

    func sessionManager(_ sessionManager: GCKSessionManager, didStart session: GCKSession) {
        log("Session started: \(session.sessionID ?? "unknown")")

        // Register for playback updates
        if let castSession = session as? GCKCastSession {
            castSession.remoteMediaClient?.add(self)
        }

        notifyState(connectionState: .connected, playbackState: .idle)
    }

    func sessionManager(_ sessionManager: GCKSessionManager, didFailToStart session: GCKSession, withError error: Error) {
        log("Session start failed: \(error.localizedDescription)")
        notifyState(
            connectionState: .disconnected,
            playbackState: .error,
            errorMessage: "Failed to connect: \(error.localizedDescription)"
        )
    }

    func sessionManager(_ sessionManager: GCKSessionManager, willEnd session: GCKSession) {
        log("Session ending...")

        // Unregister from playback updates
        if let castSession = session as? GCKCastSession {
            castSession.remoteMediaClient?.remove(self)
        }
    }

    func sessionManager(_ sessionManager: GCKSessionManager, didEnd session: GCKSession, withError error: Error?) {
        if let error = error {
            log("Session ended with error: \(error.localizedDescription)")
        } else {
            log("Session ended")
        }

        currentMedia = nil
        notifyState(connectionState: .disconnected, playbackState: .idle)
    }

    func sessionManager(_ sessionManager: GCKSessionManager, willResumeCastSession session: GCKCastSession) {
        log("Session resuming...")
        notifyState(connectionState: .connecting, playbackState: .idle)
    }

    func sessionManager(_ sessionManager: GCKSessionManager, didResumeCastSession session: GCKCastSession) {
        log("Session resumed")
        session.remoteMediaClient?.add(self)
        notifyState(connectionState: .connected, playbackState: .idle)
    }

    func sessionManager(_ sessionManager: GCKSessionManager, didSuspend session: GCKSession, with reason: GCKConnectionSuspendReason) {
        log("Session suspended: reason=\(reason.rawValue)")
        // Keep connected state - session may resume automatically
    }
}

// ════════════════════════════════════════════════════════════════════════════════
// MARK: - GCKRemoteMediaClientListener (Layer 3: Playback Control)
// ════════════════════════════════════════════════════════════════════════════════

extension CastingHostApiImpl: GCKRemoteMediaClientListener {

    func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        guard let status = mediaStatus else { return }

        let playbackState = status.toPlaybackState()
        let positionMs = Int64(client.approximateStreamPosition() * 1000)
        var durationMs: Int64? = nil
        if let mediaInfo = status.mediaInformation {
            durationMs = Int64(mediaInfo.streamDuration * 1000)
        }

        log("Playback status: \(playbackState), position=\(positionMs)ms")

        notifyState(
            connectionState: .connected,
            playbackState: playbackState,
            positionMs: positionMs,
            durationMs: durationMs
        )
    }
}

// ════════════════════════════════════════════════════════════════════════════════
// MARK: - Extension Functions (Swift idiom for clean conversions)
// ════════════════════════════════════════════════════════════════════════════════

/// Convert Pigeon `MediaInfo` to Cast SDK `GCKMediaInformation`.
private extension MediaInfo {

    func toCastMediaInfo() -> GCKMediaInformation {
        let metadata = GCKMediaMetadata(metadataType: mediaType == .video ? .movie : .musicTrack)
        metadata.setString(title, forKey: kGCKMetadataKeyTitle)

        if let subtitle = subtitle {
            metadata.setString(subtitle, forKey: kGCKMetadataKeySubtitle)
        }

        if let imageUrl = imageUrl, let url = URL(string: imageUrl) {
            metadata.addImage(GCKImage(url: url, width: 480, height: 270))
        }

        let builder = GCKMediaInformationBuilder(contentURL: URL(string: contentUrl)!)
        builder.streamType = .buffered
        builder.contentType = contentType ?? "video/mp4"
        builder.metadata = metadata

        if let duration = duration {
            builder.streamDuration = TimeInterval(duration) / 1000.0
        }

        return builder.build()
    }
}

/// Convert Cast SDK `GCKMediaStatus` to Pigeon `CastingPlaybackState`.
private extension GCKMediaStatus {

    func toPlaybackState() -> CastingPlaybackState {
        switch playerState {
        case .idle:
            switch idleReason {
            case .finished:
                return .ended
            case .error:
                return .error
            default:
                return .idle
            }
        case .buffering:
            return .loading
        case .playing:
            return .playing
        case .paused:
            return .paused
        case .loading:
            return .loading
        @unknown default:
            return .idle
        }
    }
}

