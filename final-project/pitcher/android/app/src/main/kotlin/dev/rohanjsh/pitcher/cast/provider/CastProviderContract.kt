package dev.rohanjsh.pitcher.cast.provider

import dev.rohanjsh.pitcher.cast.CastDevice
import dev.rohanjsh.pitcher.cast.MediaInfo
import dev.rohanjsh.pitcher.cast.session.SessionSnapshot


interface CastProviderContract : CastDiscoveryCapable, CastConnectionCapable, CastPlaybackCapable {
    val identifier: String
    fun setObserver(observer: CastProviderObserver?)
    fun dispose()
}


interface CastDiscoveryCapable {
    fun startDiscovery()
    fun stopDiscovery()
    fun getDiscoveredDevices(): List<CastDevice>
}

interface CastConnectionCapable {
    fun connect(deviceId: String)
    fun disconnect()
}

interface CastPlaybackCapable {
    fun loadMedia(mediaInfo: MediaInfo, autoplay: Boolean, positionMs: Long)
    fun play()
    fun pause()
    fun seek(positionMs: Long)
    fun stop()
    fun setVolume(volume: Double)
    fun setMuted(muted: Boolean)
}

/**
 * Observer for provider state changes.
 * Uses SessionSnapshot directly - no separate ProviderSessionState needed.
 */
interface CastProviderObserver {
    fun onProviderStateChanged(provider: CastProviderContract, state: SessionSnapshot)
    fun onProviderDevicesChanged(provider: CastProviderContract, devices: List<CastDevice>)
}

object CastProviderIdentifiers {
    const val GOOGLE_CAST = "google_cast"
//    const val DLNA = "dlna"
}
