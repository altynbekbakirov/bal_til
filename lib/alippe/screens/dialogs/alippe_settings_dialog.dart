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

        return Center(
          child: SizedBox(
            width: 700,
            height: 480,
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

                // Close button
                Positioned(
                  top: -15,
                  right: -15,
                  child: AlippeAnimButton(
                    width: 65,
                    height: 65,
                    imageAsset: AlippeAssets.closeButton,
                    onPress: () => Navigator.of(context).pop(),
                  ),
                ),

                // Settings Contents
                Padding(
                  padding: const EdgeInsets.fromLTRB(80, 50, 80, 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Sound volume slider
                      Row(
                        children: [
                          Image.asset(AlippeAssets.soundIcon, width: 50, height: 50),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: const Color(0xFFFFB300),
                                inactiveTrackColor: Colors.amber.withValues(alpha: 0.3),
                                thumbColor: const Color(0xFFFF6F00),
                                trackHeight: 12,
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 16),
                              ),
                              child: Slider(
                                value: state.sndValue,
                                onChanged: (val) => cubit.setSndValue(val),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Music volume slider
                      Row(
                        children: [
                          Image.asset(AlippeAssets.musIcon, width: 50, height: 50),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: const Color(0xFFFFB300),
                                inactiveTrackColor: Colors.amber.withValues(alpha: 0.3),
                                thumbColor: const Color(0xFFFF6F00),
                                trackHeight: 12,
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 16),
                              ),
                              child: Slider(
                                value: state.musValue,
                                onChanged: (val) => cubit.setMusValue(val),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Voice Chooser (Boy / Girl)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AlippeAnimButton(
                            width: 100,
                            height: 100,
                            imageAsset: state.boyActive
                                ? AlippeAssets.boyActive
                                : AlippeAssets.boyDisabled,
                            onPress: () => cubit.setBoyActive(true),
                          ),
                          const SizedBox(width: 32),
                          AlippeAnimButton(
                            width: 100,
                            height: 100,
                            imageAsset: !state.boyActive
                                ? AlippeAssets.girlActive
                                : AlippeAssets.girlDisabled,
                            onPress: () => cubit.setBoyActive(false),
                          ),
                        ],
                      ),
                      const Spacer(),

                      // Info button & Reset progress
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              cubit.resetScores();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Жыйынтыктар тазаланды (Scores reset)'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            icon: const Icon(Icons.refresh, color: Colors.brown),
                            label: const Text(
                              'Кайра баштоо',
                              style: TextStyle(
                                color: Colors.brown,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
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
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            ),
                            onPressed: () => AlippeInfoDialog.show(context),
                            icon: const Icon(Icons.info_outline, size: 20),
                            label: const Text(
                              'Маалымат',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
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
