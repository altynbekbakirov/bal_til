class WordConnectProgress {
  final int packIndex;
  final int levelIndex;
  final int unlockedPackIndex;
  final int unlockedLevelIndex;
  final int totalScore;
  final int totalStars;
  final int levelsCompleted;
  final bool isGameCompleted;

  const WordConnectProgress({
    this.packIndex = 0,
    this.levelIndex = 0,
    this.unlockedPackIndex = 0,
    this.unlockedLevelIndex = 0,
    this.totalScore = 0,
    this.totalStars = 0,
    this.levelsCompleted = 0,
    this.isGameCompleted = false,
  });

  WordConnectProgress copyWith({
    int? packIndex,
    int? levelIndex,
    int? unlockedPackIndex,
    int? unlockedLevelIndex,
    int? totalScore,
    int? totalStars,
    int? levelsCompleted,
    bool? isGameCompleted,
  }) {
    return WordConnectProgress(
      packIndex: packIndex ?? this.packIndex,
      levelIndex: levelIndex ?? this.levelIndex,
      unlockedPackIndex: unlockedPackIndex ?? this.unlockedPackIndex,
      unlockedLevelIndex: unlockedLevelIndex ?? this.unlockedLevelIndex,
      totalScore: totalScore ?? this.totalScore,
      totalStars: totalStars ?? this.totalStars,
      levelsCompleted: levelsCompleted ?? this.levelsCompleted,
      isGameCompleted: isGameCompleted ?? this.isGameCompleted,
    );
  }
}

class WordSearchProgress {
  final int categoryIndex;
  final int levelIndex;
  final int unlockedCategoryIndex;
  final int unlockedLevelIndex;
  final int categoriesCompleted;
  final int levelsCompleted;
  final int totalScore;
  final int totalStars;
  final int totalWordsFound;
  final bool isGameCompleted;

  const WordSearchProgress({
    this.categoryIndex = 0,
    this.levelIndex = 0,
    this.unlockedCategoryIndex = 0,
    this.unlockedLevelIndex = 0,
    this.categoriesCompleted = 0,
    this.levelsCompleted = 0,
    this.totalScore = 0,
    this.totalStars = 0,
    this.totalWordsFound = 0,
    this.isGameCompleted = false,
  });

  WordSearchProgress copyWith({
    int? categoryIndex,
    int? levelIndex,
    int? unlockedCategoryIndex,
    int? unlockedLevelIndex,
    int? categoriesCompleted,
    int? levelsCompleted,
    int? totalScore,
    int? totalStars,
    int? totalWordsFound,
    bool? isGameCompleted,
  }) {
    return WordSearchProgress(
      categoryIndex: categoryIndex ?? this.categoryIndex,
      levelIndex: levelIndex ?? this.levelIndex,
      unlockedCategoryIndex: unlockedCategoryIndex ?? this.unlockedCategoryIndex,
      unlockedLevelIndex: unlockedLevelIndex ?? this.unlockedLevelIndex,
      categoriesCompleted: categoriesCompleted ?? this.categoriesCompleted,
      levelsCompleted: levelsCompleted ?? this.levelsCompleted,
      totalScore: totalScore ?? this.totalScore,
      totalStars: totalStars ?? this.totalStars,
      totalWordsFound: totalWordsFound ?? this.totalWordsFound,
      isGameCompleted: isGameCompleted ?? this.isGameCompleted,
    );
  }
}

class AnimalsProgress {
  final int currentIndex;
  final int totalScore;
  final int totalStars;
  final int itemsCompleted;
  final bool isGameCompleted;

  const AnimalsProgress({
    this.currentIndex = 0,
    this.totalScore = 0,
    this.totalStars = 0,
    this.itemsCompleted = 0,
    this.isGameCompleted = false,
  });

  AnimalsProgress copyWith({
    int? currentIndex,
    int? totalScore,
    int? totalStars,
    int? itemsCompleted,
    bool? isGameCompleted,
  }) {
    return AnimalsProgress(
      currentIndex: currentIndex ?? this.currentIndex,
      totalScore: totalScore ?? this.totalScore,
      totalStars: totalStars ?? this.totalStars,
      itemsCompleted: itemsCompleted ?? this.itemsCompleted,
      isGameCompleted: isGameCompleted ?? this.isGameCompleted,
    );
  }
}

class PlantsProgress {
  final int currentIndex;
  final int totalScore;
  final int totalStars;
  final int itemsCompleted;
  final bool isGameCompleted;

  const PlantsProgress({
    this.currentIndex = 0,
    this.totalScore = 0,
    this.totalStars = 0,
    this.itemsCompleted = 0,
    this.isGameCompleted = false,
  });

  PlantsProgress copyWith({
    int? currentIndex,
    int? totalScore,
    int? totalStars,
    int? itemsCompleted,
    bool? isGameCompleted,
  }) {
    return PlantsProgress(
      currentIndex: currentIndex ?? this.currentIndex,
      totalScore: totalScore ?? this.totalScore,
      totalStars: totalStars ?? this.totalStars,
      itemsCompleted: itemsCompleted ?? this.itemsCompleted,
      isGameCompleted: isGameCompleted ?? this.isGameCompleted,
    );
  }
}

class OverallScore {
  final int totalScore;
  final int totalStars;
  final int wordConnectCompleted;
  final int wordSearchCompleted;
  final int animalsCompleted;
  final int plantsCompleted;

  const OverallScore({
    this.totalScore = 0,
    this.totalStars = 0,
    this.wordConnectCompleted = 0,
    this.wordSearchCompleted = 0,
    this.animalsCompleted = 0,
    this.plantsCompleted = 0,
  });
}

