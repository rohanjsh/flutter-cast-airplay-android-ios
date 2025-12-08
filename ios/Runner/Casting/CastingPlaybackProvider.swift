import Foundation

struct ProviderState {
    let connectionState: CastingConnectionState
    let playbackState: CastingPlaybackState
    let device: CastDevice?
    let positionMs: Int64
    let durationMs: Int64
    let error: String?

    init(
        connectionState: CastingConnectionState = .disconnected,
        playbackState: CastingPlaybackState = .idle,
        device: CastDevice? = nil,
        positionMs: Int64 = 0,
        durationMs: Int64 = 0,
        error: String? = nil
    ) {
        self.connectionState = connectionState
        self.playbackState = playbackState
        self.device = device
        self.positionMs = positionMs
        self.durationMs = durationMs
        self.error = error
    }
}

@MainActor
protocol CastingPlaybackProvider: AnyObject {
    func loadMedia(_ mediaInfo: MediaInfo, autoplay: Bool, positionMs: Int64)
    func play()
    func pause()
    func seek(to positionMs: Int64)
    func stop()
    func setVolume(_ volume: Float)
    func disconnect()
}

