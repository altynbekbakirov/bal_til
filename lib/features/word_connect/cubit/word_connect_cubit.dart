import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart';
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
  final String activeHintPrefix;
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
    this.activeHintPrefix = '',
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

  String get effectiveHintPrefix {
    if (activeHintPrefix.isNotEmpty) {
      for (final w in level.words) {
        if (!solvedWords.contains(w) && w.startsWith(activeHintPrefix)) {
          return activeHintPrefix;
        }
      }
    }
    for (final w in level.words) {
      if (!solvedWords.contains(w)) {
        final hints = hintedLetters[w];
        if (hints != null && hints.contains(0)) {
          int count = 0;
          while (hints.contains(count) && count < w.length) {
            count++;
          }
          if (count > 0 && count < w.length) {
            return w.substring(0, count);
          }
        }
      }
    }
    return '';
  }

  int get totalLevels => packs.fold<int>(0, (sum, p) => sum + p.levels.length);

  int get currentOverallLevel {
    int count = 0;
    for (int i = 0; i < packIndex && i < packs.length; i++) {
      count += packs[i].levels.length;
    }
    return count + levelIndex + 1;
  }

  WordConnectPlaying copyWith({
    int? packIndex,
    int? levelIndex,
    WordGame1Level? level,
    List<String>? currentLetters,
    Set<String>? solvedWords,
    Map<String, Set<int>>? hintedLetters,
    String? currentAttempt,
    String? activeHintPrefix,
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
      activeHintPrefix: activeHintPrefix ?? this.activeHintPrefix,
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

  Timer? _feedbackTimer;

  void _scheduleFeedbackDismiss([Duration duration = const Duration(milliseconds: 1500)]) {
    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(duration, () {
      if (state is WordConnectPlaying) {
        final s = state as WordConnectPlaying;
        if (s.feedback.text.isNotEmpty) {
          emit(s.copyWith(feedback: const WordFeedback()));
        }
      }
    });
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
      final hintPrefix = s.effectiveHintPrefix;
      if (hintPrefix.isNotEmpty &&
          s.currentAttempt.length > hintPrefix.length &&
          s.currentAttempt.startsWith(hintPrefix)) {
        emit(s.copyWith(
          currentAttempt: hintPrefix,
          feedback: const WordFeedback(),
        ));
      } else {
        emit(s.copyWith(
          currentAttempt: '',
          activeHintPrefix: '',
          feedback: const WordFeedback(),
        ));
      }
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
      final restored = s.effectiveHintPrefix;
      emit(s.copyWith(
        currentAttempt: restored,
        feedback: const WordFeedback(
          text: 'Буга чейин табылган!',
          type: FeedbackType.warning,
        ),
      ));
      _scheduleFeedbackDismiss();
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

      String newActiveHint = s.activeHintPrefix;
      if (candidate.startsWith(s.activeHintPrefix) || candidate == s.activeHintPrefix) {
        newActiveHint = '';
      }

      emit(s.copyWith(
        solvedWords: newSolved,
        currentAttempt: '',
        activeHintPrefix: newActiveHint,
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
      _scheduleFeedbackDismiss();
    } else {
      AudioController.instance.playWrongWord();
      final restored = s.effectiveHintPrefix;
      emit(s.copyWith(
        currentAttempt: restored,
        feedback: const WordFeedback(
          text: 'Мындай сөз жок',
          type: FeedbackType.error,
        ),
      ));
      _scheduleFeedbackDismiss();
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

    // Pick target word & letter index
    String targetWord = '';
    int letterIdx = -1;

    // If current attempt is a prefix of an unsolved word, continue with that word
    final currentPref = s.currentAttempt.toLowerCase().trim();
    if (currentPref.isNotEmpty) {
      for (final w in unsolvedWords) {
        if (w.startsWith(currentPref) && w.length > currentPref.length) {
          targetWord = w;
          letterIdx = currentPref.length;
          break;
        }
      }
    }

    // Otherwise, pick the first unsolved word with an unhinted letter
    if (targetWord.isEmpty) {
      for (final w in unsolvedWords) {
        final alreadyHinted = s.hintedLetters[w] ?? {};
        for (int i = 0; i < w.length; i++) {
          if (!alreadyHinted.contains(i)) {
            targetWord = w;
            letterIdx = i;
            break;
          }
        }
        if (targetWord.isNotEmpty) break;
      }
    }

    if (targetWord.isEmpty || letterIdx < 0) return;

    final word = targetWord;

    AudioController.instance.playHint();
    AudioController.instance.playLetterSelect();
    HapticFeedback.lightImpact();

    final newHintedMap = Map<String, Set<int>>.from(s.hintedLetters);
    final wordHints = Set<int>.from(newHintedMap[word] ?? {});
    for (int i = 0; i <= letterIdx; i++) {
      wordHints.add(i);
    }
    newHintedMap[word] = wordHints;

    final isWordFullyHinted = wordHints.length >= word.length;
    final newSolved = Set<String>.from(s.solvedWords);
    if (isWordFullyHinted) {
      newSolved.add(word);
    }

    final isAllSolved = newSolved.length >= s.level.words.length;
    int starsEarned = 0;
    int levelScore = 0;
    int newTotalScore = s.totalScore;
    int newTotalStars = s.totalStars;
    final newHintsUsed = s.hintsUsed + 1;

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
    } else if (isWordFullyHinted) {
      AudioController.instance.playWordSolved();
    }

    final newAttempt = isWordFullyHinted ? '' : word.substring(0, letterIdx + 1);
    final feedback = isWordFullyHinted
        ? WordFeedback(
            text: '«${word.toUpperCase()}» табылды! 🎉',
            type: FeedbackType.success,
          )
        : const WordFeedback();

    emit(s.copyWith(
      hintedLetters: newHintedMap,
      solvedWords: newSolved,
      hintsUsed: newHintsUsed,
      currentAttempt: newAttempt,
      activeHintPrefix: newAttempt,
      feedback: feedback,
      isCompleted: isAllSolved,
      starsEarned: starsEarned,
      levelScore: levelScore,
      totalScore: newTotalScore,
      totalStars: newTotalStars,
    ));

    if (isWordFullyHinted) {
      _scheduleFeedbackDismiss();
    }
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

  @override
  Future<void> close() {
    _feedbackTimer?.cancel();
    return super.close();
  }
}
