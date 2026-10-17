import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/alippe_audio.dart';
import '../../core/alippe_constants.dart';
import '../../core/alippe_cubit.dart';
import '../../data/alippe_data.dart';
import '../../widgets/alippe_anim_button.dart';
import '../../widgets/alippe_container.dart';
import '../dialogs/alippe_game_finish_dialog.dart';

class Section10View extends StatefulWidget {
  const Section10View({super.key});

  @override
  State<Section10View> createState() => _Section10ViewState();
}

class _CardModel {
  final int pairId;
  final String image;
  bool isFaceUp = false;
  bool isMatched = false;

  _CardModel({
    required this.pairId,
    required this.image,
  });
}

class _Section10ViewState extends State<Section10View> {
  int _level = 1; // 1: 6 cards (3 pairs), 2: 8 cards (4 pairs)
  late List<_CardModel> _cards;
  int? _firstSelectedIndex;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _startLevel();
  }

  void _startLevel() {
    _firstSelectedIndex = null;
    _isProcessing = false;

    final numPairs = _level == 1 ? 3 : 4;
    final allImages = List<String>.from(AlippeData.section10Items)..shuffle();
    final chosenImages = allImages.take(numPairs).toList();

    final List<_CardModel> list = [];
    for (int i = 0; i < chosenImages.length; i++) {
      list.add(_CardModel(pairId: i, image: chosenImages[i]));
      list.add(_CardModel(pairId: i, image: chosenImages[i]));
    }
    list.shuffle();

    setState(() {
      _cards = list;
    });
  }

  void _onCardTap(int index) {
    if (_isProcessing || _cards[index].isFaceUp || _cards[index].isMatched) {
      return;
    }

    AlippeAudio().playFlipCard();

    setState(() {
      _cards[index].isFaceUp = true;
    });

    if (_firstSelectedIndex == null) {
      // First card flipped
      _firstSelectedIndex = index;
    } else {
      // Second card flipped
      final firstIdx = _firstSelectedIndex!;
      _firstSelectedIndex = null;
      _isProcessing = true;

      if (_cards[firstIdx].pairId == _cards[index].pairId) {
        // Matched!
        AlippeAudio().playGood();
        setState(() {
          _cards[firstIdx].isMatched = true;
          _cards[index].isMatched = true;
          _isProcessing = false;
        });

        // Check if all matched
        if (_cards.every((c) => c.isMatched)) {
          AlippeAudio().playNext();
          Future.delayed(const Duration(milliseconds: 700), () {
            if (!mounted) return;
            if (_level == 1) {
              setState(() {
                _level = 2;
                _startLevel();
              });
            } else {
              // Level 2 complete -> Finished Section 10!
              context.read<AlippeCubit>().addScore(5, 3);
              AlippeGameFinishDialog.show(
                context: context,
                score: 3,
                onRestart: () {
                  setState(() {
                    _level = 1;
                    _startLevel();
                  });
                },
                onNext: () {
                  AlippeGameFinishDialog.navigateToAlippeHome(context);
                },
                onHome: () {
                  AlippeGameFinishDialog.navigateToAlippeHome(context);
                },
              );
            }
          });
        }
      } else {
        // Not a match -> flip back after delay
        AlippeAudio().playFail();
        Future.delayed(const Duration(milliseconds: 700), () {
          if (!mounted) return;
          setState(() {
            _cards[firstIdx].isFaceUp = false;
            _cards[index].isFaceUp = false;
            _isProcessing = false;
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final columns = _level == 1 ? 3 : 4;

    return AlippeContainer(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sidebar with Restart and Back buttons
          Container(
            width: 100,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Column(
              children: [
                AlippeAnimButton(
                  width: 75,
                  height: 75,
                  scaleFactor: 1.15,
                  imageAsset: AlippeAssets.sideRestart,
                  onPress: () {
                    AlippeAudio().playReset();
                    _startLevel();
                  },
                ),
                const Spacer(),
                AlippeAnimButton(
                  width: 75,
                  height: 75,
                  scaleFactor: 1.15,
                  imageAsset: AlippeAssets.sideBack,
                  onPress: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Main Card Rows (2 rows, strictly bounded by screen height)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 16, 24, 16),
              child: Column(
                children: [
                  // Row 1
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (int i = 0; i < columns; i++)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              child: _buildCard(i),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Row 2
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (int i = columns; i < columns * 2; i++)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              child: _buildCard(i),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(int index) {
    if (index >= _cards.length) return const SizedBox.shrink();
    final card = _cards[index];

    if (card.isMatched) {
      return const SizedBox.shrink(); // Vanish on match
    }

    return GestureDetector(
      onTap: () => _onCardTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return ScaleTransition(
            scale: animation,
            child: child,
          );
        },
        child: card.isFaceUp
            ? Center(
                key: ValueKey('front_${card.pairId}_$index'),
                child: AspectRatio(
                  aspectRatio: 255 / 347,
                  child: Stack(
                    alignment: Alignment.center,
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        AlippeData.cardFront,
                        fit: BoxFit.contain,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Image.asset(
                          card.image,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Center(
                key: ValueKey('back_$index'),
                child: AspectRatio(
                  aspectRatio: 255 / 347,
                  child: Image.asset(
                    AlippeData.cardBack,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
      ),
    );
  }
}
