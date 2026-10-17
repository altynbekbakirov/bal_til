import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
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
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      await _bgmPlayer.setLoopMode(LoopMode.one);
    } catch (_) {}
  }

  Future<void> playMenuMusic() async {
    if (!isMusicEnabled) return;
    try {
      await _bgmPlayer.setLoopMode(LoopMode.one);
      await _bgmPlayer.setAsset(AssetPaths.menuMusic);
      await _bgmPlayer.play();
    } catch (_) {}
  }

  Future<void> playGameplayMusic() async {
    if (!isMusicEnabled) return;
    try {
      await _bgmPlayer.setLoopMode(LoopMode.one);
      await _bgmPlayer.setAsset(AssetPaths.gameplayMusic);
      await _bgmPlayer.play();
    } catch (_) {}
  }

  Future<void> stopMenuMusic() async {
    try {
      await _bgmPlayer.stop();
    } catch (_) {}
  }

  Future<void> stopGameplayMusic() async => stopMenuMusic();

  Future<void> playSfx(String assetPath) async {
    if (!isSoundEnabled) return;
    try {
      await _sfxPlayer.setAsset(assetPath);
      await _sfxPlayer.play();
    } catch (_) {}
  }

  Future<void> playButtonClick() async => playSfx(AssetPaths.clickSound);
  Future<void> playLetterSelect() async => playSfx(AssetPaths.letterSelect);
  Future<void> playWordSolved() async => playSfx(AssetPaths.wordSolved);
  Future<void> playWrongWord() async => playSfx(AssetPaths.wrongWord);
  Future<void> playLevelComplete() async => playSfx(AssetPaths.levelComplete);
  Future<void> playHint() async => playSfx(AssetPaths.hintSound);
  Future<void> playShuffle() async => playSfx(AssetPaths.shuffleSound);

  bool _isAnthemLoaded = false;

  Future<void> playAnthem() async {
    try {
      await stopMenuMusic();
      if (!_isAnthemLoaded) {
        await _anthemPlayer.setAsset(AssetPaths.anthem);
        _isAnthemLoaded = true;
      }
      if (_anthemPlayer.processingState == ProcessingState.completed) {
        await _anthemPlayer.seek(Duration.zero);
      }
      await _anthemPlayer.play();
    } catch (e) {
      _isAnthemLoaded = false;
      debugPrint('Error playing anthem: $e');
    }
  }

  Future<void> pauseAnthem() async {
    try {
      await _anthemPlayer.pause();
    } catch (_) {}
  }

  Future<void> stopAnthem() async {
    try {
      await _anthemPlayer.stop();
      await _anthemPlayer.seek(Duration.zero);
    } catch (_) {}
  }

  Future<void> seekAnthem(Duration position) async {
    try {
      await _anthemPlayer.seek(position);
    } catch (_) {}
  }

  Stream<PlayerState> get anthemPlayerStateStream => _anthemPlayer.playerStateStream;
  Stream<Duration> get anthemPositionStream => _anthemPlayer.positionStream;
  Stream<Duration?> get anthemDurationStream => _anthemPlayer.durationStream;
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
