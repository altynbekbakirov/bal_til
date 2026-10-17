import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bal_til/data/repositories/score_repository.dart';
import 'package:bal_til/core/score/score_cubit.dart';
import 'package:bal_til/features/word_connect/cubit/word_connect_cubit.dart';
import 'package:bal_til/features/word_search/cubit/word_search_cubit.dart';
import 'package:bal_til/data/models/models.dart';

import 'package:bal_til/core/audio/audio_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ScoreRepository & ScoreCubit', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      AudioController.instance.isSoundEnabled = false;
      AudioController.instance.isMusicEnabled = false;
    });

    test('Initial progress is zero', () async {
      final repo = ScoreRepository();
      final wc = await repo.getWordConnectProgress();
      final ws = await repo.getWordSearchProgress();
      final overall = await repo.getOverallScore();

      expect(wc.packIndex, 0);
      expect(wc.levelIndex, 0);
      expect(wc.totalScore, 0);
      expect(wc.totalStars, 0);
      expect(ws.categoryIndex, 0);
      expect(overall.totalScore, 0);
    });

    test('Records Word Connect level completion and calculates progress', () async {
      final repo = ScoreRepository();
      final updated = await repo.recordWordConnectLevelCompleted(
        packIndex: 0,
        levelIndex: 0,
        starsEarned: 3,
        scoreEarned: 50,
        maxLevelsInPack: 5,
        maxPacks: 2,
      );

      expect(updated.totalScore, 50);
      expect(updated.totalStars, 3);
      expect(updated.unlockedLevelIndex, 1);
      expect(updated.levelsCompleted, 1);

      final overall = await repo.getOverallScore();
      expect(overall.totalScore, 50);
      expect(overall.totalStars, 3);
      expect(overall.wordConnectCompleted, 1);
    });

    test('Records Word Search category completion', () async {
      final repo = ScoreRepository();
      final updated = await repo.recordWordSearchCategoryCompleted(
        categoryIndex: 0,
        wordsFoundCount: 4,
        scoreEarned: 40,
        totalCategories: 3,
      );

      expect(updated.totalScore, 40);
      expect(updated.categoriesCompleted, 1);
      expect(updated.totalWordsFound, 4);
      expect(updated.categoryIndex, 1);
    });

    test('Records Word Search level progression (10 levels per category)', () async {
      final repo = ScoreRepository();
      final level1 = await repo.recordWordSearchLevelCompleted(
        categoryIndex: 0,
        levelIndex: 0,
        wordsFoundCount: 4,
        scoreEarned: 40,
        maxLevelsInCategory: 10,
        maxCategories: 3,
      );

      expect(level1.categoryIndex, 0);
      expect(level1.levelIndex, 1);
      expect(level1.categoriesCompleted, 1);
      expect(level1.totalScore, 40);

      final level10 = await repo.recordWordSearchLevelCompleted(
        categoryIndex: 0,
        levelIndex: 9,
        wordsFoundCount: 4,
        scoreEarned: 40,
        maxLevelsInCategory: 10,
        maxCategories: 3,
      );

      expect(level10.categoryIndex, 1);
      expect(level10.levelIndex, 0);
      expect(level10.categoriesCompleted, 2);
    });

    test('ScoreCubit loads and resets scores', () async {
      final repo = ScoreRepository();
      await repo.recordWordConnectLevelCompleted(
        packIndex: 0,
        levelIndex: 0,
        starsEarned: 3,
        scoreEarned: 50,
        maxLevelsInPack: 5,
        maxPacks: 2,
      );

      final cubit = ScoreCubit(repository: repo);
      await cubit.loadScores();

      expect(cubit.state.wordConnect.totalScore, 50);
      expect(cubit.state.overall.totalScore, 50);

      await cubit.resetAll();
      expect(cubit.state.overall.totalScore, 0);
      expect(cubit.state.overall.totalStars, 0);
    });

    test('WordConnect hint limitation enforces maximum of 3 hints per level', () async {
      final level = const WordGame1Level(
        letters: ['о', 'т'],
        words: ['от'],
      );
      final pack = WordGame1Pack(
        title: 'Тест',
        maxLetters: 2,
        levels: [level],
      );

      final state = WordConnectPlaying(
        packs: [pack],
        packIndex: 0,
        levelIndex: 0,
        level: level,
        currentLetters: ['о', 'т'],
        solvedWords: {},
      );

      expect(state.remainingHints, 3);
      expect(state.canUseHint, true);

      final after1 = state.copyWith(hintsUsed: 1);
      expect(after1.remainingHints, 2);
      expect(after1.canUseHint, true);

      final after3 = state.copyWith(hintsUsed: 3);
      expect(after3.remainingHints, 0);
      expect(after3.canUseHint, false);
    });

    test('User clicks letter, clicks hint, then clears: only hinted letter remains', () async {
      final level = const WordGame1Level(
        letters: ['с', 'ы', 'р'],
        words: ['сыр'],
      );
      final pack = WordGame1Pack(
        title: 'Тест',
        maxLetters: 3,
        levels: [level],
      );

      final state = WordConnectPlaying(
        packs: [pack],
        packIndex: 0,
        levelIndex: 0,
        level: level,
        currentLetters: ['с', 'ы', 'р'],
        solvedWords: {},
      );

      final cubit = WordConnectCubit();
      cubit.emit(state.copyWith(currentAttempt: 'с'));

      await cubit.giveHint();
      final afterHint = cubit.state as WordConnectPlaying;
      expect(afterHint.hintedLetters['сыр'], {0});
      expect(afterHint.currentAttempt, 'с');
      expect(afterHint.hintsUsed, 1);

      cubit.updateAttempt('сы');
      expect((cubit.state as WordConnectPlaying).currentAttempt, 'сы');

      cubit.clearAttempt();
      final afterClear = cubit.state as WordConnectPlaying;
      expect(afterClear.currentAttempt, 'с');

      // Clearing again still preserves the hinted letter
      cubit.clearAttempt();
      final afterSecondClear = cubit.state as WordConnectPlaying;
      expect(afterSecondClear.currentAttempt, 'с');

      // Even if user only enters remaining letters 'ыр', hinted letter 'с' is calculated!
      cubit.updateAttempt('ыр');
      await cubit.submitAttempt();
      final afterSubmit = cubit.state as WordConnectPlaying;
      expect(afterSubmit.solvedWords.contains('сыр'), true);
    });

    test('WordConnect restartGame resets level position to 0,0 while keeping cumulative stats', () async {
      final repo = ScoreRepository();
      await repo.recordWordConnectLevelCompleted(
        packIndex: 2,
        levelIndex: 4,
        starsEarned: 3,
        scoreEarned: 50,
        maxLevelsInPack: 5,
        maxPacks: 5,
      );

      final cubit = WordConnectCubit();
      await cubit.loadGame();
      expect(cubit.state is WordConnectPlaying, true);

      await cubit.restartGame();
      final state = cubit.state as WordConnectPlaying;
      expect(state.packIndex, 0);
      expect(state.levelIndex, 0);
      expect(state.currentOverallLevel, 1);
      expect(state.totalScore > 0, true);

      final pos = await repo.getWordConnectProgress();
      expect(pos.packIndex, 0);
      expect(pos.levelIndex, 0);
    });

    test('WordSearch restartGame resets level position to 0,0 while keeping cumulative stats', () async {
      final repo = ScoreRepository();
      await repo.recordWordSearchLevelCompleted(
        categoryIndex: 1,
        levelIndex: 8,
        wordsFoundCount: 4,
        scoreEarned: 40,
        maxLevelsInCategory: 10,
        maxCategories: 3,
      );

      final cubit = WordSearchCubit();
      await cubit.loadGame();
      expect(cubit.state is WordSearchPlaying, true);

      await cubit.restartGame();
      final state = cubit.state as WordSearchPlaying;
      expect(state.categoryIndex, 0);
      expect(state.levelIndex, 0);
      expect(state.currentOverallLevel, 1);
      expect(state.totalScore > 0, true);

      final pos = await repo.getWordSearchProgress();
      expect(pos.categoryIndex, 0);
      expect(pos.levelIndex, 0);
    });
  });
}
