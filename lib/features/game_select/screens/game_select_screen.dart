import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';
import '../../../alippe/core/alippe_audio.dart';
import '../../../configs/routes.dart';
import '../../../core/audio/audio_controller.dart';
import '../../../core/audio/audio_cubit.dart';
import '../../../core/services/common_services.dart';
import '../../../core/services/upgrader_messages_ky.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_orientation.dart';
import '../../home/widgets/settings_dialog.dart';

class GameSelectScreen extends StatefulWidget {
  const GameSelectScreen({super.key});

  @override
  State<GameSelectScreen> createState() => _GameSelectScreenState();
}

class _GameSelectScreenState extends State<GameSelectScreen> with RouteAware {
  String? _lastPlayedGame; // 'bal_til' or 'alippe'
  DateTime? _timeBackPressed;
  Upgrader? _upgrader;

  static Upgrader? _sharedUpgrader;
  static bool _alertDismissed = false;

  @override
  void initState() {
    super.initState();
    _resetOrientationAndAudio();
    _loadPreferences();
    _initUpgrader();
  }

  @override
  void dispose() {
    ExitNotificationOverlay.hide();
    super.dispose();
  }

  Future<void> _initUpgrader() async {
    // Reuse existing instance if already initialized this session
    if (_sharedUpgrader != null) {
      if (mounted) setState(() => _upgrader = _sharedUpgrader);
      return;
    }

    final upgrader = Upgrader(
      storeController: UpgraderStoreController(
        onAndroid: () => UpgraderPlayStore(),
        oniOS: () => UpgraderAppStore(),
      ),
      messages: UpgraderMessagesKy(),
      durationUntilAlertAgain: kDebugMode
          ? Duration.zero
          : const Duration(days: 1),
      debugLogging: kDebugMode,
    );
    if (kDebugMode) {
      await Upgrader.clearSavedSettings();
    }
    _sharedUpgrader = upgrader;
    if (mounted) {
      setState(() => _upgrader = upgrader);
    }
  }

  Future<void> _resetOrientationAndAudio() async {
    AudioController.instance.isBalTilActive = false;
    AlippeAudio().isAlippeActive = false;
    await AppOrientation.forcePortrait();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final lastGame = prefs.getString('last_played_game');
    if (mounted) {
      setState(() {
        _lastPlayedGame = lastGame;
      });
      await context.read<AudioCubit>().loadPreferences();
      if (AudioController.instance.isMusicEnabled) {
        AudioController.instance.playMenuMusic();
      }
    }
  }

  Future<void> _saveLastGame(String game) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_played_game', game);
    if (mounted) {
      setState(() {
        _lastPlayedGame = game;
      });
    }
  }

  Future<void> _launchBalTil() async {
    _saveLastGame('bal_til');
    AudioController.instance.playButtonClick();
    AlippeAudio().isAlippeActive = false;
    AudioController.instance.isBalTilActive = true;
    AlippeAudio().stopAll();
    AppOrientation.setPortrait();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    if (!mounted) return;
    await Navigator.of(context).pushNamed(Routers.balTil);

    // When returning from Bal Til
    if (mounted) {
      _resetOrientationAndAudio();
      _loadPreferences();
    }
  }

  Future<void> _launchAlippe() async {
    AudioController.instance.playButtonClick();
    _saveLastGame('alippe');

    AudioController.instance.isBalTilActive = false;
    AlippeAudio().isAlippeActive = true;
    AudioController.instance.stopAll();
    AlippeAudio().stopAll();

    // Do NOT rotate orientation here! GameSelectScreen stays strictly in portrait.
    // AlippeHomeScreen manages its own landscape mode upon opening.

    if (!mounted) return;
    await Navigator.of(context).pushNamed(Routers.alippeHome);

    // When returning from Alippe
    if (mounted) {
      await _resetOrientationAndAudio();
      _loadPreferences();
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        final res = await handlePopInvoked(context, didPop, _timeBackPressed);
        if (res != null && mounted) {
          setState(() {
            _timeBackPressed = res;
          });
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Top App Bar / Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF59E0B), Color(0xFFEA580C)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33EA580C),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.sports_esports_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Оюн тандаңыз',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            'Балаңыздын курагына ылайыктуу программа',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings_rounded, color: Color(0xFF475569), size: 26),
                      tooltip: 'Орнотуулар',
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

            // Quick Audio & Music Controls Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: BlocBuilder<AudioCubit, AudioState>(
                  builder: (context, audioState) {
                    final cubit = context.read<AudioCubit>();
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x08000000),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.tune_rounded, size: 18, color: Color(0xFF64748B)),
                              SizedBox(width: 6),
                              Text(
                                'Үн & Музыка:',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Music toggle chip
                              InkWell(
                                onTap: () {
                                  cubit.toggleMusic();
                                  AudioController.instance.playButtonClick();
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: audioState.isMusicEnabled
                                        ? const Color(0xFFFEF3C7)
                                        : const Color(0xFFE2E8F0),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: audioState.isMusicEnabled
                                          ? const Color(0xFFF59E0B)
                                          : const Color(0xFFCBD5E1),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        audioState.isMusicEnabled
                                            ? Icons.music_note_rounded
                                            : Icons.music_off_rounded,
                                        size: 15,
                                        color: audioState.isMusicEnabled
                                            ? const Color(0xFFB45309)
                                            : const Color(0xFF64748B),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Музыка',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: audioState.isMusicEnabled
                                              ? const Color(0xFF92400E)
                                              : const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Sound effects toggle chip
                              InkWell(
                                onTap: () {
                                  final willEnable = !audioState.isSoundEnabled;
                                  cubit.toggleSound();
                                  if (willEnable) {
                                    AudioController.instance.playButtonClick();
                                  }
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: audioState.isSoundEnabled
                                        ? const Color(0xFFD1FAE5)
                                        : const Color(0xFFE2E8F0),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: audioState.isSoundEnabled
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFFCBD5E1),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        audioState.isSoundEnabled
                                            ? Icons.volume_up_rounded
                                            : Icons.volume_off_rounded,
                                        size: 15,
                                        color: audioState.isSoundEnabled
                                            ? const Color(0xFF047857)
                                            : const Color(0xFF64748B),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Эффект',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: audioState.isSoundEnabled
                                              ? const Color(0xFF065F46)
                                              : const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            // Game Cards Section
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Card 1: Alippe (3-6 years)
                  _buildGameChoiceCard(
                    title: '«Алиппе»',
                    subtitle: 'Мектепке чейинки курак • Бала бакча',
                    ageRange: '3 – 6 жаш',
                    badgeColor: const Color(0xFFEA580C),
                    primaryColor: const Color(0xFFEA580C),
                    gradientColors: [
                      const Color(0xFFFFF7ED),
                      const Color(0xFFFFEDD5),
                    ],
                    borderColor: const Color(0xFFFDBA74),
                    iconAsset: 'assets/alippe/images/icon.png',
                    fallbackIcon: Icons.child_care_rounded,
                    isLastPlayed: _lastPlayedGame == 'alippe',
                    bulletPoints: const [
                      'Үндүү жана сүрөттүү 36 тамгалуу алиппе',
                      '2-3 тамгалуу сөздөр (Ай, Ат, От, Үй, Топ, Нан...)',
                      'Көлөкөсүн табуу жана түстүү шар саноо',
                      'Эстутум карточкалары жана интерактивдүү китептер',
                    ],
                    buttonText: '«Алиппени» ойноо (3–6 жаш)',
                    buttonColor: const Color(0xFFEA580C),
                    onSelect: _launchAlippe,
                  ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.06, duration: 350.ms),

                  const SizedBox(height: 18),

                  // Card 2: Bal Til (7-10 years)
                  _buildGameChoiceCard(
                    title: '«Бал тил»',
                    subtitle: '1 – 4-класс • Башталгыч класстар',
                    ageRange: '7 – 10 жаш',
                    badgeColor: AppTheme.emeraldGreen,
                    primaryColor: AppTheme.emeraldGreen,
                    gradientColors: [
                      const Color(0xFFECFDF5),
                      const Color(0xFFD1FAE5),
                    ],
                    borderColor: const Color(0xFF6EE7B7),
                    iconAsset: 'assets/images/app_icon.png',
                    fallbackIcon: Icons.school_rounded,
                    isLastPlayed: _lastPlayedGame == 'bal_til',
                    bulletPoints: const [
                      'Сөздү тап (34 деңгээл) жана Сөз издөө (30 деңгээл)',
                      'Кыргызстандын интерактивдүү картасы (7 облус, кооз жерлер)',
                      'Мамлекеттик гимн жана сөздөрүн үйрөнүү',
                      'Кыргызстандын жаныбарлар жана өсүмдүктөр дүйнөсү',
                    ],
                    buttonText: '«Бал тилди» ойноо (7–10 жаш)',
                    buttonColor: AppTheme.emeraldGreen,
                    onSelect: _launchBalTil,
                  ).animate().fadeIn(delay: 100.ms, duration: 350.ms).slideY(begin: 0.06, duration: 350.ms),
                ]),
              ),
            ),
          ],
        ),
      ),
    ),
    );

    // Show UpgradeAlert only if upgrader is ready and user hasn't dismissed it this session
    if (_upgrader == null || _alertDismissed) return body;
    return UpgradeAlert(
      upgrader: _upgrader!,
      onLater: () {
        setState(() => _alertDismissed = true);
        return true;
      },
      onIgnore: () {
        setState(() => _alertDismissed = true);
        return true;
      },
      onUpdate: () {
        setState(() => _alertDismissed = true);
        return true;
      },
      child: body,
    );
  }

  Widget _buildGameChoiceCard({
    required String title,
    required String subtitle,
    required String ageRange,
    required Color badgeColor,
    required Color primaryColor,
    required List<Color> gradientColors,
    required Color borderColor,
    required String iconAsset,
    required IconData fallbackIcon,
    required bool isLastPlayed,
    required List<String> bulletPoints,
    required String buttonText,
    required Color buttonColor,
    required VoidCallback onSelect,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onSelect,
        child: InkWell(
          onTap: onSelect,
          borderRadius: BorderRadius.circular(24),
        splashColor: primaryColor.withValues(alpha: 0.12),
        highlightColor: primaryColor.withValues(alpha: 0.06),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isLastPlayed ? primaryColor : borderColor,
              width: isLastPlayed ? 3 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: isLastPlayed ? primaryColor.withValues(alpha: 0.22) : const Color(0x0F000000),
                blurRadius: isLastPlayed ? 16 : 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Badge, Last Played badge, and Game Icon
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isLastPlayed)
                          Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF08A),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFEAB308), width: 1.5),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star_rounded, size: 14, color: Color(0xFFB45309)),
                                SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    'Акыркы ойнолгон оюн',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF854D0E),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: badgeColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // App icon image with fallback to icon
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        iconAsset,
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          fallbackIcon,
                          color: primaryColor,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Title & Age row
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      ageRange,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Bullet points
              ...bulletPoints.map((point) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 6, right: 8),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            point,
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.35,
                              color: Color(0xFF334155),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 14),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onSelect,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: isLastPlayed ? 3 : 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isLastPlayed ? Icons.play_arrow_rounded : Icons.arrow_forward_rounded,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          buttonText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}
