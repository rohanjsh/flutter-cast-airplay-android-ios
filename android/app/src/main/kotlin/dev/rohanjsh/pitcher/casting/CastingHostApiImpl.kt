package dev.rohanjsh.pitcher.casting

import android.content.Context
import android.util.Log

class CastingHostApiImpl(
    context: Context,
    private val flutterApi: CastingFlutterApi
) : CastingHostApi {

    private val chromecastManager = ChromecastManager(context)

    private var activeProvider: CastingProvider? = null
    private var currentMedia: MediaInfo? = null
    private var isDiscovering = false

    private val activePlaybackProvider: CastingPlaybackProvider?
        get() = when (activeProvider) {
            CastingProvider.CHROMECAST -> chromecastManager
            CastingProvider.AIRPLAY, null -> null
        }

    init {
        chromecastManager.setStateChangeHandler { state ->
            handleProviderStateChange(CastingProvider.CHROMECAST, state)
        }
        chromecastManager.setDevicesChangeHandler { devices ->
            handleDevicesChanged(devices)
        }
    }

    override fun startDiscovery() {
        if (isDiscovering) {
            log("Discovery already active")
            return
        }

        log("Starting discovery...")
        isDiscovering = true
        chromecastManager.startDiscovery()
    }

    override fun stopDiscovery() {
        if (!isDiscovering) return

        log("Stopping discovery...")
        isDiscovering = false
        chromecastManager.stopDiscovery()
    }

    override fun getDiscoveredDevices(): List<CastDevice> {
        return chromecastManager.getDiscoveredDevices()
    }

    override fun connect(deviceId: String) {
        val chromecastDevice = chromecastManager.getDiscoveredDevices().find { it.id == deviceId }

        when {
            chromecastDevice != null -> {
                log("Connecting to Chromecast: ${chromecastDevice.name}")
                activeProvider = CastingProvider.CHROMECAST
                chromecastManager.connect(deviceId)
            }
            else -> {
                log("Device not found: $deviceId")
                notifyState(
                    connectionState = CastingConnectionState.DISCONNECTED,
                    playbackState = CastingPlaybackState.ERROR,
                    errorMessage = "Device not found: $deviceId"
                )
            }
        }
    }

    override fun disconnect() { activePlaybackProvider?.disconnect() ?: log("No active session to disconnect"); activeProvider = null }
    override fun showAirPlayPicker() { log("showAirPlayPicker called on Android (no-op)") }

    override fun loadMedia(mediaInfo: MediaInfo, autoplay: Boolean, positionMs: Long) {
        currentMedia = mediaInfo; activePlaybackProvider?.loadMedia(mediaInfo, autoplay, positionMs) ?: log("Cannot load media: no active session")
    }
    override fun play() { activePlaybackProvider?.play() }
    override fun pause() { activePlaybackProvider?.pause() }
    override fun seek(positionMs: Long) { activePlaybackProvider?.seek(positionMs) }
    override fun stop() { activePlaybackProvider?.stop(); currentMedia = null }
    override fun setVolume(volume: Double) { activePlaybackProvider?.setVolume(volume) }

    override fun setMuted(muted: Boolean) {
        when (activeProvider) {
            CastingProvider.CHROMECAST -> chromecastManager.setMuted(muted)
            CastingProvider.AIRPLAY, null -> log("No active session for setMuted")
        }
    }

    fun dispose() { log("Disposing..."); stopDiscovery(); chromecastManager.dispose() }

    private fun handleProviderStateChange(provider: CastingProvider, state: ProviderState) {
        when (state.connectionState) {
            CastingConnectionState.CONNECTED, CastingConnectionState.CONNECTING -> activeProvider = provider
            CastingConnectionState.DISCONNECTED -> if (activeProvider == provider) { activeProvider = null; currentMedia = null }
        }
        if (activeProvider != provider && activeProvider != null) return
        notifyState(state.connectionState, state.playbackState, state.device, state.positionMs.takeIf { it > 0 }, state.durationMs.takeIf { it > 0 }, state.error)
    }

    private fun handleDevicesChanged(devices: List<CastDevice>) {
        log("Devices changed: ${getDiscoveredDevices().size} total")
        flutterApi.onDevicesChanged(getDiscoveredDevices()) { }
    }

    private fun notifyState(connectionState: CastingConnectionState, playbackState: CastingPlaybackState,
                            connectedDevice: CastDevice? = null, positionMs: Long? = null, durationMs: Long? = null, errorMessage: String? = null) {
        flutterApi.onStateChanged(CastingState(connectionState, playbackState, connectedDevice, currentMedia, positionMs, durationMs, errorMessage)) { }
    }

    private fun log(message: String) = Log.d(TAG, message)
    companion object { private const val TAG = "CastingHostApi" }
}

