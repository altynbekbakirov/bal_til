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
    final screenHeight = MediaQuery.of(context).size.height;
    final isCompact = screenHeight < 360;
    final btnSize = isCompact ? 80.0 : 92.0;
    final playSize = isCompact ? 88.0 : 100.0;

    return Container(
      width: isCompact ? 116 : 134,
      padding: EdgeInsets.symmetric(
        vertical: isCompact ? 10 : 14,
        horizontal: isCompact ? 8 : 10,
      ),
      child: Column(
        children: [
          AlippeAnimButton(
            width: btnSize,
            height: btnSize,
            imageAsset: AlippeAssets.sideSettings,
            onPress: onSettings,
          ),
          if (onBack != null) ...[
            SizedBox(height: isCompact ? 8 : 12),
            AlippeAnimButton(
              width: btnSize,
              height: btnSize,
              imageAsset: AlippeAssets.sideBack,
              onPress: onBack!,
            ),
          ],
          const Spacer(),
          AlippeAnimButton(
            width: playSize,
            height: playSize,
            imageAsset: AlippeAssets.sidePlay,
            onPress: onPlay,
          ),
        ],
      ),
    );
  }
}
