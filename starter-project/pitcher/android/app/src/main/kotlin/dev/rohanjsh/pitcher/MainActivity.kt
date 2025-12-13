package dev.rohanjsh.pitcher

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import dev.rohanjsh.pitcher.cast.CastBridge
import dev.rohanjsh.pitcher.cast.CastFlutterApi
import dev.rohanjsh.pitcher.cast.CastHostApi
import dev.rohanjsh.pitcher.cast.provider.googlecast.GoogleCastProviderFactory
import dev.rohanjsh.pitcher.cast.session.CastSessionManager

class MainActivity : FlutterActivity() {

    private var castBridge: CastBridge? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val binaryMessenger = flutterEngine.dartExecutor.binaryMessenger

        // ╔═══════════════════════════════════════════════════════════════════════╗
        // ║  TODO 3: Complete the Pigeon bridge setup - Android (1 line)          ║
        // ╚═══════════════════════════════════════════════════════════════════════╝
        //
        // 👉 ADD: CastHostApi.setUp(binaryMessenger, castBridge)
        //
        // ───────────────────────────────────────────────────────────────────────────
        // 📚 CONCEPT: Pigeon on Android vs iOS
        // ───────────────────────────────────────────────────────────────────────────
        // Notice the API difference:
        //   • iOS:     CastHostApiSetup.setUp(binaryMessenger:, api:)  // Named params
        //   • Android: CastHostApi.setUp(binaryMessenger, api)        // Positional
        //
        // Same concept, different syntax. Pigeon generates idiomatic code for each
        // platform - Swift style for iOS, Kotlin style for Android.
        //
        // ───────────────────────────────────────────────────────────────────────────
        // ⚠️ CRITICAL: Activity Lifecycle Gotcha
        // ───────────────────────────────────────────────────────────────────────────
        // configureFlutterEngine() is called when the FlutterActivity creates its
        // FlutterEngine. But Android can destroy/recreate activities (rotation,
        // memory pressure). If you store state in the Activity, it's lost!
        //
        // In this app, CastBridge is recreated each time, which is fine because
        // the GoogleCast SDK maintains session state independently via
        // SessionManager.getCurrentCastSession().
        //
        // ───────────────────────────────────────────────────────────────────────────
        // 🔍 DEBUGGING: Common Issues
        // ───────────────────────────────────────────────────────────────────────────
        // 1. "App crashes immediately on launch"
        //    → Make sure super.configureFlutterEngine() is called FIRST
        //
        // 2. "MissingPluginException on method calls"
        //    → Verify setUp is called with the correct binaryMessenger instance
        //    → Check that castBridge is not null when passed to setUp
        //
        // 3. "Methods work but callbacks don't reach Flutter"
        //    → This TODO only enables Flutter→Native. Check TODO 1 for Native→Flutter.
        //
        // ───────────────────────────────────────────────────────────────────────────
        // 🏭 PRODUCTION: Process Death
        // ───────────────────────────────────────────────────────────────────────────
        // Android may kill your process while the app is backgrounded. When user
        // returns, a NEW FlutterEngine is created. The Cast SDK handles session
        // persistence, but your Pigeon bridge needs to reconnect.
        // SessionManagerListener.onSessionResumed handles this automatically.
        //
        // ───────────────────────────────────────────────────────────────────────────
        // ✅ RESULT: After this TODO, Flutter can send commands to native.
        // ───────────────────────────────────────────────────────────────────────────
        val flutterApi = CastFlutterApi(binaryMessenger)
        val sessionManager = CastSessionManager().apply {
            registerProvider(GoogleCastProviderFactory.create(this@MainActivity))
        }
        castBridge = CastBridge(sessionManager, flutterApi)

        throw NotImplementedError("TODO 3: CastHostApi.setUp(...)")
    }

    override fun onDestroy() {
        castBridge?.dispose()
        super.onDestroy()
    }
}
