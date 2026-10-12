import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repositories.dart';

abstract class NatureState {}

class NatureLoading extends NatureState {}

class AnimalsLoaded extends NatureState {
  final List<AnimalModel> animals;
  final int activeIndex;
  AnimalsLoaded({required this.animals, this.activeIndex = 0});
}

class PlantsLoaded extends NatureState {
  final List<PlantModel> plants;
  final int activeIndex;
  PlantsLoaded({required this.plants, this.activeIndex = 0});
}

class NatureError extends NatureState {
  final String message;
  NatureError(this.message);
}

class NatureCubit extends Cubit<NatureState> {
  final NatureRepository _repository = NatureRepository();

  NatureCubit() : super(NatureLoading());

  Future<void> loadAnimals() async {
    emit(NatureLoading());
    try {
      final list = await _repository.loadAnimals();
      emit(AnimalsLoaded(animals: list));
    } catch (e) {
      emit(NatureError('Жаныбарлар жүктөлгөн жок: $e'));
    }
  }

  Future<void> loadPlants() async {
    emit(NatureLoading());
    try {
      final list = await _repository.loadPlants();
      emit(PlantsLoaded(plants: list));
    } catch (e) {
      emit(NatureError('Өсүмдүктөр жүктөлгөн жок: $e'));
    }
  }

  void setActiveIndex(int index) {
    if (state is AnimalsLoaded) {
      final s = state as AnimalsLoaded;
      emit(AnimalsLoaded(animals: s.animals, activeIndex: index));
    } else if (state is PlantsLoaded) {
      final s = state as PlantsLoaded;
      emit(PlantsLoaded(plants: s.plants, activeIndex: index));
    }
  }
}

