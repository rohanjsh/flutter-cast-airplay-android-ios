import Foundation
import os.log

@MainActor
final class CastSessionManager: CastProviderObserver {

    typealias StateObserver = (SessionSnapshot) -> Void
    typealias DevicesObserver = ([CastDevice]) -> Void

    private var providers: [String: CastProviderContract] = [:]
    private var activeProvider: CastProviderContract?
    private var currentState = SessionSnapshot()

    private var stateObserver: StateObserver?
    private var devicesObserver: DevicesObserver?

    func registerProvider(_ provider: CastProviderContract) {
        log("Registering provider: \(provider.identifier)")
        providers[provider.identifier] = provider
        provider.setObserver(self)
    }

    // MARK: - Discovery

    func startDiscovery() {
        log("Starting discovery on \(providers.count) providers")
        providers.values.forEach { $0.startDiscovery() }
    }

    func stopDiscovery() {
        log("Stopping discovery")
        providers.values.forEach { $0.stopDiscovery() }
    }

    func getDiscoveredDevices() -> [CastDevice] {
        providers.values.flatMap { $0.getDiscoveredDevices() }
    }

    // MARK: - Connection

    func connect(deviceId: String) {
        guard let provider = resolveProviderForDevice(deviceId) else {
            log("No provider found for device: \(deviceId)")
            updateState(currentState.copy(
                connectionState: .disconnected,
                playbackState: .error,
                errorMessage: "Device not found: \(deviceId)"
            ))
            return
        }

        if let active = activeProvider, active.identifier != provider.identifier {
            active.disconnect()
        }

        log("Connecting via \(provider.identifier) to device: \(deviceId)")
        activeProvider = provider
        provider.connect(deviceId: deviceId)
    }

    func disconnect() {
        log("Disconnect requested")
        activeProvider?.disconnect()
        activeProvider = nil
        updateState(SessionSnapshot())
    }

    // MARK: - Playback

    func loadMedia(_ mediaInfo: MediaInfo, autoplay: Bool, positionMs: Int64) {
        guardActive("loadMedia") { $0.loadMedia(mediaInfo, autoplay: autoplay, positionMs: positionMs) }
    }

    func play() {
        guardActive("play") { $0.play() }
    }

    func pause() {
        guardActive("pause") { $0.pause() }
    }

    func seek(positionMs: Int64) {
        guardActive("seek") { $0.seek(positionMs: positionMs) }
    }

    func stop() {
        guardActive("stop") { $0.stop() }
    }

    func setVolume(_ volume: Double) {
        guardActive("setVolume") { $0.setVolume(volume) }
    }

    func setMuted(_ muted: Bool) {
        guardActive("setMuted") { $0.setMuted(muted) }
    }

    // MARK: - Observers

    func setStateObserver(_ observer: StateObserver?) {
        stateObserver = observer
    }

    func setDevicesObserver(_ observer: DevicesObserver?) {
        devicesObserver = observer
    }

    func dispose() {
        log("Disposing session manager")
        providers.values.forEach { $0.dispose() }
        providers.removeAll()
        activeProvider = nil
        stateObserver = nil
        devicesObserver = nil
    }

    // MARK: - CastProviderObserver

    func onProviderStateChanged(_ provider: CastProviderContract, state: SessionSnapshot) {
        if activeProvider != nil && activeProvider?.identifier != provider.identifier {
            log("Ignoring state from inactive provider: \(provider.identifier)")
            return
        }

        if state.connectionState == .connected && activeProvider == nil {
            activeProvider = provider
        }

        if state.connectionState == .disconnected {
            if activeProvider?.identifier == provider.identifier {
                activeProvider = nil
            }
        }

        let newState = state.connectionState == .disconnected
            ? state.copy(activeProviderId: nil)
            : state

        updateState(newState)
    }

    func onProviderDevicesChanged(_ provider: CastProviderContract, devices: [CastDevice]) {
        log("Devices changed from \(provider.identifier): \(devices.count) devices")
        devicesObserver?(getDiscoveredDevices())
    }

    // MARK: - Private

    private func resolveProviderForDevice(_ deviceId: String) -> CastProviderContract? {
        if deviceId.hasPrefix("airplay") {
            return providers[CastProviderIdentifiers.airPlay]
        }

        return providers.values.first { provider in
            provider.getDiscoveredDevices().contains { $0.id == deviceId }
        }
    }

    private func guardActive(_ operation: String, action: (CastProviderContract) -> Void) {
        guard let provider = activeProvider else {
            log("No active provider for \(operation)")
            return
        }
        action(provider)
    }

    private func updateState(_ newState: SessionSnapshot) {
        guard currentState != newState else { return }
        log("State changed: \(newState)")
        currentState = newState
        stateObserver?(newState)
    }

    private func log(_ message: String) {
        os_log("[CastSessionManager] %{public}@", log: .default, type: .debug, message)
    }
}
