import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/score_models.dart';
import '../../data/repositories/score_repository.dart';

class ScoreState {
  final WordConnectProgress wordConnect;
  final WordSearchProgress wordSearch;
  final OverallScore overall;
  final bool isLoading;

  const ScoreState({
    this.wordConnect = const WordConnectProgress(),
    this.wordSearch = const WordSearchProgress(),
    this.overall = const OverallScore(),
    this.isLoading = false,
  });

  ScoreState copyWith({
    WordConnectProgress? wordConnect,
    WordSearchProgress? wordSearch,
    OverallScore? overall,
    bool? isLoading,
  }) {
    return ScoreState(
      wordConnect: wordConnect ?? this.wordConnect,
      wordSearch: wordSearch ?? this.wordSearch,
      overall: overall ?? this.overall,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ScoreCubit extends Cubit<ScoreState> {
  final ScoreRepository _repository;

  ScoreCubit({ScoreRepository? repository})
      : _repository = repository ?? ScoreRepository(),
        super(const ScoreState(isLoading: true));

  Future<void> loadScores() async {
    final wc = await _repository.getWordConnectProgress();
    final ws = await _repository.getWordSearchProgress();
    final overall = OverallScore(
      totalScore: wc.totalScore + ws.totalScore,
      totalStars: wc.totalStars,
      wordConnectCompleted: wc.levelsCompleted,
      wordSearchCompleted: ws.categoriesCompleted,
    );

    emit(ScoreState(
      wordConnect: wc,
      wordSearch: ws,
      overall: overall,
      isLoading: false,
    ));
  }

  Future<void> updateWordConnectPosition(int packIndex, int levelIndex) async {
    await _repository.saveWordConnectCurrentPosition(packIndex, levelIndex);
    emit(state.copyWith(
      wordConnect: state.wordConnect.copyWith(
        packIndex: packIndex,
        levelIndex: levelIndex,
      ),
    ));
  }

  Future<WordConnectProgress> recordWordConnectCompleted({
    required int packIndex,
    required int levelIndex,
    required int starsEarned,
    required int scoreEarned,
    required int maxLevelsInPack,
    required int maxPacks,
  }) async {
    final updatedWc = await _repository.recordWordConnectLevelCompleted(
      packIndex: packIndex,
      levelIndex: levelIndex,
      starsEarned: starsEarned,
      scoreEarned: scoreEarned,
      maxLevelsInPack: maxLevelsInPack,
      maxPacks: maxPacks,
    );

    final overall = OverallScore(
      totalScore: updatedWc.totalScore + state.wordSearch.totalScore,
      totalStars: updatedWc.totalStars,
      wordConnectCompleted: updatedWc.levelsCompleted,
      wordSearchCompleted: state.wordSearch.categoriesCompleted,
    );

    emit(state.copyWith(
      wordConnect: updatedWc,
      overall: overall,
    ));
    return updatedWc;
  }

  Future<WordSearchProgress> recordWordSearchCompleted({
    required int categoryIndex,
    required int wordsFoundCount,
    required int scoreEarned,
    required int totalCategories,
  }) async {
    final updatedWs = await _repository.recordWordSearchCategoryCompleted(
      categoryIndex: categoryIndex,
      wordsFoundCount: wordsFoundCount,
      scoreEarned: scoreEarned,
      totalCategories: totalCategories,
    );

    final overall = OverallScore(
      totalScore: state.wordConnect.totalScore + updatedWs.totalScore,
      totalStars: state.wordConnect.totalStars,
      wordConnectCompleted: state.wordConnect.levelsCompleted,
      wordSearchCompleted: updatedWs.categoriesCompleted,
    );

    emit(state.copyWith(
      wordSearch: updatedWs,
      overall: overall,
    ));
    return updatedWs;
  }

  Future<void> resetAll() async {
    await _repository.resetAll();
    emit(const ScoreState(
      wordConnect: WordConnectProgress(),
      wordSearch: WordSearchProgress(),
      overall: OverallScore(),
      isLoading: false,
    ));
  }
}
