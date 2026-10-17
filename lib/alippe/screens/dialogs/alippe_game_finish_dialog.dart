import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/alippe_audio.dart';
import '../../core/alippe_constants.dart';
import '../../widgets/alippe_anim_button.dart';

class AlippeGameFinishDialog extends StatefulWidget {
  final int score;
  final VoidCallback onRestart;
  final VoidCallback onNext;
  final VoidCallback onHome;

  const AlippeGameFinishDialog({
    super.key,
    required this.score,
    required this.onRestart,
    required this.onNext,
    required this.onHome,
  });

  static Future<void> show({
    required BuildContext context,
    required int score,
    required VoidCallback onRestart,
    required VoidCallback onNext,
    required VoidCallback onHome,
  }) {
    AlippeAudio().playFinish();
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (_) => AlippeGameFinishDialog(
        score: score,
        onRestart: onRestart,
        onNext: onNext,
        onHome: onHome,
      ),
    );
  }

  @override
  State<AlippeGameFinishDialog> createState() => _AlippeGameFinishDialogState();
}

class _AlippeGameFinishDialogState extends State<AlippeGameFinishDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: SizedBox(
          width: 500,
          height: 600,
          child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Rotating Sunburst / Blend Behind
            AnimatedBuilder(
              animation: _spinController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _spinController.value * 2 * math.pi,
                  child: Image.asset(
                    AlippeAssets.finishBlend,
                    width: 480,
                    height: 480,
                    fit: BoxFit.contain,
                  ),
                );
              },
            ),

            // Main Background Plaque
            Image.asset(
              AlippeAssets.finishBg,
              width: 420,
              height: 520,
              fit: BoxFit.contain,
            ),

            // Content inside the plaque
            Positioned(
              top: 140,
              child: Column(
                children: [
                  // Stars Awarded
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        widget.score >= 1
                            ? AlippeAssets.finishStarSm
                            : AlippeAssets.starOneDis,
                        width: 70,
                        height: 70,
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Image.asset(
                          widget.score >= 2
                              ? AlippeAssets.finishStarLg
                              : AlippeAssets.starTwoDis,
                          width: 90,
                          height: 90,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Image.asset(
                        widget.score >= 3
                            ? AlippeAssets.finishStarSm
                            : AlippeAssets.starThreeDis,
                        width: 70,
                        height: 70,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Score banner
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        AlippeAssets.finishScoreBg,
                        width: 220,
                        height: 70,
                        fit: BoxFit.contain,
                      ),
                      Text(
                        'Азаматсың!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Action Buttons (Home, Restart, Next)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AlippeAnimButton(
                        width: 65,
                        height: 65,
                        imageAsset: AlippeAssets.finishListBtn,
                        onPress: () {
                          Navigator.of(context).pop();
                          widget.onHome();
                        },
                      ),
                      const SizedBox(width: 16),
                      AlippeAnimButton(
                        width: 65,
                        height: 65,
                        imageAsset: AlippeAssets.finishRestartBtn,
                        onPress: () {
                          Navigator.of(context).pop();
                          widget.onRestart();
                        },
                      ),
                      const SizedBox(width: 16),
                      AlippeAnimButton(
                        width: 75,
                        height: 75,
                        imageAsset: AlippeAssets.finishPlayBtn,
                        onPress: () {
                          Navigator.of(context).pop();
                          widget.onNext();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
