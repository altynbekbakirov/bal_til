import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../alippe/core/alippe_audio.dart';
import '../../../configs/routes.dart';
import '../../../core/audio/audio_controller.dart';
import '../../../core/audio/audio_cubit.dart';
import '../../../core/score/score_cubit.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_orientation.dart';
import '../widgets/game_selection_modal.dart';
import '../widgets/menu_button.dart';
import '../widgets/settings_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    AudioController.instance.isBalTilActive = true;
    AlippeAudio().isAlippeActive = false;
    AppOrientation.setPortrait();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_played_game', 'bal_til');
      if (mounted) {
        await context.read<AudioCubit>().loadPreferences();
        if (AudioController.instance.isMusicEnabled && AudioController.instance.isBalTilActive) {
          AudioController.instance.playMenuMusic();
        }
      }
    });
  }

  void _exitToGameSelect() {
    AudioController.instance.isBalTilActive = false;
    if (mounted) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pushNamedAndRemoveUntil(Routers.gameSelect, (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _exitToGameSelect();
      },
      child: Scaffold(
        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 20, 12),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, size: 26, color: Color(0xFF0F172A)),
                        tooltip: 'Оюн тандоого кайтуу',
                        onPressed: () {
                          AudioController.instance.playButtonClick();
                          _exitToGameSelect();
                        },
                      ),
                      const SizedBox(width: 4),
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
                    const SizedBox(width: 4),
                    // Game Selector Icon Button
                    IconButton(
                      icon: const Icon(Icons.sports_esports_rounded, size: 28, color: Color(0xFFEA580C)),
                      tooltip: 'Оюн тандаңыз (3–6 / 7–10 жаш)',
                      onPressed: () {
                        AudioController.instance.playButtonClick();
                        GameSelectionModal.show(context);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings_rounded, size: 28, color: Color(0xFF475569)),
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
            // Alippe Quick Selection Banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: InkWell(
                  onTap: () {
                    AudioController.instance.playButtonClick();
                    GameSelectionModal.show(context);
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFF7ED), Color(0xFFFFEDD5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFDBA74), width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: const BoxDecoration(
                            color: Color(0xFFEA580C),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.child_care_rounded, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '«Алиппе» (3 – 6 жаш) оюну',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF9A3412),
                                ),
                              ),
                              Text(
                                'Бала бакча курагы үчүн сүрөттүү алиппе жана оюндар',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFFC2410C),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEA580C),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Тандоо ➜',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
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
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
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
                            ),
                          ),
                          Container(height: 28, width: 1, color: const Color(0xFFE2E8F0)),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
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
                            ),
                          ),
                          Container(height: 28, width: 1, color: const Color(0xFFE2E8F0)),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
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
                            ),
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
                    subtitle: 'Тамгаларды кошуп сөз кура • 34 деңгээл',
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
                    subtitle: 'Торчодогу сөздөрдү тап • 30 деңгээл',
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
    ),
    );
  }
}
