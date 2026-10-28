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
  static const String _kWcIsCompleted = 'wc_is_completed';

  static const String _kWsCategory = 'ws_category_index';
  static const String _kWsLevel = 'ws_level_index';
  static const String _kWsUnlockedCategory = 'ws_unlocked_category';
  static const String _kWsUnlockedLevel = 'ws_unlocked_level';
  static const String _kWsScore = 'ws_total_score';
  static const String _kWsStars = 'ws_total_stars';
  static const String _kWsCompletedCount = 'ws_completed_count';
  static const String _kWsWordsFound = 'ws_words_found';
  static const String _kWsIsCompleted = 'ws_is_completed';

  static const String _kAnimalsIndex = 'animals_current_index';
  static const String _kAnimalsScore = 'animals_total_score';
  static const String _kAnimalsStars = 'animals_total_stars';
  static const String _kAnimalsCompletedCount = 'animals_completed_count';
  static const String _kAnimalsIsCompleted = 'animals_is_completed';

  static const String _kPlantsIndex = 'plants_current_index';
  static const String _kPlantsScore = 'plants_total_score';
  static const String _kPlantsStars = 'plants_total_stars';
  static const String _kPlantsCompletedCount = 'plants_completed_count';
  static const String _kPlantsIsCompleted = 'plants_is_completed';

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
      isGameCompleted: prefs.getBool(_kWcIsCompleted) ?? false,
    );
  }

  Future<void> saveWordConnectCurrentPosition(int packIndex, int levelIndex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kWcPack, packIndex);
    await prefs.setInt(_kWcLevel, levelIndex);
  }

  Future<void> saveWordConnectGameCompleted(bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kWcIsCompleted, completed);
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

    final totalGameLevels = maxPacks * maxLevelsInPack;
    final isGameCompleted = newCompleted >= totalGameLevels ||
        (packIndex >= maxPacks - 1 && levelIndex >= maxLevelsInPack - 1);

    await prefs.setInt(_kWcScore, newScore);
    await prefs.setInt(_kWcStars, newStars);
    await prefs.setInt(_kWcCompletedCount, newCompleted);
    await prefs.setInt(_kWcUnlockedPack, unlockedPack);
    await prefs.setInt(_kWcUnlockedLevel, unlockedLevel);
    if (isGameCompleted) {
      await prefs.setBool(_kWcIsCompleted, true);
    }

    return WordConnectProgress(
      packIndex: packIndex,
      levelIndex: levelIndex,
      unlockedPackIndex: unlockedPack,
      unlockedLevelIndex: unlockedLevel,
      totalScore: newScore,
      totalStars: newStars,
      levelsCompleted: newCompleted,
      isGameCompleted: isGameCompleted,
    );
  }

  Future<WordSearchProgress> getWordSearchProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final completedCount = prefs.getInt(_kWsCompletedCount) ?? 0;
    return WordSearchProgress(
      categoryIndex: prefs.getInt(_kWsCategory) ?? 0,
      levelIndex: prefs.getInt(_kWsLevel) ?? 0,
      unlockedCategoryIndex: prefs.getInt(_kWsUnlockedCategory) ?? 0,
      unlockedLevelIndex: prefs.getInt(_kWsUnlockedLevel) ?? 0,
      categoriesCompleted: completedCount,
      levelsCompleted: completedCount,
      totalScore: prefs.getInt(_kWsScore) ?? 0,
      totalStars: prefs.getInt(_kWsStars) ?? 0,
      totalWordsFound: prefs.getInt(_kWsWordsFound) ?? 0,
      isGameCompleted: prefs.getBool(_kWsIsCompleted) ?? false,
    );
  }

  Future<void> saveWordSearchCurrentPosition(int categoryIndex, int levelIndex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kWsCategory, categoryIndex);
    await prefs.setInt(_kWsLevel, levelIndex);
  }

  Future<void> saveWordSearchCurrentCategory(int categoryIndex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kWsCategory, categoryIndex);
  }

  Future<void> saveWordSearchGameCompleted(bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kWsIsCompleted, completed);
  }

  Future<WordSearchProgress> recordWordSearchLevelCompleted({
    required int categoryIndex,
    required int levelIndex,
    required int wordsFoundCount,
    required int scoreEarned,
    int starsEarned = 3,
    required int maxLevelsInCategory,
    required int maxCategories,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final prevScore = prefs.getInt(_kWsScore) ?? 0;
    final prevStars = prefs.getInt(_kWsStars) ?? 0;
    final prevCompleted = prefs.getInt(_kWsCompletedCount) ?? 0;
    final prevWords = prefs.getInt(_kWsWordsFound) ?? 0;
    int unlockedCat = prefs.getInt(_kWsUnlockedCategory) ?? 0;
    int unlockedLvl = prefs.getInt(_kWsUnlockedLevel) ?? 0;

    final newScore = prevScore + scoreEarned;
    final newStars = prevStars + starsEarned;
    final newCompleted = prevCompleted + 1;
    final newWords = prevWords + wordsFoundCount;

    // Check if this advances highest unlocked level
    if (categoryIndex > unlockedCat || (categoryIndex == unlockedCat && levelIndex >= unlockedLvl)) {
      if (levelIndex + 1 < maxLevelsInCategory) {
        unlockedLvl = levelIndex + 1;
      } else if (categoryIndex + 1 < maxCategories) {
        unlockedCat = categoryIndex + 1;
        unlockedLvl = 0;
      }
    }

    int nextLevel = levelIndex + 1;
    int nextCategory = categoryIndex;
    final totalGameLevels = maxCategories * maxLevelsInCategory;
    final isGameCompleted = newCompleted >= totalGameLevels ||
        (categoryIndex >= maxCategories - 1 && levelIndex >= maxLevelsInCategory - 1);

    if (nextLevel >= maxLevelsInCategory) {
      if (categoryIndex + 1 < maxCategories) {
        nextCategory = categoryIndex + 1;
        nextLevel = 0;
      } else {
        // Last level completed: keep at last level so it doesn't wrap around
        nextCategory = categoryIndex;
        nextLevel = levelIndex;
      }
    }

    await prefs.setInt(_kWsScore, newScore);
    await prefs.setInt(_kWsStars, newStars);
    await prefs.setInt(_kWsCompletedCount, newCompleted);
    await prefs.setInt(_kWsWordsFound, newWords);
    await prefs.setInt(_kWsCategory, nextCategory);
    await prefs.setInt(_kWsLevel, nextLevel);
    await prefs.setInt(_kWsUnlockedCategory, unlockedCat);
    await prefs.setInt(_kWsUnlockedLevel, unlockedLvl);
    if (isGameCompleted) {
      await prefs.setBool(_kWsIsCompleted, true);
    }

    return WordSearchProgress(
      categoryIndex: nextCategory,
      levelIndex: nextLevel,
      unlockedCategoryIndex: unlockedCat,
      unlockedLevelIndex: unlockedLvl,
      categoriesCompleted: newCompleted,
      levelsCompleted: newCompleted,
      totalScore: newScore,
      totalStars: newStars,
      totalWordsFound: newWords,
      isGameCompleted: isGameCompleted,
    );
  }

  Future<WordSearchProgress> recordWordSearchCategoryCompleted({
    required int categoryIndex,
    required int wordsFoundCount,
    required int scoreEarned,
    int starsEarned = 3,
    required int totalCategories,
  }) async {
    return recordWordSearchLevelCompleted(
      categoryIndex: categoryIndex,
      levelIndex: 0,
      wordsFoundCount: wordsFoundCount,
      scoreEarned: scoreEarned,
      starsEarned: starsEarned,
      maxLevelsInCategory: 1,
      maxCategories: totalCategories,
    );
  }

  Future<AnimalsProgress> getAnimalsProgress() async {
    final prefs = await SharedPreferences.getInstance();
    return AnimalsProgress(
      currentIndex: prefs.getInt(_kAnimalsIndex) ?? 0,
      totalScore: prefs.getInt(_kAnimalsScore) ?? 0,
      totalStars: prefs.getInt(_kAnimalsStars) ?? 0,
      itemsCompleted: prefs.getInt(_kAnimalsCompletedCount) ?? 0,
      isGameCompleted: prefs.getBool(_kAnimalsIsCompleted) ?? false,
    );
  }

  Future<void> saveAnimalsCurrentPosition(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kAnimalsIndex, index);
  }

  Future<void> saveAnimalsGameCompleted(bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAnimalsIsCompleted, completed);
  }

  Future<AnimalsProgress> recordAnimalsItemCompleted({
    required int itemIndex,
    required int starsEarned,
    required int scoreEarned,
    required int totalItems,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final prevScore = prefs.getInt(_kAnimalsScore) ?? 0;
    final prevStars = prefs.getInt(_kAnimalsStars) ?? 0;
    final prevCompleted = prefs.getInt(_kAnimalsCompletedCount) ?? 0;

    final newScore = prevScore + scoreEarned;
    final newStars = prevStars + starsEarned;
    final newCompleted = prevCompleted + 1;
    final isGameCompleted = newCompleted >= totalItems || itemIndex >= totalItems - 1;

    final nextIndex = itemIndex + 1 < totalItems ? itemIndex + 1 : itemIndex;

    await prefs.setInt(_kAnimalsScore, newScore);
    await prefs.setInt(_kAnimalsStars, newStars);
    await prefs.setInt(_kAnimalsCompletedCount, newCompleted);
    await prefs.setInt(_kAnimalsIndex, nextIndex);
    if (isGameCompleted) {
      await prefs.setBool(_kAnimalsIsCompleted, true);
    }

    return AnimalsProgress(
      currentIndex: nextIndex,
      totalScore: newScore,
      totalStars: newStars,
      itemsCompleted: newCompleted,
      isGameCompleted: isGameCompleted,
    );
  }

  Future<PlantsProgress> getPlantsProgress() async {
    final prefs = await SharedPreferences.getInstance();
    return PlantsProgress(
      currentIndex: prefs.getInt(_kPlantsIndex) ?? 0,
      totalScore: prefs.getInt(_kPlantsScore) ?? 0,
      totalStars: prefs.getInt(_kPlantsStars) ?? 0,
      itemsCompleted: prefs.getInt(_kPlantsCompletedCount) ?? 0,
      isGameCompleted: prefs.getBool(_kPlantsIsCompleted) ?? false,
    );
  }

  Future<void> savePlantsCurrentPosition(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kPlantsIndex, index);
  }

  Future<void> savePlantsGameCompleted(bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPlantsIsCompleted, completed);
  }

  Future<PlantsProgress> recordPlantsItemCompleted({
    required int itemIndex,
    required int starsEarned,
    required int scoreEarned,
    required int totalItems,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final prevScore = prefs.getInt(_kPlantsScore) ?? 0;
    final prevStars = prefs.getInt(_kPlantsStars) ?? 0;
    final prevCompleted = prefs.getInt(_kPlantsCompletedCount) ?? 0;

    final newScore = prevScore + scoreEarned;
    final newStars = prevStars + starsEarned;
    final newCompleted = prevCompleted + 1;
    final isGameCompleted = newCompleted >= totalItems || itemIndex >= totalItems - 1;

    final nextIndex = itemIndex + 1 < totalItems ? itemIndex + 1 : itemIndex;

    await prefs.setInt(_kPlantsScore, newScore);
    await prefs.setInt(_kPlantsStars, newStars);
    await prefs.setInt(_kPlantsCompletedCount, newCompleted);
    await prefs.setInt(_kPlantsIndex, nextIndex);
    if (isGameCompleted) {
      await prefs.setBool(_kPlantsIsCompleted, true);
    }

    return PlantsProgress(
      currentIndex: nextIndex,
      totalScore: newScore,
      totalStars: newStars,
      itemsCompleted: newCompleted,
      isGameCompleted: isGameCompleted,
    );
  }

  Future<OverallScore> getOverallScore() async {
    final wc = await getWordConnectProgress();
    final ws = await getWordSearchProgress();
    final animals = await getAnimalsProgress();
    final plants = await getPlantsProgress();
    return OverallScore(
      totalScore: wc.totalScore + ws.totalScore + animals.totalScore + plants.totalScore,
      totalStars: wc.totalStars + ws.totalStars + animals.totalStars + plants.totalStars,
      wordConnectCompleted: wc.levelsCompleted,
      wordSearchCompleted: ws.levelsCompleted,
      animalsCompleted: animals.itemsCompleted,
      plantsCompleted: plants.itemsCompleted,
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
    await prefs.remove(_kWcIsCompleted);

    await prefs.remove(_kWsCategory);
    await prefs.remove(_kWsLevel);
    await prefs.remove(_kWsUnlockedCategory);
    await prefs.remove(_kWsUnlockedLevel);
    await prefs.remove(_kWsScore);
    await prefs.remove(_kWsStars);
    await prefs.remove(_kWsCompletedCount);
    await prefs.remove(_kWsWordsFound);
    await prefs.remove(_kWsIsCompleted);

    await prefs.remove(_kAnimalsIndex);
    await prefs.remove(_kAnimalsScore);
    await prefs.remove(_kAnimalsStars);
    await prefs.remove(_kAnimalsCompletedCount);
    await prefs.remove(_kAnimalsIsCompleted);

    await prefs.remove(_kPlantsIndex);
    await prefs.remove(_kPlantsScore);
    await prefs.remove(_kPlantsStars);
    await prefs.remove(_kPlantsCompletedCount);
    await prefs.remove(_kPlantsIsCompleted);
  }
}

