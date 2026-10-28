import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/score_models.dart';
import '../../data/repositories/score_repository.dart';

class ScoreState {
  final WordConnectProgress wordConnect;
  final WordSearchProgress wordSearch;
  final AnimalsProgress animals;
  final PlantsProgress plants;
  final OverallScore overall;
  final bool isLoading;

  const ScoreState({
    this.wordConnect = const WordConnectProgress(),
    this.wordSearch = const WordSearchProgress(),
    this.animals = const AnimalsProgress(),
    this.plants = const PlantsProgress(),
    this.overall = const OverallScore(),
    this.isLoading = false,
  });

  ScoreState copyWith({
    WordConnectProgress? wordConnect,
    WordSearchProgress? wordSearch,
    AnimalsProgress? animals,
    PlantsProgress? plants,
    OverallScore? overall,
    bool? isLoading,
  }) {
    return ScoreState(
      wordConnect: wordConnect ?? this.wordConnect,
      wordSearch: wordSearch ?? this.wordSearch,
      animals: animals ?? this.animals,
      plants: plants ?? this.plants,
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
    final animals = await _repository.getAnimalsProgress();
    final plants = await _repository.getPlantsProgress();
    final overall = OverallScore(
      totalScore: wc.totalScore + ws.totalScore + animals.totalScore + plants.totalScore,
      totalStars: wc.totalStars + ws.totalStars + animals.totalStars + plants.totalStars,
      wordConnectCompleted: wc.levelsCompleted,
      wordSearchCompleted: ws.levelsCompleted,
      animalsCompleted: animals.itemsCompleted,
      plantsCompleted: plants.itemsCompleted,
    );

    emit(ScoreState(
      wordConnect: wc,
      wordSearch: ws,
      animals: animals,
      plants: plants,
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

  Future<void> updateWordSearchPosition(int categoryIndex, int levelIndex) async {
    await _repository.saveWordSearchCurrentPosition(categoryIndex, levelIndex);
    emit(state.copyWith(
      wordSearch: state.wordSearch.copyWith(
        categoryIndex: categoryIndex,
        levelIndex: levelIndex,
      ),
    ));
  }

  Future<void> updateAnimalsPosition(int index) async {
    await _repository.saveAnimalsCurrentPosition(index);
    emit(state.copyWith(
      animals: state.animals.copyWith(currentIndex: index),
    ));
  }

  Future<void> updatePlantsPosition(int index) async {
    await _repository.savePlantsCurrentPosition(index);
    emit(state.copyWith(
      plants: state.plants.copyWith(currentIndex: index),
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
      totalScore: updatedWc.totalScore + state.wordSearch.totalScore + state.animals.totalScore + state.plants.totalScore,
      totalStars: updatedWc.totalStars + state.wordSearch.totalStars + state.animals.totalStars + state.plants.totalStars,
      wordConnectCompleted: updatedWc.levelsCompleted,
      wordSearchCompleted: state.wordSearch.levelsCompleted,
      animalsCompleted: state.animals.itemsCompleted,
      plantsCompleted: state.plants.itemsCompleted,
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
    int starsEarned = 3,
    required int totalCategories,
  }) async {
    final updatedWs = await _repository.recordWordSearchCategoryCompleted(
      categoryIndex: categoryIndex,
      wordsFoundCount: wordsFoundCount,
      scoreEarned: scoreEarned,
      starsEarned: starsEarned,
      totalCategories: totalCategories,
    );

    final overall = OverallScore(
      totalScore: state.wordConnect.totalScore + updatedWs.totalScore + state.animals.totalScore + state.plants.totalScore,
      totalStars: state.wordConnect.totalStars + updatedWs.totalStars + state.animals.totalStars + state.plants.totalStars,
      wordConnectCompleted: state.wordConnect.levelsCompleted,
      wordSearchCompleted: updatedWs.levelsCompleted,
      animalsCompleted: state.animals.itemsCompleted,
      plantsCompleted: state.plants.itemsCompleted,
    );

    emit(state.copyWith(
      wordSearch: updatedWs,
      overall: overall,
    ));
    return updatedWs;
  }

  Future<AnimalsProgress> recordAnimalsCompleted({
    required int itemIndex,
    required int starsEarned,
    required int scoreEarned,
    required int totalItems,
  }) async {
    final updatedAnimals = await _repository.recordAnimalsItemCompleted(
      itemIndex: itemIndex,
      starsEarned: starsEarned,
      scoreEarned: scoreEarned,
      totalItems: totalItems,
    );

    final overall = OverallScore(
      totalScore: state.wordConnect.totalScore + state.wordSearch.totalScore + updatedAnimals.totalScore + state.plants.totalScore,
      totalStars: state.wordConnect.totalStars + state.wordSearch.totalStars + updatedAnimals.totalStars + state.plants.totalStars,
      wordConnectCompleted: state.wordConnect.levelsCompleted,
      wordSearchCompleted: state.wordSearch.levelsCompleted,
      animalsCompleted: updatedAnimals.itemsCompleted,
      plantsCompleted: state.plants.itemsCompleted,
    );

    emit(state.copyWith(
      animals: updatedAnimals,
      overall: overall,
    ));
    return updatedAnimals;
  }

  Future<PlantsProgress> recordPlantsCompleted({
    required int itemIndex,
    required int starsEarned,
    required int scoreEarned,
    required int totalItems,
  }) async {
    final updatedPlants = await _repository.recordPlantsItemCompleted(
      itemIndex: itemIndex,
      starsEarned: starsEarned,
      scoreEarned: scoreEarned,
      totalItems: totalItems,
    );

    final overall = OverallScore(
      totalScore: state.wordConnect.totalScore + state.wordSearch.totalScore + state.animals.totalScore + updatedPlants.totalScore,
      totalStars: state.wordConnect.totalStars + state.wordSearch.totalStars + state.animals.totalStars + updatedPlants.totalStars,
      wordConnectCompleted: state.wordConnect.levelsCompleted,
      wordSearchCompleted: state.wordSearch.levelsCompleted,
      animalsCompleted: state.animals.itemsCompleted,
      plantsCompleted: updatedPlants.itemsCompleted,
    );

    emit(state.copyWith(
      plants: updatedPlants,
      overall: overall,
    ));
    return updatedPlants;
  }

  Future<void> resetAll() async {
    await _repository.resetAll();
    emit(const ScoreState(
      wordConnect: WordConnectProgress(),
      wordSearch: WordSearchProgress(),
      animals: AnimalsProgress(),
      plants: PlantsProgress(),
      overall: OverallScore(),
      isLoading: false,
    ));
  }
}

