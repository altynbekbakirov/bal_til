import 'dart:math' as math;
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

class _DraggableLetterEntry {
  final int id; // Unique instance ID so multiple identical letters (e.g. 'N', 'A', 'N') are tracked independently
  final SpellingLetter letter;
  final double rotation;

  const _DraggableLetterEntry({
    required this.id,
    required this.letter,
    required this.rotation,
  });
}

class _Section1ViewState extends State<Section1View> {
  int _wordIndex = 0;
  final List<SpellingWord> _words = AlippeData.section1Items;

  late List<_DraggableLetterEntry?> _placedEntries;
  late List<_DraggableLetterEntry> _availableEntries;

  @override
  void initState() {
    super.initState();
    _loadWord();
  }

  void _loadWord() {
    final currentWord = _words[_wordIndex];
    final random = math.Random();
    _placedEntries = List<_DraggableLetterEntry?>.filled(currentWord.letters.length, null);

    // Create unique letter entries with individual rotation
    final entries = List.generate(currentWord.letters.length, (i) {
      final deg = (random.nextDouble() * 40 - 20); // -20deg .. 20deg
      return _DraggableLetterEntry(
        id: i,
        letter: currentWord.letters[i],
        rotation: deg * math.pi / 180,
      );
    });

    // Always show a scrambled (wrong) combination of letters at the bottom
    if (entries.length > 1) {
      final targetSpell = currentWord.letters.map((l) => l.key).join('');
      String currentSpell(List<_DraggableLetterEntry> list) =>
          list.map((e) => e.letter.key).join('');

      int attempts = 0;
      while (currentSpell(entries) == targetSpell && attempts < 25) {
        entries.shuffle(random);
        attempts++;
      }

      // If still matching the answer (e.g. palindromes like 'nan' after symmetric shuffle),
      // forcefully swap two distinct letters so it is guaranteed scrambled.
      if (currentSpell(entries) == targetSpell) {
        for (int i = 0; i < entries.length - 1; i++) {
          if (entries[i].letter.key != entries[i + 1].letter.key) {
            final temp = entries[i];
            entries[i] = entries[i + 1];
            entries[i + 1] = temp;
            break;
          }
        }
      }
    }

    _availableEntries = entries;
  }

  void _onLetterPlaced(int slotIndex, _DraggableLetterEntry entry) {
    AlippeAudio().playBell();

    setState(() {
      _placedEntries[slotIndex] = entry;
      // Remove ONLY this specific letter instance by its unique id
      _availableEntries.removeWhere((e) => e.id == entry.id);
    });

    // Check if word is complete
    if (!_placedEntries.contains(null)) {
      final currentWord = _words[_wordIndex];
      bool correct = true;
      for (int i = 0; i < currentWord.letters.length; i++) {
        if (_placedEntries[i]?.letter.key != currentWord.letters[i].key) {
          correct = false;
          break;
        }
      }

      if (correct) {
        AlippeAudio().playGood();
        Future.delayed(const Duration(milliseconds: 600), () {
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
                AlippeGameFinishDialog.navigateToAlippeHome(context);
              },
            );
          }
        });
      }
    }
  }

  void _onLetterTapped(_DraggableLetterEntry entry) {
    final currentWord = _words[_wordIndex];
    // Find matching empty slot for this letter
    for (int i = 0; i < currentWord.letters.length; i++) {
      if (_placedEntries[i] == null && currentWord.letters[i].key == entry.letter.key) {
        _onLetterPlaced(i, entry);
        return;
      }
    }
    // If no matching empty slot, play swoosh sound
    AlippeAudio().playBackSwoosh();
  }

  void _onSlotTapped(int slotIndex) {
    final entry = _placedEntries[slotIndex];
    if (entry != null) {
      AlippeAudio().playPickUp2();
      setState(() {
        _placedEntries[slotIndex] = null;
        _availableEntries.add(entry);
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
            // Left Page: Word illustration with pic_bg.png frame (matches React Section 1)
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Stack(
                    alignment: Alignment.center,
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        AlippeData.section1PicBg,
                        fit: BoxFit.contain,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(28.0),
                        child: Image.asset(
                          word.pic,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
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
                    // Slots Row with generous hit-test area and hover animation
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(word.letters.length, (slotIdx) {
                          final placed = _placedEntries[slotIdx];
                          final slotSize = word.letters.length <= 2
                              ? 120.0
                              : (word.letters.length == 3 ? 112.0 : 88.0);
                          final horizontalPad = word.letters.length <= 2
                              ? 12.0
                              : (word.letters.length == 3 ? 6.0 : 4.0);

                          return DragTarget<_DraggableLetterEntry>(
                            hitTestBehavior: HitTestBehavior.translucent,
                            onWillAcceptWithDetails: (details) =>
                                placed == null && details.data.letter.key == word.letters[slotIdx].key,
                            onAcceptWithDetails: (details) =>
                              _onLetterPlaced(slotIdx, details.data),
                            builder: (context, candidateData, rejectedData) {
                              final isHovering = candidateData.isNotEmpty;

                              return GestureDetector(
                                onTap: () => _onSlotTapped(slotIdx),
                                behavior: HitTestBehavior.translucent,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: horizontalPad, vertical: 16),
                                  color: Colors.transparent,
                                  child: AnimatedScale(
                                    scale: isHovering ? 1.15 : 1.0,
                                    duration: const Duration(milliseconds: 160),
                                    curve: Curves.easeOutBack,
                                    child: SizedBox(
                                      width: slotSize,
                                      height: slotSize,
                                      child: placed != null
                                          ? Image.asset(placed.letter.item, fit: BoxFit.contain)
                                          : Image.asset(
                                              word.letters[slotIdx].placeholder,
                                              fit: BoxFit.contain,
                                            ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Available Letters Row (always scrambled, individual instance tracking)
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _availableEntries.map((entry) {
                          final letterSize = word.letters.length <= 2
                              ? 106.0
                              : (word.letters.length == 3 ? 98.0 : 85.0);

                          return Transform.rotate(
                            angle: entry.rotation,
                            child: Draggable<_DraggableLetterEntry>(
                              data: entry,
                              onDragStarted: () => AlippeAudio().playPickUp(),
                              onDraggableCanceled: (velocity, offset) =>
                                  AlippeAudio().playBackSwoosh(),
                              feedback: Material(
                                color: Colors.transparent,
                                child: Transform.scale(
                                  scale: 1.25,
                                  child: SizedBox(
                                    width: 110,
                                    height: 110,
                                    child: Image.asset(
                                      entry.letter.item,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                              childWhenDragging: const Opacity(
                                opacity: 0.0,
                                child: SizedBox(width: 85, height: 85),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 6),
                                child: AlippeAnimButton(
                                  width: letterSize,
                                  height: letterSize,
                                  noTapSnd: true,
                                  noTimeout: true,
                                  imageAsset: entry.letter.item,
                                  onPress: () => _onLetterTapped(entry),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
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
