import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'alippe_constants.dart';

class AlippeAudio {
  static final AlippeAudio _instance = AlippeAudio._internal();
  factory AlippeAudio() => _instance;
  AlippeAudio._internal();

  final AudioPlayer _musicPlayer = AudioPlayer();
  final List<AudioPlayer> _sfxPlayers = List.generate(4, (_) => AudioPlayer());
  int _currentSfxIndex = 0;

  double _musicVolume = 0.7;
  double _soundVolume = 0.7;
  bool _isMusicInitialized = false;

  bool isMusicEnabled = true;
  bool isSoundEnabled = true;
  bool isAlippeActive = false;

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
    if (!isMusicEnabled || !isAlippeActive || _musicVolume <= 0) return;
    try {
      if (!_isMusicInitialized) {
        await init();
      }
      if (!_musicPlayer.playing) {
        await _musicPlayer.setVolume(_musicVolume);
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

  Future<void> stopAll() async {
    try {
      await _musicPlayer.stop();
      for (final p in _sfxPlayers) {
        await p.stop();
      }
    } catch (e) {
      debugPrint('Error stopping all audio in Alippe: $e');
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
    if (!isMusicEnabled || !isAlippeActive || _musicVolume <= 0) return;
    try {
      await _musicPlayer.setVolume(_musicVolume);
      await _musicPlayer.play();
    } catch (e) {
      debugPrint('Error resuming music: $e');
    }
  }

  Future<void> setMusicEnabled(bool enabled) async {
    isMusicEnabled = enabled;
    if (!enabled) {
      await stopMusic();
    } else if (isAlippeActive) {
      if (_musicVolume <= 0.05) _musicVolume = 0.7;
      resumeMusic();
    }
  }

  void setSoundEnabled(bool enabled) {
    isSoundEnabled = enabled;
    if (!enabled) {
      for (final p in _sfxPlayers) {
        try {
          p.stop();
        } catch (_) {}
      }
    } else if (_soundVolume <= 0.05) {
      _soundVolume = 0.7;
    }
  }

  Future<void> setMusicVolume(double volume) async {
    _musicVolume = volume.clamp(0.0, 1.0);
    isMusicEnabled = _musicVolume > 0.05;
    try {
      _musicPlayer.setVolume(_musicVolume);
      if (isMusicEnabled && !_musicPlayer.playing) {
        _musicPlayer.play();
      } else if (!isMusicEnabled && _musicPlayer.playing) {
        _musicPlayer.pause();
      }
    } catch (e) {
      debugPrint('Error setting music volume: $e');
    }
  }

  void setSoundVolume(double volume) {
    _soundVolume = volume.clamp(0.0, 1.0);
    isSoundEnabled = _soundVolume > 0.05;
    if (!isSoundEnabled) {
      for (final p in _sfxPlayers) {
        try {
          p.stop();
        } catch (_) {}
      }
    } else {
      for (final p in _sfxPlayers) {
        try {
          p.setVolume(_soundVolume);
        } catch (_) {}
      }
    }
  }

  Future<void> playSfx(String assetPath) async {
    if (!isSoundEnabled || _soundVolume <= 0) return;
    try {
      final player = _sfxPlayers[_currentSfxIndex];
      _currentSfxIndex = (_currentSfxIndex + 1) % _sfxPlayers.length;
      await player.setAsset(assetPath);
      await player.seek(Duration.zero);
      await player.setVolume(_soundVolume);
      player.play();
    } catch (e) {
      // Loading interruptions can happen during rapid successive clicks; ignore safely
      if (!e.toString().contains('interrupted')) {
        debugPrint('Notice playing SFX ($assetPath): $e');
      }
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
    for (final p in _sfxPlayers) {
      p.dispose();
    }
  }
}
