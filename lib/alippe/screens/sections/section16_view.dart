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

class Section16View extends StatefulWidget {
  const Section16View({super.key});

  @override
  State<Section16View> createState() => _Section16ViewState();
}

class _Section16ViewState extends State<Section16View> with SingleTickerProviderStateMixin {
  late final List<PhrasePairItem> _items;
  int _currentIndex = 0;
  bool _isWord1Played = false;
  bool _isWord2Played = false;
  bool _isCombined = false;
  Timer? _autoPlayTimer;
  Timer? _transitionTimer;

  late final AnimationController _connectController;
  late final Animation<Offset> _leftSlideAnimation;
  late final Animation<Offset> _rightSlideAnimation;

  @override
  void initState() {
    super.initState();
    _items = List.from(SpeechDevelopmentData.stage5Phrases);
    _connectController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _leftSlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.2, 0),
    ).animate(CurvedAnimation(parent: _connectController, curve: Curves.easeInOut));
    _rightSlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.2, 0),
    ).animate(CurvedAnimation(parent: _connectController, curve: Curves.easeInOut));

    _loadPhrase();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _transitionTimer?.cancel();
    _connectController.dispose();
    super.dispose();
  }

  void _loadPhrase() {
    _autoPlayTimer?.cancel();
    _connectController.reset();
    _isWord1Played = false;
    _isWord2Played = false;
    _isCombined = false;

    _autoPlayTimer = Timer(const Duration(milliseconds: 350), () {
      if (mounted) _playWord(1);
    });
  }

  void _playWord(int wordNum) {
    if (!mounted) return;
    final current = _items[_currentIndex];
    final text = wordNum == 1 ? current.word1 : current.word2;
    AlippeAudio().playTap();
    AlippeTts().speak(text);

    setState(() {
      if (wordNum == 1) _isWord1Played = true;
      if (wordNum == 2) _isWord2Played = true;
    });
  }

  void _combineWords() {
    final current = _items[_currentIndex];
    _connectController.forward();

    setState(() {
      _isCombined = true;
    });

    final isBoy = context.read<AlippeCubit>().state.boyActive;
    final sound = current.getSound(isBoy);
    AlippeAudio().playSfx(sound);
    AlippeTts().speak(current.fullPhrase);

    _transitionTimer?.cancel();
    _transitionTimer = Timer(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      if (_currentIndex < _items.length - 1) {
        setState(() {
          _currentIndex++;
          _loadPhrase();
        });
      } else {
        _finishGame();
      }
    });
  }

  void _finishGame() {
    final cubit = context.read<AlippeCubit>();
    cubit.completeSection(16);
    cubit.addScore(10, 3);

    AlippeGameFinishDialog.show(
      context: context,
      score: 3,
      onRestart: () {
        AlippeAudio().playReset();
        setState(() {
          _currentIndex = 0;
          _loadPhrase();
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
                    key: const Key('section16_restart_button'),
                    width: 75,
                    height: 75,
                    scaleFactor: 1.3,
                    imageAsset: AlippeAssets.sideRestart,
                    onPress: () {
                      AlippeAudio().playReset();
                      setState(() {
                        _currentIndex = 0;
                        _loadPhrase();
                      });
                    },
                  ),
                  const Spacer(),
                  AlippeAnimButton(
                    key: const Key('section16_back_button'),
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
                // Header status
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
                        'Сөз айкашы: ${_currentIndex + 1}/${_items.length}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                    const Text(
                      'Эки сөздү бириктирип сөз айкашын түз!',
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

                // Cards Area
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Left Word Card
                          SlideTransition(
                            position: _leftSlideAnimation,
                            child: GestureDetector(
                              onTap: () => _playWord(1),
                              child: _buildWordCard(
                                word: current.word1,
                                image: current.image1,
                                isPlayed: _isWord1Played,
                                color: const Color(0xFFE8F5E9),
                                borderColor: const Color(0xFF4CAF50),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Plus sign
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                              ],
                            ),
                            child: const Icon(Icons.add_rounded, size: 30, color: Color(0xFF2E7D32)),
                          ),
                          const SizedBox(width: 16),

                          // Right Word Card
                          SlideTransition(
                            position: _rightSlideAnimation,
                            child: GestureDetector(
                              onTap: () => _playWord(2),
                              child: _buildWordCard(
                                word: current.word2,
                                image: current.image2,
                                isPlayed: _isWord2Played,
                                color: const Color(0xFFE0F2F1),
                                borderColor: const Color(0xFF009688),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Full phrase banner or Connect Button
                      if (_isCombined)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF9C4),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFFBC02D), width: 3),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
                            ],
                          ),
                          child: Text(
                            '«${current.fullPhrase}»',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE65100),
                            ),
                          ),
                        )
                      else
                        ElevatedButton.icon(
                          key: const Key('combine_words_button'),
                          onPressed: _combineWords,
                          icon: const Icon(Icons.link_rounded, size: 28),
                          label: const Text(
                            'Бириктир! ✨',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
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
    );
  }

  Widget _buildWordCard({
    required String word,
    required String image,
    required bool isPlayed,
    required Color color,
    required Color borderColor,
  }) {
    return Container(
      width: 160,
      height: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 3),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Image.asset(image, fit: BoxFit.contain),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor.withOpacity(0.6)),
            ),
            child: Text(
              word,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: borderColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
