class WordConnectProgress {
  final int packIndex;
  final int levelIndex;
  final int unlockedPackIndex;
  final int unlockedLevelIndex;
  final int totalScore;
  final int totalStars;
  final int levelsCompleted;

  const WordConnectProgress({
    this.packIndex = 0,
    this.levelIndex = 0,
    this.unlockedPackIndex = 0,
    this.unlockedLevelIndex = 0,
    this.totalScore = 0,
    this.totalStars = 0,
    this.levelsCompleted = 0,
  });

  WordConnectProgress copyWith({
    int? packIndex,
    int? levelIndex,
    int? unlockedPackIndex,
    int? unlockedLevelIndex,
    int? totalScore,
    int? totalStars,
    int? levelsCompleted,
  }) {
    return WordConnectProgress(
      packIndex: packIndex ?? this.packIndex,
      levelIndex: levelIndex ?? this.levelIndex,
      unlockedPackIndex: unlockedPackIndex ?? this.unlockedPackIndex,
      unlockedLevelIndex: unlockedLevelIndex ?? this.unlockedLevelIndex,
      totalScore: totalScore ?? this.totalScore,
      totalStars: totalStars ?? this.totalStars,
      levelsCompleted: levelsCompleted ?? this.levelsCompleted,
    );
  }
}

class WordSearchProgress {
  final int categoryIndex;
  final int levelIndex;
  final int categoriesCompleted;
  final int totalScore;
  final int totalWordsFound;

  const WordSearchProgress({
    this.categoryIndex = 0,
    this.levelIndex = 0,
    this.categoriesCompleted = 0,
    this.totalScore = 0,
    this.totalWordsFound = 0,
  });

  WordSearchProgress copyWith({
    int? categoryIndex,
    int? levelIndex,
    int? categoriesCompleted,
    int? totalScore,
    int? totalWordsFound,
  }) {
    return WordSearchProgress(
      categoryIndex: categoryIndex ?? this.categoryIndex,
      levelIndex: levelIndex ?? this.levelIndex,
      categoriesCompleted: categoriesCompleted ?? this.categoriesCompleted,
      totalScore: totalScore ?? this.totalScore,
      totalWordsFound: totalWordsFound ?? this.totalWordsFound,
    );
  }
}

class OverallScore {
  final int totalScore;
  final int totalStars;
  final int wordConnectCompleted;
  final int wordSearchCompleted;

  const OverallScore({
    this.totalScore = 0,
    this.totalStars = 0,
    this.wordConnectCompleted = 0,
    this.wordSearchCompleted = 0,
  });
}
