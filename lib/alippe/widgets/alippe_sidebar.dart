import 'package:flutter/material.dart';
import '../core/alippe_constants.dart';
import 'alippe_anim_button.dart';

class AlippeSidebar extends StatelessWidget {
  final VoidCallback onSettings;
  final VoidCallback onPlay;
  final VoidCallback? onBack;

  const AlippeSidebar({
    super.key,
    required this.onSettings,
    required this.onPlay,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        children: [
          AlippeAnimButton(
            width: 85,
            height: 85,
            imageAsset: AlippeAssets.sideSettings,
            onPress: onSettings,
          ),
          if (onBack != null) ...[
            const SizedBox(height: 14),
            AlippeAnimButton(
              width: 85,
              height: 85,
              imageAsset: AlippeAssets.sideBack,
              onPress: onBack!,
            ),
          ],
          const Spacer(),
          AlippeAnimButton(
            width: 90,
            height: 90,
            imageAsset: AlippeAssets.sidePlay,
            onPress: onPlay,
          ),
        ],
      ),
    );
  }
}
