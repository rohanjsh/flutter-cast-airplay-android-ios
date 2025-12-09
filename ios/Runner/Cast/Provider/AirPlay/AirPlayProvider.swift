import AVFoundation
import AVKit
import MediaPlayer
import os.log
import UIKit

@MainActor
final class AirPlayProvider: NSObject, CastProviderContract {

    let identifier = CastProviderIdentifiers.airPlay

    private let routeDetector = AVRouteDetector()
    private let positionTimer: PositionUpdateTimer

    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var statusObservation: NSKeyValueObservation?
    private var externalPlaybackObservation: NSKeyValueObservation?
    private var routeChangeObservation: NSObjectProtocol?

    private lazy var routePickerView: AVRoutePickerView = {
        let picker = AVRoutePickerView()
        picker.activeTintColor = .systemBlue
        picker.prioritizesVideoDevices = false
        return picker
    }()

    private weak var observer: CastProviderObserver?
    private var currentMedia: MediaInfo?
    private var isConnected = false

    init(positionTimer: PositionUpdateTimer = PositionUpdateTimer()) {
        self.positionTimer = positionTimer
        super.init()

        positionTimer.setTickHandler { [weak self] in
            self?.notifyCurrentState()
        }

        setupAudioSession()
        setupRouteChangeNotification()
        log("Initialized")
    }

    // MARK: - CastDiscoveryCapable

    func startDiscovery() {
        log("Starting route detection...")
        routeDetector.isRouteDetectionEnabled = true
        notifyDevicesChanged()
    }

    func stopDiscovery() {
        log("Stopping route detection...")
        routeDetector.isRouteDetectionEnabled = false
    }

    func getDiscoveredDevices() -> [CastDevice] {
        guard routeDetector.multipleRoutesDetected else { return [] }
        return [
            CastDevice(
                id: "airplay_available",
                name: "AirPlay",
                provider: .airplay,
                modelName: "Tap to select device"
            )
        ]
    }

    // MARK: - CastConnectionCapable

    func connect(deviceId: String) {
        log("AirPlay selected - showing picker")
        showPicker()
    }

    func disconnect() {
        log("Disconnecting...")
        player?.allowsExternalPlayback = false
        cleanup()
        isConnected = false
        currentMedia = nil
        notifyState()
    }

    // MARK: - CastPlaybackCapable

    func loadMedia(_ mediaInfo: MediaInfo, autoplay: Bool, positionMs: Int64) {
        guard let url = URL(string: mediaInfo.contentUrl) else {
            notifyState(
                playbackState: .error,
                errorMessage: "Invalid media URL: \(mediaInfo.contentUrl)"
            )
            return
        }

        log("Loading media: \(mediaInfo.title)")
        currentMedia = mediaInfo

        let asset = AVURLAsset(url: url)
        playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)

        player?.allowsExternalPlayback = true
        player?.usesExternalPlaybackWhileExternalScreenIsActive = true

        setupPlayerObservers()

        if positionMs > 0 {
            let time = CMTime(value: positionMs, timescale: 1000)
            player?.seek(to: time)
        }

        if autoplay {
            player?.play()
        }

        notifyCurrentState()
    }

    func play() {
        log("Play")
        player?.play()
        notifyCurrentState()
    }

    func pause() {
        log("Pause")
        player?.pause()
        notifyCurrentState()
    }

    func seek(positionMs: Int64) {
        log("Seek to \(positionMs)ms")
        let time = CMTime(value: positionMs, timescale: 1000)
        player?.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
    }

    func stop() {
        log("Stop")
        cleanup()
        currentMedia = nil
        notifyState()
    }

    func setVolume(_ volume: Double) {
        log("Set volume: \(volume)")
        player?.volume = Float(volume)
    }

    func setMuted(_ muted: Bool) {
        log("Set muted: \(muted)")
        player?.isMuted = muted
    }

    // MARK: - CastProviderContract

    func setObserver(_ observer: CastProviderObserver?) {
        self.observer = observer
    }

    func dispose() {
        log("Disposing...")
        positionTimer.stop()
        stopDiscovery()
        cleanup()
        routeChangeObservation.map { NotificationCenter.default.removeObserver($0) }
        observer = nil
    }

    // MARK: - Public

    func showPicker() {
        guard let button = routePickerView.subviews.compactMap({ $0 as? UIButton }).first else {
            log("Failed to show AirPlay picker - button not found")
            return
        }
        button.sendActions(for: .touchUpInside)
        log("AirPlay picker shown")
    }

    var multipleRoutesDetected: Bool {
        routeDetector.multipleRoutesDetected
    }

    // MARK: - Private

    private var connectedRouteName: String? {
        AVAudioSession.sharedInstance().currentRoute.outputs.first { $0.portType == .airPlay }?.portName
    }

    private var currentPositionMs: Int64 {
        guard let player = player else { return 0 }
        let seconds = CMTimeGetSeconds(player.currentTime())
        return seconds.isFinite ? Int64(seconds * 1000) : 0
    }

    private var currentDurationMs: Int64 {
        guard let duration = playerItem?.duration else { return 0 }
        let seconds = CMTimeGetSeconds(duration)
        return seconds.isFinite ? Int64(seconds * 1000) : 0
    }

    private var isPlaying: Bool {
        player?.timeControlStatus == .playing
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
        let connectionState: CastConnectionState = isConnected ? .connected : .disconnected
        let playbackState: CastPlaybackState = isPlaying ? .playing : (currentPositionMs > 0 ? .paused : .idle)
        let device = connectedRouteName.map {
            CastDevice(
                id: "airplay_\($0.hashValue)",
                name: $0,
                provider: .airplay,
                modelName: "AirPlay"
            )
        }

        notifyState(
            connectionState: connectionState,
            playbackState: playbackState,
            connectedDevice: device,
            positionMs: currentPositionMs,
            durationMs: currentDurationMs
        )

        positionTimer.updateForPlaybackState(isPlaying: isPlaying)
    }

    private func notifyDevicesChanged() {
        let devices = getDiscoveredDevices()
        log("Discovered \(devices.count) AirPlay device(s)")
        observer?.onProviderDevicesChanged(self, devices: devices)
    }

    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .moviePlayback, options: [.allowAirPlay])
            try session.setActive(true)
            log("Audio session configured for AirPlay")
        } catch {
            log("Failed to configure audio session: \(error.localizedDescription)")
        }
    }

    private func setupRouteChangeNotification() {
        routeChangeObservation = NotificationCenter.default.addObserver(
            forName: AVAudioSession.routeChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            Task { @MainActor in
                self?.handleRouteChange(notification)
            }
        }
    }

    private func setupPlayerObservers() {
        guard let player = player else { return }

        statusObservation = player.observe(\.status, options: [.new]) { [weak self] player, _ in
            Task { @MainActor in
                self?.handlePlayerStatusChange(player.status)
            }
        }

        externalPlaybackObservation = player.observe(\.isExternalPlaybackActive, options: [.new]) { [weak self] player, _ in
            Task { @MainActor in
                self?.isConnected = player.isExternalPlaybackActive
                self?.log("External playback active: \(player.isExternalPlaybackActive)")
                self?.notifyCurrentState()
            }
        }
    }

    private func handleRouteChange(_ notification: Notification) {
        guard let reasonValue = notification.userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else { return }

        switch reason {
        case .newDeviceAvailable:
            log("New AirPlay device available")
        case .oldDeviceUnavailable:
            log("AirPlay device disconnected")
            isConnected = false
        default:
            break
        }

        if reason != .oldDeviceUnavailable {
            isConnected = connectedRouteName != nil
        }

        notifyCurrentState()
    }

    private func handlePlayerStatusChange(_ status: AVPlayer.Status) {
        switch status {
        case .readyToPlay:
            log("Player ready to play")
            notifyCurrentState()
        case .failed:
            let errorMessage = player?.error?.localizedDescription ?? "Unknown playback error"
            log("Player failed: \(errorMessage)")
            notifyState(playbackState: .error, errorMessage: errorMessage)
        case .unknown:
            log("Player status unknown")
        @unknown default:
            break
        }
    }

    private func cleanup() {
        positionTimer.stop()
        statusObservation?.invalidate()
        statusObservation = nil
        externalPlaybackObservation?.invalidate()
        externalPlaybackObservation = nil
        player?.pause()
        player = nil
        playerItem = nil
    }

    private nonisolated func log(_ message: String) {
        os_log("[AirPlayProvider] %{public}@", log: .default, type: .debug, message)
    }
}
