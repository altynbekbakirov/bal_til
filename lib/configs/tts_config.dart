/// Environment configuration for the Kyrgyz TTS server.
///
/// Pass values at build/run time with:
/// `flutter run --dart-define-from-file=.env`
class TtsConfig {
  TtsConfig._();

  static const String url = String.fromEnvironment(
    'TTS_URL',
    defaultValue: 'http://185.138.184.46:5000/api/tts',
  );

  static const String token = String.fromEnvironment('TTS_TOKEN');

  static const int speaker = int.fromEnvironment(
    'TTS_SPEAKER',
    defaultValue: 4,
  );
}
