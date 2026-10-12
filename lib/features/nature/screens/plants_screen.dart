import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/audio/audio_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../cubit/nature_cubit.dart';

class PlantsScreen extends StatelessWidget {
  const PlantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NatureCubit()..loadPlants(),
      child: const _PlantsView(),
    );
  }
}

class _PlantsView extends StatefulWidget {
  const _PlantsView();

  @override
  State<_PlantsView> createState() => _PlantsViewState();
}

class _PlantsViewState extends State<_PlantsView> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.84);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFCE8),
      appBar: AppBar(
        title: const Text(
          'Өсүмдүктөр',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B)),
          onPressed: () {
            AudioController.instance.playButtonClick();
            Navigator.pop(context);
          },
        ),
      ),
      body: BlocBuilder<NatureCubit, NatureState>(
        builder: (context, state) {
          if (state is NatureLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.emeraldGreen));
          }
          if (state is PlantsLoaded) {
            final plants = state.plants;
            return Column(
              children: [
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Кыргыз жериндеги дары чөптөр жана тоо өсүмдүктөрү',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.blueGrey.shade700),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: plants.length,
                    onPageChanged: (idx) {
                      AudioController.instance.playLetterSelect();
                      context.read<NatureCubit>().setActiveIndex(idx);
                    },
                    itemBuilder: (context, index) {
                      final plant = plants[index];
                      final isCurrent = index == state.activeIndex;
                      return AnimatedScale(
                        duration: const Duration(milliseconds: 300),
                        scale: isCurrent ? 1.0 : 0.88,
                        child: Card(
                          elevation: isCurrent ? 10 : 3,
                          shadowColor: Colors.black12,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                          child: Padding(
                            padding: const EdgeInsets.all(22),
                            child: Column(
                              children: [
                                Expanded(
                                  flex: 6,
                                  child: Image.asset(
                                    plant.imagePath,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, _, _) => const Icon(
                                      Icons.eco_rounded,
                                      size: 100,
                                      color: AppTheme.emeraldGreen,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  plant.name,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF15803D),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Expanded(
                                  flex: 4,
                                  child: SingleChildScrollView(
                                    physics: const BouncingScrollPhysics(),
                                    child: Text(
                                      plant.description,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        height: 1.45,
                                        color: Color(0xFF475569),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  '${state.activeIndex + 1} / ${plants.length}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 26),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

