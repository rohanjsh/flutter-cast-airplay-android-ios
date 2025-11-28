package dev.rohanjsh.pitcher.casting

import android.content.Context
import com.google.android.gms.cast.CastMediaControlIntent
import com.google.android.gms.cast.framework.CastOptions
import com.google.android.gms.cast.framework.OptionsProvider
import com.google.android.gms.cast.framework.SessionProvider

/**
 * Provides Cast SDK options for the application.
 *
 * This class is required by the Google Cast SDK and must be registered
 * in AndroidManifest.xml. It configures:
 * - The receiver application ID (Default Media Receiver for demo)
 * - Session management options
 *
 * For production, replace [CastMediaControlIntent.DEFAULT_MEDIA_RECEIVER_APPLICATION_ID]
 * with your registered Cast Application ID from the Google Cast Developer Console.
 *
 * @see <a href="https://developers.google.com/cast/docs/android_sender">Cast Android Sender</a>
 */
class CastOptionsProvider : OptionsProvider {

    override fun getCastOptions(context: Context): CastOptions {
        return CastOptions.Builder()
            // Use Default Media Receiver for demo purposes
            // For production: Register your app at https://cast.google.com/publish
            .setReceiverApplicationId(CastMediaControlIntent.DEFAULT_MEDIA_RECEIVER_APPLICATION_ID)
            // Don't stop casting when the app goes to background
            .setStopReceiverApplicationWhenEndingSession(true)
            .build()
    }

    override fun getAdditionalSessionProviders(context: Context): List<SessionProvider>? {
        return null
    }
}

