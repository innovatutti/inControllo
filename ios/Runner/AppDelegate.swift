import Flutter
import UIKit
import FamilyControls

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    let controller = window?.rootViewController as! FlutterViewController
    let deviceAdminChannel = FlutterMethodChannel(
      name: "com.incontrollo.parental_control_v2/device_admin",
      binaryMessenger: controller.binaryMessenger
    )
    
    deviceAdminChannel.setMethodCallHandler { [weak self] (call, result) in
      switch call.method {
      case "hasScreenTimePermission":
        self?.checkScreenTimePermission(result: result)
      case "requestScreenTimePermission":
        self?.requestScreenTimePermission(result: result)
      case "blockApp":
        result(FlutterError(code: "UNAVAILABLE", message: "iOS non supporta il blocco diretto delle app", details: nil))
      case "unblockApp":
        result(FlutterError(code: "UNAVAILABLE", message: "iOS non supporta lo sblocco diretto delle app", details: nil))
      case "getInstalledApps":
        result(FlutterError(code: "UNAVAILABLE", message: "iOS non permette di listare le app installate", details: nil))
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func checkScreenTimePermission(result: @escaping FlutterResult) {
    if #available(iOS 15.0, *) {
      let center = AuthorizationCenter.shared
      let status = center.authorizationStatus
      result(status == .approved)
    } else {
      result(false)
    }
  }
  
  private func requestScreenTimePermission(result: @escaping FlutterResult) {
    if #available(iOS 15.0, *) {
      Task {
        do {
          try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
          result(nil)
        } catch {
          result(FlutterError(code: "PERMISSION_DENIED", message: error.localizedDescription, details: nil))
        }
      }
    } else {
      result(FlutterError(code: "UNAVAILABLE", message: "Screen Time richiede iOS 15+", details: nil))
    }
  }
}

