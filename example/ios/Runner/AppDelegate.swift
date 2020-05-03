import UIKit
import Flutter
import DP3TSDK

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // Initialize DP3T:
    do {
      try DP3TTracing.initialize(with: .manual(.init(
        appId: "dummy",
        bucketBaseUrl: URL(string: "https://example.com")!,
        reportBaseUrl: URL(string: "https://example.com")!,
        jwtPublicKey: nil
      )))
    } catch {
      // do nothing
    }

    // Do the rest..

    GeneratedPluginRegistrant.register(with: self)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
