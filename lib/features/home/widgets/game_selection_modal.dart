import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../alippe/screens/alippe_splash_screen.dart';
import '../../../core/audio/audio_controller.dart';
import '../../../core/theme/app_theme.dart';

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
    AudioController.instance.stopMenuMusic();
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    if (!context.mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => const AlippeSplashScreen()),
    );

    // Revert to portrait and restore UI upon returning to Bal Til
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    AudioController.instance.playMenuMusic();
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
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 26),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Card 1: Alippe (3-6 years)
              _buildGameCard(
                context: context,
                badgeText: 'Мектепке чейинки курак • Бала бакча',
                badgeColor: const Color(0xFFEA580C),
                title: '«Алиппе»',
                ageRange: '3 – 6 жаш',
                icon: Icons.child_care_rounded,
                primaryColor: const Color(0xFFEA580C),
                gradientColors: [
                  const Color(0xFFFFF7ED),
                  const Color(0xFFFFEDD5),
                ],
                borderColor: const Color(0xFFFDBA74),
                bulletPoints: const [
                  'Үндүү жана сүрөттүү 36 тамгалуу алиппе',
                  '2-3 тамгалуу сөздөр (Ай, Ат, От, Үй, Топ, Нан...)',
                  'Көлөкөсүн табуу жана түстүү шар саноо',
                  'Эстутум карточкалары жана интерактивдүү китептер',
                ],
                buttonText: '«Алиппеге» өтүү (3–6 жаш)',
                buttonColor: const Color(0xFFEA580C),
                onSelect: () {
                  Navigator.pop(context);
                  launchAlippe(context);
                },
              ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.08, duration: 300.ms),

              const SizedBox(height: 18),

              // Card 2: Bal Til (7-10 years)
              _buildGameCard(
                context: context,
                badgeText: '1 – 4-класс • Башталгыч класстар',
                badgeColor: AppTheme.emeraldGreen,
                title: '«Бал тил»',
                ageRange: '7 – 10 жаш',
                icon: Icons.school_rounded,
                primaryColor: AppTheme.emeraldGreen,
                gradientColors: [
                  const Color(0xFFECFDF5),
                  const Color(0xFFD1FAE5),
                ],
                borderColor: const Color(0xFF6EE7B7),
                bulletPoints: const [
                  'Сөздү тап (34 деңгээл) жана Сөз издөө (30 деңгээл)',
                  'Кыргызстандын интерактивдүү картасы (7 облус, кооз жерлер)',
                  'Мамлекеттик гимн жана сөздөрүн үйрөнүү',
                  'Кыргызстандын жаныбарлар жана өсүмдүктөр дүйнөсү',
                ],
                buttonText: '«Бал тилди» улантуу (7–10 жаш)',
                buttonColor: AppTheme.emeraldGreen,
                isCurrent: true,
                onSelect: () => Navigator.pop(context),
              ).animate().fadeIn(delay: 100.ms, duration: 300.ms).slideY(begin: 0.08, duration: 300.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameCard({
    required BuildContext context,
    required String badgeText,
    required Color badgeColor,
    required String title,
    required String ageRange,
    required IconData icon,
    required Color primaryColor,
    required List<Color> gradientColors,
    required Color borderColor,
    required List<String> bulletPoints,
    required String buttonText,
    required Color buttonColor,
    required VoidCallback onSelect,
    bool isCurrent = false,
  }) {
    return Container(
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
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge + Icon Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: badgeColor,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                  ],
                ),
                child: Icon(icon, color: primaryColor, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Title & Age
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(10),
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
              if (isCurrent) ...[
                const Spacer(),
                const Text(
                  'Азыркы оюн',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.emeraldGreen,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // Bullets
          ...bulletPoints.map((point) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 5, right: 8),
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

          // Action button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                AudioController.instance.playButtonClick();
                onSelect();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
