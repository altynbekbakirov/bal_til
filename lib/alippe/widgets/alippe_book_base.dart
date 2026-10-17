import 'package:flutter/material.dart';
import '../core/alippe_constants.dart';
import '../data/alippe_data.dart';
import 'alippe_anim_button.dart';

class AlippeBookBase extends StatelessWidget {
  final int bookId;
  final VoidCallback? onLeftPress;
  final VoidCallback? onRightPress;
  final VoidCallback? onClose;
  final Widget child;

  const AlippeBookBase({
    super.key,
    this.bookId = 0,
    this.onLeftPress,
    this.onRightPress,
    this.onClose,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final book = AlippeData.books[bookId.clamp(0, 5)];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left page turn button
          SizedBox(
            width: 90,
            height: 140,
            child: onLeftPress != null
                ? AlippeAnimButton(
                    onPress: onLeftPress,
                    imageAsset: book.leftBtn,
                  )
                : Image.asset(book.leftBtnNoArr, fit: BoxFit.contain),
          ),
          const SizedBox(width: 8),

          // Central Book
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Book background
                Positioned.fill(
                  child: Image.asset(
                    book.bgImage,
                    fit: BoxFit.fill,
                  ),
                ),

                // Close Button in top right
                Positioned(
                  top: -15,
                  right: -15,
                  child: AlippeAnimButton(
                    width: 70,
                    height: 70,
                    onPress: onClose ?? () => Navigator.of(context).pop(),
                    imageAsset: AlippeAssets.closeButton,
                  ),
                ),

                // Book content (pages)
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 55,
                      vertical: 35,
                    ),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Right page turn button
          SizedBox(
            width: 90,
            height: 140,
            child: onRightPress != null
                ? AlippeAnimButton(
                    onPress: onRightPress,
                    imageAsset: book.rightBtn,
                  )
                : Image.asset(book.rightBtnNoArr, fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }
}
