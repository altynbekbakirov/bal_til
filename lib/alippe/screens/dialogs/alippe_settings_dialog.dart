import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/alippe_constants.dart';
import '../../core/alippe_cubit.dart';
import '../../widgets/alippe_anim_button.dart';
import 'alippe_info_dialog.dart';

class AlippeSettingsDialog extends StatefulWidget {
  const AlippeSettingsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) => const AlippeSettingsDialog(),
    );
  }

  @override
  State<AlippeSettingsDialog> createState() => _AlippeSettingsDialogState();
}

class _AlippeSettingsDialogState extends State<AlippeSettingsDialog> {
  @override
  void initState() {
    super.initState();
    context.read<AlippeCubit>().init();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlippeCubit, AlippeState>(
      builder: (context, state) {
        final cubit = context.read<AlippeCubit>();
        final size = MediaQuery.of(context).size;
        final screenHeight = size.height;

        // Proportional to landscape screen height, fitting completely without overflow
        final cardHeight = (screenHeight * 0.84).clamp(280.0, 360.0);
        final cardWidth = (cardHeight * 1.6).clamp(460.0, 600.0);

        final isCompact = cardHeight < 315;
        final closeBtnSize = isCompact ? 44.0 : 48.0;
        const sliderIconSize = 38.0;
        const avatarSize = 72.0;
        final horizPadding = cardWidth * 0.09;
        final vertPadding = cardHeight * 0.08;

        return Material(
          type: MaterialType.transparency,
          child: Center(
            child: SizedBox(
              width: cardWidth,
              height: cardHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Background
                  Positioned.fill(
                    child: Image.asset(
                      AlippeAssets.settingsBg,
                      fit: BoxFit.fill,
                    ),
                  ),

                  // Close button positioned cleanly on the stitched border
                  Positioned(
                    top: -8,
                    right: -8,
                    child: AlippeAnimButton(
                      width: closeBtnSize,
                      height: closeBtnSize,
                      imageAsset: AlippeAssets.closeButton,
                      onPress: () => Navigator.of(context).pop(),
                    ),
                  ),

                  // Settings Contents
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizPadding,
                      vertPadding,
                      horizPadding,
                      vertPadding * 0.8,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 500,
                        height: 280,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Sound volume slider
                            Row(
                              children: [
                                Image.asset(AlippeAssets.soundIcon, width: sliderIconSize, height: sliderIconSize),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      activeTrackColor: const Color(0xFFFFB300),
                                      inactiveTrackColor: Colors.amber.withValues(alpha: 0.3),
                                      thumbColor: const Color(0xFFFF6F00),
                                      trackHeight: isCompact ? 9 : 11,
                                      thumbShape: RoundSliderThumbShape(enabledThumbRadius: isCompact ? 13 : 15),
                                    ),
                                    child: Slider(
                                      value: state.sndValue,
                                      onChanged: (val) => cubit.setSndValue(val),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // Music volume slider
                            Row(
                              children: [
                                Image.asset(AlippeAssets.musIcon, width: sliderIconSize, height: sliderIconSize),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      activeTrackColor: const Color(0xFFFFB300),
                                      inactiveTrackColor: Colors.amber.withValues(alpha: 0.3),
                                      thumbColor: const Color(0xFFFF6F00),
                                      trackHeight: isCompact ? 9 : 11,
                                      thumbShape: RoundSliderThumbShape(enabledThumbRadius: isCompact ? 13 : 15),
                                    ),
                                    child: Slider(
                                      value: state.musValue,
                                      onChanged: (val) => cubit.setMusValue(val),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // Voice Chooser (Boy / Girl)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AlippeAnimButton(
                                  width: avatarSize,
                                  height: avatarSize,
                                  imageAsset: state.boyActive
                                      ? AlippeAssets.boyActive
                                      : AlippeAssets.boyDisabled,
                                  onPress: () => cubit.setBoyActive(true),
                                ),
                                SizedBox(width: isCompact ? 20 : 28),
                                AlippeAnimButton(
                                  width: avatarSize,
                                  height: avatarSize,
                                  imageAsset: !state.boyActive
                                      ? AlippeAssets.girlActive
                                      : AlippeAssets.girlDisabled,
                                  onPress: () => cubit.setBoyActive(false),
                                ),
                              ],
                            ),

                            // Info button & Reset progress
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton.icon(
                                  onPressed: () => _showResetConfirmDialog(context, cubit),
                                  icon: const Icon(Icons.restart_alt_rounded, color: Colors.brown, size: 20),
                                  label: Text(
                                    'Упайларды тазалоо',
                                    style: TextStyle(
                                      color: Colors.brown,
                                      fontWeight: FontWeight.bold,
                                      fontSize: isCompact ? 13 : 14.5,
                                    ),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFF8F00),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isCompact ? 14 : 18,
                                      vertical: isCompact ? 7 : 9,
                                    ),
                                  ),
                                  onPressed: () => AlippeInfoDialog.show(context),
                                  icon: const Icon(Icons.info_outline, size: 18),
                                  label: Text(
                                    'Маалымат',
                                    style: TextStyle(
                                      fontSize: isCompact ? 13.5 : 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showResetConfirmDialog(BuildContext context, AlippeCubit cubit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Упайларды тазалоо',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5D4037)),
        ),
        content: const Text(
          'Бардык топтолгон жылдыздар баштапкы абалга келтирилет. Улантууга макулсузбу?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Жокко чыгаруу', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8F00),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              cubit.resetScores();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Упайлар тазаланды'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Ооба, тазалоо'),
          ),
        ],
      ),
    );
  }
}
