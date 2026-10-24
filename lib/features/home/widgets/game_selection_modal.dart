import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../alippe/core/alippe_audio.dart';
import '../../../core/audio/audio_controller.dart';
import '../../../core/audio/audio_cubit.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_orientation.dart';
import '../../../configs/routes.dart';
import 'settings_dialog.dart';

class GameSelectionModal extends StatelessWidget {
  const GameSelectionModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const GameSelectionModal(),
    );
  }

  static Future<void> launchAlippe(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_played_game', 'alippe');

    // 1. Mark active game and silence Bal Til audio before switching
    AudioController.instance.isBalTilActive = false;
    AlippeAudio().isAlippeActive = true;
    await Future.delayed(const Duration(milliseconds: 100));
    await AudioController.instance.stopAll();
    await AlippeAudio().stopAll();

    // Do NOT rotate orientation here! HomeScreen must remain strictly in portrait.
    // AlippeHomeScreen manages its own landscape mode upon opening.

    if (!context.mounted) return;
    await Navigator.of(context).pushNamed(Routers.alippeHome);

    // When returning to HomeScreen
    if (context.mounted) {
      await AppOrientation.forcePortrait();
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      AudioController.instance.isBalTilActive = true;
      AlippeAudio().isAlippeActive = false;
      if (AudioController.instance.isMusicEnabled) {
        AudioController.instance.playMenuMusic();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.90;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryAmber.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.sports_esports_rounded,
                      color: AppTheme.primaryDarkAmber,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Оюн тандаңыз',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
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
                    icon: const Icon(Icons.settings_rounded, color: Color(0xFF64748B), size: 24),
                    tooltip: 'Орнотуулар',
                    onPressed: () {
                      AudioController.instance.playButtonClick();
                      showDialog(
                        context: context,
                        builder: (_) => const SettingsDialog(),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 26),
                    onPressed: () {
                      AudioController.instance.playButtonClick();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Quick Audio & Effect Settings Bar
              BlocBuilder<AudioCubit, AudioState>(
                builder: (context, audioState) {
                  final cubit = context.read<AudioCubit>();
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
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
                            Icon(Icons.tune_rounded, size: 20, color: Color(0xFF64748B)),
                            SizedBox(width: 8),
                            Text(
                              'Үн & Музыка:',
                              style: TextStyle(
                                fontSize: 13,
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
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                                      size: 16,
                                      color: audioState.isMusicEnabled
                                          ? const Color(0xFFB45309)
                                          : const Color(0xFF64748B),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Музыка',
                                      style: TextStyle(
                                        fontSize: 12,
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
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                                      size: 16,
                                      color: audioState.isSoundEnabled
                                          ? const Color(0xFF047857)
                                          : const Color(0xFF64748B),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Эффект',
                                      style: TextStyle(
                                        fontSize: 12,
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
              const SizedBox(height: 16),

              // Card 1: Alippe (3-6 years)
              // Card 1: Бал тил 1 (3-6 years)
              _buildGameCard(
                context: context,
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
                buttonColor: const Color(0xFFEA580C),
                onSelect: () {
                  Navigator.pop(context);
                  launchAlippe(context);
                },
              ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.08, duration: 300.ms),

              const SizedBox(height: 18),

              // Card 2: Бал тил 2 (7-10 years)
              _buildGameCard(
                context: context,
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
                buttonColor: AppTheme.emeraldGreen,
                isCurrent: true,
                onSelect: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('last_played_game', 'bal_til');
                  if (context.mounted) Navigator.pop(context);
                },
              ).animate().fadeIn(delay: 100.ms, duration: 300.ms).slideY(begin: 0.08, duration: 300.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameCard({
    required BuildContext context,
    required String title,
    required String ageRange,
    required Color primaryColor,
    required List<Color> gradientColors,
    required Color borderColor,
    required String iconAsset,
    required IconData fallbackIcon,
    required Color buttonColor,
    required VoidCallback onSelect,
    bool isCurrent = false,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: () {
          AudioController.instance.playButtonClick();
          onSelect();
        },
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
            border: Border.all(color: borderColor, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left side: Title, Children years, and Action button
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isCurrent)
                      Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.emeraldGreen.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.emeraldGreen.withValues(alpha: 0.3)),
                        ),
                        child: const Text(
                          'Азыркы оюн',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.emeraldGreen,
                          ),
                        ),
                      ),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                        letterSpacing: -0.3,
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
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton(
                      onPressed: () {
                        AudioController.instance.playButtonClick();
                        onSelect();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        foregroundColor: Colors.white,
                        elevation: 1,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Ойноо',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.arrow_forward_rounded, size: 15),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              // Right side: Large image of game
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 95,
                  height: 95,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    iconAsset,
                    width: 95,
                    height: 95,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: primaryColor.withValues(alpha: 0.1),
                      child: Icon(
                        fallbackIcon,
                        color: primaryColor,
                        size: 42,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
