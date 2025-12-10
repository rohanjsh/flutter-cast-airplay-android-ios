import Foundation

struct SessionSnapshot: Equatable {
    let connectionState: CastConnectionState
    let playbackState: CastPlaybackState
    let connectedDevice: CastDevice?
    let activeProviderId: String?
    let positionMs: Int64
    let durationMs: Int64
    let errorMessage: String?

    init(
        connectionState: CastConnectionState = .disconnected,
        playbackState: CastPlaybackState = .idle,
        connectedDevice: CastDevice? = nil,
        activeProviderId: String? = nil,
        positionMs: Int64 = 0,
        durationMs: Int64 = 0,
        errorMessage: String? = nil
    ) {
        self.connectionState = connectionState
        self.playbackState = playbackState
        self.connectedDevice = connectedDevice
        self.activeProviderId = activeProviderId
        self.positionMs = positionMs
        self.durationMs = durationMs
        self.errorMessage = errorMessage
    }

    func copy(
        connectionState: CastConnectionState? = nil,
        playbackState: CastPlaybackState? = nil,
        connectedDevice: CastDevice?? = nil,
        activeProviderId: String?? = nil,
        positionMs: Int64? = nil,
        durationMs: Int64? = nil,
        errorMessage: String?? = nil
    ) -> SessionSnapshot {
        SessionSnapshot(
            connectionState: connectionState ?? self.connectionState,
            playbackState: playbackState ?? self.playbackState,
            connectedDevice: connectedDevice ?? self.connectedDevice,
            activeProviderId: activeProviderId ?? self.activeProviderId,
            positionMs: positionMs ?? self.positionMs,
            durationMs: durationMs ?? self.durationMs,
            errorMessage: errorMessage ?? self.errorMessage
        )
    }
}

@MainActor
protocol CastProviderContract: CastDiscoveryCapable, CastConnectionCapable, CastPlaybackCapable {
    var identifier: String { get }
    func setObserver(_ observer: CastProviderObserver?)
    func dispose()
}

@MainActor
protocol CastDiscoveryCapable: AnyObject {
    func startDiscovery()
    func stopDiscovery()
    func getDiscoveredDevices() -> [CastDevice]
}

@MainActor
protocol CastConnectionCapable: AnyObject {
    func connect(deviceId: String)
    func disconnect()
}

@MainActor
protocol CastPlaybackCapable: AnyObject {
    func loadMedia(_ mediaInfo: MediaInfo, autoplay: Bool, positionMs: Int64)
    func play()
    func pause()
    func seek(positionMs: Int64)
    func stop()
    func setVolume(_ volume: Double)
    func setMuted(_ muted: Bool)
}

@MainActor
protocol CastProviderObserver: AnyObject {
    func onProviderStateChanged(_ provider: CastProviderContract, state: SessionSnapshot)
    func onProviderDevicesChanged(_ provider: CastProviderContract, devices: [CastDevice])
}

enum CastProviderIdentifiers {
    static let googleCast = "google_cast"
    static let airPlay = "airplay"
}
