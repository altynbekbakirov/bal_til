import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/alippe_audio.dart';
import '../../core/alippe_constants.dart';
import '../../core/alippe_cubit.dart';
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
  Timer? _combineTimer;
  Timer? _speechTimer;

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
    _combineTimer?.cancel();
    _speechTimer?.cancel();
    AlippeAudio().stopSfx();
    _connectController.dispose();
    super.dispose();
  }

  void _loadPhrase() {
    _autoPlayTimer?.cancel();
    _transitionTimer?.cancel();
    _combineTimer?.cancel();
    _speechTimer?.cancel();
    _connectController.reset();
    _isWord1Played = false;
    _isWord2Played = false;
    _isCombined = false;

    AlippeAudio().stopSfx();

    _autoPlayTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) _playWord(1);
    });
  }

  void _playWord(int wordNum) {
    if (!mounted) return;
    final current = _items[_currentIndex];
    final isBoy = context.read<AlippeCubit>().state.boyActive;
    final sound = wordNum == 1 ? current.getWord1Sound(isBoy) : current.getWord2Sound(isBoy);
    AlippeAudio().stopSfx();
    AlippeAudio().playSfx(sound);

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

    AlippeAudio().stopSfx();
    _combineTimer?.cancel();
    _speechTimer?.cancel();
    // Play good sound on combining words consistent with games 1-6
    AlippeAudio().playGood();

    // Play full phrase audio after brief jingle pause without sound overlap
    _combineTimer = Timer(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      final isBoy = context.read<AlippeCubit>().state.boyActive;
      final sound = current.getSound(isBoy);
      AlippeAudio().playSfx(sound);
    });

    _transitionTimer?.cancel();
    // Time pause before proceeding to next round so sounds do not overlap
    _transitionTimer = Timer(const Duration(milliseconds: 2600), () {
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
    AlippeAudio().stopSfx();
    final cubit = context.read<AlippeCubit>();
    cubit.completeSection(16);
    cubit.addScore(10, 3);

    AlippeGameFinishDialog.show(
      context: context,
      score: 3,
      onRestart: () {
        AlippeAudio().playReset();
        AlippeAudio().stopSfx();
        _autoPlayTimer?.cancel();
        _transitionTimer?.cancel();
        setState(() {
          _currentIndex = 0;
          _loadPhrase();
        });
      },
      onNext: () {
        AlippeAudio().stopSfx();
        AlippeGameFinishDialog.goToNextSection(context, 16);
      },
      onHome: () {
        AlippeAudio().stopSfx();
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
              width: 100,
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
                      AlippeAudio().stopSfx();
                      _combineTimer?.cancel();
                      _speechTimer?.cancel();
                      _autoPlayTimer?.cancel();
                      _transitionTimer?.cancel();
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
                    onPress: () {
                      AlippeAudio().stopSfx();
                      _combineTimer?.cancel();
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
            left: 105,
            right: 15,
            top: 12,
            bottom: 12,
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
                const SizedBox(height: 8),

                // Cards Area - dynamically enlarged at least twice
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final availW = constraints.maxWidth;
                      final availH = constraints.maxHeight;

                      // Allocate space for two cards, plus sign, gaps and connect button/banner
                      final maxCardW = (availW - 64) / 2;
                      final maxCardH = availH - 78;

                      final cardW = maxCardW.clamp(200.0, 320.0);
                      final cardH = maxCardH.clamp(180.0, 285.0);

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Left Word Card
                              SlideTransition(
                                position: _leftSlideAnimation,
                                child: GestureDetector(
                                  key: const Key('section16_word1_card'),
                                  onTap: () => _playWord(1),
                                  child: _buildWordCard(
                                    width: cardW,
                                    height: cardH,
                                    word: current.word1,
                                    image: current.image1,
                                    isPlayed: _isWord1Played,
                                    color: const Color(0xFFE8F5E9),
                                    borderColor: const Color(0xFF4CAF50),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Plus sign
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.add_rounded,
                                  size: 34,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Right Word Card
                              SlideTransition(
                                position: _rightSlideAnimation,
                                child: GestureDetector(
                                  key: const Key('section16_word2_card'),
                                  onTap: () => _playWord(2),
                                  child: _buildWordCard(
                                    width: cardW,
                                    height: cardH,
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
                          const SizedBox(height: 12),

                          // Full phrase banner or Connect Button
                          if (_isCombined)
                            GestureDetector(
                              key: const Key('section16_phrase_banner'),
                              onTap: () {
                                final isBoy = context.read<AlippeCubit>().state.boyActive;
                                AlippeAudio().stopSfx();
                                AlippeAudio().playSfx(current.getSound(isBoy));
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF9C4),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(color: const Color(0xFFFBC02D), width: 3.5),
                                  boxShadow: const [
                                    BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '«${current.fullPhrase}»',
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFE65100),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Icon(Icons.volume_up_rounded, size: 32, color: Color(0xFFE65100)),
                                  ],
                                ),
                              ),
                            )
                          else
                            ElevatedButton.icon(
                              key: const Key('combine_words_button'),
                              onPressed: _combineWords,
                              icon: const Icon(Icons.link_rounded, size: 30),
                              label: const Text(
                                'Бириктир! ✨',
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E7D32),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 4,
                              ),
                            ),
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
    );
  }

  Widget _buildWordCard({
    required double width,
    required double height,
    required String word,
    required String image,
    required bool isPlayed,
    required Color color,
    required Color borderColor,
  }) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: borderColor, width: 3.5),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isPlayed ? borderColor : Colors.white,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1)),
                ],
              ),
              child: Icon(
                Icons.volume_up_rounded,
                size: 20,
                color: isPlayed ? Colors.white : borderColor,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Image.asset(image, fit: BoxFit.contain),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor.withOpacity(0.7), width: 2),
                  ),
                  child: Text(
                    word,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: borderColor,
                    ),
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
