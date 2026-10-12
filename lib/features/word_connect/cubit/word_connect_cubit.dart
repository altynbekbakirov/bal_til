import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repositories.dart';
import '../../../core/audio/audio_controller.dart';

abstract class WordConnectState {}

class WordConnectLoading extends WordConnectState {}

class WordConnectPlaying extends WordConnectState {
  final List<WordGame1Pack> packs;
  final int packIndex;
  final int levelIndex;
  final WordGame1Level level;
  final Set<String> solvedWords;
  final String currentAttempt;
  final bool isCompleted;

  WordConnectPlaying({
    required this.packs,
    required this.packIndex,
    required this.levelIndex,
    required this.level,
    required this.solvedWords,
    this.currentAttempt = '',
    this.isCompleted = false,
  });

  WordConnectPlaying copyWith({
    int? packIndex,
    int? levelIndex,
    WordGame1Level? level,
    Set<String>? solvedWords,
    String? currentAttempt,
    bool? isCompleted,
  }) {
    return WordConnectPlaying(
      packs: packs,
      packIndex: packIndex ?? this.packIndex,
      levelIndex: levelIndex ?? this.levelIndex,
      level: level ?? this.level,
      solvedWords: solvedWords ?? this.solvedWords,
      currentAttempt: currentAttempt ?? this.currentAttempt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class WordConnectError extends WordConnectState {
  final String message;
  WordConnectError(this.message);
}

class WordConnectCubit extends Cubit<WordConnectState> {
  final WordGameRepository _repository = WordGameRepository();

  WordConnectCubit() : super(WordConnectLoading());

  Future<void> loadGame() async {
    emit(WordConnectLoading());
    try {
      final packs = await _repository.loadWordGame1Packs();
      if (packs.isEmpty) {
        emit(WordConnectError('Деңгээлдер табылган жок'));
        return;
      }
      _startLevel(packs: packs, packIndex: 0, levelIndex: 0);
    } catch (e) {
      emit(WordConnectError('Оюнду жүктөөдө ката чыкты: $e'));
    }
  }

  void _startLevel({
    required List<WordGame1Pack> packs,
    required int packIndex,
    required int levelIndex,
  }) {
    final pack = packs[packIndex];
    final level = pack.levels[levelIndex];
    emit(WordConnectPlaying(
      packs: packs,
      packIndex: packIndex,
      levelIndex: levelIndex,
      level: level,
      solvedWords: {},
      currentAttempt: '',
      isCompleted: false,
    ));
  }

  void updateAttempt(String word) {
    if (state is WordConnectPlaying) {
      final s = state as WordConnectPlaying;
      emit(s.copyWith(currentAttempt: word));
    }
  }

  void submitAttempt() {
    if (state is! WordConnectPlaying) return;
    final s = state as WordConnectPlaying;
    final candidate = s.currentAttempt.toLowerCase().trim();

    if (candidate.isEmpty) return;

    if (s.level.words.contains(candidate) && !s.solvedWords.contains(candidate)) {
      final newSolved = Set<String>.from(s.solvedWords)..add(candidate);
      final isAllSolved = newSolved.length >= s.level.words.length;

      if (isAllSolved) {
        AudioController.instance.playLevelComplete();
      } else {
        AudioController.instance.playWordSolved();
      }

      emit(s.copyWith(
        solvedWords: newSolved,
        currentAttempt: '',
        isCompleted: isAllSolved,
      ));
    } else {
      AudioController.instance.playWrongWord();
      emit(s.copyWith(currentAttempt: ''));
    }
  }

  void nextLevel() {
    if (state is! WordConnectPlaying) return;
    final s = state as WordConnectPlaying;
    int nextLevelIdx = s.levelIndex + 1;
    int nextPackIdx = s.packIndex;

    if (nextLevelIdx >= s.packs[nextPackIdx].levels.length) {
      nextPackIdx++;
      nextLevelIdx = 0;
    }

    if (nextPackIdx < s.packs.length) {
      _startLevel(packs: s.packs, packIndex: nextPackIdx, levelIndex: nextLevelIdx);
    }
  }
}

