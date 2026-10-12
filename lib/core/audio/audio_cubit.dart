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

  AudioCubit() : super(const AudioState(isMusicEnabled: true, isSoundEnabled: true)) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final music = prefs.getBool('music_enabled') ?? true;
    final sound = prefs.getBool('sound_enabled') ?? true;
    _controller.isMusicEnabled = music;
    _controller.isSoundEnabled = sound;
    emit(AudioState(isMusicEnabled: music, isSoundEnabled: sound));
    if (music) {
      _controller.playMenuMusic();
    }
  }

  Future<void> toggleMusic() async {
    final newValue = !state.isMusicEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('music_enabled', newValue);
    _controller.toggleMusic(newValue);
    emit(state.copyWith(isMusicEnabled: newValue));
  }

  Future<void> toggleSound() async {
    final newValue = !state.isSoundEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', newValue);
    _controller.toggleSound(newValue);
    emit(state.copyWith(isSoundEnabled: newValue));
  }
}

