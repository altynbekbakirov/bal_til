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
import '../../home/widgets/app_info_dialog.dart';

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
                    const Expanded(
                      child: Text(
                        'Бал тил',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.info_outline_rounded, color: Color(0xFF475569), size: 26),
                      tooltip: 'Тиркеме жөнүндө',
                      onPressed: () {
                        AudioController.instance.playButtonClick();
                        AppInfoDialog.show(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Game Cards Section
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Card 1: Бал тил 1 (3-6 years)
                  _buildGameChoiceCard(
                    title: 'Бал тил 1',
                    ageRange: '3 – 6 жаш',
                    primaryColor: const Color(0xFFEA580C),
                    gradientColors: [
                      const Color(0xFFFFF7ED),
                      const Color(0xFFFFEDD5),
                    ],
                    borderColor: const Color(0xFFFDBA74),
                    iconAsset: 'assets/alippe/images/icon.png',
                    fallbackIcon: Icons.child_care_rounded,
                    isLastPlayed: _lastPlayedGame == 'alippe',
                    buttonColor: const Color(0xFFEA580C),
                    onSelect: _launchAlippe,
                  ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.06, duration: 350.ms),

                  const SizedBox(height: 18),

                  // Card 2: Бал тил 2 (7-10 years)
                  _buildGameChoiceCard(
                    title: 'Бал тил 2',
                    ageRange: '7 – 10 жаш',
                    primaryColor: AppTheme.emeraldGreen,
                    gradientColors: [
                      const Color(0xFFECFDF5),
                      const Color(0xFFD1FAE5),
                    ],
                    borderColor: const Color(0xFF6EE7B7),
                    iconAsset: 'assets/images/app_icon.png',
                    fallbackIcon: Icons.school_rounded,
                    isLastPlayed: _lastPlayedGame == 'bal_til',
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
    required String ageRange,
    required Color primaryColor,
    required List<Color> gradientColors,
    required Color borderColor,
    required String iconAsset,
    required IconData fallbackIcon,
    required bool isLastPlayed,
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
                  color: isLastPlayed
                      ? primaryColor.withValues(alpha: 0.22)
                      : const Color(0x0F000000),
                  blurRadius: isLastPlayed ? 16 : 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left side: Title, Children years, and Play button
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isLastPlayed)
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
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
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          ageRange,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: onSelect,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          foregroundColor: Colors.white,
                          elevation: isLastPlayed ? 3 : 1,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Ойноо',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(Icons.arrow_forward_rounded, size: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Right side: Large image of game
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    width: 105,
                    height: 105,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      iconAsset,
                      width: 105,
                      height: 105,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: primaryColor.withValues(alpha: 0.1),
                        child: Icon(
                          fallbackIcon,
                          color: primaryColor,
                          size: 48,
                        ),
                      ),
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
