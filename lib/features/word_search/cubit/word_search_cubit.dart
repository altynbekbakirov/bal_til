import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repositories.dart';
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
  final WordSearchBoard board;
  final int categoryIndex;
  final bool isCompleted;

  WordSearchPlaying({
    required this.board,
    required this.categoryIndex,
    this.isCompleted = false,
  });
}

class WordSearchError extends WordSearchState {
  final String message;
  WordSearchError(this.message);
}

class WordSearchCubit extends Cubit<WordSearchState> {
  final WordGameRepository _repository = WordGameRepository();
  List<WordGame2Category> _categories = [];

  WordSearchCubit() : super(WordSearchLoading());

  Future<void> loadGame() async {
    emit(WordSearchLoading());
    try {
      _categories = await _repository.loadWordGame2Categories();
      if (_categories.isEmpty) {
        emit(WordSearchError('Сөздөр табылган жок'));
        return;
      }
      _generateBoard(0);
    } catch (e) {
      emit(WordSearchError('Оюнду жүктөөдө ката чыкты: $e'));
    }
  }

  void _generateBoard(int categoryIndex) {
    const size = 6;
    final cat = _categories[categoryIndex];
    final random = Random();

    // Pick 4-5 words of length <= size
    final candidateWords = cat.words.where((w) => w.length >= 2 && w.length <= size).toList();
    candidateWords.shuffle(random);
    final targetWords = candidateWords.take(4).toList();

    // Create empty grid
    final grid = List.generate(size, (_) => List.generate(size, (_) => ''));

    // Place words horizontally or vertically
    for (final word in targetWords) {
      bool placed = false;
      int attempts = 0;
      while (!placed && attempts < 50) {
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

    emit(WordSearchPlaying(
      board: WordSearchBoard(
        size: size,
        grid: grid,
        targetWords: targetWords,
        foundWords: {},
      ),
      categoryIndex: categoryIndex,
      isCompleted: false,
    ));
  }

  void submitSelectedWord(String word) {
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

      if (isAll) {
        AudioController.instance.playLevelComplete();
      } else {
        AudioController.instance.playWordSolved();
      }

      emit(WordSearchPlaying(
        board: s.board.copyWith(foundWords: newFound),
        categoryIndex: s.categoryIndex,
        isCompleted: isAll,
      ));
    } else {
      AudioController.instance.playWrongWord();
    }
  }

  void nextCategory() {
    if (state is! WordSearchPlaying) return;
    final s = state as WordSearchPlaying;
    final nextIdx = (s.categoryIndex + 1) % _categories.length;
    _generateBoard(nextIdx);
  }
}

