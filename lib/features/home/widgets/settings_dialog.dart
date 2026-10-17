import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/audio/audio_cubit.dart';
import '../../../core/audio/audio_controller.dart';
import '../../../core/score/score_cubit.dart';
import '../../../core/theme/app_theme.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  @override
  void initState() {
    super.initState();
    context.read<AudioCubit>().loadPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 40),
                const Text(
                  'Орнотуулар',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 28),
                  onPressed: () {
                    AudioController.instance.playButtonClick();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            BlocBuilder<AudioCubit, AudioState>(
              builder: (context, state) {
                return Column(
                  children: [
                    _SettingRow(
                      icon: state.isMusicEnabled ? Icons.music_note_rounded : Icons.music_off_rounded,
                      title: 'Музыка',
                      value: state.isMusicEnabled,
                      onChanged: (val) => context.read<AudioCubit>().toggleMusic(),
                    ),
                    const SizedBox(height: 12),
                    _SettingRow(
                      icon: state.isSoundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                      title: 'Үн эффекттери',
                      value: state.isSoundEnabled,
                      onChanged: (val) => context.read<AudioCubit>().toggleSound(),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            // Reset Progress Button
            InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                AudioController.instance.playButtonClick();
                _showResetConfirmDialog(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFFECDD3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.restart_alt_rounded, color: AppTheme.coralRed, size: 24),
                    SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Упайларды тазалоо',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.coralRed,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.coralRed, size: 14),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.softBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Бал тил 2.0 (Алиппе)',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Упайларды тазалоо', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'Бардык оюндардагы топтолгон упайлар жана ачылган деңгээлдер баштапкы абалга келтирилет. Чын эле тазалайсызбы?',
          style: TextStyle(fontSize: 14, color: Color(0xFF334155)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Жок'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.coralRed,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<ScoreCubit>().resetAll();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Упайлар жана деңгээлдер баштапкы абалга келтирилди!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Ооба, тазала'),
          ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryDarkAmber, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: AppTheme.primaryAmber,
            onChanged: (v) {
              AudioController.instance.playButtonClick();
              onChanged(v);
            },
          ),
        ],
      ),
    );
  }
}
