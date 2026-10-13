import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../configs/routes.dart';
import '../../../core/audio/audio_controller.dart';
import '../../../core/score/score_cubit.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/menu_button.dart';
import '../widgets/settings_dialog.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryAmber.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.auto_stories_rounded,
                              color: AppTheme.primaryDarkAmber,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Бал тил',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                Text(
                                  'Кыргызча интерактивдүү алиппе',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.settings_rounded, size: 30, color: Color(0xFF475569)),
                      onPressed: () {
                        AudioController.instance.playButtonClick();
                        showDialog(
                          context: context,
                          builder: (_) => const SettingsDialog(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: BlocBuilder<ScoreCubit, ScoreState>(
                builder: (context, state) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0A000000),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(7),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFDE68A),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.star_rounded, color: AppTheme.primaryDarkAmber, size: 20),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${state.overall.totalStars}',
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  const Text(
                                    'Жылдыз',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(height: 28, width: 1, color: const Color(0xFFE2E8F0)),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: AppTheme.skyTurquoise.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.military_tech_rounded, color: AppTheme.skyTurquoise, size: 20),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${state.overall.totalScore}',
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  const Text(
                                    'Упай',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(height: 28, width: 1, color: const Color(0xFFE2E8F0)),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: AppTheme.emeraldGreen.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check_circle_rounded, color: AppTheme.emeraldGreen, size: 20),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${state.overall.wordConnectCompleted + state.overall.wordSearchCompleted}',
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  const Text(
                                    'Деңгээл',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 350.ms);
                },
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  MenuCardButton(
                    title: 'Сөздү тап',
                    subtitle: 'Тамгаларды кошуп сөз кура (Word Connect)',
                    icon: Icons.extension_rounded,
                    primaryColor: const Color(0xFFF59E0B),
                    secondaryColor: const Color(0xFFEA580C),
                    onTap: () async {
                      await Navigator.pushNamed(context, Routers.wordConnect);
                      if (context.mounted) {
                        context.read<ScoreCubit>().loadScores();
                      }
                    },
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, duration: 400.ms),
                  const SizedBox(height: 16),
                  MenuCardButton(
                    title: 'Сөз издөө',
                    subtitle: 'Торчодогу жашырылган сөздөрдү тап (Word Search)',
                    icon: Icons.grid_view_rounded,
                    primaryColor: const Color(0xFF10B981),
                    secondaryColor: const Color(0xFF059669),
                    onTap: () async {
                      await Navigator.pushNamed(context, Routers.wordSearch);
                      if (context.mounted) {
                        context.read<ScoreCubit>().loadScores();
                      }
                    },
                  ).animate().fadeIn(delay: 80.ms, duration: 400.ms).slideY(begin: 0.1, duration: 400.ms),
                  const SizedBox(height: 16),
                  MenuCardButton(
                    title: 'Жаныбарлар',
                    subtitle: 'Кыргызстандын жапайы жана үй жаныбарлары',
                    icon: Icons.pets_rounded,
                    primaryColor: const Color(0xFF0EA5E9),
                    secondaryColor: const Color(0xFF0284C7),
                    onTap: () => Navigator.pushNamed(context, Routers.animals),
                  ).animate().fadeIn(delay: 160.ms, duration: 400.ms).slideY(begin: 0.1, duration: 400.ms),
                  const SizedBox(height: 16),
                  MenuCardButton(
                    title: 'Өсүмдүктөр',
                    subtitle: 'Тоо гүлдөрү, дары чөптөр жана мөмөлөр',
                    icon: Icons.eco_rounded,
                    primaryColor: const Color(0xFF84CC16),
                    secondaryColor: const Color(0xFF65A30D),
                    onTap: () => Navigator.pushNamed(context, Routers.plants),
                  ).animate().fadeIn(delay: 240.ms, duration: 400.ms).slideY(begin: 0.1, duration: 400.ms),
                  const SizedBox(height: 16),
                  MenuCardButton(
                    title: 'Кыргызстан картасы',
                    subtitle: 'Облустар, шаарлар жана тарыхый жерлер',
                    icon: Icons.map_rounded,
                    primaryColor: const Color(0xFF8B5CF6),
                    secondaryColor: const Color(0xFF6D28D9),
                    onTap: () => Navigator.pushNamed(context, Routers.map),
                  ).animate().fadeIn(delay: 320.ms, duration: 400.ms).slideY(begin: 0.1, duration: 400.ms),
                  const SizedBox(height: 16),
                  MenuCardButton(
                    title: 'Мамлекеттик гимн',
                    subtitle: 'Кыргыз Республикасынын улуттук гимни',
                    icon: Icons.music_note_rounded,
                    primaryColor: const Color(0xFFF43F5E),
                    secondaryColor: const Color(0xFFE11D48),
                    onTap: () => Navigator.pushNamed(context, Routers.anthem),
                  ).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideY(begin: 0.1, duration: 400.ms),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
