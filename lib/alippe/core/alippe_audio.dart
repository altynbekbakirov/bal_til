import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'alippe_constants.dart';

class AlippeAudio {
  static final AlippeAudio _instance = AlippeAudio._internal();
  factory AlippeAudio() => _instance;
  AlippeAudio._internal();

  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  double _musicVolume = 0.5;
  double _soundVolume = 0.5;
  bool _isMusicInitialized = false;

  double get musicVolume => _musicVolume;
  double get soundVolume => _soundVolume;

  Future<void> init() async {
    try {
      await _musicPlayer.setAsset(AlippeAssets.audioBgMusic);
      await _musicPlayer.setLoopMode(LoopMode.all);
      await _musicPlayer.setVolume(_musicVolume);
      _isMusicInitialized = true;
    } catch (e) {
      debugPrint('Alippe audio music init error: $e');
    }
  }

  Future<void> startMusic() async {
    try {
      if (!_isMusicInitialized) {
        await init();
      }
      if (!_musicPlayer.playing && _musicVolume > 0) {
        await _musicPlayer.play();
      }
    } catch (e) {
      debugPrint('Error starting music: $e');
    }
  }

  Future<void> stopMusic() async {
    try {
      await _musicPlayer.stop();
    } catch (e) {
      debugPrint('Error stopping music: $e');
    }
  }

  Future<void> pauseMusic() async {
    try {
      await _musicPlayer.pause();
    } catch (e) {
      debugPrint('Error pausing music: $e');
    }
  }

  Future<void> resumeMusic() async {
    try {
      if (_musicVolume > 0) {
        await _musicPlayer.play();
      }
    } catch (e) {
      debugPrint('Error resuming music: $e');
    }
  }

  Future<void> setMusicVolume(double volume) async {
    _musicVolume = volume.clamp(0.0, 1.0);
    try {
      await _musicPlayer.setVolume(_musicVolume);
      if (_musicVolume > 0 && !_musicPlayer.playing) {
        await _musicPlayer.play();
      } else if (_musicVolume == 0 && _musicPlayer.playing) {
        await _musicPlayer.pause();
      }
    } catch (e) {
      debugPrint('Error setting music volume: $e');
    }
  }

  void setSoundVolume(double volume) {
    _soundVolume = volume.clamp(0.0, 1.0);
  }

  Future<void> playSfx(String assetPath) async {
    if (_soundVolume <= 0) return;
    try {
      await _sfxPlayer.setAsset(assetPath);
      await _sfxPlayer.setVolume(_soundVolume);
      await _sfxPlayer.play();
    } catch (e) {
      debugPrint('Error playing SFX ($assetPath): $e');
    }
  }

  void playTap() => playSfx(AlippeAssets.audioTap);
  void playBell() => playSfx(AlippeAssets.audioBell);
  void playFail() => playSfx(AlippeAssets.audioFail);
  void playGood() => playSfx(AlippeAssets.audioGood);
  void playNext() => playSfx(AlippeAssets.audioNext);
  void playFlipCard() => playSfx(AlippeAssets.audioFlipCard);
  void playPickUp() => playSfx(AlippeAssets.audioPickUp);
  void playPickUp2() => playSfx(AlippeAssets.audioPickUp2);
  void playFinish() => playSfx(AlippeAssets.audioFinishMusic);
  void playReset() => playSfx(AlippeAssets.audioReset);
  void playSuccessPin() => playSfx(AlippeAssets.audioSuccessPin);
  void playBackSwoosh() => playSfx(AlippeAssets.audioBackSwoosh);

  void dispose() {
    _musicPlayer.dispose();
    _sfxPlayer.dispose();
  }
}
