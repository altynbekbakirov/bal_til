import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../configs/routes.dart';
import '../../core/alippe_audio.dart';
import '../../core/alippe_constants.dart';
import '../../widgets/alippe_anim_button.dart';

class AlippeGameFinishDialog extends StatefulWidget {
  final int score;
  final VoidCallback onRestart;
  final VoidCallback onNext;
  final VoidCallback? onHome;

  const AlippeGameFinishDialog({
    super.key,
    required this.score,
    required this.onRestart,
    required this.onNext,
    this.onHome,
  });

  static void navigateToAlippeHome(BuildContext context) {
    bool foundHome = false;
    Navigator.of(context).popUntil((route) {
      if (route.settings.name == '/home' || route.settings.name == Routers.alippeHome) {
        foundHome = true;
        return true;
      }
      return route.isFirst;
    });
    if (!foundHome) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  static Future<void> show({
    required BuildContext context,
    required int score,
    required VoidCallback onRestart,
    required VoidCallback onNext,
    VoidCallback? onHome,
  }) {
    AlippeAudio().playFinish();
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (_) => AlippeGameFinishDialog(
        score: score,
        onRestart: onRestart,
        onNext: onNext,
        onHome: onHome ?? () => navigateToAlippeHome(context),
      ),
    );
  }

  @override
  State<AlippeGameFinishDialog> createState() => _AlippeGameFinishDialogState();
}

class _AlippeGameFinishDialogState extends State<AlippeGameFinishDialog>
    with TickerProviderStateMixin {
  late AnimationController _spinController;
  late AnimationController _starController;
  late Animation<double> _star1Anim;
  late Animation<double> _star2Anim;
  late Animation<double> _star3Anim;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _starController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _star1Anim = CurvedAnimation(
      parent: _starController,
      curve: const Interval(0.05, 0.45, curve: Curves.elasticOut),
    );
    _star2Anim = CurvedAnimation(
      parent: _starController,
      curve: const Interval(0.25, 0.70, curve: Curves.elasticOut),
    );
    _star3Anim = CurvedAnimation(
      parent: _starController,
      curve: const Interval(0.45, 0.95, curve: Curves.elasticOut),
    );

    _starController.forward();
  }

  @override
  void dispose() {
    _spinController.dispose();
    _starController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenHeight = size.height;

    // Proportional to screen height, fitting completely in landscape
    final cardHeight = (screenHeight * 0.86).clamp(250.0, 480.0);
    // Aspect ratio of game_finish_bg.png is 541 / 522
    final cardWidth = cardHeight * (541.0 / 522.0);
    final blendSize = cardHeight * 1.15;

    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: SizedBox(
          width: cardWidth,
          height: cardHeight,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // 1. Rotating Sunburst / Blend Behind
              Positioned(
                child: SizedBox(
                  width: blendSize,
                  height: blendSize,
                  child: AnimatedBuilder(
                    animation: _spinController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _spinController.value * 2 * math.pi,
                        child: Image.asset(
                          AlippeAssets.finishBlend,
                          fit: BoxFit.contain,
                        ),
                      );
                    },
                  ),
                ),
              ),

              // 2. Main Background Plaque
              Image.asset(
                AlippeAssets.finishBg,
                width: cardWidth,
                height: cardHeight,
                fit: BoxFit.contain,
              ),

              // 3. Content inside the plaque
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: cardWidth * 0.08,
                    vertical: cardHeight * 0.07,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Stars Awarded
                      _buildStars(cardHeight),

                      // Score Banner with Apple & Clear Text
                      _buildScoreBanner(cardWidth, cardHeight),

                      // Action Buttons (List, Play, Restart)
                      _buildActionButtons(context, cardWidth, cardHeight),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStars(double cardHeight) {
    final starSmSize = cardHeight * 0.20;
    final starLgSize = cardHeight * 0.26;

    return SizedBox(
      height: starLgSize,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ScaleTransition(
            scale: _star1Anim,
            child: Image.asset(
              widget.score >= 1
                  ? AlippeAssets.finishStarSm
                  : AlippeAssets.starOneDis,
              width: starSmSize,
              height: starSmSize,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(width: cardHeight * 0.02),
          ScaleTransition(
            scale: _star2Anim,
            child: Padding(
              padding: EdgeInsets.only(bottom: cardHeight * 0.035),
              child: Image.asset(
                widget.score >= 2
                    ? AlippeAssets.finishStarLg
                    : AlippeAssets.starTwoDis,
                width: starLgSize,
                height: starLgSize,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(width: cardHeight * 0.02),
          ScaleTransition(
            scale: _star3Anim,
            child: Image.asset(
              widget.score >= 3
                  ? AlippeAssets.finishStarSm
                  : AlippeAssets.starThreeDis,
              width: starSmSize,
              height: starSmSize,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBanner(double cardWidth, double cardHeight) {
    final bannerHeight = cardHeight * 0.17;
    // Aspect ratio of score_bg_no_prgrsbg.png is 406 / 101
    final bannerWidth =
        (bannerHeight * (406.0 / 101.0)).clamp(0.0, cardWidth * 0.84);

    return SizedBox(
      width: bannerWidth,
      height: bannerHeight,
      child: Stack(
        children: [
          // Banner background (includes apple icon on left ~22%)
          Image.asset(
            AlippeAssets.finishScoreBg,
            width: bannerWidth,
            height: bannerHeight,
            fit: BoxFit.contain,
          ),
          // High-contrast celebratory text offset past apple icon
          Positioned(
            left: bannerWidth * 0.22,
            right: bannerWidth * 0.04,
            top: 0,
            bottom: 0,
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Азаматсың!',
                  style: TextStyle(
                    fontSize: (bannerHeight * 0.44).clamp(14.0, 22.0),
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.8,
                    shadows: const [
                      Shadow(
                        color: Color(0xFF004D40),
                        offset: Offset(1.5, 1.5),
                        blurRadius: 2.0,
                      ),
                      Shadow(
                        color: Color(0xFF00695C),
                        offset: Offset(-1.0, -1.0),
                        blurRadius: 1.0,
                      ),
                      Shadow(
                        color: Color(0x80000000),
                        offset: Offset(0, 2.0),
                        blurRadius: 3.0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, double cardWidth, double cardHeight) {
    final smBtnSize = (cardHeight * 0.18).clamp(44.0, 68.0);
    final lgBtnSize = (cardHeight * 0.23).clamp(56.0, 84.0);
    final spacing = cardWidth * 0.04;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // List / Home button
        AlippeAnimButton(
          width: smBtnSize,
          height: smBtnSize * (120.0 / 115.0),
          scaleFactor: 1.15,
          imageAsset: AlippeAssets.finishListBtn,
          onPress: () {
            Navigator.of(context).pop();
            if (widget.onHome != null) {
              widget.onHome!();
            } else {
              AlippeGameFinishDialog.navigateToAlippeHome(context);
            }
          },
        ),
        SizedBox(width: spacing),
        // Play / Next button (Primary & larger, centered)
        AlippeAnimButton(
          width: lgBtnSize,
          height: lgBtnSize * (155.0 / 150.0),
          scaleFactor: 1.15,
          imageAsset: AlippeAssets.finishPlayBtn,
          onPress: () {
            Navigator.of(context).pop();
            widget.onNext();
          },
        ),
        SizedBox(width: spacing),
        // Restart button
        AlippeAnimButton(
          width: smBtnSize,
          height: smBtnSize * (120.0 / 115.0),
          scaleFactor: 1.15,
          imageAsset: AlippeAssets.finishRestartBtn,
          onPress: () {
            Navigator.of(context).pop();
            widget.onRestart();
          },
        ),
      ],
    );
  }
}
