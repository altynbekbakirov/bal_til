import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/alippe_audio.dart';
import '../../core/alippe_cubit.dart';
import '../../data/alippe_data.dart';
import '../../widgets/alippe_anim_button.dart';
import '../../widgets/alippe_book_base.dart';
import '../../widgets/alippe_container.dart';
import '../dialogs/alippe_game_finish_dialog.dart';

class Section1View extends StatefulWidget {
  const Section1View({super.key});

  @override
  State<Section1View> createState() => _Section1ViewState();
}

class _Section1ViewState extends State<Section1View> {
  int _wordIndex = 0;
  final List<SpellingWord> _words = AlippeData.section1Items;

  late List<SpellingLetter?> _placedLetters;
  late List<SpellingLetter> _availableLetters;

  @override
  void initState() {
    super.initState();
    _loadWord();
  }

  void _loadWord() {
    final currentWord = _words[_wordIndex];
    _placedLetters = List<SpellingLetter?>.filled(currentWord.letters.length, null);
    _availableLetters = List<SpellingLetter>.from(currentWord.letters)..shuffle();
  }

  void _onLetterPlaced(int slotIndex, SpellingLetter letter) {
    setState(() {
      _placedLetters[slotIndex] = letter;
      _availableLetters.remove(letter);
    });

    AlippeAudio().playPickUp();

    // Check if word is complete
    if (!_placedLetters.contains(null)) {
      final currentWord = _words[_wordIndex];
      bool correct = true;
      for (int i = 0; i < currentWord.letters.length; i++) {
        if (_placedLetters[i]?.key != currentWord.letters[i].key) {
          correct = false;
          break;
        }
      }

      if (correct) {
        AlippeAudio().playGood();
        Future.delayed(const Duration(milliseconds: 700), () {
          if (!mounted) return;
          if (_wordIndex < _words.length - 1) {
            setState(() {
              _wordIndex++;
              _loadWord();
            });
          } else {
            // Word game finished!
            context.read<AlippeCubit>().addScore(0, 3);
            AlippeGameFinishDialog.show(
              context: context,
              score: 3,
              onRestart: () {
                setState(() {
                  _wordIndex = 0;
                  _loadWord();
                });
              },
              onNext: () {
                Navigator.of(context).pushReplacementNamed('/section', arguments: 2);
              },
              onHome: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            );
          }
        });
      } else {
        AlippeAudio().playFail();
        Future.delayed(const Duration(milliseconds: 600), () {
          if (!mounted) return;
          setState(() {
            _loadWord();
          });
        });
      }
    }
  }

  void _onLetterTapped(SpellingLetter letter) {
    // Find first empty slot
    final emptySlot = _placedLetters.indexOf(null);
    if (emptySlot != -1) {
      _onLetterPlaced(emptySlot, letter);
    }
  }

  void _onSlotTapped(int slotIndex) {
    final letter = _placedLetters[slotIndex];
    if (letter != null) {
      AlippeAudio().playPickUp2();
      setState(() {
        _placedLetters[slotIndex] = null;
        _availableLetters.add(letter);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final word = _words[_wordIndex];

    return AlippeContainer(
      child: AlippeBookBase(
        bookId: 0,
        onLeftPress: _wordIndex > 0
            ? () {
                setState(() {
                  _wordIndex--;
                  _loadWord();
                });
              }
            : null,
        onRightPress: _wordIndex < _words.length - 1
            ? () {
                setState(() {
                  _wordIndex++;
                  _loadWord();
                });
              }
            : null,
        child: Row(
          children: [
            // Left Page: Word illustration image
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Image.asset(
                    word.pic,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 40),

            // Right Page: Slots on top, Draggable/Tappable letters below
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Slots Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(word.letters.length, (slotIdx) {
                        final placed = _placedLetters[slotIdx];
                        return DragTarget<SpellingLetter>(
                          onWillAcceptWithDetails: (_) => placed == null,
                          onAcceptWithDetails: (details) =>
                              _onLetterPlaced(slotIdx, details.data),
                          builder: (context, candidateData, rejectedData) {
                            return GestureDetector(
                              onTap: () => _onSlotTapped(slotIdx),
                              child: Container(
                                width: 85,
                                height: 85,
                                margin: const EdgeInsets.symmetric(horizontal: 8),
                                child: placed != null
                                    ? Image.asset(placed.item, fit: BoxFit.contain)
                                    : Image.asset(
                                        word.letters[slotIdx].placeholder,
                                        fit: BoxFit.contain,
                                      ),
                              ),
                            );
                          },
                        );
                      }),
                    ),

                    const SizedBox(height: 20),

                    // Available Letters Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _availableLetters.map((letter) {
                        return Draggable<SpellingLetter>(
                          data: letter,
                          feedback: Material(
                            color: Colors.transparent,
                            child: Image.asset(
                              letter.item,
                              width: 90,
                              height: 90,
                              fit: BoxFit.contain,
                            ),
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.3,
                            child: Image.asset(
                              letter.item,
                              width: 80,
                              height: 80,
                              fit: BoxFit.contain,
                            ),
                          ),
                          child: GestureDetector(
                            onTap: () => _onLetterTapped(letter),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 10),
                              child: AlippeAnimButton(
                                width: 85,
                                height: 85,
                                imageAsset: letter.item,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
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
