import 'package:just_audio/just_audio.dart';
import '../utils/asset_paths.dart';

class AudioController {
  static final AudioController instance = AudioController._internal();
  AudioController._internal() {
    init();
  }

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _anthemPlayer = AudioPlayer();

  bool isMusicEnabled = true;
  bool isSoundEnabled = true;

  Future<void> init() async {
    try {
      await _bgmPlayer.setLoopMode(LoopMode.one);
    } catch (_) {}
  }

  Future<void> playMenuMusic() async {
    if (!isMusicEnabled) return;
    try {
      await _bgmPlayer.setAsset(AssetPaths.menuMusic);
      await _bgmPlayer.play();
    } catch (_) {}
  }

  Future<void> stopMenuMusic() async {
    try {
      await _bgmPlayer.stop();
    } catch (_) {}
  }

  Future<void> playSfx(String assetPath) async {
    if (!isSoundEnabled) return;
    try {
      await _sfxPlayer.setAsset(assetPath);
      await _sfxPlayer.play();
    } catch (_) {}
  }

  Future<void> playButtonClick() async {
    await playSfx(AssetPaths.clickSound);
  }

  Future<void> playLetterSelect() async {
    await playSfx(AssetPaths.letterSelect);
  }

  Future<void> playWordSolved() async {
    await playSfx(AssetPaths.wordSolved);
  }

  Future<void> playWrongWord() async {
    await playSfx(AssetPaths.wrongWord);
  }

  Future<void> playLevelComplete() async {
    await playSfx(AssetPaths.levelComplete);
  }

  Future<void> playAnthem() async {
    try {
      await stopMenuMusic();
      await _anthemPlayer.setAsset(AssetPaths.anthem);
      await _anthemPlayer.play();
    } catch (_) {}
  }

  Future<void> pauseAnthem() async {
    try {
      await _anthemPlayer.pause();
    } catch (_) {}
  }

  Future<void> stopAnthem() async {
    try {
      await _anthemPlayer.stop();
    } catch (_) {}
  }

  Stream<PlayerState> get anthemPlayerStateStream => _anthemPlayer.playerStateStream;
  Stream<Duration> get anthemPositionStream => _anthemPlayer.positionStream;
  Duration? get anthemDuration => _anthemPlayer.duration;

  void toggleMusic(bool enabled) {
    isMusicEnabled = enabled;
    if (!enabled) {
      stopMenuMusic();
    } else {
      playMenuMusic();
    }
  }

  void toggleSound(bool enabled) {
    isSoundEnabled = enabled;
  }

  void dispose() {
    _bgmPlayer.dispose();
    _sfxPlayer.dispose();
    _anthemPlayer.dispose();
  }
}
