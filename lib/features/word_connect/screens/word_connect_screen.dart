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
                '${state.packs[state.packIndex].title} • ${state.levelIndex + 1}-деңгээл',
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
        actions: [
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
                  const SizedBox(height: 8),
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
                          hintedLetters: state.hintedLetters,
                        ),
                      ),
                    ),
                  ),

                  // Attempt Preview & Feedback Banner
                  Container(
                    height: 52,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildFeedbackOrAttempt(state, context),
                  ),

                  const SizedBox(height: 6),

                  // Action Buttons + Circular Word Wheel
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Shuffle button
                          _CircleActionButton(
                            icon: Icons.shuffle_rounded,
                            tooltip: 'Аралаштыруу',
                            onTap: () => context.read<WordConnectCubit>().shuffleLetters(),
                          ),
                          const SizedBox(width: 8),
                          // Wheel
                          Expanded(
                            child: AspectRatio(
                              aspectRatio: 1.0,
                              child: WordWheel(
                                letters: state.currentLetters,
                                currentAttempt: state.currentAttempt,
                                onWordChanged: (word) {
                                  context.read<WordConnectCubit>().updateAttempt(word);
                                },
                                onWordCompleted: () {
                                  context.read<WordConnectCubit>().submitAttempt();
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Hint button
                          _CircleActionButton(
                            icon: Icons.lightbulb_outline_rounded,
                            tooltip: 'Кеңеш',
                            onTap: () => context.read<WordConnectCubit>().giveHint(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Tap mode actions if letters entered
                  if (state.currentAttempt.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12, top: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              AudioController.instance.playButtonClick();
                              context.read<WordConnectCubit>().clearAttempt();
                            },
                            icon: const Icon(Icons.close_rounded, size: 18),
                            label: const Text('Тазалоо'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF64748B),
                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                            ),
                          ),
                          const SizedBox(width: 14),
                          ElevatedButton.icon(
                            onPressed: () => context.read<WordConnectCubit>().submitAttempt(),
                            icon: const Icon(Icons.check_rounded, size: 18),
                            label: const Text('Текшерүү'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryAmber,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    const SizedBox(height: 16),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildFeedbackOrAttempt(WordConnectPlaying state, BuildContext context) {
    if (state.feedback.text.isNotEmpty) {
      Color bg;
      Color textColor = Colors.white;
      IconData icon;

      switch (state.feedback.type) {
        case FeedbackType.success:
          bg = AppTheme.emeraldGreen;
          icon = Icons.check_circle_rounded;
          break;
        case FeedbackType.warning:
          bg = AppTheme.primaryAmber;
          icon = Icons.info_outline_rounded;
          break;
        case FeedbackType.error:
          bg = AppTheme.coralRed;
          icon = Icons.cancel_rounded;
          break;
        case FeedbackType.none:
          bg = const Color(0xFF64748B);
          icon = Icons.info_outline_rounded;
          break;
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: bg.withValues(alpha: 0.35), blurRadius: 8, offset: const Offset(0, 3)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              state.feedback.text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ).animate().scale(duration: 180.ms);
    }

    if (state.currentAttempt.isNotEmpty) {
      return Container(
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
            letterSpacing: 3.0,
          ),
        ),
      ).animate().scale(duration: 150.ms);
    }

    return const SizedBox.shrink();
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
                '1. Тегерекчедеги тамгалардын үстүнөн манжаңызды көтөрбөй сызыңыз (же тамгаларды бирден басыңыз).\n\n'
                '2. Манжаңызды көтөргөндө сөз автоматтык түрдө текшерилет.\n\n'
                '3. Мисалы, 1-деңгээлде төмөнкү сөздөр бар:\n'
                '   • О -> Т = «ОТ»\n'
                '   • О -> К = «ОК»\n'
                '   • Т -> О -> К = «ТОК»\n'
                '   • Т -> О -> О = «ТОО»\n'
                '   • Т -> О -> О -> К = «ТООК»\n\n'
                '4. Бардык сөздөр табылганда кийинки деңгээл ачылат!',
                style: TextStyle(fontSize: 14, height: 1.45, color: Color(0xFF334155)),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryAmber,
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

class _CircleActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _CircleActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      shadowColor: Colors.black12,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          AudioController.instance.playButtonClick();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: AppTheme.primaryDarkAmber, size: 26),
        ),
      ),
    );
  }
}


