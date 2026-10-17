import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/utils/app_orientation.dart';
import '../core/alippe_constants.dart';

class AlippeContainer extends StatefulWidget {
  final Widget child;
  final String bgImage;

  const AlippeContainer({
    super.key,
    required this.child,
    this.bgImage = AlippeAssets.mainBg,
  });

  @override
  State<AlippeContainer> createState() => _AlippeContainerState();
}

class _AlippeContainerState extends State<AlippeContainer> {
  @override
  void initState() {
    super.initState();
    AppOrientation.setLandscape();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background covering full screen
          Image.asset(
            widget.bgImage,
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
                  child: widget.child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
