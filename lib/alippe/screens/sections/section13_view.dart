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

class Section13View extends StatefulWidget {
  const Section13View({super.key});

  @override
  State<Section13View> createState() => _Section13ViewState();
}

class _Section13ViewState extends State<Section13View> with SingleTickerProviderStateMixin {
  late final List<SoundItem> _items;
  int _currentIndex = 0;
  bool _hasRepeated = false;
  Timer? _autoPlayTimer;
  Timer? _transitionTimer;
  Timer? _speechTimer;

  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _items = List.from(SpeechDevelopmentData.stage2Sounds);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    ));

    _autoPlayTimer = Timer(const Duration(milliseconds: 400), () {
      if (mounted) _playSound();
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _transitionTimer?.cancel();
    _speechTimer?.cancel();
    AlippeAudio().stopSfx();
    AlippeTts().stop();
    _animController.dispose();
    super.dispose();
  }

  void _playSound() {
    if (!mounted) return;
    _animController.forward(from: 0.0);
    final current = _items[_currentIndex];
    final isBoy = context.read<AlippeCubit>().state.boyActive;
    final soundAsset = current.getSound(isBoy);
    AlippeAudio().stopSfx();
    AlippeTts().stop();
    AlippeAudio().playSfx(soundAsset);
    // After the spoken word, play the real animal/object sound when we have a
    // recording; otherwise fall back to speaking the sound text via TTS.
    final effect = current.effectSound;
    _speechTimer?.cancel();
    if (effect != null) {
      _speechTimer = Timer(const Duration(milliseconds: 1100), () {
        if (mounted) AlippeAudio().playSfx(effect);
      });
    } else {
      _speechTimer = Timer(const Duration(milliseconds: 650), () {
        if (mounted) AlippeTts().speak(current.soundText);
      });
    }
  }

  void _onRepeatTap() {
    if (_hasRepeated) return;

    _speechTimer?.cancel();
    AlippeAudio().stopSfx();
    AlippeTts().stop();
    // Play good sound on successful repetition consistent with games 1-6
    AlippeAudio().playGood();

    setState(() {
      _hasRepeated = true;
    });

    _transitionTimer?.cancel();
    // Pause before advancing to next round so sounds do not overlap
    _transitionTimer = Timer(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      if (_currentIndex < _items.length - 1) {
        setState(() {
          _currentIndex++;
          _hasRepeated = false;
        });
        _autoPlayTimer?.cancel();
        _autoPlayTimer = Timer(const Duration(milliseconds: 400), () {
          if (mounted) _playSound();
        });
      } else {
        _finishGame();
      }
    });
  }

  void _finishGame() {
    AlippeAudio().stopSfx();
    AlippeTts().stop();
    final cubit = context.read<AlippeCubit>();
    cubit.completeSection(13);
    cubit.addScore(7, 3);

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
          _hasRepeated = false;
        });
        _playSound();
      },
      onNext: () {
        AlippeAudio().stopSfx();
        AlippeTts().stop();
        AlippeGameFinishDialog.goToNextSection(context, 13);
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
                    key: const Key('section13_restart_button'),
                    width: 75,
                    height: 75,
                    scaleFactor: 1.3,
                    imageAsset: AlippeAssets.sideRestart,
                    onPress: () {
                      AlippeAudio().playReset();
                      AlippeAudio().stopSfx();
                      AlippeTts().stop();
                      _speechTimer?.cancel();
                      _autoPlayTimer?.cancel();
                      _transitionTimer?.cancel();
                      setState(() {
                        _currentIndex = 0;
                        _hasRepeated = false;
                      });
                      _playSound();
                    },
                  ),
                  const Spacer(),
                  AlippeAnimButton(
                    key: const Key('section13_back_button'),
                    width: 75,
                    height: 75,
                    scaleFactor: 1.3,
                    imageAsset: AlippeAssets.sideBack,
                    onPress: () {
                      AlippeAudio().stopSfx();
                      AlippeTts().stop();
                      _speechTimer?.cancel();
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
                // Header progress & instruction
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
                        'Үн чыгаруу: ${_currentIndex + 1}/${_items.length}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE65100),
                        ),
                      ),
                    ),
                    Text(
                      current.description,
                      style: const TextStyle(
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

                // Main Interactive Sound Card
                Expanded(
                  child: Row(
                    children: [
                      // Left: Picture & Sound bubble
                      Expanded(
                        flex: 5,
                        child: GestureDetector(
                          onTap: _playSound,
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: Container(
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: const Color(0xFFFFB74D), width: 3),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Image.asset(
                                      current.image,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  Positioned(
                                    top: 12,
                                    right: 12,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFF9800),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.volume_up_rounded,
                                        color: Colors.white,
                                        size: 26,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF3E0),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: const Color(0xFFFF9800)),
                                      ),
                                      child: Text(
                                        current.title,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFE65100),
                                        ),
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

                      // Right: Big Sound Prompt & Repeat Button
                      Expanded(
                        flex: 6,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Big speech balloon
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.amber.shade400, width: 3),
                                boxShadow: const [
                                  BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
                                ],
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    'Үндү кайтала:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF5D4037),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    current.soundText,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 34,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFE65100),
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Action buttons: "Угуу" and "Кайталадым!"
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    key: const Key('listen_again_button'),
                                    onPressed: () {
                                      AlippeAudio().playTap();
                                      _playSound();
                                    },
                                    icon: const Icon(Icons.replay_rounded, size: 24),
                                    label: const Text(
                                      'Дагы угуу',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0288D1),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 2,
                                  child: ElevatedButton.icon(
                                    key: const Key('repeat_done_button'),
                                    onPressed: _onRepeatTap,
                                    icon: const Icon(Icons.check_circle_rounded, size: 26),
                                    label: Text(
                                      _hasRepeated ? 'Азамат! 👍' : 'Кайталадым! 🗣️',
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _hasRepeated
                                          ? const Color(0xFF4CAF50)
                                          : const Color(0xFFFF9800),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 4,
                                    ),
                                  ),
                                ),
                              ],
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
}
