import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/alippe_audio.dart';
import '../../core/alippe_cubit.dart';
import '../../widgets/alippe_book_base.dart';
import '../../widgets/alippe_container.dart';
import '../dialogs/alippe_game_finish_dialog.dart';

class Section9View extends StatefulWidget {
  const Section9View({super.key});

  @override
  State<Section9View> createState() => _Section9ViewState();
}

class _ColorItem {
  final String key;
  final String bgImage;
  final String btnImage;

  const _ColorItem({
    required this.key,
    required this.bgImage,
    required this.btnImage,
  });
}

class _Section9ViewState extends State<Section9View> {
  int _targetColorIndex = 0;
  int _collectedCount = 0;
  int _goal = 3;
  late List<int?> _availableChoices; // null if collected

  // The 7 colors in exact order of original React Native section9.js
  static const List<_ColorItem> _colors = [
    _ColorItem(
      key: 'black',
      bgImage: 'assets/alippe/images/books/book5/section2/colors_bg/black.png',
      btnImage: 'assets/alippe/images/books/book5/section2/colors_btn/black.png',
    ),
    _ColorItem(
      key: 'blue',
      bgImage: 'assets/alippe/images/books/book5/section2/colors_bg/blue.png',
      btnImage: 'assets/alippe/images/books/book5/section2/colors_btn/blue.png',
    ),
    _ColorItem(
      key: 'red',
      bgImage: 'assets/alippe/images/books/book5/section2/colors_bg/red.png',
      btnImage: 'assets/alippe/images/books/book5/section2/colors_btn/red.png',
    ),
    _ColorItem(
      key: 'green',
      bgImage: 'assets/alippe/images/books/book5/section2/colors_bg/green.png',
      btnImage: 'assets/alippe/images/books/book5/section2/colors_btn/green.png',
    ),
    _ColorItem(
      key: 'yellow',
      bgImage: 'assets/alippe/images/books/book5/section2/colors_bg/yellow.png',
      btnImage: 'assets/alippe/images/books/book5/section2/colors_btn/yellow.png',
    ),
    _ColorItem(
      key: 'brown',
      bgImage: 'assets/alippe/images/books/book5/section2/colors_bg/brown.png',
      btnImage: 'assets/alippe/images/books/book5/section2/colors_btn/brown.png',
    ),
    _ColorItem(
      key: 'white',
      bgImage: 'assets/alippe/images/books/book5/section2/colors_bg/white.png',
      btnImage: 'assets/alippe/images/books/book5/section2/colors_btn/white.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _setupChoices();
  }

  void _setupChoices() {
    final random = math.Random();
    // Goal between 1 and 5 (matching React Native randomIntFromInterval(1, 5))
    _goal = random.nextInt(4) + 2; // 2 to 5 balloons

    // Fill 6 choices: _goal of target color, rest random other colors
    final List<int?> list = [];
    for (int i = 0; i < _goal; i++) {
      list.add(_targetColorIndex);
    }
    for (int i = _goal; i < 6; i++) {
      int other;
      do {
        other = random.nextInt(_colors.length);
      } while (other == _targetColorIndex);
      list.add(other);
    }
    list.shuffle();
    _availableChoices = list;
  }

  void _onColorMatched(int choiceIndex, int colorIndex) {
    if (colorIndex == _targetColorIndex) {
      AlippeAudio().playBell();
      setState(() {
        _collectedCount++;
        _availableChoices[choiceIndex] = null;
      });

      if (_collectedCount >= _goal) {
        AlippeAudio().playGood();
        Future.delayed(const Duration(milliseconds: 600), () {
          if (!mounted) return;
          if (_targetColorIndex < _colors.length - 1) {
            setState(() {
              _targetColorIndex++;
              _collectedCount = 0;
              _setupChoices();
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
                  _setupChoices();
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
      AlippeAudio().playBackSwoosh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBoy = context.watch<AlippeCubit>().state.boyActive;
    final currentTarget = _colors[_targetColorIndex];

    return AlippeContainer(
      child: AlippeBookBase(
        bookId: 4,
        onLeftPress: null, // No skip arrows, matches original React Native
        onRightPress: null,
        child: Row(
          children: [
            // Left page: 6 Balloons (2 rows of 3) matching React Section 9
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Row 1
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (int i = 0; i < 3; i++) _buildBalloonChoice(i),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Row 2
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (int i = 3; i < 6; i++) _buildBalloonChoice(i),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 24),

            // Right page: Character holding colored balloons + count overlay
            Expanded(
              child: DragTarget<Map<String, int>>(
                onWillAcceptWithDetails: (details) => true,
                onAcceptWithDetails: (details) => _onColorMatched(
                  details.data['choiceIndex']!,
                  details.data['colorIndex']!,
                ),
                builder: (context, candidateData, rejectedData) {
                  return Stack(
                    alignment: Alignment.center,
                    fit: StackFit.expand,
                    children: [
                      // Base balloon holder (boy/girl)
                      Image.asset(
                        isBoy
                            ? 'assets/alippe/images/books/book5/section2/baloon_holders/boy.png'
                            : 'assets/alippe/images/books/book5/section2/baloon_holders/girl.png',
                        fit: BoxFit.contain,
                      ),

                      // Overlay of colored balloons target
                      Image.asset(
                        currentTarget.bgImage,
                        fit: BoxFit.contain,
                      ),

                      // Digit count overlay on top of balloons
                      Image.asset(
                        'assets/alippe/images/books/book5/section2/digits/$_collectedCount.png',
                        fit: BoxFit.contain,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalloonChoice(int index) {
    if (index >= _availableChoices.length) return const SizedBox.shrink();
    final colorIdx = _availableChoices[index];
    if (colorIdx == null) return const SizedBox(width: 90, height: 90);

    final colorItem = _colors[colorIdx];

    return Transform.rotate(
      angle: -5 * math.pi / 180, // React Native's -5deg tilt
      child: Draggable<Map<String, int>>(
        data: {'choiceIndex': index, 'colorIndex': colorIdx},
        onDragStarted: () => AlippeAudio().playPickUp2(),
        onDraggableCanceled: (velocity, offset) => AlippeAudio().playBackSwoosh(),
        feedback: Material(
          color: Colors.transparent,
          child: Transform.rotate(
            angle: -5 * math.pi / 180,
            child: Transform.scale(
              scale: 1.2,
              child: SizedBox(
                width: 95,
                height: 95,
                child: Image.asset(colorItem.btnImage, fit: BoxFit.contain),
              ),
            ),
          ),
        ),
        childWhenDragging: const Opacity(
          opacity: 0.0,
          child: SizedBox(width: 90, height: 90),
        ),
        child: SizedBox(
          width: 90,
          height: 90,
          child: Image.asset(colorItem.btnImage, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
