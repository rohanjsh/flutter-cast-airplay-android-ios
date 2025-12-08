package dev.rohanjsh.pitcher.casting

import android.content.Context
import android.util.Log

class DlnaManager(
    @Suppress("UNUSED_PARAMETER") context: Context
) : CastingPlaybackProvider {

    private var stateChangeHandler: CastingPlaybackProvider.StateChangeHandler? = null
    private var devicesChangeHandler: DevicesChangeHandler? = null

    fun interface DevicesChangeHandler {
        fun onDevicesChanged(devices: List<CastDevice>)
    }

    fun setDevicesChangeHandler(handler: DevicesChangeHandler) {
        this.devicesChangeHandler = handler
    }

    fun startDiscovery() {
        log("Starting DLNA discovery... (not implemented)")
    }

    fun stopDiscovery() {
        log("Stopping DLNA discovery... (not implemented)")
    }

    fun getDiscoveredDevices(): List<CastDevice> {
        return emptyList()
    }

    fun connect(deviceId: String) {
        log("Connecting to DLNA device: $deviceId (not implemented)")
        notifyState(error = "DLNA not implemented")
    }

    override fun setStateChangeHandler(handler: CastingPlaybackProvider.StateChangeHandler) {
        this.stateChangeHandler = handler
    }

    override fun loadMedia(mediaInfo: MediaInfo, autoplay: Boolean, positionMs: Long) {
        log("Load media: ${mediaInfo.title} (not implemented)")
        notifyState(error = "DLNA not implemented")
    }

    override fun play() {
        log("Play (not implemented)")
    }

    override fun pause() {
        log("Pause (not implemented)")
    }

    override fun seek(positionMs: Long) {
        log("Seek to ${positionMs}ms (not implemented)")
    }

    override fun stop() {
        log("Stop (not implemented)")
    }

    override fun setVolume(volume: Double) {
        log("Set volume: $volume (not implemented)")
    }

    override fun disconnect() {
        log("Disconnect (not implemented)")
        notifyState()
    }

    fun dispose() {
        log("Disposing...")
        stopDiscovery()
    }

    private fun notifyState(
        connectionState: CastingConnectionState = CastingConnectionState.DISCONNECTED,
        playbackState: CastingPlaybackState = CastingPlaybackState.IDLE,
        positionMs: Long = 0,
        durationMs: Long = 0,
        error: String? = null,
        device: CastDevice? = null
    ) {
        stateChangeHandler?.onStateChanged(ProviderState(
            connectionState = connectionState,
            playbackState = playbackState,
            device = device,
            positionMs = positionMs,
            durationMs = durationMs,
            error = error
        ))
    }

    private fun log(message: String) {
        Log.d(TAG, message)
    }

    companion object {
        private const val TAG = "DlnaManager"
    }
}

