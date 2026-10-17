import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repositories.dart';
import '../../../data/repositories/score_repository.dart';
import '../../../core/audio/audio_controller.dart';

class WordSearchBoard {
  final int size;
  final List<List<String>> grid;
  final List<String> targetWords;
  final Set<String> foundWords;

  WordSearchBoard({
    required this.size,
    required this.grid,
    required this.targetWords,
    required this.foundWords,
  });

  WordSearchBoard copyWith({
    Set<String>? foundWords,
  }) {
    return WordSearchBoard(
      size: size,
      grid: grid,
      targetWords: targetWords,
      foundWords: foundWords ?? this.foundWords,
    );
  }
}

abstract class WordSearchState {}

class WordSearchLoading extends WordSearchState {}

class WordSearchPlaying extends WordSearchState {
  static const int levelsPerCategory = 10;

  final WordSearchBoard board;
  final int categoryIndex;
  final int levelIndex;
  final String categoryName;
  final int totalCategories;
  final bool isCompleted;
  final int scoreEarned;
  final int totalScore;
  final int categoriesCompleted;

  WordSearchPlaying({
    required this.board,
    required this.categoryIndex,
    this.levelIndex = 0,
    required this.categoryName,
    this.totalCategories = 3,
    this.isCompleted = false,
    this.scoreEarned = 0,
    this.totalScore = 0,
    this.categoriesCompleted = 0,
  });

  int get levelsInCategory => levelsPerCategory;
  int get totalLevels => totalCategories * levelsPerCategory;
  int get currentOverallLevel => (categoryIndex * levelsPerCategory) + levelIndex + 1;

  WordSearchPlaying copyWith({
    WordSearchBoard? board,
    int? categoryIndex,
    int? levelIndex,
    String? categoryName,
    int? totalCategories,
    bool? isCompleted,
    int? scoreEarned,
    int? totalScore,
    int? categoriesCompleted,
  }) {
    return WordSearchPlaying(
      board: board ?? this.board,
      categoryIndex: categoryIndex ?? this.categoryIndex,
      levelIndex: levelIndex ?? this.levelIndex,
      categoryName: categoryName ?? this.categoryName,
      totalCategories: totalCategories ?? this.totalCategories,
      isCompleted: isCompleted ?? this.isCompleted,
      scoreEarned: scoreEarned ?? this.scoreEarned,
      totalScore: totalScore ?? this.totalScore,
      categoriesCompleted: categoriesCompleted ?? this.categoriesCompleted,
    );
  }
}

class WordSearchError extends WordSearchState {
  final String message;
  WordSearchError(this.message);
}

class WordSearchCubit extends Cubit<WordSearchState> {
  final WordGameRepository _repository = WordGameRepository();
  final ScoreRepository _scoreRepository = ScoreRepository();
  List<WordGame2Category> _categories = [];
  int _totalScore = 0;
  int _categoriesCompleted = 0;

  WordSearchCubit() : super(WordSearchLoading());

  Future<void> loadGame() async {
    emit(WordSearchLoading());
    try {
      _categories = await _repository.loadWordGame2Categories();
      if (_categories.isEmpty) {
        emit(WordSearchError('Сөздөр табылган жок'));
        return;
      }
      final progress = await _scoreRepository.getWordSearchProgress();
      _totalScore = progress.totalScore;
      _categoriesCompleted = progress.categoriesCompleted;

      int catIdx = progress.categoryIndex;
      int lvlIdx = progress.levelIndex;

      if (catIdx >= _categories.length) {
        catIdx = 0;
        lvlIdx = 0;
      } else if (lvlIdx >= WordSearchPlaying.levelsPerCategory) {
        lvlIdx = 0;
      }

      _generateBoard(catIdx, lvlIdx);
    } catch (e) {
      emit(WordSearchError('Оюнду жүктөөдө ката чыкты: $e'));
    }
  }

  void _generateBoard(int categoryIndex, int levelIndex) {
    const size = 6;
    final cat = _categories[categoryIndex];
    // Seeded Random for repeatable level generation
    final random = Random((categoryIndex + 1) * 1000 + levelIndex * 37 + 13);

    // Pick 4 words of length <= size
    final candidateWords = cat.words.where((w) => w.length >= 2 && w.length <= size).toList();
    candidateWords.shuffle(random);
    final targetWords = candidateWords.take(4).toList();

    // Create empty grid
    final grid = List.generate(size, (_) => List.generate(size, (_) => ''));

    // Place words horizontally or vertically
    for (final word in targetWords) {
      bool placed = false;
      int attempts = 0;
      while (!placed && attempts < 100) {
        attempts++;
        final horizontal = random.nextBool();
        final row = random.nextInt(horizontal ? size : size - word.length + 1);
        final col = random.nextInt(horizontal ? size - word.length + 1 : size);

        bool canPlace = true;
        for (int i = 0; i < word.length; i++) {
          final r = horizontal ? row : row + i;
          final c = horizontal ? col + i : col;
          if (grid[r][c] != '' && grid[r][c] != word[i]) {
            canPlace = false;
            break;
          }
        }

        if (canPlace) {
          for (int i = 0; i < word.length; i++) {
            final r = horizontal ? row : row + i;
            final c = horizontal ? col + i : col;
            grid[r][c] = word[i];
          }
          placed = true;
        }
      }
    }

    // Fill blanks with Kyrgyz alphabet letters
    const kyrgyzAlphabet = 'абвгдежзийклмнопрстуфхцчшщъыьэюяөүң';
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (grid[r][c] == '') {
          grid[r][c] = kyrgyzAlphabet[random.nextInt(kyrgyzAlphabet.length)];
        }
      }
    }

    String categoryTitle = '${categoryIndex + 1}-топтом';
    if (categoryIndex == 0) {
      categoryTitle = '1-топтом (Жөнөкөй)';
    } else if (categoryIndex == 1) {
      categoryTitle = '2-топтом (Орточо)';
    } else if (categoryIndex == 2) {
      categoryTitle = '3-топтом (Татаал)';
    }

    emit(WordSearchPlaying(
      board: WordSearchBoard(
        size: size,
        grid: grid,
        targetWords: targetWords,
        foundWords: {},
      ),
      categoryIndex: categoryIndex,
      levelIndex: levelIndex,
      categoryName: categoryTitle,
      totalCategories: _categories.length,
      isCompleted: false,
      scoreEarned: 0,
      totalScore: _totalScore,
      categoriesCompleted: _categoriesCompleted,
    ));
  }

  Future<void> submitSelectedWord(String word) async {
    if (state is! WordSearchPlaying) return;
    final s = state as WordSearchPlaying;
    final candidate = word.toLowerCase().trim();
    final reversed = candidate.split('').reversed.join();

    String? matched;
    if (s.board.targetWords.contains(candidate)) {
      matched = candidate;
    } else if (s.board.targetWords.contains(reversed)) {
      matched = reversed;
    }

    if (matched != null && !s.board.foundWords.contains(matched)) {
      final newFound = Set<String>.from(s.board.foundWords)..add(matched);
      final isAll = newFound.length >= s.board.targetWords.length;

      int scoreEarned = 0;
      if (isAll) {
        AudioController.instance.playLevelComplete();
        scoreEarned = (s.board.targetWords.length * 5) + 20;

        final updated = await _scoreRepository.recordWordSearchLevelCompleted(
          categoryIndex: s.categoryIndex,
          levelIndex: s.levelIndex,
          wordsFoundCount: s.board.targetWords.length,
          scoreEarned: scoreEarned,
          maxLevelsInCategory: WordSearchPlaying.levelsPerCategory,
          maxCategories: _categories.length,
        );
        _totalScore = updated.totalScore;
        _categoriesCompleted = updated.categoriesCompleted;
      } else {
        AudioController.instance.playWordSolved();
      }

      emit(s.copyWith(
        board: s.board.copyWith(foundWords: newFound),
        isCompleted: isAll,
        scoreEarned: scoreEarned,
        totalScore: _totalScore,
        categoriesCompleted: _categoriesCompleted,
      ));
    } else {
      AudioController.instance.playWrongWord();
    }
  }

  Future<void> nextLevel() async {
    if (state is! WordSearchPlaying) return;
    final s = state as WordSearchPlaying;
    int nextLevelIdx = s.levelIndex + 1;
    int nextCategoryIdx = s.categoryIndex;

    if (nextLevelIdx >= WordSearchPlaying.levelsPerCategory) {
      nextCategoryIdx = _categories.isNotEmpty ? (s.categoryIndex + 1) % _categories.length : 0;
      nextLevelIdx = 0;
    }

    await _scoreRepository.saveWordSearchCurrentPosition(nextCategoryIdx, nextLevelIdx);
    _generateBoard(nextCategoryIdx, nextLevelIdx);
  }

  // Alias for backward compatibility
  Future<void> nextCategory() => nextLevel();

  Future<void> restartGame() async {
    if (state is! WordSearchPlaying) return;
    await _scoreRepository.saveWordSearchCurrentPosition(0, 0);
    _generateBoard(0, 0);
  }
}
