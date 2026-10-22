import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  @objc(windowScene:supportedInterfaceOrientationsForWindow:)
  func windowScene(
    _ windowScene: UIWindowScene,
    supportedInterfaceOrientationsFor window: UIWindow?
  ) -> UIInterfaceOrientationMask {
    return [.portrait, .landscapeLeft, .landscapeRight]
  }
}
