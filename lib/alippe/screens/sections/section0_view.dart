import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/alippe_cubit.dart';
import '../../core/alippe_tts.dart';
import '../../data/alippe_data.dart';
import '../../widgets/alippe_anim_button.dart';
import '../../widgets/alippe_book_base.dart';
import '../../widgets/alippe_container.dart';
import '../dialogs/alippe_game_finish_dialog.dart';

class Section0View extends StatefulWidget {
  const Section0View({super.key});

  @override
  State<Section0View> createState() => _Section0ViewState();
}

class _Section0ViewState extends State<Section0View> {
  int _letterIndex = 0;
  final List<LetterItem> _items = AlippeData.section0Items;

  void _nextLetter() {
    AlippeTts().stop();
    final cubit = context.read<AlippeCubit>();
    if (_letterIndex < _items.length - 1) {
      setState(() {
        _letterIndex++;
      });
      if (_letterIndex == 10) cubit.addScore(0, 1);
      if (_letterIndex == 20) cubit.addScore(0, 2);
    } else {
      // Completed all 36 letters!
      cubit.addScore(0, 3);
      AlippeGameFinishDialog.show(
        context: context,
        score: 3,
        onRestart: () {
          setState(() {
            _letterIndex = 0;
          });
        },
        onNext: () {
          // Open section 1
          Navigator.of(context).pushReplacementNamed('/section', arguments: 1);
        },
        onHome: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      );
    }
  }

  void _prevLetter() {
    AlippeTts().stop();
    if (_letterIndex > 0) {
      setState(() {
        _letterIndex--;
      });
    }
  }

  @override
  void dispose() {
    AlippeTts().stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = _items[_letterIndex];
    final isBoy = context.watch<AlippeCubit>().state.boyActive;

    return AlippeContainer(
      child: AlippeBookBase(
        bookId: 0,
        onLeftPress: _letterIndex > 0 ? _prevLetter : null,
        onRightPress: _nextLetter,
        child: Row(
          children: [
            // Left Page: Letters (PIC1 and PIC2)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Expanded(
                      child: AlippeAnimButton(
                        key: ValueKey('letter_${_letterIndex}_pic1'),
                        imageAsset: item.pic1,
                        soundAsset: item.letterSound(isBoy),
                        spokenText: item.letter,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: AlippeAnimButton(
                        key: ValueKey('letter_${_letterIndex}_pic2'),
                        imageAsset: item.pic2,
                        soundAsset: item.letterSound(isBoy),
                        spokenText: item.letter,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 40),

            // Right Page: Illustrations (PIC3 and PIC4)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Expanded(
                      child: AlippeAnimButton(
                        key: ValueKey('letter_${_letterIndex}_pic3'),
                        imageAsset: item.pic3,
                        soundAsset: item.pic1Sound(isBoy),
                        spokenText: item.word1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: AlippeAnimButton(
                        key: ValueKey('letter_${_letterIndex}_pic4'),
                        imageAsset: item.pic4,
                        soundAsset: item.pic2Sound(isBoy),
                        spokenText: item.word2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
