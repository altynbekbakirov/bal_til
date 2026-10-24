import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'alippe_audio.dart';

class AlippeState {
  final double musValue;
  final double sndValue;
  final bool boyActive;
  final List<int> scores;
  final int lastSection;

  const AlippeState({
    this.musValue = 0.7,
    this.sndValue = 0.7,
    this.boyActive = true,
    this.scores = const [0, 0, 0, 0, 0, 0],
    this.lastSection = 0,
  });

  AlippeState copyWith({
    double? musValue,
    double? sndValue,
    bool? boyActive,
    List<int>? scores,
    int? lastSection,
  }) {
    return AlippeState(
      musValue: musValue ?? this.musValue,
      sndValue: sndValue ?? this.sndValue,
      boyActive: boyActive ?? this.boyActive,
      scores: scores ?? this.scores,
      lastSection: lastSection ?? this.lastSection,
    );
  }
}

class AlippeCubit extends Cubit<AlippeState> {
  AlippeCubit() : super(const AlippeState());

  static const _keyMusValue = 'alippe_mus_value';
  static const _keySndValue = 'alippe_snd_value';
  static const _keyMusicEnabled = 'alippe_music_enabled';
  static const _keySoundEnabled = 'alippe_sound_enabled';
  static const _keyBoyActive = 'alippe_boy_active';
  static const _keyScores = 'alippe_scores';
  static const _keyLastSection = 'alippe_last_section';

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final musicEnabled = prefs.getBool(_keyMusicEnabled) ?? true;
    final soundEnabled = prefs.getBool(_keySoundEnabled) ?? true;
    final savedMus = prefs.getDouble(_keyMusValue) ?? 0.7;
    final savedSnd = prefs.getDouble(_keySndValue) ?? 0.7;

    final mus = musicEnabled ? (savedMus > 0.05 ? savedMus : 0.7) : 0.0;
    final snd = soundEnabled ? (savedSnd > 0.05 ? savedSnd : 0.7) : 0.0;

    final boy = prefs.getBool(_keyBoyActive) ?? true;
    final lastSec = prefs.getInt(_keyLastSection) ?? 0;
    final scoresRaw = prefs.getStringList(_keyScores);

    List<int> loadedScores = [0, 0, 0, 0, 0, 0];
    if (scoresRaw != null && scoresRaw.length == 6) {
      loadedScores = scoresRaw.map((e) => int.tryParse(e) ?? 0).toList();
    }

    AlippeAudio().isMusicEnabled = musicEnabled;
    AlippeAudio().isSoundEnabled = soundEnabled;
    AlippeAudio().setMusicVolume(mus);
    AlippeAudio().setSoundVolume(snd);

    emit(state.copyWith(
      musValue: mus,
      sndValue: snd,
      boyActive: boy,
      scores: loadedScores,
      lastSection: lastSec,
    ));
  }

  Future<void> setMusValue(double val) async {
    final clamped = val.clamp(0.0, 1.0);
    final isEnabled = clamped > 0.05;

    AlippeAudio().isMusicEnabled = isEnabled;
    await AlippeAudio().setMusicVolume(clamped);

    emit(state.copyWith(musValue: clamped));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyMusValue, clamped);
    await prefs.setBool(_keyMusicEnabled, isEnabled);
  }

  Future<void> setSndValue(double val) async {
    final clamped = val.clamp(0.0, 1.0);
    final isEnabled = clamped > 0.05;

    AlippeAudio().isSoundEnabled = isEnabled;
    AlippeAudio().setSoundVolume(clamped);

    emit(state.copyWith(sndValue: clamped));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keySndValue, clamped);
    await prefs.setBool(_keySoundEnabled, isEnabled);
  }

  Future<void> setBoyActive(bool boy) async {
    emit(state.copyWith(boyActive: boy));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBoyActive, boy);
  }

  Future<void> setLastSection(int sectionId) async {
    emit(state.copyWith(lastSection: sectionId));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLastSection, sectionId);
  }

  Future<void> addScore(int bookId, int stars) async {
    if (bookId < 0 || bookId >= 6) return;
    final newScores = List<int>.from(state.scores);
    final current = newScores[bookId];
    if (stars > current) {
      newScores[bookId] = stars.clamp(0, 3);
      emit(state.copyWith(scores: newScores));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _keyScores,
        newScores.map((e) => e.toString()).toList(),
      );
    }
  }

  Future<void> resetScores() async {
    final newScores = [0, 0, 0, 0, 0, 0];
    emit(state.copyWith(scores: newScores, lastSection: 0));
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyScores);
    await prefs.remove(_keyLastSection);
  }
}
