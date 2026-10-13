import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repositories.dart';
import '../../../data/repositories/score_repository.dart';
import '../../../core/audio/audio_controller.dart';

enum FeedbackType { none, success, warning, error }

class WordFeedback {
  final String text;
  final FeedbackType type;
  const WordFeedback({this.text = '', this.type = FeedbackType.none});
}

abstract class WordConnectState {}

class WordConnectLoading extends WordConnectState {}

class WordConnectPlaying extends WordConnectState {
  static const int maxHintsPerLevel = 3;

  final List<WordGame1Pack> packs;
  final int packIndex;
  final int levelIndex;
  final WordGame1Level level;
  final List<String> currentLetters;
  final Set<String> solvedWords;
  final Map<String, Set<int>> hintedLetters;
  final String currentAttempt;
  final WordFeedback feedback;
  final bool isCompleted;
  final int hintsUsed;
  final int starsEarned;
  final int levelScore;
  final int totalScore;
  final int totalStars;

  WordConnectPlaying({
    required this.packs,
    required this.packIndex,
    required this.levelIndex,
    required this.level,
    required this.currentLetters,
    required this.solvedWords,
    this.hintedLetters = const {},
    this.currentAttempt = '',
    this.feedback = const WordFeedback(),
    this.isCompleted = false,
    this.hintsUsed = 0,
    this.starsEarned = 0,
    this.levelScore = 0,
    this.totalScore = 0,
    this.totalStars = 0,
  });

  int get remainingHints => (maxHintsPerLevel - hintsUsed).clamp(0, maxHintsPerLevel);
  bool get canUseHint => remainingHints > 0 && !isCompleted;

  WordConnectPlaying copyWith({
    int? packIndex,
    int? levelIndex,
    WordGame1Level? level,
    List<String>? currentLetters,
    Set<String>? solvedWords,
    Map<String, Set<int>>? hintedLetters,
    String? currentAttempt,
    WordFeedback? feedback,
    bool? isCompleted,
    int? hintsUsed,
    int? starsEarned,
    int? levelScore,
    int? totalScore,
    int? totalStars,
  }) {
    return WordConnectPlaying(
      packs: packs,
      packIndex: packIndex ?? this.packIndex,
      levelIndex: levelIndex ?? this.levelIndex,
      level: level ?? this.level,
      currentLetters: currentLetters ?? this.currentLetters,
      solvedWords: solvedWords ?? this.solvedWords,
      hintedLetters: hintedLetters ?? this.hintedLetters,
      currentAttempt: currentAttempt ?? this.currentAttempt,
      feedback: feedback ?? this.feedback,
      isCompleted: isCompleted ?? this.isCompleted,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      starsEarned: starsEarned ?? this.starsEarned,
      levelScore: levelScore ?? this.levelScore,
      totalScore: totalScore ?? this.totalScore,
      totalStars: totalStars ?? this.totalStars,
    );
  }
}

class WordConnectError extends WordConnectState {
  final String message;
  WordConnectError(this.message);
}

class WordConnectCubit extends Cubit<WordConnectState> {
  final WordGameRepository _repository = WordGameRepository();
  final ScoreRepository _scoreRepository = ScoreRepository();

  WordConnectCubit() : super(WordConnectLoading());

  Future<void> loadGame() async {
    emit(WordConnectLoading());
    try {
      final packs = await _repository.loadWordGame1Packs();
      if (packs.isEmpty) {
        emit(WordConnectError('Деңгээлдер табылган жок'));
        return;
      }

      final progress = await _scoreRepository.getWordConnectProgress();
      int packIdx = progress.packIndex;
      int levelIdx = progress.levelIndex;

      if (packIdx >= packs.length) {
        packIdx = 0;
        levelIdx = 0;
      } else if (levelIdx >= packs[packIdx].levels.length) {
        levelIdx = 0;
      }

      _startLevel(
        packs: packs,
        packIndex: packIdx,
        levelIndex: levelIdx,
        totalScore: progress.totalScore,
        totalStars: progress.totalStars,
      );
    } catch (e) {
      emit(WordConnectError('Оюнду жүктөөдө ката чыкты: $e'));
    }
  }

  void _startLevel({
    required List<WordGame1Pack> packs,
    required int packIndex,
    required int levelIndex,
    int totalScore = 0,
    int totalStars = 0,
  }) {
    final pack = packs[packIndex];
    final level = pack.levels[levelIndex];
    emit(WordConnectPlaying(
      packs: packs,
      packIndex: packIndex,
      levelIndex: levelIndex,
      level: level,
      currentLetters: List.from(level.letters),
      solvedWords: {},
      hintedLetters: {},
      currentAttempt: '',
      feedback: const WordFeedback(),
      isCompleted: false,
      hintsUsed: 0,
      starsEarned: 0,
      levelScore: 0,
      totalScore: totalScore,
      totalStars: totalStars,
    ));
  }

  void updateAttempt(String word) {
    if (state is WordConnectPlaying) {
      final s = state as WordConnectPlaying;
      emit(s.copyWith(
        currentAttempt: word,
        feedback: const WordFeedback(),
      ));
    }
  }

  void clearAttempt() {
    if (state is WordConnectPlaying) {
      final s = state as WordConnectPlaying;
      emit(s.copyWith(
        currentAttempt: '',
        feedback: const WordFeedback(),
      ));
    }
  }

  Future<void> submitAttempt() async {
    if (state is! WordConnectPlaying) return;
    final s = state as WordConnectPlaying;
    final candidate = s.currentAttempt.toLowerCase().trim().replaceAll(' ', '');

    if (candidate.isEmpty) return;

    // Check if already found
    if (s.solvedWords.contains(candidate)) {
      AudioController.instance.playWrongWord();
      emit(s.copyWith(
        currentAttempt: '',
        feedback: const WordFeedback(
          text: 'Буга чейин табылган!',
          type: FeedbackType.warning,
        ),
      ));
      return;
    }

    // Check if in target list
    if (s.level.words.contains(candidate)) {
      final newSolved = Set<String>.from(s.solvedWords)..add(candidate);
      final isAllSolved = newSolved.length >= s.level.words.length;

      int starsEarned = 0;
      int levelScore = 0;
      int newTotalScore = s.totalScore;
      int newTotalStars = s.totalStars;

      if (isAllSolved) {
        AudioController.instance.playLevelComplete();
        starsEarned = s.hintsUsed == 0 ? 3 : (s.hintsUsed == 1 ? 2 : 1);
        levelScore = (s.level.words.length * 10) + (starsEarned * 10);

        final updatedProgress = await _scoreRepository.recordWordConnectLevelCompleted(
          packIndex: s.packIndex,
          levelIndex: s.levelIndex,
          starsEarned: starsEarned,
          scoreEarned: levelScore,
          maxLevelsInPack: s.packs[s.packIndex].levels.length,
          maxPacks: s.packs.length,
        );

        newTotalScore = updatedProgress.totalScore;
        newTotalStars = updatedProgress.totalStars;
      } else {
        AudioController.instance.playWordSolved();
      }

      emit(s.copyWith(
        solvedWords: newSolved,
        currentAttempt: '',
        feedback: const WordFeedback(
          text: 'Туура!',
          type: FeedbackType.success,
        ),
        isCompleted: isAllSolved,
        starsEarned: starsEarned,
        levelScore: levelScore,
        totalScore: newTotalScore,
        totalStars: newTotalStars,
      ));
    } else {
      AudioController.instance.playWrongWord();
      emit(s.copyWith(
        currentAttempt: '',
        feedback: const WordFeedback(
          text: 'Мындай сөз жок',
          type: FeedbackType.error,
        ),
      ));
    }
  }

  void shuffleLetters() {
    if (state is! WordConnectPlaying) return;
    final s = state as WordConnectPlaying;
    AudioController.instance.playShuffle();
    final shuffled = List<String>.from(s.currentLetters)..shuffle(Random());
    emit(s.copyWith(currentLetters: shuffled));
  }

  Future<void> giveHint() async {
    if (state is! WordConnectPlaying) return;
    final s = state as WordConnectPlaying;

    if (!s.canUseHint) {
      AudioController.instance.playWrongWord();
      emit(s.copyWith(
        feedback: const WordFeedback(
          text: 'Бул деңгээлде кеңештер бүттү! Өзүң ойлонуп көр 😊',
          type: FeedbackType.warning,
        ),
      ));
      return;
    }

    final unsolvedWords = s.level.words.where((w) => !s.solvedWords.contains(w)).toList();
    if (unsolvedWords.isEmpty) return;

    final List<MapEntry<String, int>> unhinted = [];
    for (final word in unsolvedWords) {
      final alreadyHinted = s.hintedLetters[word] ?? {};
      for (int i = 0; i < word.length; i++) {
        if (!alreadyHinted.contains(i)) {
          unhinted.add(MapEntry(word, i));
        }
      }
    }

    if (unhinted.isEmpty) return;

    final choice = unhinted.first;
    final word = choice.key;
    final letterIdx = choice.value;

    AudioController.instance.playHint();

    final newHintedMap = Map<String, Set<int>>.from(s.hintedLetters);
    final wordHints = Set<int>.from(newHintedMap[word] ?? {})..add(letterIdx);
    newHintedMap[word] = wordHints;

    final newSolved = Set<String>.from(s.solvedWords);
    if (wordHints.length >= word.length) {
      newSolved.add(word);
    }

    final isAllSolved = newSolved.length >= s.level.words.length;
    int starsEarned = 0;
    int levelScore = 0;
    int newTotalScore = s.totalScore;
    int newTotalStars = s.totalStars;
    final newHintsUsed = s.hintsUsed + 1;
    final remainingAfterThis = (WordConnectPlaying.maxHintsPerLevel - newHintsUsed).clamp(0, WordConnectPlaying.maxHintsPerLevel);

    if (isAllSolved) {
      AudioController.instance.playLevelComplete();
      starsEarned = newHintsUsed == 0 ? 3 : (newHintsUsed == 1 ? 2 : 1);
      levelScore = (s.level.words.length * 10) + (starsEarned * 10);

      final updatedProgress = await _scoreRepository.recordWordConnectLevelCompleted(
        packIndex: s.packIndex,
        levelIndex: s.levelIndex,
        starsEarned: starsEarned,
        scoreEarned: levelScore,
        maxLevelsInPack: s.packs[s.packIndex].levels.length,
        maxPacks: s.packs.length,
      );

      newTotalScore = updatedProgress.totalScore;
      newTotalStars = updatedProgress.totalStars;
    }

    emit(s.copyWith(
      hintedLetters: newHintedMap,
      solvedWords: newSolved,
      hintsUsed: newHintsUsed,
      feedback: WordFeedback(
        text: 'Кеңеш: «${word[letterIdx].toUpperCase()}» тамгасы ачылды! (Калды: $remainingAfterThis)',
        type: FeedbackType.warning,
      ),
      isCompleted: isAllSolved,
      starsEarned: starsEarned,
      levelScore: levelScore,
      totalScore: newTotalScore,
      totalStars: newTotalStars,
    ));
  }

  Future<void> nextLevel() async {
    if (state is! WordConnectPlaying) return;
    final s = state as WordConnectPlaying;
    int nextLevelIdx = s.levelIndex + 1;
    int nextPackIdx = s.packIndex;

    if (nextLevelIdx >= s.packs[nextPackIdx].levels.length) {
      nextPackIdx++;
      nextLevelIdx = 0;
    }

    if (nextPackIdx >= s.packs.length) {
      nextPackIdx = 0;
      nextLevelIdx = 0;
    }

    await _scoreRepository.saveWordConnectCurrentPosition(nextPackIdx, nextLevelIdx);

    _startLevel(
      packs: s.packs,
      packIndex: nextPackIdx,
      levelIndex: nextLevelIdx,
      totalScore: s.totalScore,
      totalStars: s.totalStars,
    );
  }
}
