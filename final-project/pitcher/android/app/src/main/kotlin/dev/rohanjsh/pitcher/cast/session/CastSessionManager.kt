package dev.rohanjsh.pitcher.cast.session

import android.util.Log
import dev.rohanjsh.pitcher.cast.CastConnectionState
import dev.rohanjsh.pitcher.cast.CastDevice
import dev.rohanjsh.pitcher.cast.CastPlaybackState
import dev.rohanjsh.pitcher.cast.MediaInfo
import dev.rohanjsh.pitcher.cast.provider.CastProviderContract
import dev.rohanjsh.pitcher.cast.provider.CastProviderObserver


class CastSessionManager : CastProviderObserver {

    fun interface StateObserver {
        fun onStateChanged(state: SessionSnapshot)
    }

    fun interface DevicesObserver {
        fun onDevicesChanged(devices: List<CastDevice>)
    }

    private val providers = mutableMapOf<String, CastProviderContract>()

    private var activeProvider: CastProviderContract? = null
    private var currentState = SessionSnapshot()

    private var stateObserver: StateObserver? = null
    private var devicesObserver: DevicesObserver? = null

    fun registerProvider(provider: CastProviderContract) {
        log("Registering provider: ${provider.identifier}")
        providers[provider.identifier] = provider
        provider.setObserver(this)
    }

    fun startDiscovery() {
        log("Starting discovery on ${providers.size} providers")
        providers.values.forEach { it.startDiscovery() }
    }

    fun stopDiscovery() {
        log("Stopping discovery")
        providers.values.forEach { it.stopDiscovery() }
    }

    fun getDiscoveredDevices(): List<CastDevice> {
        return providers.values.flatMap { it.getDiscoveredDevices() }
    }

    fun connect(deviceId: String) {
        val provider = resolveProviderForDevice(deviceId)
        if (provider == null) {
            log("No provider found for device: $deviceId")
            updateState(currentState.copy(
                connectionState = CastConnectionState.DISCONNECTED,
                playbackState = CastPlaybackState.ERROR,
                errorMessage = "Device not found: $deviceId"
            ))
            return
        }
        
        activeProvider?.takeIf { it.identifier != provider.identifier }?.disconnect()

        log("Connecting via ${provider.identifier} to device: $deviceId")
        activeProvider = provider
        provider.connect(deviceId)
    }

    fun disconnect() {
        log("Disconnect requested")
        activeProvider?.disconnect()
        activeProvider = null
        updateState(SessionSnapshot())
    }

    fun loadMedia(mediaInfo: MediaInfo, autoplay: Boolean, positionMs: Long) {
        guardActive("loadMedia") { it.loadMedia(mediaInfo, autoplay, positionMs) }
    }

    fun play() = guardActive("play") { it.play() }

    fun pause() = guardActive("pause") { it.pause() }

    fun seek(positionMs: Long) = guardActive("seek") { it.seek(positionMs) }

    fun stop() = guardActive("stop") { it.stop() }

    fun setVolume(volume: Double) = guardActive("setVolume") { it.setVolume(volume) }

    fun setMuted(muted: Boolean) = guardActive("setMuted") { it.setMuted(muted) }

    fun setStateObserver(observer: StateObserver?) {
        stateObserver = observer
    }

    fun setDevicesObserver(observer: DevicesObserver?) {
        devicesObserver = observer
    }

    fun dispose() {
        log("Disposing session manager")
        providers.values.forEach { it.dispose() }
        providers.clear()
        activeProvider = null
        stateObserver = null
        devicesObserver = null
    }

    override fun onProviderStateChanged(provider: CastProviderContract, state: SessionSnapshot) {
        if (activeProvider != null && activeProvider?.identifier != provider.identifier) {
            log("Ignoring state from inactive provider: ${provider.identifier}")
            return
        }

        if (state.connectionState == CastConnectionState.CONNECTED && activeProvider == null) {
            activeProvider = provider
        }

        if (state.connectionState == CastConnectionState.DISCONNECTED) {
            if (activeProvider?.identifier == provider.identifier) {
                activeProvider = null
            }
        }

        val newState = if (state.connectionState == CastConnectionState.DISCONNECTED) {
            state.copy(activeProviderId = null)
        } else {
            state
        }
        updateState(newState)
    }

    override fun onProviderDevicesChanged(provider: CastProviderContract, devices: List<CastDevice>) {
        log("Devices changed from ${provider.identifier}: ${devices.size} devices")
        devicesObserver?.onDevicesChanged(getDiscoveredDevices())
    }

    private fun resolveProviderForDevice(deviceId: String): CastProviderContract? {
        return providers.values.find { provider ->
            provider.getDiscoveredDevices().any { it.id == deviceId }
        }
    }

    private inline fun guardActive(operation: String, action: (CastProviderContract) -> Unit) {
        val provider = activeProvider
        if (provider == null) {
            log("No active provider for $operation")
            return
        }
        action(provider)
    }

    private fun updateState(newState: SessionSnapshot) {
        if (currentState != newState) {
            log("State changed: $newState")
            currentState = newState
            stateObserver?.onStateChanged(newState)
        }
    }

    private fun log(message: String) = Log.d(TAG, message)

    companion object {
        private const val TAG = "CastSessionManager"
    }
}

data class SessionSnapshot(
    val connectionState: CastConnectionState = CastConnectionState.DISCONNECTED,
    val playbackState: CastPlaybackState = CastPlaybackState.IDLE,
    val connectedDevice: CastDevice? = null,
    val activeProviderId: String? = null,
    val positionMs: Long = 0,
    val durationMs: Long = 0,
    val errorMessage: String? = null
)
