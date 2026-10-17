import 'package:flutter/material.dart';
import '../core/alippe_constants.dart';
import 'alippe_anim_button.dart';

class AlippeSidebar extends StatelessWidget {
  final VoidCallback onSettings;
  final VoidCallback onPlay;

  const AlippeSidebar({
    super.key,
    required this.onSettings,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          AlippeAnimButton(
            width: 100,
            height: 100,
            imageAsset: AlippeAssets.sideSettings,
            onPress: onSettings,
          ),
          const Spacer(),
          AlippeAnimButton(
            width: 100,
            height: 100,
            imageAsset: AlippeAssets.sidePlay,
            onPress: onPlay,
          ),
        ],
      ),
    );
  }
}
