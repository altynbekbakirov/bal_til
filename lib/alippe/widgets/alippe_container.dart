import 'package:flutter/material.dart';
import '../core/alippe_constants.dart';

class AlippeContainer extends StatelessWidget {
  final Widget child;
  final String bgImage;

  const AlippeContainer({
    super.key,
    required this.child,
    this.bgImage = AlippeAssets.mainBg,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background covering full screen
          Image.asset(
            bgImage,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          // Virtual canvas matching original React Native 1280x720 canvas
          Center(
            child: AspectRatio(
              aspectRatio: 1280 / 720,
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: 1280,
                  height: 720,
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
