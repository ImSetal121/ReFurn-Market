import Flutter
import UIKit
import GoogleMaps  // Add this import

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Add your Google Maps API key
    GMSServices.provideAPIKey("AIzaSyC7XN5Ai6ZkIiAi0HmVjP17obnzFINbCNE")

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
