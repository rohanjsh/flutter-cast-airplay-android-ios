import Foundation
import GoogleCast
import os.log

@MainActor
final class CastingHostApiImpl: NSObject, @preconcurrency CastingHostApi {

    private let flutterApi: CastingFlutterApi
    private let chromecastManager: ChromecastManager
    private let airPlayManager: AirPlayManager

    private var isDiscovering = false
    private var currentMedia: MediaInfo?
    private var activeProvider: CastingProvider?

    private var activePlaybackProvider: CastingPlaybackProvider? {
        switch activeProvider {
        case .chromecast: return chromecastManager
        case .airplay: return airPlayManager
        case nil: return nil
        }
    }

    init(flutterApi: CastingFlutterApi, castContext: GCKCastContext) {
        self.flutterApi = flutterApi
        self.chromecastManager = ChromecastManager(castContext: castContext)
        self.airPlayManager = AirPlayManager()
        super.init()

        setupManagerCallbacks()
        log("Initialized (Chromecast + AirPlay)")
    }

    deinit {
        dispose()
    }

    private func setupManagerCallbacks() {
        chromecastManager.setStateChangeHandler { [weak self] state in
            Task { @MainActor in self?.handleProviderStateChange(state, provider: .chromecast) }
        }
        chromecastManager.setDevicesChangeHandler { [weak self] _ in
            Task { @MainActor in self?.refreshDiscoveredDevices() }
        }
        airPlayManager.setStateChangeHandler { [weak self] state in
            Task { @MainActor in self?.handleProviderStateChange(state, provider: .airplay) }
        }
    }

    func startDiscovery() throws {
        guard !isDiscovering else {
            log("Discovery already active")
            return
        }

        log("Starting discovery...")
        isDiscovering = true
        chromecastManager.startDiscovery()
        airPlayManager.startRouteDetection()
        refreshDiscoveredDevices()
    }

    func stopDiscovery() throws {
        guard isDiscovering else { return }

        log("Stopping discovery...")
        isDiscovering = false
        chromecastManager.stopDiscovery()
        airPlayManager.stopRouteDetection()
    }

    func getDiscoveredDevices() throws -> [CastDevice] {
        return getAggregatedDevices()
    }

    func connect(deviceId: String) throws {
        if deviceId.hasPrefix("airplay_") {
            log("AirPlay selected - showing picker")
            activeProvider = .airplay
            airPlayManager.showPicker()
        } else {
            log("Connecting to Chromecast: \(deviceId)")
            activeProvider = .chromecast
            chromecastManager.connect(deviceId: deviceId)
        }
    }

    func disconnect() throws {
        activePlaybackProvider?.disconnect()
        activeProvider = nil
    }

    func showAirPlayPicker() throws {
        activeProvider = .airplay
        airPlayManager.showPicker()
    }

    func loadMedia(mediaInfo: MediaInfo, autoplay: Bool, positionMs: Int64) throws {
        currentMedia = mediaInfo
        activePlaybackProvider?.loadMedia(mediaInfo, autoplay: autoplay, positionMs: positionMs)
    }

    func play() throws {
        activePlaybackProvider?.play()
    }

    func pause() throws {
        activePlaybackProvider?.pause()
    }

    func seek(positionMs: Int64) throws {
        activePlaybackProvider?.seek(to: positionMs)
    }

    func stop() throws {
        activePlaybackProvider?.stop()
        currentMedia = nil
    }

    func setVolume(volume: Double) throws {
        activePlaybackProvider?.setVolume(Float(volume))
    }

    func setMuted(muted: Bool) throws {
        switch activeProvider {
        case .chromecast: chromecastManager.setMuted(muted)
        case .airplay: airPlayManager.setVolume(muted ? 0 : 1)
        case nil: break
        }
    }

    nonisolated func dispose() {
        Task { @MainActor in
            log("Disposing...")
            try? stopDiscovery()
            chromecastManager.stop()
            airPlayManager.stop()
        }
    }

    private func handleProviderStateChange(_ state: ProviderState, provider: CastingProvider) {
        switch state.connectionState {
        case .connected, .connecting:
            activeProvider = provider
        case .disconnected:
            if activeProvider == provider { activeProvider = nil; currentMedia = nil }
        }

        guard activeProvider == provider || activeProvider == nil else { return }

        flutterApi.onStateChanged(state: CastingState(
            connectionState: state.connectionState, playbackState: state.playbackState, connectedDevice: state.device,
            currentMedia: currentMedia, positionMs: state.positionMs, durationMs: state.durationMs, errorMessage: state.error
        )) { _ in }
    }

    private func getAggregatedDevices() -> [CastDevice] {
        var devices = chromecastManager.getDiscoveredDevices()
        if airPlayManager.multipleRoutesDetected {
            devices.append(CastDevice(id: "airplay_available", name: "AirPlay", provider: .airplay, modelName: "Tap to select device"))
        }
        return devices
    }

    private func refreshDiscoveredDevices() {
        let devices = getAggregatedDevices(); log("Discovered \(devices.count) device(s)")
        flutterApi.onDevicesChanged(devices: devices) { _ in }
    }

    private nonisolated func log(_ message: String) {
        os_log("[CastingHostApi] %{public}@", log: .default, type: .debug, message)
    }
}
