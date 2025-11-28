package dev.rohanjsh.pitcher

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import dev.rohanjsh.pitcher.casting.CastingFlutterApi
import dev.rohanjsh.pitcher.casting.CastingHostApi
import dev.rohanjsh.pitcher.casting.CastingHostApiImpl

class MainActivity : FlutterActivity() {

    private var castingApi: CastingHostApiImpl? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val binaryMessenger = flutterEngine.dartExecutor.binaryMessenger

        // Create Flutter API for callbacks from native to Flutter
        val flutterApi = CastingFlutterApi(binaryMessenger)

        // Create and register the Host API implementation
        castingApi = CastingHostApiImpl(this, flutterApi)
        CastingHostApi.setUp(binaryMessenger, castingApi)
    }

    override fun onDestroy() {
        castingApi?.dispose()
        super.onDestroy()
    }
}
