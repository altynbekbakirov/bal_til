import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/alippe_audio.dart';
import '../../core/alippe_cubit.dart';
import '../../widgets/alippe_anim_button.dart';
import '../../widgets/alippe_book_base.dart';
import '../../widgets/alippe_container.dart';
import '../dialogs/alippe_game_finish_dialog.dart';

class Section9View extends StatefulWidget {
  const Section9View({super.key});

  @override
  State<Section9View> createState() => _Section9ViewState();
}

class _Section9ViewState extends State<Section9View> {
  int _targetColorIndex = 0;
  int _collectedCount = 0;
  final int _goal = 3;

  final List<String> _colorNames = [
    'Кара (Black)',
    'Көк (Blue)',
    'Кызыл (Red)',
    'Жашыл (Green)',
  ];

  final List<String> _balloonImages = [
    'assets/alippe/images/books/book5/section2/colors_btn/black.png',
    'assets/alippe/images/books/book5/section2/colors_btn/blue.png',
    'assets/alippe/images/books/book5/section2/colors_btn/red.png',
    'assets/alippe/images/books/book5/section2/colors_btn/green.png',
  ];

  void _onBalloonTap(int colorIndex) {
    if (colorIndex == _targetColorIndex) {
      AlippeAudio().playGood();
      setState(() {
        _collectedCount++;
      });

      if (_collectedCount >= _goal) {
        Future.delayed(const Duration(milliseconds: 600), () {
          if (!mounted) return;
          if (_targetColorIndex < _balloonImages.length - 1) {
            setState(() {
              _targetColorIndex++;
              _collectedCount = 0;
            });
          } else {
            // Section 9 finished!
            context.read<AlippeCubit>().addScore(4, 3);
            AlippeGameFinishDialog.show(
              context: context,
              score: 3,
              onRestart: () {
                setState(() {
                  _targetColorIndex = 0;
                  _collectedCount = 0;
                });
              },
              onNext: () {
                Navigator.of(context).pushReplacementNamed('/section', arguments: 10);
              },
              onHome: () {
                AlippeGameFinishDialog.navigateToAlippeHome(context);
              },
            );
          }
        });
      }
    } else {
      AlippeAudio().playFail();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBoy = context.watch<AlippeCubit>().state.boyActive;

    return AlippeContainer(
      child: AlippeBookBase(
        bookId: 4,
        onLeftPress: _targetColorIndex > 0
            ? () {
                setState(() {
                  _targetColorIndex--;
                  _collectedCount = 0;
                });
              }
            : null,
        onRightPress: _targetColorIndex < _balloonImages.length - 1
            ? () {
                setState(() {
                  _targetColorIndex++;
                  _collectedCount = 0;
                });
              }
            : null,
        child: Row(
          children: [
            // Left: Character holding balloons
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    isBoy
                        ? 'assets/alippe/images/books/book5/section2/baloon_holders/boy.png'
                        : 'assets/alippe/images/books/book5/section2/baloon_holders/girl.png',
                    fit: BoxFit.contain,
                  ),
                  Positioned(
                    top: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.amber.shade800, width: 2),
                      ),
                      child: Text(
                        'Тап: ${_colorNames[_targetColorIndex]} ($_collectedCount/$_goal)',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 40),

            // Right: Balloon Choices Grid
            Expanded(
              child: Center(
                child: Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  alignment: WrapAlignment.center,
                  children: List.generate(_balloonImages.length, (idx) {
                    return AlippeAnimButton(
                      width: 130,
                      height: 130,
                      imageAsset: _balloonImages[idx],
                      onPress: () => _onBalloonTap(idx),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
