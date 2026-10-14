import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/audio/audio_controller.dart';
import '../../../core/score/score_cubit.dart';
import '../../../core/theme/app_theme.dart';
import '../cubit/word_search_cubit.dart';
import '../widgets/grid_board.dart';

class WordSearchScreen extends StatelessWidget {
  const WordSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WordSearchCubit()..loadGame(),
      child: const _WordSearchView(),
    );
  }
}

class _WordSearchView extends StatelessWidget {
  const _WordSearchView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECFDF5),
      appBar: AppBar(
        title: BlocBuilder<WordSearchCubit, WordSearchState>(
          builder: (context, state) {
            if (state is WordSearchPlaying) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Сөз издөө',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  Text(
                    '${state.categoryIndex + 1}/${state.totalCategories}-деңгээл (${state.categoryName})',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.emeraldGreen),
                  ),
                ],
              );
            }
            return const Text(
              'Сөз издөө',
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            );
          },
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B)),
          onPressed: () {
            AudioController.instance.playButtonClick();
            Navigator.pop(context);
          },
        ),
        actions: [
          BlocBuilder<WordSearchCubit, WordSearchState>(
            builder: (context, state) {
              if (state is WordSearchPlaying) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.emeraldGreen.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.military_tech_rounded, size: 18, color: AppTheme.emeraldGreen),
                      const SizedBox(width: 4),
                      Text(
                        '${state.totalScore}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.emeraldGreen),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.check_circle_rounded, size: 16, color: AppTheme.skyTurquoise),
                      const SizedBox(width: 4),
                      Text(
                        '${state.categoriesCompleted}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.skyTurquoise),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<WordSearchCubit, WordSearchState>(
        listener: (context, state) {
          if (state is WordSearchPlaying && state.isCompleted) {
            context.read<ScoreCubit>().loadScores();
            _showVictoryDialog(context, state);
          }
        },
        builder: (context, state) {
          if (state is WordSearchLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.emeraldGreen));
          }
          if (state is WordSearchPlaying) {
            final board = state.board;
            return SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  // Solved counter badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.emeraldGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Табылды: ${board.foundWords.length} / ${board.targetWords.length}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.emeraldGreen,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Word Checklist
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: board.targetWords.map((word) {
                        final isFound = board.foundWords.contains(word);
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isFound ? AppTheme.emeraldGreen : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isFound ? AppTheme.emeraldGreen : Colors.grey.shade300,
                              width: 2,
                            ),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                            ],
                          ),
                          child: Text(
                            word.toUpperCase(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              decoration: isFound ? TextDecoration.lineThrough : null,
                              decorationThickness: 2,
                              color: isFound ? Colors.white : const Color(0xFF334155),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Grid Board
                  Expanded(
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: GridBoard(
                            grid: board.grid,
                            onWordSelected: (word) {
                              context.read<WordSearchCubit>().submitSelectedWord(word);
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

  void _showVictoryDialog(BuildContext context, WordSearchPlaying state) {
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
                const Icon(Icons.emoji_events_rounded, size: 72, color: AppTheme.emeraldGreen)
                    .animate()
                    .scale(duration: 500.ms, curve: Curves.elasticOut),
                const SizedBox(height: 12),
                const Text(
                  'Куттуктайбыз!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '+${state.scoreEarned} упай топтолду!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.emeraldGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${state.categoryIndex + 1}/${state.totalCategories}-деңгээл ийгиликтүү бүттү!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    AudioController.instance.playButtonClick();
                    Navigator.pop(dialogCtx);
                    context.read<WordSearchCubit>().nextCategory();
                    context.read<ScoreCubit>().loadScores();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.emeraldGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text(
                    'Кийинки топтом',
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
