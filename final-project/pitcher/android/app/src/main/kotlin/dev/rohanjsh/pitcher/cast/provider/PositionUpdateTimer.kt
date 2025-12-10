package dev.rohanjsh.pitcher.cast.provider

import android.os.Handler
import android.os.Looper
import android.util.Log

class PositionUpdateTimer(
    private val intervalMs: Long = DEFAULT_INTERVAL_MS,
    private val onTick: () -> Unit
) {
    private val handler = Handler(Looper.getMainLooper())
    private var runnable: Runnable? = null
    private var isRunning = false

    fun start() {
        if (isRunning) return
        log("Starting position timer")
        isRunning = true
        runnable = object : Runnable {
            override fun run() {
                onTick()
                handler.postDelayed(this, intervalMs)
            }
        }
        handler.postDelayed(runnable!!, intervalMs)
    }

    fun stop() {
        if (!isRunning) return
        log("Stopping position timer")
        runnable?.let { handler.removeCallbacks(it) }
        runnable = null
        isRunning = false
    }


    fun updateForPlaybackState(isPlaying: Boolean) {
        if (isPlaying) start() else stop()
    }

    private fun log(message: String) = Log.d(TAG, message)

    companion object {
        private const val TAG = "PositionUpdateTimer"
        private const val DEFAULT_INTERVAL_MS = 500L
    }
}
