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
        val flutterApi = CastFlutterApi(binaryMessenger)

        val sessionManager = CastSessionManager().apply {
            registerProvider(GoogleCastProviderFactory.create(this@MainActivity))
            // Future: registerProvider(DlnaProviderFactory.create(this@MainActivity))
        }
        
        castBridge = CastBridge(sessionManager, flutterApi)
        CastHostApi.setUp(binaryMessenger, castBridge)
    }

    override fun onDestroy() {
        castBridge?.dispose()
        super.onDestroy()
    }
}
