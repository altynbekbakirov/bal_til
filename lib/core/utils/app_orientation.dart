import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AppOrientation {
  static bool _isLandscape = false;

  /// Returns true if the app has requested landscape orientation.
  static bool get isLandscape => _isLandscape;

  /// Lock exclusively to portrait mode without switching through landscape.
  static Future<void> setPortrait() async {
    if (!_isLandscape) return;
    _isLandscape = false;
    try {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    } catch (e) {
      debugPrint('Failed to change device orientation to portrait: $e');
    }
  }

  /// Lock exclusively to landscape mode without switching through portrait.
  static Future<void> setLandscape() async {
    if (_isLandscape) return;
    _isLandscape = true;
    try {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } catch (e) {
      debugPrint('Failed to change device orientation to landscape: $e');
    }
  }

  /// Force orientation lock to portrait regardless of current cached state.
  static Future<void> forcePortrait() async {
    _isLandscape = false;
    try {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    } catch (e) {
      debugPrint('Failed to change device orientation to portrait: $e');
    }
  }

  /// Force orientation lock to landscape regardless of current cached state.
  static Future<void> forceLandscape() async {
    _isLandscape = true;
    try {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } catch (e) {
      debugPrint('Failed to change device orientation to landscape: $e');
    }
  }
}
