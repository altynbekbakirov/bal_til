import 'dart:math' as math;
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
  final bool isFaceUp;
  final bool isMatched;

  const _CardModel({
    required this.pairId,
    required this.image,
    this.isFaceUp = false,
    this.isMatched = false,
  });

  _CardModel copyWith({
    bool? isFaceUp,
    bool? isMatched,
  }) {
    return _CardModel(
      pairId: pairId,
      image: image,
      isFaceUp: isFaceUp ?? this.isFaceUp,
      isMatched: isMatched ?? this.isMatched,
    );
  }
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
      _cards[index] = _cards[index].copyWith(isFaceUp: true);
    });

    if (_firstSelectedIndex == null) {
      // First card flipped
      _firstSelectedIndex = index;
    } else {
      // Second card flipped
      final firstIdx = _firstSelectedIndex!;
      _firstSelectedIndex = null;

      if (_cards[firstIdx].pairId == _cards[index].pairId) {
        // Matched!
        AlippeAudio().playGood();
        setState(() {
          _cards[firstIdx] = _cards[firstIdx].copyWith(isMatched: true);
          _cards[index] = _cards[index].copyWith(isMatched: true);
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
        _isProcessing = true;
        Future.delayed(const Duration(milliseconds: 750), () {
          if (!mounted) return;
          setState(() {
            _cards[firstIdx] = _cards[firstIdx].copyWith(isFaceUp: false);
            _cards[index] = _cards[index].copyWith(isFaceUp: false);
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
                  scaleFactor: 1.3,
                  imageAsset: AlippeAssets.sideRestart,
                  onPress: () {
                    AlippeAudio().playReset();
                    setState(() {
                      _level = 1;
                      _startLevel();
                    });
                  },
                ),
                const Spacer(),
                AlippeAnimButton(
                  width: 75,
                  height: 75,
                  scaleFactor: 1.3,
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
    return _AlippeMemoryCardWidget(
      key: ValueKey('card_${_level}_${card.pairId}_$index'),
      isFaceUp: card.isFaceUp,
      isMatched: card.isMatched,
      image: card.image,
      onTap: () => _onCardTap(index),
    );
  }
}

class _AlippeMemoryCardWidget extends StatefulWidget {
  final bool isFaceUp;
  final bool isMatched;
  final String image;
  final VoidCallback onTap;

  const _AlippeMemoryCardWidget({
    super.key,
    required this.isFaceUp,
    required this.isMatched,
    required this.image,
    required this.onTap,
  });

  @override
  State<_AlippeMemoryCardWidget> createState() => _AlippeMemoryCardWidgetState();
}

class _AlippeMemoryCardWidgetState extends State<_AlippeMemoryCardWidget>
    with TickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  late AnimationController _matchController;
  late Animation<double> _matchScaleAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: math.pi).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );

    if (widget.isFaceUp) {
      _flipController.value = 1.0;
    }

    _matchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _matchScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.30)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 55,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.30, end: 1.0)
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 45,
      ),
    ]).animate(_matchController);
  }

  @override
  void didUpdateWidget(covariant _AlippeMemoryCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFaceUp != oldWidget.isFaceUp) {
      if (widget.isFaceUp) {
        _flipController.forward();
      } else {
        _flipController.reverse();
      }
    }

    if (widget.isMatched && !oldWidget.isMatched) {
      _matchController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    _matchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: Listenable.merge([_flipAnimation, _matchScaleAnimation]),
        builder: (context, _) {
          final angle = _flipAnimation.value;
          final isUnder = angle > (math.pi / 2);

          // 3D perspective flip around Y axis
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.0015)
            ..rotateY(angle);

          Widget content;
          if (isUnder) {
            // Front face (reverse rotation so content is right-side up)
            content = Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(math.pi),
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
                      padding: const EdgeInsets.all(16.0),
                      child: Image.asset(
                        widget.image,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            // Back face
            content = AspectRatio(
              aspectRatio: 255 / 347,
              child: Image.asset(
                AlippeData.cardBack,
                fit: BoxFit.contain,
              ),
            );
          }

          return Center(
            child: ScaleTransition(
              scale: _matchScaleAnimation,
              child: Transform(
                alignment: Alignment.center,
                transform: transform,
                child: content,
              ),
            ),
          );
        },
      ),
    );
  }
}
