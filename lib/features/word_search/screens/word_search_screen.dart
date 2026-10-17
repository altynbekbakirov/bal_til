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

class _WordSearchView extends StatefulWidget {
  const _WordSearchView();

  @override
  State<_WordSearchView> createState() => _WordSearchViewState();
}

class _WordSearchViewState extends State<_WordSearchView> {
  @override
  void initState() {
    super.initState();
    AudioController.instance.playGameplayMusic();
  }

  @override
  void dispose() {
    AudioController.instance.playMenuMusic();
    super.dispose();
  }

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
                    '${state.currentOverallLevel}/${state.totalLevels}-деңгээл (${state.levelIndex + 1}/${state.levelsInCategory})',
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
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.emeraldGreen.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 16, color: AppTheme.emeraldGreen),
                      const SizedBox(width: 4),
                      Text(
                        '${state.categoriesCompleted}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.emeraldGreen),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.military_tech_rounded, size: 18, color: AppTheme.skyTurquoise),
                      const SizedBox(width: 2),
                      Text(
                        '${state.totalScore}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.skyTurquoise),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: const Icon(Icons.help_outline_rounded, color: Color(0xFF1E293B), size: 26),
            tooltip: 'Кантип ойноо керек?',
            onPressed: () {
              AudioController.instance.playButtonClick();
              _showHowToPlayDialog(context);
            },
          ),
        ],
      ),
      body: BlocConsumer<WordSearchCubit, WordSearchState>(
        listenWhen: (previous, current) {
          return current is WordSearchPlaying &&
              current.isCompleted &&
              (previous is! WordSearchPlaying || !previous.isCompleted);
        },
        listener: (context, state) {
          if (state is WordSearchPlaying && state.isCompleted) {
            context.read<ScoreCubit>().loadScores();
            if (state.currentOverallLevel >= state.totalLevels) {
              _showGameCompletedDialog(context, state);
            } else {
              _showVictoryDialog(context, state);
            }
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

  void _showHowToPlayDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Кантип ойноо керек?',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(dialogCtx),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                '1. Торчодо жашырылган сөздөрдү табыңыз.\n\n'
                '2. Тамгаларды манжаңыз менен туурасынан же тигинен сызып белгилеңиз.\n\n'
                '3. Сөздөр алдыга да, артка да жазылышы мүмкүн.\n\n'
                '4. Төмөндө тизмеленген 4 сөз тең табылганда кийинки деңгээл ачылат!\n\n'
                '5. Ар бир табылган сөз үчүн +5 упай, деңгээл бүткөндө +20 бонус берилет. 🏆',
                style: TextStyle(fontSize: 14, height: 1.45, color: Color(0xFF334155)),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.emeraldGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: const Text('Түшүндүм'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showVictoryDialog(BuildContext context, WordSearchPlaying state) {
    bool isDismissing = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
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
                      '${state.currentOverallLevel}/${state.totalLevels}-деңгээл ийгиликтүү бүттү!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: isDismissing
                          ? null
                          : () {
                              setDialogState(() => isDismissing = true);
                              AudioController.instance.playButtonClick();
                              Navigator.pop(dialogCtx);
                              context.read<WordSearchCubit>().nextLevel();
                              context.read<ScoreCubit>().loadScores();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.emeraldGreen,
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
      },
    );
  }

  void _showGameCompletedDialog(BuildContext context, WordSearchPlaying state) {
    bool isDismissing = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.emeraldGreen.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.emoji_events_rounded,
                        size: 68,
                        color: AppTheme.emeraldGreen,
                      ),
                    ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                    const SizedBox(height: 16),
                    const Text(
                      'Куттуктайбыз! 🎉',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '«Сөз издөө» оюнунун бардык деңгээлдерин толугу менен аяктадыңыз!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            icon: Icons.check_circle_rounded,
                            iconColor: AppTheme.emeraldGreen,
                            value: '${state.categoriesCompleted}',
                            label: 'Бүткөн топтом',
                          ),
                          Container(width: 1, height: 36, color: const Color(0xFFE2E8F0)),
                          _buildStatItem(
                            icon: Icons.military_tech_rounded,
                            iconColor: AppTheme.skyTurquoise,
                            value: '${state.totalScore}',
                            label: 'Жалпы упай',
                          ),
                          Container(width: 1, height: 36, color: const Color(0xFFE2E8F0)),
                          _buildStatItem(
                            icon: Icons.task_alt_rounded,
                            iconColor: AppTheme.emeraldGreen,
                            value: '${state.totalLevels}/${state.totalLevels}',
                            label: 'Деңгээлдер',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isDismissing
                            ? null
                            : () {
                                setDialogState(() => isDismissing = true);
                                AudioController.instance.playButtonClick();
                                Navigator.pop(dialogCtx);
                                Navigator.pop(context);
                              },
                        icon: const Icon(Icons.home_rounded, size: 20),
                        label: const Text(
                          'Башкы бетке чыгуу',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.emeraldGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: isDismissing
                            ? null
                            : () {
                                setDialogState(() => isDismissing = true);
                                AudioController.instance.playButtonClick();
                                Navigator.pop(dialogCtx);
                                context.read<WordSearchCubit>().restartGame();
                                context.read<ScoreCubit>().loadScores();
                              },
                        icon: const Icon(Icons.replay_rounded, size: 20),
                        label: const Text(
                          'Кайра ойноо (1-деңгээлден)',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.emeraldGreen,
                          side: BorderSide(color: AppTheme.emeraldGreen.withValues(alpha: 0.5), width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
