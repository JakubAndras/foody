import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var backgroundTaskId: UIBackgroundTaskIdentifier = .invalid

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)

    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(name: "com.foody/background_task", binaryMessenger: controller.binaryMessenger)
      channel.setMethodCallHandler { [weak self] (call, channelResult) in
        guard let self = self else { channelResult(nil); return }
        switch call.method {
        case "beginBackgroundTask":
          if self.backgroundTaskId == .invalid {
            self.backgroundTaskId = UIApplication.shared.beginBackgroundTask {
              UIApplication.shared.endBackgroundTask(self.backgroundTaskId)
              self.backgroundTaskId = .invalid
            }
          }
          channelResult(nil)
        case "endBackgroundTask":
          if self.backgroundTaskId != .invalid {
            UIApplication.shared.endBackgroundTask(self.backgroundTaskId)
            self.backgroundTaskId = .invalid
          }
          channelResult(nil)
        default:
          channelResult(FlutterMethodNotImplemented)
        }
      }
    }

    return result
  }
}
