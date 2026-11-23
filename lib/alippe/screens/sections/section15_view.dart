import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/alippe_audio.dart';
import '../../core/alippe_constants.dart';
import '../../core/alippe_cubit.dart';
import '../../core/alippe_tts.dart';
import '../../data/speech_development_data.dart';
import '../../widgets/alippe_anim_button.dart';
import '../../widgets/alippe_container.dart';
import '../dialogs/alippe_game_finish_dialog.dart';

class Section15View extends StatefulWidget {
  const Section15View({super.key});

  @override
  State<Section15View> createState() => _Section15ViewState();
}

class _Section15ViewState extends State<Section15View> {
  late final List<WordGuessItem> _items;
  int _currentIndex = 0;
  String? _selectedOption;
  bool _isSolved = false;
  final Set<String> _wrongOptions = {};
  Timer? _autoPlayTimer;
  Timer? _transitionTimer;

  @override
  void initState() {
    super.initState();
    _items = List.from(SpeechDevelopmentData.stage4WordGuesses);
    _loadQuestion();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _transitionTimer?.cancel();
    super.dispose();
  }

  void _loadQuestion() {
    _autoPlayTimer?.cancel();
    _transitionTimer?.cancel();
    _selectedOption = null;
    _isSolved = false;
    _wrongOptions.clear();

    _autoPlayTimer = Timer(const Duration(milliseconds: 350), () {
      if (mounted) _playFirstPartPrompt();
    });
  }

  void _playFirstPartPrompt() {
    if (!mounted) return;
    final current = _items[_currentIndex];
    // Speak the first syllable prompt, e.g. "Ал..."
    AlippeTts().speak(current.firstPart);
  }

  void _playFullWord() {
    if (!mounted) return;
    final current = _items[_currentIndex];
    final isBoy = context.read<AlippeCubit>().state.boyActive;
    final sound = current.getSound(isBoy);
    AlippeAudio().playSfx(sound);
    AlippeTts().speak(current.fullWord);
  }

  void _onOptionTap(String option) {
    if (_isSolved || _wrongOptions.contains(option)) return;

    final current = _items[_currentIndex];

    if (option == current.missingPart) {
      setState(() {
        _isSolved = true;
        _selectedOption = option;
      });
      _playFullWord();

      _transitionTimer = Timer(const Duration(milliseconds: 1100), () {
        if (!mounted) return;
        if (_currentIndex < _items.length - 1) {
          setState(() {
            _currentIndex++;
            _loadQuestion();
          });
        } else {
          _finishGame();
        }
      });
    } else {
      AlippeAudio().playFail();
      setState(() {
        _wrongOptions.add(option);
      });
    }
  }

  void _finishGame() {
    final cubit = context.read<AlippeCubit>();
    cubit.completeSection(15);
    cubit.addScore(9, 3);

    AlippeGameFinishDialog.show(
      context: context,
      score: 3,
      onRestart: () {
        AlippeAudio().playReset();
        setState(() {
          _currentIndex = 0;
          _loadQuestion();
        });
      },
      onNext: () => AlippeGameFinishDialog.navigateToAlippeHome(context),
      onHome: () => AlippeGameFinishDialog.navigateToAlippeHome(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = _items[_currentIndex];

    return AlippeContainer(
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 120,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: Column(
                children: [
                  AlippeAnimButton(
                    key: const Key('section15_restart_button'),
                    width: 75,
                    height: 75,
                    scaleFactor: 1.3,
                    imageAsset: AlippeAssets.sideRestart,
                    onPress: () {
                      AlippeAudio().playReset();
                      setState(() {
                        _currentIndex = 0;
                        _loadQuestion();
                      });
                    },
                  ),
                  const Spacer(),
                  AlippeAnimButton(
                    key: const Key('section15_back_button'),
                    width: 75,
                    height: 75,
                    scaleFactor: 1.3,
                    imageAsset: AlippeAssets.sideBack,
                    onPress: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ),
          Positioned.fill(
            left: 120,
            right: 20,
            top: 16,
            bottom: 16,
            child: Column(
              children: [
                // Top status bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                        ],
                      ),
                      child: Text(
                        'Сөздү тап: ${_currentIndex + 1}/${_items.length}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFC2185B),
                        ),
                      ),
                    ),
                    const Text(
                      'Сөздүн уландысын тап!',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        shadows: [
                          Shadow(blurRadius: 4, color: Colors.black54, offset: Offset(1, 1)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Main Area
                Expanded(
                  child: Row(
                    children: [
                      // Left: Word puzzle card + Image
                      Expanded(
                        flex: 6,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFFF06292), width: 3),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Picture
                              Expanded(
                                child: Image.asset(current.image, fit: BoxFit.contain),
                              ),
                              const SizedBox(height: 12),

                              // Syllable Puzzle Display
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // First Part
                                  GestureDetector(
                                    onTap: _playFirstPartPrompt,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFCE4EC),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: const Color(0xFFE91E63), width: 2),
                                      ),
                                      child: Text(
                                        current.firstPart,
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFAD1457),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Missing Part Slot
                                  Container(
                                    width: 84,
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: _isSolved ? const Color(0xFFE8F5E9) : const Color(0xFFFFF9C4),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: _isSolved ? const Color(0xFF4CAF50) : const Color(0xFFFBC02D),
                                        width: 2.5,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      _isSolved ? current.missingPart : '?',
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: _isSolved ? const Color(0xFF2E7D32) : const Color(0xFFF57F17),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (_isSolved) ...[
                                const SizedBox(height: 8),
                                Text(
                                  '= ${current.fullWord}!',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E7D32),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Right: Choices (Syllable bubbles)
                      Expanded(
                        flex: 5,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Туура муунду танда:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                              ),
                            ),
                            const SizedBox(height: 12),
                            for (final opt in current.options) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6.0),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    key: Key('word_guess_opt_$opt'),
                                    onPressed: _wrongOptions.contains(opt) ? null : () => _onOptionTap(opt),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _selectedOption == opt
                                          ? const Color(0xFF4CAF50)
                                          : _wrongOptions.contains(opt)
                                              ? Colors.grey.shade400
                                              : Colors.white,
                                      foregroundColor: _selectedOption == opt
                                          ? Colors.white
                                          : const Color(0xFFC2185B),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        side: BorderSide(
                                          color: _wrongOptions.contains(opt)
                                              ? Colors.grey
                                              : const Color(0xFFE91E63),
                                          width: 2,
                                        ),
                                      ),
                                      elevation: 3,
                                    ),
                                    child: Text(
                                      opt,
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: _wrongOptions.contains(opt)
                                            ? Colors.white70
                                            : _selectedOption == opt
                                                ? Colors.white
                                                : const Color(0xFFC2185B),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
