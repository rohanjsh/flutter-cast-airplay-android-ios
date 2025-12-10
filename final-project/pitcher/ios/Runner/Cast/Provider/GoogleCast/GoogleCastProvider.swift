import Foundation
import GoogleCast
import os.log

@MainActor
final class GoogleCastProvider: NSObject, CastProviderContract {

    let identifier = CastProviderIdentifiers.googleCast

    private let castContext: GCKCastContext
    private let discoveryManager: GCKDiscoveryManager
    private let sessionManager: GCKSessionManager
    private let positionTimer: PositionUpdateTimer

    private weak var observer: CastProviderObserver?
    private var currentMedia: MediaInfo?

    init(
        castContext: GCKCastContext,
        positionTimer: PositionUpdateTimer = PositionUpdateTimer()
    ) {
        self.castContext = castContext
        self.discoveryManager = castContext.discoveryManager
        self.sessionManager = castContext.sessionManager
        self.positionTimer = positionTimer
        super.init()

        positionTimer.setTickHandler { [weak self] in
            self?.notifyCurrentState()
        }

        log("Initialized")
    }

    // MARK: - CastDiscoveryCapable

    func startDiscovery() {
        log("Starting discovery...")
        discoveryManager.add(self)
        discoveryManager.passiveScan = true
        discoveryManager.startDiscovery()
        sessionManager.add(self)
        notifyDevicesChanged()
    }

    func stopDiscovery() {
        log("Stopping discovery...")
        discoveryManager.stopDiscovery()
        discoveryManager.remove(self)
    }

    func getDiscoveredDevices() -> [CastDevice] {
        (0..<discoveryManager.deviceCount).map { index in
            let device = discoveryManager.device(at: index)
            return CastDevice(
                id: device.uniqueID,
                name: device.friendlyName ?? device.uniqueID,
                provider: .chromecast,
                modelName: device.modelName
            )
        }
    }

    // MARK: - CastConnectionCapable

    func connect(deviceId: String) {
        guard let device = discoveryManager.device(withUniqueID: deviceId) else {
            log("Device not found: \(deviceId)")
            notifyState(
                playbackState: .error,
                errorMessage: "Device not found: \(deviceId)"
            )
            return
        }

        log("Connecting to: \(device.friendlyName ?? deviceId)")
        sessionManager.startSession(with: device)
    }

    func disconnect() {
        guard sessionManager.hasConnectedSession() else {
            log("No active session to disconnect")
            return
        }

        log("Disconnecting...")
        positionTimer.stop()
        sessionManager.endSessionAndStopCasting(true)
    }

    // MARK: - CastPlaybackCapable

    func loadMedia(_ mediaInfo: MediaInfo, autoplay: Bool, positionMs: Int64) {
        guard let client = remoteMediaClient else {
            log("Cannot load media: no active session")
            notifyState(
                playbackState: .error,
                errorMessage: "No active Chromecast session"
            )
            return
        }

        guard let castMediaInfo = mediaInfo.toCastMediaInfo() else {
            log("Cannot load media: invalid content URL")
            notifyState(
                playbackState: .error,
                errorMessage: "Invalid media URL: \(mediaInfo.contentUrl)"
            )
            return
        }

        log("Loading media: \(mediaInfo.title)")
        currentMedia = mediaInfo

        let loadOptions = GCKMediaLoadOptions()
        loadOptions.autoplay = autoplay
        loadOptions.playPosition = TimeInterval(positionMs) / 1000.0

        client.loadMedia(castMediaInfo, with: loadOptions)
    }

    func play() {
        log("Play")
        remoteMediaClient?.play()
    }

    func pause() {
        log("Pause")
        remoteMediaClient?.pause()
    }

    func seek(positionMs: Int64) {
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

    func setVolume(_ volume: Double) {
        log("Set volume: \(volume)")
        remoteMediaClient?.setStreamVolume(Float(volume))
    }

    func setMuted(_ muted: Bool) {
        log("Set muted: \(muted)")
        remoteMediaClient?.setStreamMuted(muted)
    }

    // MARK: - CastProviderContract

    func setObserver(_ observer: CastProviderObserver?) {
        self.observer = observer
    }

    func dispose() {
        log("Disposing...")
        positionTimer.stop()
        stopDiscovery()
        sessionManager.remove(self)
        remoteMediaClient?.remove(self)
        observer = nil
    }

    // MARK: - Private

    private var remoteMediaClient: GCKRemoteMediaClient? {
        sessionManager.currentCastSession?.remoteMediaClient
    }

    private func notifyState(
        connectionState: CastConnectionState = .disconnected,
        playbackState: CastPlaybackState = .idle,
        connectedDevice: CastDevice? = nil,
        positionMs: Int64 = 0,
        durationMs: Int64 = 0,
        errorMessage: String? = nil
    ) {
        let state = SessionSnapshot(
            connectionState: connectionState,
            playbackState: playbackState,
            connectedDevice: connectedDevice,
            activeProviderId: identifier,
            positionMs: positionMs,
            durationMs: durationMs,
            errorMessage: errorMessage
        )
        log("State changed: \(state)")
        observer?.onProviderStateChanged(self, state: state)
    }

    private func notifyCurrentState() {
        guard let client = remoteMediaClient else { return }

        let playbackState = client.mediaStatus?.toPlaybackState() ?? .idle
        let positionMs = Int64(client.approximateStreamPosition() * 1000)
        let durationMs: Int64 = {
            guard let mediaInfo = client.mediaStatus?.mediaInformation else { return 0 }
            return Int64(mediaInfo.streamDuration * 1000)
        }()

        notifyState(
            connectionState: .connected,
            playbackState: playbackState,
            connectedDevice: sessionManager.currentCastSession?.toDevice(),
            positionMs: positionMs.clamped(to: 0...Int64.max),
            durationMs: durationMs.clamped(to: 0...Int64.max)
        )

        positionTimer.updateForPlaybackState(isPlaying: playbackState == .playing)
    }

    private func notifyDevicesChanged() {
        let devices = getDiscoveredDevices()
        log("Discovered \(devices.count) device(s)")
        observer?.onProviderDevicesChanged(self, devices: devices)
    }

    private nonisolated func log(_ message: String) {
        os_log("[GoogleCastProvider] %{public}@", log: .default, type: .debug, message)
    }
}

// MARK: - GCKDiscoveryManagerListener

extension GoogleCastProvider: GCKDiscoveryManagerListener {

    nonisolated func didInsert(_ device: GCKDevice, at index: UInt) {
        Task { @MainActor in
            log("Route added: \(device.friendlyName ?? device.uniqueID)")
            notifyDevicesChanged()
        }
    }

    nonisolated func didRemove(_ device: GCKDevice, at index: UInt) {
        Task { @MainActor in
            log("Route removed: \(device.friendlyName ?? device.uniqueID)")
            notifyDevicesChanged()
        }
    }

    nonisolated func didUpdate(_ device: GCKDevice, at index: UInt) {
        Task { @MainActor in
            log("Route changed: \(device.friendlyName ?? device.uniqueID)")
            notifyDevicesChanged()
        }
    }
}

// MARK: - GCKSessionManagerListener

extension GoogleCastProvider: GCKSessionManagerListener {

    nonisolated func sessionManager(_ sessionManager: GCKSessionManager, willStart session: GCKSession) {
        Task { @MainActor in
            log("Session starting...")
            notifyState(connectionState: .connecting)
        }
    }

    nonisolated func sessionManager(_ sessionManager: GCKSessionManager, didStart session: GCKSession) {
        Task { @MainActor in
            log("Session started: \(session.sessionID ?? "unknown")")

            if let castSession = session as? GCKCastSession {
                castSession.remoteMediaClient?.add(self)
            }

            notifyState(
                connectionState: .connected,
                connectedDevice: (session as? GCKCastSession)?.toDevice()
            )
        }
    }

    nonisolated func sessionManager(_ sessionManager: GCKSessionManager, didFailToStart session: GCKSession, withError error: Error) {
        Task { @MainActor in
            log("Session start failed: \(error.localizedDescription)")
            notifyState(
                connectionState: .disconnected,
                playbackState: .error,
                errorMessage: "Failed to connect: \(error.localizedDescription)"
            )
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

            currentMedia = nil
            positionTimer.stop()
            notifyState()
        }
    }

    nonisolated func sessionManager(_ sessionManager: GCKSessionManager, willResumeCastSession session: GCKCastSession) {
        Task { @MainActor in
            log("Session resuming...")
            notifyState(connectionState: .connecting)
        }
    }

    nonisolated func sessionManager(_ sessionManager: GCKSessionManager, didResumeCastSession session: GCKCastSession) {
        Task { @MainActor in
            log("Session resumed")
            session.remoteMediaClient?.add(self)
            notifyState(
                connectionState: .connected,
                connectedDevice: session.toDevice()
            )
        }
    }

    nonisolated func sessionManager(_ sessionManager: GCKSessionManager, didSuspend session: GCKSession, with reason: GCKConnectionSuspendReason) {
        Task { @MainActor in
            log("Session suspended: reason=\(reason.rawValue)")
        }
    }
}

// MARK: - GCKRemoteMediaClientListener

extension GoogleCastProvider: GCKRemoteMediaClientListener {

    nonisolated func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        Task { @MainActor in
            guard mediaStatus != nil else { return }
            log("Playback status updated")
            notifyCurrentState()
        }
    }
}

// MARK: - Extensions

private extension GCKCastSession {

    func toDevice() -> CastDevice {
        CastDevice(
            id: device.uniqueID,
            name: device.friendlyName ?? device.uniqueID,
            provider: .chromecast,
            modelName: device.modelName
        )
    }
}

private extension GCKMediaStatus {

    func toPlaybackState() -> CastPlaybackState {
        switch playerState {
        case .idle:
            switch idleReason {
            case .finished: return .ended
            case .error: return .error
            default: return .idle
            }
        case .buffering: return .loading
        case .playing: return .playing
        case .paused: return .paused
        default: return .idle
        }
    }
}

extension MediaInfo {

    func toCastMediaInfo() -> GCKMediaInformation? {
        guard let url = URL(string: contentUrl) else { return nil }

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

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
