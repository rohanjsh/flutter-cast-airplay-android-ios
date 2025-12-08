import AVFoundation
import AVKit
import MediaPlayer
import os.log
import UIKit

@MainActor
final class AirPlayManager: NSObject, CastingPlaybackProvider {

    typealias StateChangeHandler = (ProviderState) -> Void

    private let routeDetector = AVRouteDetector()
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var timeObserver: Any?
    private var statusObservation: NSKeyValueObservation?
    private var externalPlaybackObservation: NSKeyValueObservation?
    private var routeChangeObservation: NSObjectProtocol?

    private lazy var routePickerView: AVRoutePickerView = {
        let picker = AVRoutePickerView()
        picker.activeTintColor = .systemBlue
        picker.prioritizesVideoDevices = false
        return picker
    }()

    private var currentMedia: MediaInfo?
    private(set) var isConnected = false
    private var onStateChange: StateChangeHandler?

    override init() {
        super.init()
        setupAudioSession()
        setupRouteChangeNotification()
        log("Initialized")
    }

    func setStateChangeHandler(_ handler: @escaping StateChangeHandler) {
        self.onStateChange = handler
    }

    func startRouteDetection() {
        routeDetector.isRouteDetectionEnabled = true
        log("Route detection enabled")
    }

    func stopRouteDetection() {
        routeDetector.isRouteDetectionEnabled = false
        log("Route detection disabled")
    }

    var multipleRoutesDetected: Bool {
        routeDetector.multipleRoutesDetected
    }

    func showPicker() {
        guard let button = routePickerView.subviews.compactMap({ $0 as? UIButton }).first else {
            return log("Failed to show AirPlay picker - button not found")
        }
        button.sendActions(for: .touchUpInside)
        log("AirPlay picker shown")
    }

    func loadMedia(_ mediaInfo: MediaInfo, autoplay: Bool, positionMs: Int64) {
        guard let url = URL(string: mediaInfo.contentUrl) else {
            notifyState(error: "Invalid media URL: \(mediaInfo.contentUrl)")
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

        notifyState()
    }

    func play() {
        log("Play")
        player?.play()
        notifyState()
    }

    func pause() {
        log("Pause")
        player?.pause()
        notifyState()
    }

    func seek(to positionMs: Int64) {
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

    func setVolume(_ volume: Float) {
        log("Set volume: \(volume)")
        player?.volume = volume
    }

    func disconnect() {
        log("Disconnect")
        player?.allowsExternalPlayback = false
        stop()
    }

    var connectedRouteName: String? {
        AVAudioSession.sharedInstance().currentRoute.outputs.first { $0.portType == .airPlay }?.portName
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
            Task { @MainActor in self?.handleRouteChange(notification) }
        }
    }

    private func setupPlayerObservers() {
        guard let player = player else { return }

        statusObservation = player.observe(\.status, options: [.new]) { [weak self] player, _ in
            Task { @MainActor in
                self?.handlePlayerStatusChange(player.status)
            }
        }

        externalPlaybackObservation = player.observe(
            \.isExternalPlaybackActive,
            options: [.new]
        ) { [weak self] player, _ in
            Task { @MainActor in
                self?.isConnected = player.isExternalPlaybackActive
                self?.log("External playback active: \(player.isExternalPlaybackActive)")
                self?.notifyState()
            }
        }

        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            Task { @MainActor in
                self?.notifyState()
            }
        }
    }

    private func handleRouteChange(_ notification: Notification) {
        guard let reasonValue = notification.userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else { return }

        switch reason {
        case .newDeviceAvailable:      log("New AirPlay device available")
        case .oldDeviceUnavailable:    log("AirPlay device disconnected"); isConnected = false
        case .categoryChange, .override, .routeConfigurationChange: break
        default: return
        }
        if reason != .oldDeviceUnavailable { isConnected = connectedRouteName != nil }
        notifyState()
    }

    private func handlePlayerStatusChange(_ status: AVPlayer.Status) {
        switch status {
        case .readyToPlay: log("Player ready to play"); notifyState()
        case .failed:      let e = player?.error?.localizedDescription ?? "Unknown playback error"; log("Player failed: \(e)"); notifyState(error: e)
        case .unknown:     log("Player status unknown")
        @unknown default:  break
        }
    }

    private func notifyState(error: String? = nil) {
        let isPlaying = player?.timeControlStatus == .playing
        let connectionState: CastingConnectionState = isConnected ? .connected : .disconnected
        let playbackState: CastingPlaybackState = error != nil ? .error : isPlaying ? .playing : currentPositionMs > 0 ? .paused : .idle
        let device = connectedRouteName.map { CastDevice(id: "airplay_\($0.hashValue)", name: $0, provider: .airplay, modelName: "AirPlay") }
        onStateChange?(ProviderState(connectionState: connectionState, playbackState: playbackState, device: device,
                                     positionMs: currentPositionMs, durationMs: currentDurationMs, error: error))
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

    private func cleanup() {
        timeObserver.map { player?.removeTimeObserver($0) }
        timeObserver = nil
        statusObservation?.invalidate(); statusObservation = nil
        externalPlaybackObservation?.invalidate(); externalPlaybackObservation = nil
        player?.pause(); player = nil; playerItem = nil
    }

    private nonisolated func log(_ message: String) {
        os_log("[AirPlayManager] %{public}@", log: .default, type: .debug, message)
    }
}

