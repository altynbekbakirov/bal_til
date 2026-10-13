import 'package:shared_preferences/shared_preferences.dart';
import '../models/score_models.dart';

class ScoreRepository {
  static const String _kWcPack = 'wc_pack_index';
  static const String _kWcLevel = 'wc_level_index';
  static const String _kWcUnlockedPack = 'wc_unlocked_pack';
  static const String _kWcUnlockedLevel = 'wc_unlocked_level';
  static const String _kWcScore = 'wc_total_score';
  static const String _kWcStars = 'wc_total_stars';
  static const String _kWcCompletedCount = 'wc_completed_count';

  static const String _kWsCategory = 'ws_category_index';
  static const String _kWsScore = 'ws_total_score';
  static const String _kWsCompletedCount = 'ws_completed_count';
  static const String _kWsWordsFound = 'ws_words_found';

  Future<WordConnectProgress> getWordConnectProgress() async {
    final prefs = await SharedPreferences.getInstance();
    return WordConnectProgress(
      packIndex: prefs.getInt(_kWcPack) ?? 0,
      levelIndex: prefs.getInt(_kWcLevel) ?? 0,
      unlockedPackIndex: prefs.getInt(_kWcUnlockedPack) ?? 0,
      unlockedLevelIndex: prefs.getInt(_kWcUnlockedLevel) ?? 0,
      totalScore: prefs.getInt(_kWcScore) ?? 0,
      totalStars: prefs.getInt(_kWcStars) ?? 0,
      levelsCompleted: prefs.getInt(_kWcCompletedCount) ?? 0,
    );
  }

  Future<void> saveWordConnectCurrentPosition(int packIndex, int levelIndex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kWcPack, packIndex);
    await prefs.setInt(_kWcLevel, levelIndex);
  }

  Future<WordConnectProgress> recordWordConnectLevelCompleted({
    required int packIndex,
    required int levelIndex,
    required int starsEarned,
    required int scoreEarned,
    required int maxLevelsInPack,
    required int maxPacks,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final prevScore = prefs.getInt(_kWcScore) ?? 0;
    final prevStars = prefs.getInt(_kWcStars) ?? 0;
    final prevCompleted = prefs.getInt(_kWcCompletedCount) ?? 0;
    int unlockedPack = prefs.getInt(_kWcUnlockedPack) ?? 0;
    int unlockedLevel = prefs.getInt(_kWcUnlockedLevel) ?? 0;

    final newScore = prevScore + scoreEarned;
    final newStars = prevStars + starsEarned;
    final newCompleted = prevCompleted + 1;

    // Check if this advances highest unlocked level
    if (packIndex > unlockedPack || (packIndex == unlockedPack && levelIndex >= unlockedLevel)) {
      if (levelIndex + 1 < maxLevelsInPack) {
        unlockedLevel = levelIndex + 1;
      } else if (packIndex + 1 < maxPacks) {
        unlockedPack = packIndex + 1;
        unlockedLevel = 0;
      }
    }

    await prefs.setInt(_kWcScore, newScore);
    await prefs.setInt(_kWcStars, newStars);
    await prefs.setInt(_kWcCompletedCount, newCompleted);
    await prefs.setInt(_kWcUnlockedPack, unlockedPack);
    await prefs.setInt(_kWcUnlockedLevel, unlockedLevel);

    return WordConnectProgress(
      packIndex: packIndex,
      levelIndex: levelIndex,
      unlockedPackIndex: unlockedPack,
      unlockedLevelIndex: unlockedLevel,
      totalScore: newScore,
      totalStars: newStars,
      levelsCompleted: newCompleted,
    );
  }

  Future<WordSearchProgress> getWordSearchProgress() async {
    final prefs = await SharedPreferences.getInstance();
    return WordSearchProgress(
      categoryIndex: prefs.getInt(_kWsCategory) ?? 0,
      categoriesCompleted: prefs.getInt(_kWsCompletedCount) ?? 0,
      totalScore: prefs.getInt(_kWsScore) ?? 0,
      totalWordsFound: prefs.getInt(_kWsWordsFound) ?? 0,
    );
  }

  Future<void> saveWordSearchCurrentCategory(int categoryIndex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kWsCategory, categoryIndex);
  }

  Future<WordSearchProgress> recordWordSearchCategoryCompleted({
    required int categoryIndex,
    required int wordsFoundCount,
    required int scoreEarned,
    required int totalCategories,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final prevScore = prefs.getInt(_kWsScore) ?? 0;
    final prevCompleted = prefs.getInt(_kWsCompletedCount) ?? 0;
    final prevWords = prefs.getInt(_kWsWordsFound) ?? 0;

    final newScore = prevScore + scoreEarned;
    final newCompleted = prevCompleted + 1;
    final newWords = prevWords + wordsFoundCount;
    final nextCategory = totalCategories > 0 ? (categoryIndex + 1) % totalCategories : 0;

    await prefs.setInt(_kWsScore, newScore);
    await prefs.setInt(_kWsCompletedCount, newCompleted);
    await prefs.setInt(_kWsWordsFound, newWords);
    await prefs.setInt(_kWsCategory, nextCategory);

    return WordSearchProgress(
      categoryIndex: nextCategory,
      categoriesCompleted: newCompleted,
      totalScore: newScore,
      totalWordsFound: newWords,
    );
  }

  Future<OverallScore> getOverallScore() async {
    final wc = await getWordConnectProgress();
    final ws = await getWordSearchProgress();
    return OverallScore(
      totalScore: wc.totalScore + ws.totalScore,
      totalStars: wc.totalStars,
      wordConnectCompleted: wc.levelsCompleted,
      wordSearchCompleted: ws.categoriesCompleted,
    );
  }

  Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kWcPack);
    await prefs.remove(_kWcLevel);
    await prefs.remove(_kWcUnlockedPack);
    await prefs.remove(_kWcUnlockedLevel);
    await prefs.remove(_kWcScore);
    await prefs.remove(_kWcStars);
    await prefs.remove(_kWcCompletedCount);

    await prefs.remove(_kWsCategory);
    await prefs.remove(_kWsScore);
    await prefs.remove(_kWsCompletedCount);
    await prefs.remove(_kWsWordsFound);
  }
}
