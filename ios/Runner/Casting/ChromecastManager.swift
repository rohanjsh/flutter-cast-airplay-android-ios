import Foundation
import GoogleCast
import os.log

@MainActor
final class ChromecastManager: NSObject, CastingPlaybackProvider {

    typealias StateChangeHandler = (ProviderState) -> Void
    typealias DevicesChangeHandler = ([CastDevice]) -> Void

    private let castContext: GCKCastContext
    private let discoveryManager: GCKDiscoveryManager
    private let sessionManager: GCKSessionManager

    private var currentMedia: MediaInfo?
    private(set) var isConnected = false
    private(set) var isConnecting = false
    private var onStateChange: StateChangeHandler?
    private var onDevicesChange: DevicesChangeHandler?
    private var positionUpdateTimer: Timer?

    init(castContext: GCKCastContext) {
        self.castContext = castContext
        self.discoveryManager = castContext.discoveryManager
        self.sessionManager = castContext.sessionManager
        super.init()

        sessionManager.add(self)
        log("Initialized")
    }

    func setStateChangeHandler(_ handler: @escaping StateChangeHandler) {
        self.onStateChange = handler
    }

    func setDevicesChangeHandler(_ handler: @escaping DevicesChangeHandler) {
        self.onDevicesChange = handler
    }

    func startDiscovery() {
        discoveryManager.add(self)
        discoveryManager.passiveScan = true
        discoveryManager.startDiscovery()
        log("Discovery started")
        refreshDevices()
    }

    func stopDiscovery() {
        discoveryManager.stopDiscovery()
        discoveryManager.remove(self)
        log("Discovery stopped")
    }

    func getDiscoveredDevices() -> [CastDevice] {
        (0..<discoveryManager.deviceCount).map { index in
            let d = discoveryManager.device(at: index)
            return CastDevice(id: d.uniqueID, name: d.friendlyName ?? d.uniqueID, provider: .chromecast, modelName: d.modelName)
        }
    }

    func connect(deviceId: String) {
        guard let device = discoveryManager.device(withUniqueID: deviceId) else {
            log("Device not found: \(deviceId)")
            notifyState(error: "Device not found: \(deviceId)")
            return
        }

        log("Connecting to: \(device.friendlyName ?? deviceId)")
        isConnecting = true
        sessionManager.startSession(with: device)
        notifyState()
    }

    func disconnect() {
        guard sessionManager.hasConnectedSession() else {
            log("No active session to disconnect")
            return
        }

        log("Disconnecting...")
        stopPositionUpdateTimer()
        sessionManager.endSessionAndStopCasting(true)
    }

    func loadMedia(_ mediaInfo: MediaInfo, autoplay: Bool, positionMs: Int64) {
        guard let remoteMediaClient = remoteMediaClient else {
            log("Cannot load media: no active session")
            notifyState(error: "No active Chromecast session")
            return
        }

        guard let castMediaInfo = mediaInfo.toCastMediaInfo() else {
            log("Cannot load media: invalid content URL")
            notifyState(error: "Invalid media URL: \(mediaInfo.contentUrl)")
            return
        }

        log("Loading media: \(mediaInfo.title)")
        currentMedia = mediaInfo

        let mediaLoadOptions = GCKMediaLoadOptions()
        mediaLoadOptions.autoplay = autoplay
        mediaLoadOptions.playPosition = TimeInterval(positionMs) / 1000.0

        remoteMediaClient.loadMedia(castMediaInfo, with: mediaLoadOptions)
    }

    func play() {
        log("Play")
        remoteMediaClient?.play()
    }

    func pause() {
        log("Pause")
        remoteMediaClient?.pause()
    }

    func seek(to positionMs: Int64) {
        log("Seek to \(positionMs)ms")
        let seekOptions = GCKMediaSeekOptions()
        seekOptions.interval = TimeInterval(positionMs) / 1000.0
        remoteMediaClient?.seek(with: seekOptions)
    }

    func stop() {
        log("Stop")
        remoteMediaClient?.stop()
        currentMedia = nil
    }

    func setVolume(_ volume: Float) {
        log("Set volume: \(volume)")
        remoteMediaClient?.setStreamVolume(volume)
    }

    func setMuted(_ muted: Bool) {
        log("Set muted: \(muted)")
        remoteMediaClient?.setStreamMuted(muted)
    }

    var connectedDeviceName: String? {
        sessionManager.currentCastSession?.device.friendlyName
    }

    var connectedDeviceId: String? {
        sessionManager.currentCastSession?.device.uniqueID
    }

    private var remoteMediaClient: GCKRemoteMediaClient? {
        sessionManager.currentCastSession?.remoteMediaClient
    }

    private func refreshDevices() {
        let devices = getDiscoveredDevices()
        log("Discovered \(devices.count) Chromecast device(s)")
        onDevicesChange?(devices)
    }

    private func notifyState(error: String? = nil) {
        let connectionState: CastingConnectionState = isConnected ? .connected : isConnecting ? .connecting : .disconnected
        let playbackState: CastingPlaybackState = error != nil ? .error : isPlaying ? .playing : currentPositionMs > 0 ? .paused : .idle
        let device = connectedDeviceId.flatMap { id in connectedDeviceName.map { CastDevice(id: id, name: $0, provider: .chromecast, modelName: nil) } }
        onStateChange?(ProviderState(connectionState: connectionState, playbackState: playbackState, device: device,
                                     positionMs: currentPositionMs, durationMs: currentDurationMs, error: error))
    }

    private var isPlaying: Bool {
        guard let status = remoteMediaClient?.mediaStatus else { return false }
        return status.playerState == .playing
    }

    private var currentPositionMs: Int64 {
        guard let client = remoteMediaClient else { return 0 }
        return Int64(client.approximateStreamPosition() * 1000)
    }

    private var currentDurationMs: Int64 {
        guard let mediaInfo = remoteMediaClient?.mediaStatus?.mediaInformation else { return 0 }
        return Int64(mediaInfo.streamDuration * 1000)
    }

    private func cleanup() {
        stopPositionUpdateTimer(); sessionManager.remove(self); remoteMediaClient?.remove(self); log("Cleaned up")
    }

    private func startPositionUpdateTimer() {
        guard positionUpdateTimer == nil else { return }
        log("Starting position update timer")
        positionUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.notifyState() }
        }
    }

    private func stopPositionUpdateTimer() { positionUpdateTimer?.invalidate(); positionUpdateTimer = nil }

    private func updatePositionTimerState() { isPlaying ? startPositionUpdateTimer() : stopPositionUpdateTimer() }

    private nonisolated func log(_ message: String) {
        os_log("[ChromecastManager] %{public}@", log: .default, type: .debug, message)
    }
}

extension ChromecastManager: GCKDiscoveryManagerListener {

    nonisolated func didInsert(_ device: GCKDevice, at index: UInt) {
        Task { @MainActor in
            log("Device added: \(device.friendlyName ?? device.uniqueID)")
            refreshDevices()
        }
    }

    nonisolated func didRemove(_ device: GCKDevice, at index: UInt) {
        Task { @MainActor in
            log("Device removed: \(device.friendlyName ?? device.uniqueID)")
            refreshDevices()
        }
    }

    nonisolated func didUpdate(_ device: GCKDevice, at index: UInt) {
        Task { @MainActor in
            log("Device updated: \(device.friendlyName ?? device.uniqueID)")
            refreshDevices()
        }
    }
}

extension ChromecastManager: GCKSessionManagerListener {

    nonisolated func sessionManager(_ sessionManager: GCKSessionManager, willStart session: GCKSession) {
        Task { @MainActor in
            log("Session starting...")
            isConnecting = true
            isConnected = false
            notifyState()
        }
    }

    nonisolated func sessionManager(_ sessionManager: GCKSessionManager, didStart session: GCKSession) {
        Task { @MainActor in
            log("Session started: \(session.sessionID ?? "unknown")")
            isConnecting = false
            isConnected = true

            if let castSession = session as? GCKCastSession {
                castSession.remoteMediaClient?.add(self)
            }

            notifyState()
        }
    }

    nonisolated func sessionManager(_ sessionManager: GCKSessionManager, didFailToStart session: GCKSession, withError error: Error) {
        Task { @MainActor in
            log("Session start failed: \(error.localizedDescription)")
            isConnecting = false
            isConnected = false
            notifyState(error: "Failed to connect: \(error.localizedDescription)")
        }
    }

    nonisolated func sessionManager(_ sessionManager: GCKSessionManager, willEnd session: GCKSession) {
        Task { @MainActor in
            log("Session ending...")

            if let castSession = session as? GCKCastSession {
                castSession.remoteMediaClient?.remove(self)
            }
        }
    }

    nonisolated func sessionManager(_ sessionManager: GCKSessionManager, didEnd session: GCKSession, withError error: Error?) {
        Task { @MainActor in
            if let error = error {
                log("Session ended with error: \(error.localizedDescription)")
            } else {
                log("Session ended")
            }

            isConnecting = false
            isConnected = false
            currentMedia = nil
            notifyState()
        }
    }

    nonisolated func sessionManager(_ sessionManager: GCKSessionManager, willResumeCastSession session: GCKCastSession) {
        Task { @MainActor in
            log("Session resuming...")
            isConnecting = true
            notifyState()
        }
    }

    nonisolated func sessionManager(_ sessionManager: GCKSessionManager, didResumeCastSession session: GCKCastSession) {
        Task { @MainActor in
            log("Session resumed")
            isConnecting = false
            isConnected = true
            session.remoteMediaClient?.add(self)
            notifyState()
        }
    }

    nonisolated func sessionManager(_ sessionManager: GCKSessionManager, didSuspend session: GCKSession, with reason: GCKConnectionSuspendReason) {
        Task { @MainActor in
            log("Session suspended: reason=\(reason.rawValue)")
        }
    }
}

extension ChromecastManager: GCKRemoteMediaClientListener {

    nonisolated func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        Task { @MainActor in
            guard mediaStatus != nil else { return }
            log("Playback status updated")
            notifyState()
            updatePositionTimerState()
        }
    }
}

extension MediaInfo {

    func toCastMediaInfo() -> GCKMediaInformation? {
        guard let url = URL(string: contentUrl) else {
            return nil
        }

        let metadata = GCKMediaMetadata(metadataType: mediaType == .video ? .movie : .musicTrack)
        metadata.setString(title, forKey: kGCKMetadataKeyTitle)

        if let subtitle = subtitle {
            metadata.setString(subtitle, forKey: kGCKMetadataKeySubtitle)
        }

        if let imageUrl = imageUrl, let imageURL = URL(string: imageUrl) {
            metadata.addImage(GCKImage(url: imageURL, width: 480, height: 270))
        }

        let builder = GCKMediaInformationBuilder(contentURL: url)
        builder.streamType = .buffered
        builder.contentType = contentType ?? "video/mp4"
        builder.metadata = metadata

        if let duration = duration {
            builder.streamDuration = TimeInterval(duration) / 1000.0
        }

        return builder.build()
    }
}

