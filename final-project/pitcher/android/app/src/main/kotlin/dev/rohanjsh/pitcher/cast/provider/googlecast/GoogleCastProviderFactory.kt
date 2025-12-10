package dev.rohanjsh.pitcher.cast.provider.googlecast

import android.content.Context
import androidx.mediarouter.media.MediaControlIntent
import androidx.mediarouter.media.MediaRouteSelector
import androidx.mediarouter.media.MediaRouter
import com.google.android.gms.cast.CastMediaControlIntent
import com.google.android.gms.cast.framework.CastContext
import dev.rohanjsh.pitcher.cast.provider.PositionUpdateTimer


object GoogleCastProviderFactory {

    fun create(context: Context): GoogleCastProvider {
        val mediaRouter = MediaRouter.getInstance(context)
        val castContext = CastContext.getSharedInstance(context)
        val sessionManager = castContext.sessionManager

        val mediaRouteSelector = MediaRouteSelector.Builder()
            .addControlCategory(
                CastMediaControlIntent.categoryForCast(
                    CastMediaControlIntent.DEFAULT_MEDIA_RECEIVER_APPLICATION_ID
                )
            )
            .addControlCategory(MediaControlIntent.CATEGORY_REMOTE_PLAYBACK)
            .build()

        lateinit var provider: GoogleCastProvider
        
        val positionTimer = PositionUpdateTimer {
            val client = sessionManager.currentCastSession?.remoteMediaClient ?: return@PositionUpdateTimer
            provider.notifyPositionUpdate(
                positionMs = client.approximateStreamPosition.coerceAtLeast(0),
                durationMs = client.streamDuration.coerceAtLeast(0)
            )
        }

        provider = GoogleCastProvider(
            mediaRouter = mediaRouter,
            sessionManager = sessionManager,
            mediaRouteSelector = mediaRouteSelector,
            positionTimer = positionTimer
        )

        return provider
    }
}
