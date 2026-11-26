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

class Section14View extends StatefulWidget {
  const Section14View({super.key});

  @override
  State<Section14View> createState() => _Section14ViewState();
}

class _Section14ViewState extends State<Section14View> with SingleTickerProviderStateMixin {
  late final List<SyllableItem> _items;
  int _currentIndex = 0;
  int _repeatCount = 0;
  Timer? _autoPlayTimer;
  Timer? _transitionTimer;
  Timer? _speechTimer;
  Timer? _bellTimer;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _items = List.from(SpeechDevelopmentData.stage3Syllables);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.12), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.12, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _autoPlayTimer = Timer(const Duration(milliseconds: 400), () {
      if (mounted) _playSyllable();
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _transitionTimer?.cancel();
    _speechTimer?.cancel();
    _bellTimer?.cancel();
    AlippeAudio().stopSfx();
    AlippeTts().stop();
    _pulseController.dispose();
    super.dispose();
  }

  void _playSyllable() {
    if (!mounted) return;
    _pulseController.forward(from: 0.0);
    final current = _items[_currentIndex];
    final isBoy = context.read<AlippeCubit>().state.boyActive;
    final soundAsset = current.getSound(isBoy);
    AlippeAudio().stopSfx();
    AlippeTts().stop();
    _speechTimer?.cancel();
    // Play human syllable recording directly without robotic TTS
    AlippeAudio().playSfx(soundAsset);
  }

  void _onTapRepeat() {
    if (_repeatCount >= 2) return;

    final newCount = _repeatCount + 1;
    setState(() {
      _repeatCount = newCount;
    });

    if (newCount == 1) {
      AlippeAudio().stopSfx();
      AlippeTts().stop();
      // First repetition plays bell sound consistent with games 1-6 intermediate progress
      AlippeAudio().playBell();
      _bellTimer?.cancel();
      _bellTimer = Timer(const Duration(milliseconds: 500), () {
        if (mounted) _playSyllable();
      });
    } else if (newCount >= 2) {
      // Completed repetition for this syllable!
      _bellTimer?.cancel();
      _speechTimer?.cancel();
      AlippeAudio().stopSfx();
      AlippeTts().stop();
      // Play good sound on completion consistent with games 1-6
      AlippeAudio().playGood();

      _transitionTimer?.cancel();
      // Time pause before proceeding to next round so sounds do not overlap
      _transitionTimer = Timer(const Duration(milliseconds: 1800), () {
        if (!mounted) return;
        if (_currentIndex < _items.length - 1) {
          setState(() {
            _currentIndex++;
            _repeatCount = 0;
          });
          _autoPlayTimer?.cancel();
          _autoPlayTimer = Timer(const Duration(milliseconds: 400), () {
            if (mounted) _playSyllable();
          });
        } else {
          _finishGame();
        }
      });
    }
  }

  void _finishGame() {
    AlippeAudio().stopSfx();
    AlippeTts().stop();
    final cubit = context.read<AlippeCubit>();
    cubit.completeSection(14);
    cubit.addScore(8, 3);

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
          _repeatCount = 0;
        });
        _playSyllable();
      },
      onNext: () {
        AlippeAudio().stopSfx();
        AlippeTts().stop();
        AlippeGameFinishDialog.goToNextSection(context, 14);
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
                    key: const Key('section14_restart_button'),
                    width: 75,
                    height: 75,
                    scaleFactor: 1.3,
                    imageAsset: AlippeAssets.sideRestart,
                    onPress: () {
                      AlippeAudio().playReset();
                      AlippeAudio().stopSfx();
                      AlippeTts().stop();
                      _speechTimer?.cancel();
                      _bellTimer?.cancel();
                      _autoPlayTimer?.cancel();
                      _transitionTimer?.cancel();
                      setState(() {
                        _currentIndex = 0;
                        _repeatCount = 0;
                      });
                      _playSyllable();
                    },
                  ),
                  const Spacer(),
                  AlippeAnimButton(
                    key: const Key('section14_back_button'),
                    width: 75,
                    height: 75,
                    scaleFactor: 1.3,
                    imageAsset: AlippeAssets.sideBack,
                    onPress: () {
                      AlippeAudio().stopSfx();
                      AlippeTts().stop();
                      _speechTimer?.cancel();
                      _bellTimer?.cancel();
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
                        'Муун кайталоо: ${_currentIndex + 1}/${_items.length}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1565C0),
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
                        'Муунду угуп, эки жолу кайтала!',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Main Syllable Board
                Expanded(
                  child: Row(
                    children: [
                      // Syllable Card
                      Expanded(
                        flex: 5,
                        child: GestureDetector(
                          onTap: _onTapRepeat,
                          child: ScaleTransition(
                            scale: _pulseAnimation,
                            child: Container(
                              margin: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(color: const Color(0xFF2196F3), width: 3),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    current.syllable,
                                    style: const TextStyle(
                                      fontSize: 76,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF0D47A1),
                                      letterSpacing: 2.0,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: const Color(0xFF64B5F6), width: 1.5),
                                    ),
                                    child: Text(
                                      'Мисалы: ${current.wordExample}',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1976D2),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Example illustration & Repeat Counter (Enlarged widgets)
                      Expanded(
                        flex: 5,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Enlarged illustration container
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: const Color(0xFF90CAF9), width: 3),
                                  boxShadow: const [
                                    BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
                                  ],
                                ),
                                child: Image.asset(current.image, fit: BoxFit.contain),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Enlarged repeat progress bubbles
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildBubble(isDone: _repeatCount >= 1, label: '1'),
                                const SizedBox(width: 24),
                                _buildBubble(isDone: _repeatCount >= 2, label: '2'),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Enlarged repeat action button
                            SizedBox(
                              width: double.infinity,
                              height: 60,
                              child: ElevatedButton.icon(
                                key: const Key('syllable_repeat_button'),
                                onPressed: _onTapRepeat,
                                icon: const Icon(Icons.mic_rounded, size: 32),
                                label: Text(
                                  _repeatCount == 0 ? 'Кайталап айт!' : 'Дагы бир жолу!',
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1976D2),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  elevation: 4,
                                ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildBubble({required bool isDone, required String label}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: isDone ? const Color(0xFF4CAF50) : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: isDone ? const Color(0xFF2E7D32) : const Color(0xFF90CAF9),
          width: 3.5,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      alignment: Alignment.center,
      child: isDone
          ? const Icon(Icons.check_rounded, color: Colors.white, size: 34)
          : Text(
              label,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976D2),
              ),
            ),
    );
  }
}
