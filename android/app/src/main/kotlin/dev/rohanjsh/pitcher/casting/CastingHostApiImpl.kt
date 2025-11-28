package dev.rohanjsh.pitcher.casting

import android.content.Context
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

/**
 * Android implementation of [CastingHostApi] using Google Cast SDK.
 *
 * ## Architecture
 * This implementation follows the **Observer Pattern** with three callback layers:
 * 1. [MediaRouter.Callback] - Device discovery events
 * 2. [SessionManagerListener] - Connection lifecycle events
 * 3. [RemoteMediaClient.Callback] - Playback state events
 *
 * All state changes flow unidirectionally to Flutter via [CastingFlutterApi].
 *
 * ## Threading
 * - All Cast SDK callbacks run on the main thread
 * - All [CastingHostApi] methods are called from Flutter on the main thread
 * - No additional synchronization needed (single-threaded access)
 *
 * @param context Application context for Cast SDK initialization
 * @param flutterApi Pigeon-generated API for sending events to Flutter
 */
class CastingHostApiImpl(
    context: Context,
    private val flutterApi: CastingFlutterApi
) : CastingHostApi {

    // ══════════════════════════════════════════════════════════════════════════════
    // DEPENDENCIES (initialized once, never change)
    // ══════════════════════════════════════════════════════════════════════════════

    private val mediaRouter = MediaRouter.getInstance(context)
    private val castContext = CastContext.getSharedInstance(context)
    private val sessionManager = castContext.sessionManager

    /** Selector that matches only Cast-compatible devices */
    private val mediaRouteSelector = MediaRouteSelector.Builder()
        .addControlCategory(
            CastMediaControlIntent.categoryForCast(
                CastMediaControlIntent.DEFAULT_MEDIA_RECEIVER_APPLICATION_ID
            )
        )
        .addControlCategory(MediaControlIntent.CATEGORY_REMOTE_PLAYBACK)
        .build()

    // ══════════════════════════════════════════════════════════════════════════════
    // STATE (mutable, single source of truth)
    // ══════════════════════════════════════════════════════════════════════════════

    private var isDiscovering = false
    private var currentMedia: MediaInfo? = null
    private val devices = mutableListOf<CastDevice>()

    // ══════════════════════════════════════════════════════════════════════════════
    // LAYER 1: DEVICE DISCOVERY (MediaRouter)
    // ══════════════════════════════════════════════════════════════════════════════

    private val discoveryCallback = object : MediaRouter.Callback() {
        override fun onRouteAdded(router: MediaRouter, route: MediaRouter.RouteInfo) {
            log("Route added: ${route.name}")
            refreshDiscoveredDevices()
        }

        override fun onRouteRemoved(router: MediaRouter, route: MediaRouter.RouteInfo) {
            log("Route removed: ${route.name}")
            refreshDiscoveredDevices()
        }

        override fun onRouteChanged(router: MediaRouter, route: MediaRouter.RouteInfo) {
            log("Route changed: ${route.name}")
            refreshDiscoveredDevices()
        }
    }

    // ══════════════════════════════════════════════════════════════════════════════
    // LAYER 2: SESSION MANAGEMENT (Connection Lifecycle)
    // ══════════════════════════════════════════════════════════════════════════════

    private val sessionListener = object : SessionManagerListener<CastSession> {
        override fun onSessionStarting(session: CastSession) {
            log("Session starting...")
            notifyState(CastingConnectionState.CONNECTING, CastingPlaybackState.IDLE)
        }

        override fun onSessionStarted(session: CastSession, sessionId: String) {
            log("Session started: $sessionId")
            session.remoteMediaClient?.registerCallback(playbackCallback)
            notifyState(CastingConnectionState.CONNECTED, CastingPlaybackState.IDLE)
        }

        override fun onSessionStartFailed(session: CastSession, error: Int) {
            log("Session start failed: error=$error")
            notifyState(
                connectionState = CastingConnectionState.DISCONNECTED,
                playbackState = CastingPlaybackState.ERROR,
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
            notifyState(CastingConnectionState.DISCONNECTED, CastingPlaybackState.IDLE)
        }

        override fun onSessionResuming(session: CastSession, sessionId: String) {
            log("Session resuming: $sessionId")
            notifyState(CastingConnectionState.CONNECTING, CastingPlaybackState.IDLE)
        }

        override fun onSessionResumed(session: CastSession, wasSuspended: Boolean) {
            log("Session resumed (wasSuspended=$wasSuspended)")
            session.remoteMediaClient?.registerCallback(playbackCallback)
            notifyState(CastingConnectionState.CONNECTED, CastingPlaybackState.IDLE)
        }

        override fun onSessionResumeFailed(session: CastSession, error: Int) {
            log("Session resume failed: error=$error")
            notifyState(
                connectionState = CastingConnectionState.DISCONNECTED,
                playbackState = CastingPlaybackState.ERROR,
                errorMessage = "Failed to resume session (error: $error)"
            )
        }

        override fun onSessionSuspended(session: CastSession, reason: Int) {
            log("Session suspended: reason=$reason")
            // Keep connected state - session may resume automatically
        }
    }

    // ══════════════════════════════════════════════════════════════════════════════
    // LAYER 3: PLAYBACK CONTROL (RemoteMediaClient)
    // ══════════════════════════════════════════════════════════════════════════════

    private val playbackCallback = object : RemoteMediaClient.Callback() {
        override fun onStatusUpdated() {
            val client = remoteMediaClient ?: return
            val status = client.mediaStatus ?: return

            val playbackState = status.toPlaybackState()
            val positionMs = client.approximateStreamPosition.takeIf { it >= 0 }
            val durationMs = client.streamDuration.takeIf { it >= 0 }

            log("Playback status: $playbackState, position=${positionMs}ms, duration=${durationMs}ms")

            notifyState(
                connectionState = CastingConnectionState.CONNECTED,
                playbackState = playbackState,
                positionMs = positionMs,
                durationMs = durationMs
            )
        }

        override fun onMetadataUpdated() {
            // Metadata changes are included in onStatusUpdated
        }
    }

    // ══════════════════════════════════════════════════════════════════════════════
    // CASTINGHOSTAPI IMPLEMENTATION
    // ══════════════════════════════════════════════════════════════════════════════

    override fun startDiscovery() {
        if (isDiscovering) {
            log("Discovery already active")
            return
        }

        log("Starting discovery...")
        isDiscovering = true

        mediaRouter.addCallback(
            mediaRouteSelector,
            discoveryCallback,
            MediaRouter.CALLBACK_FLAG_PERFORM_ACTIVE_SCAN
        )
        sessionManager.addSessionManagerListener(sessionListener, CastSession::class.java)
        refreshDiscoveredDevices()
    }

    override fun stopDiscovery() {
        if (!isDiscovering) return

        log("Stopping discovery...")
        isDiscovering = false
        mediaRouter.removeCallback(discoveryCallback)
    }

    override fun getDiscoveredDevices(): List<CastDevice> = devices.toList()

    override fun connect(deviceId: String) {
        val route = mediaRouter.routes.find { it.id == deviceId }

        if (route == null) {
            log("Device not found: $deviceId")
            notifyState(
                connectionState = CastingConnectionState.DISCONNECTED,
                playbackState = CastingPlaybackState.ERROR,
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
        sessionManager.endCurrentSession(true)
    }

    override fun showAirPlayPicker() {
        // No-op on Android — AirPlay is iOS only
        log("showAirPlayPicker called on Android (no-op)")
    }

    override fun loadMedia(mediaInfo: MediaInfo, autoplay: Boolean, positionMs: Long) {
        val client = remoteMediaClient
        if (client == null) {
            log("Cannot load media: no active session")
            return
        }

        log("Loading media: ${mediaInfo.title}")
        currentMedia = mediaInfo

        val castMediaInfo = mediaInfo.toCastMediaInfo()
        val loadRequest = MediaLoadRequestData.Builder()
            .setMediaInfo(castMediaInfo)
            .setAutoplay(autoplay)
            .setCurrentTime(positionMs)
            .build()

        client.load(loadRequest)
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
        remoteMediaClient?.seek(
            MediaSeekOptions.Builder()
                .setPosition(positionMs)
                .build()
        )
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

    // ══════════════════════════════════════════════════════════════════════════════
    // LIFECYCLE
    // ══════════════════════════════════════════════════════════════════════════════

    /** Call from Activity.onDestroy() to release resources */
    fun dispose() {
        log("Disposing...")
        stopDiscovery()
        sessionManager.removeSessionManagerListener(sessionListener, CastSession::class.java)
    }

    // ══════════════════════════════════════════════════════════════════════════════
    // PRIVATE HELPERS
    // ══════════════════════════════════════════════════════════════════════════════

    /** Convenience accessor for the current session's media client */
    private val remoteMediaClient: RemoteMediaClient?
        get() = sessionManager.currentCastSession?.remoteMediaClient

    /** Refresh the device list and notify Flutter */
    private fun refreshDiscoveredDevices() {
        devices.clear()

        mediaRouter.routes
            .filter { it.matchesSelector(mediaRouteSelector) && !it.isDefault && it.isEnabled }
            .mapTo(devices) { route ->
                CastDevice(
                    id = route.id,
                    name = route.name,
                    provider = CastingProvider.CHROMECAST,
                    modelName = route.description
                )
            }

        log("Discovered ${devices.size} device(s)")
        flutterApi.onDevicesChanged(devices.toList()) { /* ignore callback result */ }
    }

    /** Build and send state update to Flutter */
    private fun notifyState(
        connectionState: CastingConnectionState,
        playbackState: CastingPlaybackState,
        positionMs: Long? = null,
        durationMs: Long? = null,
        errorMessage: String? = null
    ) {
        val connectedDevice = sessionManager.currentCastSession?.castDevice?.let { device ->
            CastDevice(
                id = device.deviceId,
                name = device.friendlyName,
                provider = CastingProvider.CHROMECAST,
                modelName = device.modelName
            )
        }

        val state = CastingState(
            connectionState = connectionState,
            playbackState = playbackState,
            connectedDevice = connectedDevice,
            currentMedia = currentMedia,
            positionMs = positionMs,
            durationMs = durationMs,
            errorMessage = errorMessage
        )

        flutterApi.onStateChanged(state) { /* ignore callback result */ }
    }

    private fun log(message: String) {
        Log.d(TAG, message)
    }

    companion object {
        private const val TAG = "CastingHostApi"
    }
}

// ══════════════════════════════════════════════════════════════════════════════════
// EXTENSION FUNCTIONS (Kotlin idiom for clean conversions)
// ══════════════════════════════════════════════════════════════════════════════════

/** Convert Pigeon [MediaInfo] to Cast SDK [CastMediaInfo] */
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

/** Convert Cast SDK [MediaStatus] to Pigeon [CastingPlaybackState] */
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

