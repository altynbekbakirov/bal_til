import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/alippe_data.dart';
import 'alippe_audio.dart';

class AlippeState {
  final double musValue;
  final double sndValue;
  final bool boyActive;
  final List<int> scores;
  final int lastSection;
  final List<int> completedSections;

  const AlippeState({
    this.musValue = 0.7,
    this.sndValue = 0.7,
    this.boyActive = true,
    this.scores = const [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    this.lastSection = 0,
    this.completedSections = const [],
  });

  AlippeState copyWith({
    double? musValue,
    double? sndValue,
    bool? boyActive,
    List<int>? scores,
    int? lastSection,
    List<int>? completedSections,
  }) {
    return AlippeState(
      musValue: musValue ?? this.musValue,
      sndValue: sndValue ?? this.sndValue,
      boyActive: boyActive ?? this.boyActive,
      scores: scores ?? this.scores,
      lastSection: lastSection ?? this.lastSection,
      completedSections: completedSections ?? this.completedSections,
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
  static const _keyCompletedSections = 'alippe_completed_sections';

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

    List<int> loadedScores = List.filled(12, 0);
    if (scoresRaw != null) {
      for (int i = 0; i < scoresRaw.length && i < 12; i++) {
        loadedScores[i] = int.tryParse(scoresRaw[i]) ?? 0;
      }
    }

    final completedRaw = prefs.getStringList(_keyCompletedSections);
    final Set<int> completedSet = {};
    if (completedRaw != null) {
      for (final s in completedRaw) {
        final parsed = int.tryParse(s);
        if (parsed != null) completedSet.add(parsed);
      }
    } else {
      // Derive completed sections from existing scores for backward-compatibility
      if (loadedScores[0] >= 3) { completedSet.add(0); completedSet.add(1); }
      else if (loadedScores[0] >= 1) { completedSet.add(0); }

      if (loadedScores[1] >= 3) { completedSet.add(2); completedSet.add(3); }
      else if (loadedScores[1] >= 1) { completedSet.add(2); }

      if (loadedScores[2] >= 3) { completedSet.add(4); completedSet.add(5); }
      else if (loadedScores[2] >= 1) { completedSet.add(4); }

      if (loadedScores[3] >= 3) { completedSet.add(6); completedSet.add(7); }
      else if (loadedScores[3] >= 1) { completedSet.add(6); }

      if (loadedScores[4] >= 3) { completedSet.add(8); completedSet.add(9); }
      else if (loadedScores[4] >= 2) { completedSet.add(8); }

      if (loadedScores[5] >= 3) { completedSet.add(10); completedSet.add(12); }
      else if (loadedScores[5] >= 1) { completedSet.add(10); }

      if (loadedScores[6] >= 3) { completedSet.add(11); }
    }

    final loadedCompleted = completedSet.toList()..sort();

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
      completedSections: loadedCompleted,
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
    if (bookId < 0 || bookId >= 12) return;
    final newScores = List<int>.from(state.scores);
    while (newScores.length < 12) {
      newScores.add(0);
    }
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

  Future<void> completeSection(int sectionId) async {
    final newCompleted = Set<int>.from(state.completedSections)..add(sectionId);
    final list = newCompleted.toList()..sort();
    emit(state.copyWith(completedSections: list));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _keyCompletedSections,
      list.map((e) => e.toString()).toList(),
    );
  }

  bool isSectionCompleted(int sectionId) {
    return state.completedSections.contains(sectionId);
  }

  bool isBookUnlocked(int bookId) {
    if (bookId == 0) return true;
    if (bookId > 0 && bookId < state.scores.length) {
      return state.scores[bookId - 1] >= 3 || state.scores[bookId] > 0;
    }
    return false;
  }

  bool isSectionUnlocked(int sectionId) {
    if (sectionId < 0) return false;
    final bookId = AlippeData.getBookIdForSection(sectionId);
    if (!isBookUnlocked(bookId)) return false;

    // For all multi-section books: Section 2 is locked until Section 1 is completed
    if (bookId < AlippeData.books.length) {
      final book = AlippeData.books[bookId];
      if (book.section2Id == sectionId) {
        return isSectionCompleted(book.section1Id);
      }
    }
    return true;
  }

  Future<void> resetScores() async {
    final newScores = List.filled(12, 0);
    emit(state.copyWith(
      scores: newScores,
      lastSection: 0,
      completedSections: const [],
    ));
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyScores);
    await prefs.remove(_keyLastSection);
    await prefs.remove(_keyCompletedSections);
  }
}
