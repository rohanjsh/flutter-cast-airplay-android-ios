package dev.rohanjsh.pitcher.cast

import dev.rohanjsh.pitcher.cast.session.CastSessionManager
import dev.rohanjsh.pitcher.cast.session.SessionSnapshot

class CastBridge(
    private val sessionManager: CastSessionManager,
    private val flutterApi: CastFlutterApi
) : CastHostApi {

    private var currentMedia: MediaInfo? = null

    init {
        sessionManager.setStateObserver { notifyFlutter(it) }
        sessionManager.setDevicesObserver { flutterApi.onDevicesChanged(it) { } }
    }

    override fun startDiscovery() = sessionManager.startDiscovery()
    override fun stopDiscovery() = sessionManager.stopDiscovery()
    override fun getDiscoveredDevices(): List<CastDevice> = sessionManager.getDiscoveredDevices()
    override fun connect(deviceId: String) = sessionManager.connect(deviceId)
    override fun disconnect() = sessionManager.disconnect()
    override fun showAirPlayPicker() { /* No-op on Android */ }

    override fun loadMedia(mediaInfo: MediaInfo, autoplay: Boolean, positionMs: Long) {
        currentMedia = mediaInfo
        sessionManager.loadMedia(mediaInfo, autoplay, positionMs)
    }

    override fun play() = sessionManager.play()
    override fun pause() = sessionManager.pause()
    override fun seek(positionMs: Long) = sessionManager.seek(positionMs)

    override fun stop() {
        sessionManager.stop()
        currentMedia = null
    }

    override fun setVolume(volume: Double) = sessionManager.setVolume(volume)
    override fun setMuted(muted: Boolean) = sessionManager.setMuted(muted)

    fun dispose() = sessionManager.dispose()

    private fun notifyFlutter(state: SessionSnapshot) {
        flutterApi.onStateChanged(
            CastSessionState(
                connectionState = state.connectionState,
                playbackState = state.playbackState,
                connectedDevice = state.connectedDevice,
                currentMedia = currentMedia,
                positionMs = state.positionMs.takeIf { it > 0 },
                durationMs = state.durationMs.takeIf { it > 0 },
                errorMessage = state.errorMessage
            )
        ) { }
    }
}
