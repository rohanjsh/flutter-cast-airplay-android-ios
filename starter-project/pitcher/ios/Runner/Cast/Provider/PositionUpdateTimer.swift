import Foundation

final class PositionUpdateTimer {

    typealias TickHandler = () -> Void

    private var timer: Timer?
    private let interval: TimeInterval
    private var onTick: TickHandler?

    init(interval: TimeInterval = 0.5) {
        self.interval = interval
    }

    func setTickHandler(_ handler: @escaping TickHandler) {
        self.onTick = handler
    }

    @MainActor
    func start() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.onTick?()
            }
        }
    }

    @MainActor
    func stop() {
        timer?.invalidate()
        timer = nil
    }

    @MainActor
    func updateForPlaybackState(isPlaying: Bool) {
        if isPlaying {
            start()
        } else {
            stop()
        }
    }
}
