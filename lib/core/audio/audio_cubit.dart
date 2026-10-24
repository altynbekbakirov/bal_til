import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'audio_controller.dart';

class AudioState {
  final bool isMusicEnabled;
  final bool isSoundEnabled;

  const AudioState({
    required this.isMusicEnabled,
    required this.isSoundEnabled,
  });

  AudioState copyWith({bool? isMusicEnabled, bool? isSoundEnabled}) {
    return AudioState(
      isMusicEnabled: isMusicEnabled ?? this.isMusicEnabled,
      isSoundEnabled: isSoundEnabled ?? this.isSoundEnabled,
    );
  }
}

class AudioCubit extends Cubit<AudioState> {
  final AudioController _controller = AudioController.instance;
  Future<void>? _loadingFuture;

  AudioCubit() : super(const AudioState(isMusicEnabled: true, isSoundEnabled: true)) {
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    if (_loadingFuture != null) {
      await _loadingFuture;
    }
    _loadingFuture = _loadPreferencesInternal();
    await _loadingFuture;
  }

  Future<void> _loadPreferencesInternal() async {
    final prefs = await SharedPreferences.getInstance();
    final music = prefs.getBool('music_enabled') ?? true;
    final sound = prefs.getBool('sound_enabled') ?? true;

    _controller.isMusicEnabled = music;
    _controller.isSoundEnabled = sound;

    if (!music) {
      _controller.stopMenuMusic();
      _controller.stopGameplayMusic();
    }

    emit(AudioState(isMusicEnabled: music, isSoundEnabled: sound));
  }

  Future<void> toggleMusic() async {
    if (_loadingFuture != null) await _loadingFuture;
    final newValue = !state.isMusicEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('music_enabled', newValue);

    _controller.toggleMusic(newValue);

    emit(state.copyWith(isMusicEnabled: newValue));
  }

  Future<void> toggleSound() async {
    if (_loadingFuture != null) await _loadingFuture;
    final newValue = !state.isSoundEnabled;
    _controller.toggleSound(newValue);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', newValue);

    emit(state.copyWith(isSoundEnabled: newValue));
  }
}
