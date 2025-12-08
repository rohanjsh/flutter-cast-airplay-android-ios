package dev.rohanjsh.pitcher.casting

interface CastingPlaybackProvider {
    fun setStateChangeHandler(handler: StateChangeHandler)
    fun loadMedia(mediaInfo: MediaInfo, autoplay: Boolean, positionMs: Long)
    fun play()
    fun pause()
    fun seek(positionMs: Long)
    fun stop()
    fun setVolume(volume: Double)
    fun disconnect()

    fun interface StateChangeHandler {
        fun onStateChanged(state: ProviderState)
    }
}

data class ProviderState(
    val connectionState: CastingConnectionState = CastingConnectionState.DISCONNECTED,
    val playbackState: CastingPlaybackState = CastingPlaybackState.IDLE,
    val device: CastDevice? = null,
    val positionMs: Long = 0,
    val durationMs: Long = 0,
    val error: String? = null
)

