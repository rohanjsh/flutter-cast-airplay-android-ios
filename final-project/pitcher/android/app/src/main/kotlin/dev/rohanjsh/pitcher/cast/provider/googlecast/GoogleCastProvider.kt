package dev.rohanjsh.pitcher.cast.provider.googlecast

import android.util.Log
import androidx.core.net.toUri
import androidx.mediarouter.media.MediaRouteSelector
import androidx.mediarouter.media.MediaRouter
import com.google.android.gms.cast.MediaLoadRequestData
import com.google.android.gms.cast.MediaMetadata
import com.google.android.gms.cast.MediaSeekOptions
import com.google.android.gms.cast.MediaStatus
import com.google.android.gms.cast.framework.CastSession
import com.google.android.gms.cast.framework.SessionManager
import com.google.android.gms.cast.framework.SessionManagerListener
import com.google.android.gms.cast.framework.media.RemoteMediaClient
import com.google.android.gms.common.images.WebImage
import dev.rohanjsh.pitcher.cast.CastConnectionState
import dev.rohanjsh.pitcher.cast.CastDevice
import dev.rohanjsh.pitcher.cast.CastPlaybackState
import dev.rohanjsh.pitcher.cast.CastProvider
import dev.rohanjsh.pitcher.cast.MediaInfo
import dev.rohanjsh.pitcher.cast.MediaType
import dev.rohanjsh.pitcher.cast.provider.CastProviderContract
import dev.rohanjsh.pitcher.cast.provider.CastProviderIdentifiers
import dev.rohanjsh.pitcher.cast.provider.CastProviderObserver
import dev.rohanjsh.pitcher.cast.provider.PositionUpdateTimer
import dev.rohanjsh.pitcher.cast.session.SessionSnapshot
import com.google.android.gms.cast.MediaInfo as CastMediaInfo


class GoogleCastProvider(
    private val mediaRouter: MediaRouter,
    private val sessionManager: SessionManager,
    private val mediaRouteSelector: MediaRouteSelector,
    private val positionTimer: PositionUpdateTimer
) : CastProviderContract {

    override val identifier: String = CastProviderIdentifiers.GOOGLE_CAST

    private var observer: CastProviderObserver? = null
    private var currentMedia: MediaInfo? = null

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
            notifyState(connectionState = CastConnectionState.CONNECTING)
        }

        override fun onSessionStarted(session: CastSession, sessionId: String) {
            log("Session started: $sessionId")
            session.remoteMediaClient?.registerCallback(playbackCallback)
            notifyState(
                connectionState = CastConnectionState.CONNECTED,
                connectedDevice = session.toDevice()
            )
        }

        override fun onSessionStartFailed(session: CastSession, error: Int) {
            log("Session start failed: error=$error")
            notifyState(
                connectionState = CastConnectionState.DISCONNECTED,
                playbackState = CastPlaybackState.ERROR,
                errorMessage = "Failed to connect (error: $error)"
            )
        }

        override fun onSessionEnding(session: CastSession) {
            log("Session ending...")
            session.remoteMediaClient?.unregisterCallback(playbackCallback)
        }

        override fun onSessionEnded(session: CastSession, error: Int) {
            log("Session ended: error=$error")
            currentMedia = null
            positionTimer.stop()
            notifyState()
        }

        override fun onSessionResuming(session: CastSession, sessionId: String) {
            log("Session resuming: $sessionId")
            notifyState(connectionState = CastConnectionState.CONNECTING)
        }

        override fun onSessionResumed(session: CastSession, wasSuspended: Boolean) {
            log("Session resumed (wasSuspended=$wasSuspended)")
            session.remoteMediaClient?.registerCallback(playbackCallback)
            notifyState(
                connectionState = CastConnectionState.CONNECTED,
                connectedDevice = session.toDevice()
            )
        }

        override fun onSessionResumeFailed(session: CastSession, error: Int) {
            log("Session resume failed: error=$error")
            notifyState(
                connectionState = CastConnectionState.DISCONNECTED,
                playbackState = CastPlaybackState.ERROR,
                errorMessage = "Failed to resume session (error: $error)"
            )
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
            val isPlaying = playbackState == CastPlaybackState.PLAYING

            log("Playback status: $playbackState, position=${positionMs}ms")

            notifyState(
                connectionState = CastConnectionState.CONNECTED,
                playbackState = playbackState,
                connectedDevice = sessionManager.currentCastSession?.toDevice(),
                positionMs = positionMs,
                durationMs = durationMs
            )

            positionTimer.updateForPlaybackState(isPlaying)
        }

        override fun onMetadataUpdated() {}
    }

    override fun startDiscovery() {
        log("Starting discovery...")
        mediaRouter.addCallback(
            mediaRouteSelector,
            discoveryCallback,
            MediaRouter.CALLBACK_FLAG_PERFORM_ACTIVE_SCAN
        )
        sessionManager.addSessionManagerListener(sessionListener, CastSession::class.java)
        notifyDevicesChanged()
    }

    override fun stopDiscovery() {
        log("Stopping discovery...")
        mediaRouter.removeCallback(discoveryCallback)
    }

    override fun getDiscoveredDevices(): List<CastDevice> = mediaRouter.routes
        .filter { it.matchesSelector(mediaRouteSelector) && !it.isDefault && it.isEnabled }
        .map {
            CastDevice(
                id = it.id,
                name = it.name,
                provider = CastProvider.CHROMECAST,
                modelName = it.description
            )
        }

    override fun connect(deviceId: String) {
        val route = mediaRouter.routes.find { it.id == deviceId }
        if (route == null) {
            log("Device not found: $deviceId")
            notifyState(
                playbackState = CastPlaybackState.ERROR,
                errorMessage = "Device not found: $deviceId"
            )
            return
        }
        log("Connecting to: ${route.name}")
        mediaRouter.selectRoute(route)
    }

    override fun disconnect() {
        if (sessionManager.currentCastSession == null) {
            log("No active session to disconnect")
            return
        }
        log("Disconnecting...")
        positionTimer.stop()
        sessionManager.endCurrentSession(true)
    }

    override fun loadMedia(mediaInfo: MediaInfo, autoplay: Boolean, positionMs: Long) {
        val client = remoteMediaClient
        if (client == null) {
            log("Cannot load media: no active session")
            notifyState(
                playbackState = CastPlaybackState.ERROR,
                errorMessage = "No active Chromecast session"
            )
            return
        }
        log("Loading media: ${mediaInfo.title}")
        currentMedia = mediaInfo
        client.load(
            MediaLoadRequestData.Builder()
                .setMediaInfo(mediaInfo.toCastMediaInfo())
                .setAutoplay(autoplay)
                .setCurrentTime(positionMs)
                .build()
        )
    }

    override fun play() {
        log("Play")
        remoteMediaClient?.play()
    }

    override fun pause() {
        log("Pause")
        remoteMediaClient?.pause()
    }

    override fun seek(positionMs: Long) {
        log("Seek to ${positionMs}ms")
        remoteMediaClient?.seek(MediaSeekOptions.Builder().setPosition(positionMs).build())
    }

    override fun stop() {
        log("Stop")
        remoteMediaClient?.stop()
        currentMedia = null
    }

    override fun setVolume(volume: Double) {
        log("Set volume: $volume")
        remoteMediaClient?.setStreamVolume(volume)
    }

    override fun setMuted(muted: Boolean) {
        log("Set muted: $muted")
        remoteMediaClient?.setStreamMute(muted)
    }

    override fun dispose() {
        log("Disposing...")
        positionTimer.stop()
        stopDiscovery()
        sessionManager.removeSessionManagerListener(sessionListener, CastSession::class.java)
        observer = null
    }

    override fun setObserver(observer: CastProviderObserver?) {
        this.observer = observer
    }

    private val remoteMediaClient: RemoteMediaClient?
        get() = sessionManager.currentCastSession?.remoteMediaClient

    private fun notifyState(
        connectionState: CastConnectionState = CastConnectionState.DISCONNECTED,
        playbackState: CastPlaybackState = CastPlaybackState.IDLE,
        connectedDevice: CastDevice? = null,
        positionMs: Long = 0,
        durationMs: Long = 0,
        errorMessage: String? = null
    ) {
        val state = SessionSnapshot(
            connectionState = connectionState,
            playbackState = playbackState,
            connectedDevice = connectedDevice,
            activeProviderId = identifier,
            positionMs = positionMs,
            durationMs = durationMs,
            errorMessage = errorMessage
        )
        observer?.onProviderStateChanged(this, state)
    }

    private fun notifyDevicesChanged() {
        observer?.onProviderDevicesChanged(this, getDiscoveredDevices())
    }

    internal fun notifyPositionUpdate(positionMs: Long, durationMs: Long) {
        notifyState(
            connectionState = CastConnectionState.CONNECTED,
            playbackState = CastPlaybackState.PLAYING,
            connectedDevice = sessionManager.currentCastSession?.toDevice(),
            positionMs = positionMs,
            durationMs = durationMs
        )
    }

    private fun log(message: String) = Log.d(TAG, message)

    companion object {
        private const val TAG = "GoogleCastProvider"
    }
}

private fun CastSession.toDevice(): CastDevice? {
    val device = castDevice ?: return null
    return CastDevice(
        id = device.deviceId,
        name = device.friendlyName,
        provider = CastProvider.CHROMECAST,
        modelName = device.modelName
    )
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

private fun MediaStatus.toPlaybackState(): CastPlaybackState = when (playerState) {
    MediaStatus.PLAYER_STATE_IDLE -> when (idleReason) {
        MediaStatus.IDLE_REASON_FINISHED -> CastPlaybackState.ENDED
        MediaStatus.IDLE_REASON_ERROR -> CastPlaybackState.ERROR
        else -> CastPlaybackState.IDLE
    }
    MediaStatus.PLAYER_STATE_BUFFERING -> CastPlaybackState.LOADING
    MediaStatus.PLAYER_STATE_PLAYING -> CastPlaybackState.PLAYING
    MediaStatus.PLAYER_STATE_PAUSED -> CastPlaybackState.PAUSED
    else -> CastPlaybackState.IDLE
}
