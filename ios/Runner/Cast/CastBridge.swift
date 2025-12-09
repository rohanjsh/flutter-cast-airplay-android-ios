import Foundation
import GoogleCast
import os.log

@MainActor
final class CastBridge: NSObject, CastHostApi {

    private let flutterApi: CastFlutterApi
    private let sessionManager: CastSessionManager
    private var currentMedia: MediaInfo?

    init(flutterApi: CastFlutterApi, castContext: GCKCastContext) {
        self.flutterApi = flutterApi
        self.sessionManager = CastSessionManager()
        super.init()

        let googleCastProvider = GoogleCastProvider(castContext: castContext)
        let airPlayProvider = AirPlayProvider()
        sessionManager.registerProvider(googleCastProvider)
        sessionManager.registerProvider(airPlayProvider)

        sessionManager.setStateObserver { [weak self] state in
            self?.handleStateChange(state)
        }
        sessionManager.setDevicesObserver { [weak self] devices in
            self?.flutterApi.onDevicesChanged(devices: devices) { _ in }
        }

        log("Initialized")
    }

    // MARK: - CastHostApi

    func startDiscovery() throws {
        sessionManager.startDiscovery()
    }

    func stopDiscovery() throws {
        sessionManager.stopDiscovery()
    }

    func getDiscoveredDevices() throws -> [CastDevice] {
        sessionManager.getDiscoveredDevices()
    }

    func connect(deviceId: String) throws {
        sessionManager.connect(deviceId: deviceId)
    }

    func disconnect() throws {
        sessionManager.disconnect()
    }

    func showAirPlayPicker() throws {
        sessionManager.showAirPlayPicker()
    }

    func loadMedia(mediaInfo: MediaInfo, autoplay: Bool, positionMs: Int64) throws {
        currentMedia = mediaInfo
        sessionManager.loadMedia(mediaInfo, autoplay: autoplay, positionMs: positionMs)
    }

    func play() throws {
        sessionManager.play()
    }

    func pause() throws {
        sessionManager.pause()
    }

    func seek(positionMs: Int64) throws {
        sessionManager.seek(positionMs: positionMs)
    }

    func stop() throws {
        sessionManager.stop()
        currentMedia = nil
    }

    func setVolume(volume: Double) throws {
        sessionManager.setVolume(volume)
    }

    func setMuted(muted: Bool) throws {
        sessionManager.setMuted(muted)
    }

    nonisolated func dispose() {
        Task { @MainActor in
            log("Disposing...")
            sessionManager.dispose()
        }
    }

    // MARK: - Private

    private func handleStateChange(_ state: SessionSnapshot) {
        let castSessionState = CastSessionState(
            connectionState: state.connectionState,
            playbackState: state.playbackState,
            connectedDevice: state.connectedDevice,
            currentMedia: currentMedia,
            positionMs: state.positionMs,
            durationMs: state.durationMs,
            errorMessage: state.errorMessage
        )
        flutterApi.onStateChanged(state: castSessionState) { _ in }
    }

    private nonisolated func log(_ message: String) {
        os_log("[CastBridge] %{public}@", log: .default, type: .debug, message)
    }
}
