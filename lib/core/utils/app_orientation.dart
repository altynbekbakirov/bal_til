import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AppOrientation {
  /// Safely switch to portrait mode.
  /// On iOS 16+, changing directly from landscape to portrait throws Code 101
  /// if the view controller does not currently declare portrait support.
  /// First allowing both orientations allows iOS to update its scene mask before
  /// locking to portrait.
  static Future<void> setPortrait() async {
    try {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    } catch (e) {
      debugPrint('Failed to change device orientation to portrait: $e');
    }
  }

  /// Safely switch to landscape mode.
  static Future<void> setLandscape() async {
    try {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
        DeviceOrientation.portraitUp,
      ]);
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } catch (e) {
      debugPrint('Failed to change device orientation to landscape: $e');
    }
  }
}
