import Flutter
import GoogleCast
import UIKit


private let kReceiverAppID = kGCKDefaultMediaReceiverApplicationID

@main
@objc class AppDelegate: FlutterAppDelegate {

    private var castBridge: CastBridge?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        let castOptions = GCKCastOptions(discoveryCriteria: GCKDiscoveryCriteria(applicationID: kReceiverAppID))
        castOptions.physicalVolumeButtonsWillControlDeviceVolume = true
        GCKCastContext.setSharedInstanceWith(castOptions)

        GCKLogger.sharedInstance().delegate = self

        let registrar = self.registrar(forPlugin: "CastBridge")!
        let binaryMessenger = registrar.messenger()

        // ╔═══════════════════════════════════════════════════════════════════════╗
        // ║  TODO 2: Complete the Pigeon bridge setup - iOS (1 line)              ║
        // ╚═══════════════════════════════════════════════════════════════════════╝
        //
        // 👉 ADD: CastHostApiSetup.setUp(binaryMessenger: binaryMessenger, api: castBridge)
        //
        // ───────────────────────────────────────────────────────────────────────────
        // 📚 CONCEPT: The "Host" in HostApi
        // ───────────────────────────────────────────────────────────────────────────
        // In Pigeon terminology:
        //   • "Host" = the native platform (iOS/Android) that "hosts" the Flutter engine
        //   • "Flutter" = the Dart side
        //
        // CastHostApiSetup.setUp() registers your Swift class (CastBridge) as the
        // handler for incoming method channel calls FROM Flutter. When Flutter
        // calls _hostApi.startDiscovery(), it travels through:
        //
        //   Flutter → MethodChannel → iOS → CastHostApiSetup → CastBridge.startDiscovery()
        //
        // ───────────────────────────────────────────────────────────────────────────
        // ⚠️ CRITICAL: Timing Matters!
        // ───────────────────────────────────────────────────────────────────────────
        // This setUp MUST happen in application(_:didFinishLaunchingWithOptions:)
        // BEFORE returning. If you defer it (e.g., DispatchQueue.async), Flutter
        // may call methods before the handler is registered, causing:
        //   "MissingPluginException: No implementation found for method X"
        //
        // ───────────────────────────────────────────────────────────────────────────
        // 🔍 DEBUGGING: If Flutter calls fail with MissingPluginException
        // ───────────────────────────────────────────────────────────────────────────
        // 1. Verify setUp is called synchronously in didFinishLaunching
        // 2. Ensure binaryMessenger is from the correct registrar
        // 3. Check the channel names match between generated code and Pigeon spec
        //
        // ───────────────────────────────────────────────────────────────────────────
        // 🏭 PRODUCTION: The optional `api` parameter
        // ───────────────────────────────────────────────────────────────────────────
        // Passing `nil` to setUp() UNREGISTERS the handler. Useful for cleanup
        // or hot restart scenarios. In this app, we never unregister.
        //
        // ───────────────────────────────────────────────────────────────────────────
        // ✅ RESULT: After this TODO, Flutter can send commands to native.
        //    Tapping "Start Discovery" will work, but devices won't appear yet.
        // ───────────────────────────────────────────────────────────────────────────
        let flutterApi = CastFlutterApi(binaryMessenger: binaryMessenger)
        castBridge = CastBridge(flutterApi: flutterApi, castContext: GCKCastContext.sharedInstance())

        fatalError("TODO 2: CastHostApiSetup.setUp(...)")

        GeneratedPluginRegistrant.register(with: self)

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    override func applicationWillTerminate(_ application: UIApplication) {
        castBridge?.dispose()
    }
}

extension AppDelegate: GCKLoggerDelegate {

    func logMessage(
        _ message: String,
        at level: GCKLoggerLevel,
        fromFunction function: String,
        location: String
    ) {
        #if DEBUG
        if level.rawValue >= GCKLoggerLevel.warning.rawValue {
            print("[GoogleCast] \(function): \(message)")
        }
        #endif
    }
}
