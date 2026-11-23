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

    _autoPlayTimer = Timer(const Duration(milliseconds: 350), () {
      if (mounted) _playSyllable();
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _transitionTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _playSyllable() {
    if (!mounted) return;
    _pulseController.forward(from: 0.0);
    final current = _items[_currentIndex];
    final isBoy = context.read<AlippeCubit>().state.boyActive;
    final soundAsset = current.getSound(isBoy);
    AlippeAudio().playSfx(soundAsset);
    AlippeTts().speak(current.syllable);
  }

  void _onTapRepeat() {
    setState(() {
      _repeatCount++;
    });
    _playSyllable();

    if (_repeatCount >= 2) {
      _transitionTimer?.cancel();
      _transitionTimer = Timer(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        if (_currentIndex < _items.length - 1) {
          setState(() {
            _currentIndex++;
            _repeatCount = 0;
          });
          _playSyllable();
        } else {
          _finishGame();
        }
      });
    }
  }

  void _finishGame() {
    final cubit = context.read<AlippeCubit>();
    cubit.completeSection(14);
    cubit.addScore(8, 3);

    AlippeGameFinishDialog.show(
      context: context,
      score: 3,
      onRestart: () {
        AlippeAudio().playReset();
        setState(() {
          _currentIndex = 0;
          _repeatCount = 0;
        });
        _playSyllable();
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
                    key: const Key('section14_restart_button'),
                    width: 75,
                    height: 75,
                    scaleFactor: 1.3,
                    imageAsset: AlippeAssets.sideRestart,
                    onPress: () {
                      AlippeAudio().playReset();
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
                        'Муун кайталоо: ${_currentIndex + 1}/${_items.length}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                    ),
                    const Text(
                      'Муунду угуп, эки жолу кайтала!',
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

                // Main Syllable Board
                Expanded(
                  child: Row(
                    children: [
                      // Syllable Card
                      Expanded(
                        flex: 6,
                        child: GestureDetector(
                          onTap: _onTapRepeat,
                          child: ScaleTransition(
                            scale: _pulseAnimation,
                            child: Container(
                              margin: const EdgeInsets.all(8),
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
                                      fontSize: 72,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF0D47A1),
                                      letterSpacing: 2.0,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: const Color(0xFF64B5F6)),
                                    ),
                                    child: Text(
                                      'Мисалы: ${current.wordExample}',
                                      style: const TextStyle(
                                        fontSize: 18,
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

                      // Example illustration & Repeat Counter
                      Expanded(
                        flex: 5,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 120,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFF90CAF9)),
                                boxShadow: const [
                                  BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                                ],
                              ),
                              child: Image.asset(current.image, fit: BoxFit.contain),
                            ),
                            const SizedBox(height: 16),

                            // Repeat progress bubbles
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildBubble(isDone: _repeatCount >= 1, label: '1'),
                                const SizedBox(width: 16),
                                _buildBubble(isDone: _repeatCount >= 2, label: '2'),
                              ],
                            ),
                            const SizedBox(height: 16),

                            ElevatedButton.icon(
                              key: const Key('syllable_repeat_button'),
                              onPressed: _onTapRepeat,
                              icon: const Icon(Icons.mic_rounded, size: 28),
                              label: Text(
                                _repeatCount == 0 ? 'Кайталап айт!' : 'Дагы бир жолу!',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1976D2),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 4,
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
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isDone ? const Color(0xFF4CAF50) : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: isDone ? const Color(0xFF2E7D32) : const Color(0xFF90CAF9),
          width: 2.5,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      alignment: Alignment.center,
      child: isDone
          ? const Icon(Icons.check_rounded, color: Colors.white, size: 26)
          : Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976D2),
              ),
            ),
    );
  }
}
