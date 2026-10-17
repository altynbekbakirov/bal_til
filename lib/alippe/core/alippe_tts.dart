import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class AlippeTts {
  static final AlippeTts _instance = AlippeTts._internal();
  factory AlippeTts() => _instance;
  AlippeTts._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      await _flutterTts.setSpeechRate(0.45);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.05);

      final languages = await _flutterTts.getLanguages;
      if (languages is List && languages.contains('ky-KG')) {
        await _flutterTts.setLanguage('ky-KG');
      } else if (languages is List && languages.contains('ky')) {
        await _flutterTts.setLanguage('ky');
      } else if (languages is List && languages.contains('ru-RU')) {
        await _flutterTts.setLanguage('ru-RU');
      }
      _isInitialized = true;
    } catch (e) {
      debugPrint('AlippeTts init error: $e');
    }
  }

  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    try {
      if (!_isInitialized) {
        await init();
      }
      await _flutterTts.stop();
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('AlippeTts speak error: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (_) {}
  }
}
