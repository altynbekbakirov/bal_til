import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/audio/audio_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../cubit/nature_cubit.dart';

class AnimalsScreen extends StatelessWidget {
  const AnimalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NatureCubit()..loadAnimals(),
      child: const _AnimalsView(),
    );
  }
}

class _AnimalsView extends StatefulWidget {
  const _AnimalsView();

  @override
  State<_AnimalsView> createState() => _AnimalsViewState();
}

class _AnimalsViewState extends State<_AnimalsView> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.82);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      appBar: AppBar(
        title: const Text(
          'Жаныбарлар',
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
            return const Center(child: CircularProgressIndicator(color: AppTheme.skyTurquoise));
          }
          if (state is AnimalsLoaded) {
            final animals = state.animals;
            if (animals.isEmpty) {
              return const Center(child: Text('Маалымат табылган жок'));
            }
            return Column(
              children: [
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Кыргызстанда жашаган керемет жаныбарлар менен таанышкыла!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.blueGrey.shade700),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: animals.length,
                    onPageChanged: (idx) {
                      AudioController.instance.playLetterSelect();
                      context.read<NatureCubit>().setActiveIndex(idx);
                    },
                    itemBuilder: (context, index) {
                      final animal = animals[index];
                      final isCurrent = index == state.activeIndex;
                      return AnimatedScale(
                        duration: const Duration(milliseconds: 300),
                        scale: isCurrent ? 1.0 : 0.88,
                        child: Card(
                          elevation: isCurrent ? 10 : 3,
                          shadowColor: Colors.black12,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(32),
                              gradient: const LinearGradient(
                                colors: [Colors.white, Color(0xFFF8FAFC)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Image.asset(
                                    animal.imagePath,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, _, _) => const Icon(
                                      Icons.pets_rounded,
                                      size: 100,
                                      color: AppTheme.skyTurquoise,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.skyTurquoise.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    animal.name,
                                    style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0369A1),
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
                const SizedBox(height: 16),
                Text(
                  '${state.activeIndex + 1} / ${animals.length}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}


