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

    // ╔═══════════════════════════════════════════════════════════════════════════╗
    // ║  TODO 6: Notify Flutter when Chromecast devices are discovered (1 line)  ║
    // ╚═══════════════════════════════════════════════════════════════════════════╝
    //
    // 👉 ADD in onRouteAdded: notifyDevicesChanged()
    //
    // ───────────────────────────────────────────────────────────────────────────────
    // 📚 CONCEPT: MediaRouter - Android's Device Discovery System
    // ───────────────────────────────────────────────────────────────────────────────
    // MediaRouter is part of AndroidX MediaRouter library. It discovers devices
    // that support "media routes" - Chromecast, Bluetooth speakers, HDMI, etc.
    //
    //   ┌──────────────────────────────────────────────────────────────────────┐
    //   │                      MediaRouter Architecture                        │
    //   ├──────────────────────────────────────────────────────────────────────┤
    //   │  MediaRouter.getInstance(context)                                    │
    //   │       │                                                              │
    //   │       ├── addCallback(selector, callback, flags)                     │
    //   │       │        │                                                     │
    //   │       │        └── MediaRouteSelector: "What devices do I want?"     │
    //   │       │            └── Chromecast: CastMediaControlIntent.categoryForCast() │
    //   │       │                                                              │
    //   │       └── routes: List<RouteInfo>                                    │
    //   │                                                                      │
    //   │  MediaRouter.Callback                                                │
    //   │       ├── onRouteAdded()    ← Device found! Notify Flutter           │
    //   │       ├── onRouteRemoved()  ← Device gone                            │
    //   │       └── onRouteChanged()  ← Device name/status changed             │
    //   └──────────────────────────────────────────────────────────────────────┘
    //
    // ───────────────────────────────────────────────────────────────────────────────
    // ⚠️ COMMON PITFALL: "Devices never appear!"
    // ───────────────────────────────────────────────────────────────────────────────
    // 1. Chromecast discovery uses mDNS (multicast DNS) - blocked on some WiFi
    //    networks (hotels, corporate). Test on home WiFi first.
    //
    // 2. Discovery requires CALLBACK_FLAG_PERFORM_ACTIVE_SCAN for immediate
    //    results. Without it, passive discovery can take 30+ seconds.
    //
    // 3. Check if Google Play Services is installed (required for Cast SDK).
    //    Run on real device, not emulator.
    //
    // ───────────────────────────────────────────────────────────────────────────────
    // 🔍 DEBUGGING: Why only onRouteAdded?
    // ───────────────────────────────────────────────────────────────────────────────
    // We only need to add the TODO in onRouteAdded because:
    //   • onRouteRemoved: Already has notifyDevicesChanged() (device leaves)
    //   • onRouteChanged: Already has notifyDevicesChanged() (name updates)
    //   • onRouteAdded: MISSING! This is why new devices don't appear
    //
    // This simulates a real bug - "adding devices works, but initial discovery
    // doesn't populate the list"
    //
    // ───────────────────────────────────────────────────────────────────────────────
    // 🏭 PRODUCTION: Thread Safety
    // ───────────────────────────────────────────────────────────────────────────────
    // MediaRouter callbacks are delivered on the main thread, which is fine for
    // our use case. notifyDevicesChanged() calls observer?.onProviderDevicesChanged()
    // which invokes Pigeon's flutterApi - Pigeon handles the thread switch to
    // Flutter's UI thread automatically.
    //
    // ───────────────────────────────────────────────────────────────────────────────
    // ✅ RESULT: After this TODO, Chromecast devices will appear in the device list!
    // ───────────────────────────────────────────────────────────────────────────────
    private val discoveryCallback = object : MediaRouter.Callback() {
        override fun onRouteAdded(router: MediaRouter, route: MediaRouter.RouteInfo) {
            log("Route added: ${route.name}")
            TODO("TODO 6: notifyDevicesChanged()")
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

    // ╔═══════════════════════════════════════════════════════════════════════════╗
    // ║  TODO 7: Handle successful Chromecast connection (2 lines)               ║
    // ╚═══════════════════════════════════════════════════════════════════════════╝
    //
    // 👉 ADD in onSessionStarted:
    //     session.remoteMediaClient?.registerCallback(playbackCallback)
    //     notifyState(connectionState = CastConnectionState.CONNECTED, connectedDevice = session.toDevice())
    //
    // ───────────────────────────────────────────────────────────────────────────────
    // 📚 CONCEPT: Cast Session Lifecycle
    // ───────────────────────────────────────────────────────────────────────────────
    //
    //   ┌─────────────────────────────────────────────────────────────────────────┐
    //   │                    Cast Session State Machine                          │
    //   │                                                                         │
    //   │   ┌──────────┐   user taps   ┌────────────┐   handshake   ┌──────────┐ │
    //   │   │   IDLE   │ ───────────▶ │  STARTING  │ ────────────▶ │ STARTED  │ │
    //   │   └──────────┘   device      └────────────┘   complete    └──────────┘ │
    //   │        ▲                                           │                    │
    //   │        │                                           ▼                    │
    //   │        │         ┌─────────┐              ┌──────────────┐              │
    //   │        └──────── │  ENDED  │ ◀────────── │   ENDING     │              │
    //   │                  └─────────┘   user       └──────────────┘              │
    //   │                               disconnect                                │
    //   │                                                                         │
    //   │   Background:  SUSPENDED ─────▶ RESUMING ─────▶ RESUMED                │
    //   └─────────────────────────────────────────────────────────────────────────┘
    //
    // ───────────────────────────────────────────────────────────────────────────────
    // 🎯 WHY These Two Lines Matter
    // ───────────────────────────────────────────────────────────────────────────────
    //
    // Line 1: session.remoteMediaClient?.registerCallback(playbackCallback)
    // └── RemoteMediaClient is YOUR controller for what plays on the Chromecast
    // └── registerCallback subscribes to playback state changes (play/pause/seek)
    // └── Without this, you can SEND commands but won't RECEIVE status updates!
    //
    // Line 2: notifyState(connectionState = CONNECTED, connectedDevice = ...)
    // └── This is the Flutter notification that triggers UI update
    // └── session.toDevice() extracts CastDevice info (name, model, ID)
    // └── Flutter's cast button turns from "connecting" spinner to "connected" icon
    //
    // ───────────────────────────────────────────────────────────────────────────────
    // ⚠️ CRITICAL: The "?" Null Safety
    // ───────────────────────────────────────────────────────────────────────────────
    // remoteMediaClient CAN be null! This happens when:
    //   • The Chromecast is running a non-media app (e.g., Backdrop/screensaver)
    //   • The Cast receiver app failed to load
    //   • Rare race condition during session startup
    //
    // Using "?." prevents crash. In production, you might want to show an error
    // if remoteMediaClient is null when you expect media playback.
    //
    // ───────────────────────────────────────────────────────────────────────────────
    // 🔍 DEBUGGING: "Connection works but playback controls don't"
    // ───────────────────────────────────────────────────────────────────────────────
    // This is THE symptom of forgetting registerCallback(playbackCallback).
    // You can connect, load media, and even play - but the UI never updates
    // because onStatusUpdated() in playbackCallback never fires.
    //
    // ───────────────────────────────────────────────────────────────────────────────
    // 🏭 PRODUCTION: Resume vs Start
    // ───────────────────────────────────────────────────────────────────────────────
    // Notice onSessionResumed() already has this code. Why duplicate in onSessionStarted?
    //   • Started: Fresh connection from user interaction
    //   • Resumed: App returns from background with existing session
    //
    // Both need the same setup, but they're different user journeys.
    // The Cast SDK tracks sessions persistently, surviving app restarts!
    //
    // ───────────────────────────────────────────────────────────────────────────────
    // ✅ RESULT: After this TODO, the connection indicator turns green!
    // ───────────────────────────────────────────────────────────────────────────────
    private val sessionListener = object : SessionManagerListener<CastSession> {
        override fun onSessionStarting(session: CastSession) {
            log("Session starting...")
            notifyState(connectionState = CastConnectionState.CONNECTING)
        }

        override fun onSessionStarted(session: CastSession, sessionId: String) {
            log("Session started: $sessionId")
            TODO("TODO 7: Register callback and notify CONNECTED state")
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

    // ╔═══════════════════════════════════════════════════════════════════════════╗
    // ║  TODO 10: Load media onto the Chromecast (1 line)                         ║
    // ╚═══════════════════════════════════════════════════════════════════════════╝
    //
    // 👉 ADD after currentMedia = mediaInfo:
    //     client.load(MediaLoadRequestData.Builder()
    //         .setMediaInfo(mediaInfo.toCastMediaInfo())
    //         .setAutoplay(autoplay)
    //         .setCurrentTime(positionMs)
    //         .build())
    //
    // ───────────────────────────────────────────────────────────────────────────────
    // 📚 CONCEPT: RemoteMediaClient - Your TV Remote Control
    // ───────────────────────────────────────────────────────────────────────────────
    //
    //   
    //                   Flutter → Native → Chromecast Flow                      
    //                                                                            
    //     Flutter MediaInfo          Native MediaLoadRequestData     Chromecast 
    //     ┌──────────────┐           ┌─────────────────────────┐    ┌────────┐ 
    //     │ contentUrl   │ ────────▶ │ setMediaInfo()          │───▶│        │ 
    //     │ title        │   Pigeon  │ setAutoplay(true/false) │    │ Video  │ 
    //     │ mediaType    │           │ setCurrentTime(0ms)     │    └────────┘ 
    //     └──────────────┘           └─────────────────────────┘               
    //   
    //
    // The Cast SDK's RemoteMediaClient.load() sends a command to the Chromecast
    // telling it to fetch and play the media URL. The Chromecast then:
    //   1. Fetches the video directly (NOT through your phone!)
    //   2. Decodes and renders on the TV
    //   3. Sends status updates back via the playbackCallback (from TODO 7)
    //
    // ───────────────────────────────────────────────────────────────────────────────
    // ⚠️ COMMON PITFALL: "Media loads but nothing plays!"
    // ───────────────────────────────────────────────────────────────────────────────
    // 1. Check the URL is publicly accessible (Chromecast fetches it directly!)
    //    → Local URLs like http://localhost won't work
    //    → URLs requiring authentication headers won't work without custom receiver
    //
    // 2. Check the media format is supported by the Chromecast
    //    → MP4 (H.264), WebM, HLS, DASH are supported
    //    → Some codecs like HEVC may not work on older devices
    //
    // 3. Check setAutoplay(true) - without it, video loads but pauses immediately
    //
    // ───────────────────────────────────────────────────────────────────────────────
    // 🔍 DEBUGGING: Use Chrome's Remote Devices Inspector
    // ───────────────────────────────────────────────────────────────────────────────
    // 1. Open chrome://inspect/#devices in Chrome browser
    // 2. Find your Chromecast under "Remote Target"
    // 3. Click "inspect" to see console logs from the receiver app
    // 4. Network tab shows if the media URL was fetched successfully
    //
    // ───────────────────────────────────────────────────────────────────────────────
    // ✅ RESULT: After this TODO, video plays on the TV!
    // ───────────────────────────────────────────────────────────────────────────────
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

        // TODO 10: Load media onto Chromecast
        TODO("TODO 10: client.load(MediaLoadRequestData.Builder()...)")
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
