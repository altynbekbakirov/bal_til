import 'dart:async';
import 'dart:math' as math;
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
  late List<String> _currentOptions;
  String? _selectedOption;
  bool _isSolved = false;
  final Set<String> _wrongOptions = {};
  Timer? _autoPlayTimer;
  Timer? _transitionTimer;
  Timer? _fullWordTimer;

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
    _fullWordTimer?.cancel();
    AlippeAudio().stopSfx();
    AlippeTts().stop();
    super.dispose();
  }

  void _loadQuestion() {
    _autoPlayTimer?.cancel();
    _transitionTimer?.cancel();
    _fullWordTimer?.cancel();
    _selectedOption = null;
    _isSolved = false;
    _wrongOptions.clear();

    final current = _items[_currentIndex];
    // Shuffle options so the right answer is not always in the first place
    _currentOptions = List<String>.from(current.options)..shuffle(math.Random());

    AlippeTts().stop();

    _autoPlayTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) _playFirstPartPrompt();
    });
  }

  void _playFirstPartPrompt() {
    if (!mounted || _isSolved) return;
    AlippeTts().stop();
    final current = _items[_currentIndex];
    final isBoy = context.read<AlippeCubit>().state.boyActive;
    final promptSound = current.getPromptSound(isBoy);
    if (promptSound != null && promptSound.isNotEmpty) {
      // Play authentic Kyrgyz human recording from assets (e.g. "Ба", "То")
      AlippeAudio().playSfx(promptSound);
    } else {
      AlippeTts().speak(current.firstPart.replaceAll('-', '').trim());
    }
  }

  void _playFullWord() {
    if (!mounted) return;
    final current = _items[_currentIndex];
    final isBoy = context.read<AlippeCubit>().state.boyActive;
    final sound = current.getSound(isBoy);
    AlippeTts().stop();
    // Play the full word sound once (without repeating via TTS)
    if (sound.isNotEmpty) {
      AlippeAudio().playSfx(sound);
    } else {
      AlippeTts().speak(current.fullWord);
    }
  }

  void _onOptionTap(String option) {
    if (_isSolved || _wrongOptions.contains(option)) return;

    final current = _items[_currentIndex];

    if (option == current.missingPart) {
      AlippeTts().stop();
      _fullWordTimer?.cancel();
      // Play good sound on correct completion consistent with games 1-6
      AlippeAudio().playGood();

      setState(() {
        _isSolved = true;
        _selectedOption = option;
      });

      // Play completed full word once after brief jingle pause without sound overlap
      _fullWordTimer = Timer(const Duration(milliseconds: 700), () {
        if (mounted) _playFullWord();
      });

      _transitionTimer?.cancel();
      // Time pause before proceeding to next round so sounds do not overlap
      _transitionTimer = Timer(const Duration(milliseconds: 2400), () {
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
      AlippeTts().stop();
      // Incorrect answer: play fail sound consistent with games 1-6
      AlippeAudio().playFail();
      setState(() {
        _wrongOptions.add(option);
      });
    }
  }

  void _finishGame() {
    AlippeAudio().stopSfx();
    AlippeTts().stop();
    final cubit = context.read<AlippeCubit>();
    cubit.completeSection(15);
    cubit.addScore(9, 3);

    AlippeGameFinishDialog.show(
      context: context,
      score: 3,
      onRestart: () {
        AlippeAudio().playReset();
        AlippeAudio().stopSfx();
        AlippeTts().stop();
        _autoPlayTimer?.cancel();
        _transitionTimer?.cancel();
        setState(() {
          _currentIndex = 0;
          _loadQuestion();
        });
      },
      onNext: () {
        AlippeAudio().stopSfx();
        AlippeTts().stop();
        AlippeGameFinishDialog.goToNextSection(context, 15);
      },
      onHome: () {
        AlippeAudio().stopSfx();
        AlippeTts().stop();
        AlippeGameFinishDialog.navigateToAlippeHome(context);
      },
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
                      AlippeAudio().stopSfx();
                      AlippeTts().stop();
                      _fullWordTimer?.cancel();
                      _autoPlayTimer?.cancel();
                      _transitionTimer?.cancel();
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
                    onPress: () {
                      AlippeAudio().stopSfx();
                      AlippeTts().stop();
                      _fullWordTimer?.cancel();
                      _autoPlayTimer?.cancel();
                      _transitionTimer?.cancel();
                      Navigator.of(context).pop();
                    },
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                        ],
                      ),
                      child: const Text(
                        'Сөздүн уландысын тап!',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFC2185B),
                        ),
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
                                child: GestureDetector(
                                  onTap: _playFirstPartPrompt,
                                  child: Image.asset(current.image, fit: BoxFit.contain),
                                ),
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
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFCE4EC),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: const Color(0xFFE91E63), width: 2),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            current.firstPart,
                                            style: const TextStyle(
                                              fontSize: 32,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFAD1457),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          const Icon(
                                            Icons.volume_up_rounded,
                                            color: Color(0xFFE91E63),
                                            size: 24,
                                          ),
                                        ],
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
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final totalH = constraints.maxHeight;
                            // Dynamically calculate prominent button height and font size
                            final btnH = ((totalH - 48) / 3.4).clamp(66.0, 92.0);
                            final vPad = ((totalH - 48 - (btnH * 3)) / 6).clamp(4.0, 10.0);
                            final fontSize = (btnH * 0.44).clamp(28.0, 38.0);

                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.95),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0xFFF06292), width: 1.5),
                                    boxShadow: const [
                                      BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                                    ],
                                  ),
                                  child: const Text(
                                    'Туура муунду танда:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFAD1457),
                                    ),
                                  ),
                                ),
                                SizedBox(height: vPad + 4),
                                for (final opt in _currentOptions) ...[
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: vPad),
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: btnH,
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
                                            borderRadius: BorderRadius.circular(22),
                                            side: BorderSide(
                                              color: _wrongOptions.contains(opt)
                                                  ? Colors.grey
                                                  : const Color(0xFFE91E63),
                                              width: 3,
                                            ),
                                          ),
                                          elevation: 4,
                                        ),
                                        child: Text(
                                          opt,
                                          style: TextStyle(
                                            fontSize: fontSize,
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
                            );
                          },
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
