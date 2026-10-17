import 'package:flutter/material.dart';
import '../../core/alippe_constants.dart';
import '../../widgets/alippe_anim_button.dart';

class AlippeInfoDialog extends StatelessWidget {
  const AlippeInfoDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) => const AlippeInfoDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: SizedBox(
          width: 650,
          height: 420,
          child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Image.asset(
                AlippeAssets.settingsBg,
                fit: BoxFit.fill,
              ),
            ),
            Positioned(
              top: -15,
              right: -15,
              child: AlippeAnimButton(
                width: 60,
                height: 60,
                imageAsset: AlippeAssets.closeButton,
                onPress: () => Navigator.of(context).pop(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(50, 40, 50, 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Бал тил - Алиппе (3-6 жаш)',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5D4037),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Бул тиркеме 3 жаштан 6 жашка чейинки балдар үчүн кыргыз тилинин тамгаларын, сөздөрүн үйрөнүүгө жана эс тутумун өнүктүрүүгө арналган интерактивдүү оюн.\n\n'
                    '• 6 кызыктуу китеп жана 11 бөлүм\n'
                    '• Тамгаларды жана сөздөрдү куроо\n'
                    '• Шайкештикти табуу жана эстутум оюндары\n'
                    '• Кызыктуу үн коштоо жана анимациялар',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.4,
                      color: Color(0xFF4E342E),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF8F00),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Жабуу',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
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
