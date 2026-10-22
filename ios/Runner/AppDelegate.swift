import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FlutterViewController.enableDynamicOrientations()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  override func application(
    _ application: UIApplication,
    supportedInterfaceOrientationsFor window: UIWindow?
  ) -> UIInterfaceOrientationMask {
    return [.portrait, .landscapeLeft, .landscapeRight]
  }
}

extension FlutterViewController {
  static func enableDynamicOrientations() {
    let originalSelector = #selector(getter: UIViewController.supportedInterfaceOrientations)
    let swizzledSelector = #selector(customSupportedInterfaceOrientations)

    guard let originalMethod = class_getInstanceMethod(FlutterViewController.self, originalSelector),
          let swizzledMethod = class_getInstanceMethod(FlutterViewController.self, swizzledSelector) else {
      return
    }
    method_exchangeImplementations(originalMethod, swizzledMethod)
  }

  @objc func customSupportedInterfaceOrientations() -> UIInterfaceOrientationMask {
    return [.portrait, .landscapeLeft, .landscapeRight]
  }
}
