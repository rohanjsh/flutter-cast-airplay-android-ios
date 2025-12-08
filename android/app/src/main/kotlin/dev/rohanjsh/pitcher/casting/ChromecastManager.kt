package dev.rohanjsh.pitcher.casting

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.core.net.toUri
import androidx.mediarouter.media.MediaControlIntent
import androidx.mediarouter.media.MediaRouteSelector
import androidx.mediarouter.media.MediaRouter
import com.google.android.gms.cast.CastMediaControlIntent
import com.google.android.gms.cast.MediaLoadRequestData
import com.google.android.gms.cast.MediaMetadata
import com.google.android.gms.cast.MediaSeekOptions
import com.google.android.gms.cast.MediaStatus
import com.google.android.gms.cast.framework.CastContext
import com.google.android.gms.cast.framework.CastSession
import com.google.android.gms.cast.framework.SessionManagerListener
import com.google.android.gms.cast.framework.media.RemoteMediaClient
import com.google.android.gms.common.images.WebImage
import com.google.android.gms.cast.MediaInfo as CastMediaInfo

class ChromecastManager(context: Context) : CastingPlaybackProvider {

    private val mediaRouter = MediaRouter.getInstance(context)
    private val castContext = CastContext.getSharedInstance(context)
    private val sessionManager = castContext.sessionManager

    private val mediaRouteSelector = MediaRouteSelector.Builder()
        .addControlCategory(
            CastMediaControlIntent.categoryForCast(
                CastMediaControlIntent.DEFAULT_MEDIA_RECEIVER_APPLICATION_ID
            )
        )
        .addControlCategory(MediaControlIntent.CATEGORY_REMOTE_PLAYBACK)
        .build()

    private var currentMedia: MediaInfo? = null
    private var stateChangeHandler: CastingPlaybackProvider.StateChangeHandler? = null
    private var devicesChangeHandler: DevicesChangeHandler? = null

    private val positionUpdateHandler = Handler(Looper.getMainLooper())
    private var positionUpdateRunnable: Runnable? = null
    private var isCurrentlyPlaying = false

    fun interface DevicesChangeHandler {
        fun onDevicesChanged(devices: List<CastDevice>)
    }

    private val discoveryCallback = object : MediaRouter.Callback() {
        override fun onRouteAdded(router: MediaRouter, route: MediaRouter.RouteInfo) {
            log("Route added: ${route.name}")
            notifyDevicesChanged()
        }

        override fun onRouteRemoved(router: MediaRouter, route: MediaRouter.RouteInfo) {
            log("Route removed: ${route.name}")
            notifyDevicesChanged()
        }

        override fun onRouteChanged(router: MediaRouter, route: MediaRouter.RouteInfo) {
            log("Route changed: ${route.name}")
            notifyDevicesChanged()
        }
    }

    private val sessionListener = object : SessionManagerListener<CastSession> {
        override fun onSessionStarting(session: CastSession) {
            log("Session starting...")
            notifyState(connectionState = CastingConnectionState.CONNECTING)
        }

        override fun onSessionStarted(session: CastSession, sessionId: String) {
            log("Session started: $sessionId")
            session.remoteMediaClient?.registerCallback(playbackCallback)
            notifyState(connectionState = CastingConnectionState.CONNECTED, deviceFromSession = session)
        }

        override fun onSessionStartFailed(session: CastSession, error: Int) {
            log("Session start failed: error=$error")
            notifyState(playbackState = CastingPlaybackState.ERROR, error = "Failed to connect (error: $error)")
        }

        override fun onSessionEnding(session: CastSession) {
            log("Session ending...")
            session.remoteMediaClient?.unregisterCallback(playbackCallback)
        }

        override fun onSessionEnded(session: CastSession, error: Int) {
            log("Session ended: error=$error")
            currentMedia = null
            notifyState()
        }

        override fun onSessionResuming(session: CastSession, sessionId: String) {
            log("Session resuming: $sessionId")
            notifyState(connectionState = CastingConnectionState.CONNECTING)
        }

        override fun onSessionResumed(session: CastSession, wasSuspended: Boolean) {
            log("Session resumed (wasSuspended=$wasSuspended)")
            session.remoteMediaClient?.registerCallback(playbackCallback)
            notifyState(connectionState = CastingConnectionState.CONNECTED, deviceFromSession = session)
        }

        override fun onSessionResumeFailed(session: CastSession, error: Int) {
            log("Session resume failed: error=$error")
            notifyState(playbackState = CastingPlaybackState.ERROR, error = "Failed to resume session (error: $error)")
        }

        override fun onSessionSuspended(session: CastSession, reason: Int) {
            log("Session suspended: reason=$reason")
        }
    }

    private val playbackCallback = object : RemoteMediaClient.Callback() {
        override fun onStatusUpdated() {
            val client = remoteMediaClient ?: return
            val status = client.mediaStatus ?: return

            val playbackState = status.toPlaybackState()
            val positionMs = client.approximateStreamPosition.coerceAtLeast(0)
            val durationMs = client.streamDuration.coerceAtLeast(0)
            val isPlaying = playbackState == CastingPlaybackState.PLAYING

            log("Playback status: $playbackState, position=${positionMs}ms")

            notifyState(connectionState = CastingConnectionState.CONNECTED, playbackState = playbackState,
                positionMs = positionMs, durationMs = durationMs, deviceFromSession = sessionManager.currentCastSession)

            updatePositionTimerState(isPlaying)
        }

        override fun onMetadataUpdated() {}
    }

    fun setDevicesChangeHandler(handler: DevicesChangeHandler) {
        this.devicesChangeHandler = handler
    }

    fun startDiscovery() {
        log("Starting discovery...")
        mediaRouter.addCallback(
            mediaRouteSelector,
            discoveryCallback,
            MediaRouter.CALLBACK_FLAG_PERFORM_ACTIVE_SCAN
        )
        sessionManager.addSessionManagerListener(sessionListener, CastSession::class.java)
        notifyDevicesChanged()
    }

    fun stopDiscovery() {
        log("Stopping discovery...")
        mediaRouter.removeCallback(discoveryCallback)
    }

    fun getDiscoveredDevices(): List<CastDevice> = mediaRouter.routes
        .filter { it.matchesSelector(mediaRouteSelector) && !it.isDefault && it.isEnabled }
        .map { CastDevice(id = it.id, name = it.name, provider = CastingProvider.CHROMECAST, modelName = it.description) }

    fun connect(deviceId: String) {
        val route = mediaRouter.routes.find { it.id == deviceId }
            ?: return notifyState(playbackState = CastingPlaybackState.ERROR, error = "Device not found: $deviceId").also { log("Device not found: $deviceId") }
        log("Connecting to: ${route.name}")
        mediaRouter.selectRoute(route)
    }

    override fun setStateChangeHandler(handler: CastingPlaybackProvider.StateChangeHandler) {
        this.stateChangeHandler = handler
    }

    override fun loadMedia(mediaInfo: MediaInfo, autoplay: Boolean, positionMs: Long) {
        val client = remoteMediaClient ?: return notifyState(playbackState = CastingPlaybackState.ERROR, error = "No active Chromecast session").also { log("Cannot load media: no active session") }
        log("Loading media: ${mediaInfo.title}"); currentMedia = mediaInfo
        client.load(MediaLoadRequestData.Builder().setMediaInfo(mediaInfo.toCastMediaInfo()).setAutoplay(autoplay).setCurrentTime(positionMs).build())
    }

    override fun play() { log("Play"); remoteMediaClient?.play() }
    override fun pause() { log("Pause"); remoteMediaClient?.pause() }
    override fun seek(positionMs: Long) { log("Seek to ${positionMs}ms"); remoteMediaClient?.seek(MediaSeekOptions.Builder().setPosition(positionMs).build()) }
    override fun stop() { log("Stop"); remoteMediaClient?.stop(); currentMedia = null }
    override fun setVolume(volume: Double) { log("Set volume: $volume"); remoteMediaClient?.setStreamVolume(volume) }
    fun setMuted(muted: Boolean) { log("Set muted: $muted"); remoteMediaClient?.setStreamMute(muted) }

    override fun disconnect() {
        if (sessionManager.currentCastSession == null) { log("No active session to disconnect"); return }
        log("Disconnecting..."); stopPositionUpdateTimer(); isCurrentlyPlaying = false
        sessionManager.endCurrentSession(true)
    }

    fun dispose() {
        log("Disposing...")
        stopPositionUpdateTimer()
        stopDiscovery()
        sessionManager.removeSessionManagerListener(sessionListener, CastSession::class.java)
    }

    private val remoteMediaClient: RemoteMediaClient?
        get() = sessionManager.currentCastSession?.remoteMediaClient

    private fun notifyState(connectionState: CastingConnectionState = CastingConnectionState.DISCONNECTED,
                             playbackState: CastingPlaybackState = CastingPlaybackState.IDLE,
                             positionMs: Long = 0, durationMs: Long = 0, error: String? = null, deviceFromSession: CastSession? = null) {
        val device = deviceFromSession?.castDevice?.let { CastDevice(id = it.deviceId, name = it.friendlyName, provider = CastingProvider.CHROMECAST, modelName = it.modelName) }
        stateChangeHandler?.onStateChanged(ProviderState(connectionState = connectionState, playbackState = playbackState, device = device, positionMs = positionMs, durationMs = durationMs, error = error))
    }

    private fun notifyDevicesChanged() = devicesChangeHandler?.onDevicesChanged(getDiscoveredDevices())

    private fun startPositionUpdateTimer() {
        if (positionUpdateRunnable != null) return
        log("Starting position update timer")
        positionUpdateRunnable = object : Runnable {
            override fun run() {
                val client = remoteMediaClient ?: return
                notifyState(connectionState = CastingConnectionState.CONNECTED, playbackState = CastingPlaybackState.PLAYING,
                    positionMs = client.approximateStreamPosition.coerceAtLeast(0),
                    durationMs = client.streamDuration.coerceAtLeast(0),
                    deviceFromSession = sessionManager.currentCastSession)
                positionUpdateHandler.postDelayed(this, POSITION_UPDATE_INTERVAL_MS)
            }
        }
        positionUpdateHandler.postDelayed(positionUpdateRunnable!!, POSITION_UPDATE_INTERVAL_MS)
    }

    private fun stopPositionUpdateTimer() { positionUpdateRunnable?.let { positionUpdateHandler.removeCallbacks(it); positionUpdateRunnable = null } }

    private fun updatePositionTimerState(isPlaying: Boolean) {
        when { isPlaying && !isCurrentlyPlaying -> { isCurrentlyPlaying = true; startPositionUpdateTimer() }
               !isPlaying && isCurrentlyPlaying -> { isCurrentlyPlaying = false; stopPositionUpdateTimer() } }
    }

    private fun log(message: String) = Log.d(TAG, message)

    companion object {
        private const val TAG = "ChromecastManager"
        private const val POSITION_UPDATE_INTERVAL_MS = 500L
    }
}

private fun MediaInfo.toCastMediaInfo(): CastMediaInfo {
    val metadata = MediaMetadata(
        if (mediaType == MediaType.VIDEO) MediaMetadata.MEDIA_TYPE_MOVIE
        else MediaMetadata.MEDIA_TYPE_MUSIC_TRACK
    ).apply {
        putString(MediaMetadata.KEY_TITLE, title)
        subtitle?.let { putString(MediaMetadata.KEY_SUBTITLE, it) }
        imageUrl?.let { addImage(WebImage(it.toUri())) }
    }

    return CastMediaInfo.Builder(contentUrl)
        .setStreamType(CastMediaInfo.STREAM_TYPE_BUFFERED)
        .setContentType(contentType ?: "video/mp4")
        .setMetadata(metadata)
        .apply { duration?.let { setStreamDuration(it) } }
        .build()
}

private fun MediaStatus.toPlaybackState(): CastingPlaybackState = when (playerState) {
    MediaStatus.PLAYER_STATE_IDLE -> when (idleReason) {
        MediaStatus.IDLE_REASON_FINISHED -> CastingPlaybackState.ENDED
        MediaStatus.IDLE_REASON_ERROR -> CastingPlaybackState.ERROR
        else -> CastingPlaybackState.IDLE
    }
    MediaStatus.PLAYER_STATE_BUFFERING -> CastingPlaybackState.LOADING
    MediaStatus.PLAYER_STATE_PLAYING -> CastingPlaybackState.PLAYING
    MediaStatus.PLAYER_STATE_PAUSED -> CastingPlaybackState.PAUSED
    else -> CastingPlaybackState.IDLE
}
