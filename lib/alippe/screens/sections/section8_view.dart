import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/alippe_audio.dart';
import '../../core/alippe_cubit.dart';
import '../../data/alippe_data.dart';
import '../../widgets/alippe_anim_button.dart';
import '../../widgets/alippe_book_base.dart';
import '../../widgets/alippe_container.dart';
import '../dialogs/alippe_game_finish_dialog.dart';

class Section8View extends StatefulWidget {
  const Section8View({super.key});

  @override
  State<Section8View> createState() => _Section8ViewState();
}

class _Section8ViewState extends State<Section8View> {
  int _round = 0;
  final int _itemsPerRound = 3;
  late List<int> _currentRoundItemIndices;
  late List<bool> _matched;
  late List<int> _shuffledAvailable;

  @override
  void initState() {
    super.initState();
    _setupRound();
  }

  void _setupRound() {
    final start = _round * _itemsPerRound;
    _currentRoundItemIndices = List.generate(
      _itemsPerRound,
      (i) => (start + i) % AlippeData.section8Items.length,
    );
    _matched = List.filled(_itemsPerRound, false);
    _shuffledAvailable = List<int>.from(_currentRoundItemIndices)..shuffle();
  }

  void _onMatched(int slotIdx, int itemIdx) {
    if (_currentRoundItemIndices[slotIdx] == itemIdx) {
      AlippeAudio().playGood();
      setState(() {
        _matched[slotIdx] = true;
        _shuffledAvailable.remove(itemIdx);
      });

      if (!_matched.contains(false)) {
        // Round completed!
        Future.delayed(const Duration(milliseconds: 600), () {
          if (!mounted) return;
          if (_round < 6) {
            setState(() {
              _round++;
              _setupRound();
            });
          } else {
            // Section 8 finished!
            context.read<AlippeCubit>().addScore(4, 2);
            AlippeGameFinishDialog.show(
              context: context,
              score: 3,
              onRestart: () {
                setState(() {
                  _round = 0;
                  _setupRound();
                });
              },
              onNext: () {
                Navigator.of(context).pushReplacementNamed('/section', arguments: 9);
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
    return AlippeContainer(
      child: AlippeBookBase(
        bookId: 4,
        onLeftPress: _round > 0
            ? () {
                setState(() {
                  _round--;
                  _setupRound();
                });
              }
            : null,
        onRightPress: _round < 6
            ? () {
                setState(() {
                  _round++;
                  _setupRound();
                });
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Top Row: Silhouettes (Placeholders)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(_itemsPerRound, (slotIdx) {
                  final itemIdx = _currentRoundItemIndices[slotIdx];
                  final isMatched = _matched[slotIdx];

                  return DragTarget<int>(
                    onWillAcceptWithDetails: (details) => !isMatched,
                    onAcceptWithDetails: (details) =>
                        _onMatched(slotIdx, details.data),
                    builder: (context, candidateData, rejectedData) {
                      return Container(
                        width: 140,
                        height: 140,
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(
                          isMatched
                              ? AlippeData.section8Items[itemIdx]
                              : AlippeData.section8Placeholders[itemIdx],
                          fit: BoxFit.contain,
                        ),
                      );
                    },
                  );
                }),
              ),

              const Divider(color: Colors.brown, thickness: 2, height: 40),

              // Bottom Row: Draggable colorful items
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _shuffledAvailable.map((itemIdx) {
                  final imgPath = AlippeData.section8Items[itemIdx];

                  return Draggable<int>(
                    data: itemIdx,
                    feedback: Material(
                      color: Colors.transparent,
                      child: Image.asset(
                        imgPath,
                        width: 150,
                        height: 150,
                        fit: BoxFit.contain,
                      ),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.3,
                      child: Image.asset(
                        imgPath,
                        width: 130,
                        height: 130,
                        fit: BoxFit.contain,
                      ),
                    ),
                    child: AlippeAnimButton(
                      width: 130,
                      height: 130,
                      imageAsset: imgPath,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
