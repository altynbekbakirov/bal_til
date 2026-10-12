import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/audio/audio_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../cubit/word_connect_cubit.dart';
import '../widgets/word_matrix.dart';
import '../widgets/word_wheel.dart';

class WordConnectScreen extends StatelessWidget {
  const WordConnectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WordConnectCubit()..loadGame(),
      child: const _WordConnectView(),
    );
  }
}

class _WordConnectView extends StatelessWidget {
  const _WordConnectView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBEB),
      appBar: AppBar(
        title: BlocBuilder<WordConnectCubit, WordConnectState>(
          builder: (context, state) {
            if (state is WordConnectPlaying) {
              return Text(
                '${state.packs[state.packIndex].title} • Деңгээл ${state.levelIndex + 1}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              );
            }
            return const Text('Сөздү тап');
          },
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B)),
          onPressed: () {
            AudioController.instance.playButtonClick();
            Navigator.pop(context);
          },
        ),
      ),
      body: BlocConsumer<WordConnectCubit, WordConnectState>(
        listener: (context, state) {
          if (state is WordConnectPlaying && state.isCompleted) {
            _showVictoryDialog(context);
          }
        },
        builder: (context, state) {
          if (state is WordConnectLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryAmber));
          }
          if (state is WordConnectPlaying) {
            return SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  // Word Slots
                  Expanded(
                    flex: 4,
                    child: Center(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: WordMatrix(
                          targetWords: state.level.words,
                          solvedWords: state.solvedWords,
                        ),
                      ),
                    ),
                  ),
                  // Currently dragged word preview banner
                  Container(
                    height: 48,
                    alignment: Alignment.center,
                    child: state.currentAttempt.isNotEmpty
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryAmber,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryAmber.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Text(
                              state.currentAttempt.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ).animate().scale(duration: 150.ms)
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 10),
                  // Circular Word Wheel
                  Expanded(
                    flex: 5,
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: WordWheel(
                            letters: state.level.letters,
                            onWordChanged: (word) {
                              context.read<WordConnectCubit>().updateAttempt(word);
                            },
                            onWordCompleted: () {
                              context.read<WordConnectCubit>().submitAttempt();
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showVictoryDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, size: 72, color: AppTheme.sunnyYellow)
                    .animate()
                    .scale(duration: 500.ms, curve: Curves.elasticOut),
                const SizedBox(height: 12),
                const Text(
                  'Азаматсың!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Баардык сөздөр туура табылды!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 26),
                ElevatedButton(
                  onPressed: () {
                    AudioController.instance.playButtonClick();
                    Navigator.pop(dialogCtx);
                    context.read<WordConnectCubit>().nextLevel();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryAmber,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text(
                    'Кийинки деңгээл',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

