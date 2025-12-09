import Flutter
import GoogleCast
import UIKit

/// Default Media Receiver Application ID.
/// Use this for workshop demos. For production, register your own at:
/// https://cast.google.com/publish
private let kReceiverAppID = kGCKDefaultMediaReceiverApplicationID

@main
@objc class AppDelegate: FlutterAppDelegate {

    /// Holds a reference to prevent deallocation.
    private var castBridge: CastBridge?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // ════════════════════════════════════════════════════════════════════════
        // MARK: Step 1 - Initialize Google Cast SDK (must be first!)
        // ════════════════════════════════════════════════════════════════════════

        let castOptions = GCKCastOptions(discoveryCriteria: GCKDiscoveryCriteria(applicationID: kReceiverAppID))
        castOptions.physicalVolumeButtonsWillControlDeviceVolume = true
        GCKCastContext.setSharedInstanceWith(castOptions)

        // Enable Cast SDK logging for debugging (remove in production)
        GCKLogger.sharedInstance().delegate = self

        // ════════════════════════════════════════════════════════════════════════
        // MARK: Step 2 - Register Pigeon API (New Architecture)
        // ════════════════════════════════════════════════════════════════════════

        let controller = window?.rootViewController as! FlutterViewController
        let binaryMessenger = controller.binaryMessenger

        let flutterApi = CastFlutterApi(binaryMessenger: binaryMessenger)
        castBridge = CastBridge(
            flutterApi: flutterApi,
            castContext: GCKCastContext.sharedInstance()
        )
        CastHostApiSetup.setUp(binaryMessenger: binaryMessenger, api: castBridge)

        // ════════════════════════════════════════════════════════════════════════
        // MARK: Step 3 - Register Flutter plugins
        // ════════════════════════════════════════════════════════════════════════

        GeneratedPluginRegistrant.register(with: self)

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    override func applicationWillTerminate(_ application: UIApplication) {
        castBridge?.dispose()
    }
}

// ════════════════════════════════════════════════════════════════════════════════
// MARK: - GCKLoggerDelegate (Debug Logging)
// ════════════════════════════════════════════════════════════════════════════════

extension AppDelegate: GCKLoggerDelegate {

    func logMessage(
        _ message: String,
        at level: GCKLoggerLevel,
        fromFunction function: String,
        location: String
    ) {
        // Only log warnings and errors in debug builds
        #if DEBUG
        if level.rawValue >= GCKLoggerLevel.warning.rawValue {
            print("[GoogleCast] \(function): \(message)")
        }
        #endif
    }
}
