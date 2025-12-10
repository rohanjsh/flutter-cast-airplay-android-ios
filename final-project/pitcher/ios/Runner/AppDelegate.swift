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

        let flutterApi = CastFlutterApi(binaryMessenger: binaryMessenger)
        castBridge = CastBridge(
            flutterApi: flutterApi,
            castContext: GCKCastContext.sharedInstance()
        )
        CastHostApiSetup.setUp(binaryMessenger: binaryMessenger, api: castBridge)

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
