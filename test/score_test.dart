import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ball_til/data/repositories/score_repository.dart';
import 'package:ball_til/core/score/score_cubit.dart';
import 'package:ball_til/features/word_connect/cubit/word_connect_cubit.dart';
import 'package:ball_til/data/models/models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ScoreRepository & ScoreCubit', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
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
  });
}
