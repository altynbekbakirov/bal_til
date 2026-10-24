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
    final size = MediaQuery.of(context).size;
    final screenHeight = size.height;
    final cardHeight = (screenHeight * 0.82).clamp(270.0, 350.0);
    final cardWidth = (cardHeight * (650.0 / 420.0)).clamp(390.0, 540.0);
    final isCompact = cardHeight < 315;
    final closeBtnSize = isCompact ? 44.0 : 48.0;

    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: SizedBox(
          width: cardWidth,
          height: cardHeight,
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
                top: -8,
                right: -8,
                child: AlippeAnimButton(
                  width: closeBtnSize,
                  height: closeBtnSize,
                  imageAsset: AlippeAssets.closeButton,
                  onPress: () => Navigator.of(context).pop(),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: cardWidth * 0.08,
                  vertical: cardHeight * 0.07,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: cardWidth * 0.84,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Бал тил 1 — Алиппе',
                          style: TextStyle(
                            fontSize: isCompact ? 20 : 23,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF5D4037),
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE0B2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '3 – 6 жаштагы балдар үчүн',
                            style: TextStyle(
                              fontSize: isCompact ? 11 : 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFE65100),
                            ),
                          ),
                        ),
                        SizedBox(height: isCompact ? 6 : 8),
                        Text(
                          'Бөбөктөргө кыргыз тилин, тамгаларды жана жаңы түшүнүктөрдү кызыктуу оюн түрүндө үйрөтүүчү интерактивдүү программа.',
                          style: TextStyle(
                            fontSize: isCompact ? 12 : 13,
                            height: 1.3,
                            color: const Color(0xFF4E342E),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: isCompact ? 8 : 10),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isCompact ? 12 : 16,
                            vertical: isCompact ? 6 : 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0x125D4037),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0x225D4037)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFeatureRow('36 үндүү тамга жана сөз куроо', isCompact),
                              SizedBox(height: isCompact ? 3 : 4),
                              _buildFeatureRow('Түстөр, фигуралар жана сандар', isCompact),
                              SizedBox(height: isCompact ? 3 : 4),
                              _buildFeatureRow('Дене мүчөлөрү, көлөкө табуу жана эстутум', isCompact),
                              SizedBox(height: isCompact ? 3 : 4),
                              _buildFeatureRow('Шайыр анимациялар жана таза үн коштоо', isCompact),
                            ],
                          ),
                        ),
                        SizedBox(height: isCompact ? 10 : 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF8F00),
                            foregroundColor: Colors.white,
                            elevation: 1.5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: isCompact ? 26 : 34,
                              vertical: isCompact ? 7 : 9,
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            'Жабуу',
                            style: TextStyle(
                              fontSize: isCompact ? 13.5 : 14.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
  }

  Widget _buildFeatureRow(String text, bool isCompact) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.check_circle_rounded,
          size: isCompact ? 13 : 15,
          color: const Color(0xFF2E7D32),
        ),
        const SizedBox(width: 7),
        Text(
          text,
          style: TextStyle(
            fontSize: isCompact ? 11.5 : 12.5,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF3E2723),
          ),
        ),
      ],
    );
  }
}
