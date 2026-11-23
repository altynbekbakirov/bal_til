import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/alippe_audio.dart';
import '../../core/alippe_constants.dart';
import '../../core/alippe_cubit.dart';
import '../../data/sound_quiz_data.dart';
import '../../widgets/alippe_anim_button.dart';
import '../../widgets/alippe_container.dart';
import '../dialogs/alippe_game_finish_dialog.dart';

class Section11View extends StatefulWidget {
  const Section11View({super.key});

  @override
  State<Section11View> createState() => _Section11ViewState();
}

class _Section11ViewState extends State<Section11View> with SingleTickerProviderStateMixin {
  late final List<SoundQuizQuestion> _questions;
  int _currentIndex = 0;
  late List<SoundQuizOption> _currentOptions;
  final Set<int> _failedOptionIndices = {};
  int? _correctOptionIndex;
  bool _isAnsweredCorrectly = false;
  bool _isProcessing = false;
  int _firstTryCorrectCount = 0;
  Timer? _autoPlayTimer;
  Timer? _transitionTimer;

  late final AnimationController _speakerAnimController;
  late final Animation<double> _speakerScaleAnimation;

  @override
  void initState() {
    super.initState();
    // Copy and preserve questions list
    _questions = List.from(SoundQuizData.questions);

    _speakerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _speakerScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _speakerAnimController,
      curve: Curves.easeInOut,
    ));

    _loadQuestion();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _transitionTimer?.cancel();
    _speakerAnimController.dispose();
    super.dispose();
  }

  void _loadQuestion() {
    _autoPlayTimer?.cancel();
    _transitionTimer?.cancel();
    _failedOptionIndices.clear();
    _correctOptionIndex = null;
    _isAnsweredCorrectly = false;
    _isProcessing = false;

    final q = _questions[_currentIndex];
    final shuffled = List<SoundQuizOption>.from(q.options)..shuffle(math.Random());
    _currentOptions = shuffled;

    // Automatically play target sound after short delay
    _autoPlayTimer = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      _playTargetSound();
    });
  }

  void _playTargetSound() {
    if (!mounted) return;
    _speakerAnimController.forward(from: 0.0);
    final isBoy = context.read<AlippeCubit>().state.boyActive;
    final sound = _questions[_currentIndex].getSound(isBoy);
    AlippeAudio().playSfx(sound);
  }

  void _onOptionTap(int index) {
    if (_isProcessing || _isAnsweredCorrectly || _failedOptionIndices.contains(index)) {
      return;
    }

    final option = _currentOptions[index];

    if (option.isCorrect) {
      // Correct answer! (Sound removed for speech training)
      setState(() {
        _isAnsweredCorrectly = true;
        _correctOptionIndex = index;
        if (_failedOptionIndices.isEmpty) {
          _firstTryCorrectCount++;
        }
      });

      _isProcessing = true;
      _transitionTimer?.cancel();
      _transitionTimer = Timer(const Duration(milliseconds: 900), () {
        if (!mounted) return;

        if (_currentIndex < _questions.length - 1) {
          setState(() {
            _currentIndex++;
            _loadQuestion();
          });
        } else {
          // Completed all 15 questions!
          _finishGame();
        }
      });
    } else {
      // Incorrect answer
      AlippeAudio().playFail();
      setState(() {
        _failedOptionIndices.add(index);
      });
    }
  }

  void _finishGame() {
    final cubit = context.read<AlippeCubit>();
    cubit.completeSection(11);
    cubit.addScore(6, 3);

    AlippeGameFinishDialog.show(
      context: context,
      score: 3,
      onRestart: () {
        AlippeAudio().playReset();
        setState(() {
          _currentIndex = 0;
          _firstTryCorrectCount = 0;
          _loadQuestion();
        });
      },
      onNext: () {
        AlippeGameFinishDialog.navigateToAlippeHome(context);
      },
      onHome: () {
        AlippeGameFinishDialog.navigateToAlippeHome(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQ = _questions[_currentIndex];

    return AlippeContainer(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sidebar with Restart and Back buttons
          Container(
            width: 100,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Column(
              children: [
                AlippeAnimButton(
                  key: const Key('section11_restart_button'),
                  width: 75,
                  height: 75,
                  scaleFactor: 1.3,
                  imageAsset: AlippeAssets.sideRestart,
                  onPress: () {
                    AlippeAudio().playReset();
                    setState(() {
                      _currentIndex = 0;
                      _firstTryCorrectCount = 0;
                      _loadQuestion();
                    });
                  },
                ),
                const Spacer(),
                AlippeAnimButton(
                  key: const Key('section11_back_button'),
                  width: 75,
                  height: 75,
                  scaleFactor: 1.3,
                  imageAsset: AlippeAssets.sideBack,
                  onPress: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Main Game Area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 10),
              child: Column(
                children: [
                  // Top Header Row (Progress Badge + Star Counter)
                  _buildHeader(currentQ),

                  const SizedBox(height: 8),

                  // Big Listen / Speaker Button placed prominently under the header
                  _buildListenButton(),

                  const SizedBox(height: 8),

                  // 4 Picture Option Cards Row (decreased height to 230px, centered)
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final cardHeight = math.min(230.0, constraints.maxHeight);
                        return Center(
                          child: SizedBox(
                            height: cardHeight,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  for (int i = 0; i < _currentOptions.length; i++)
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 5),
                                        child: _buildOptionCard(i),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(SoundQuizQuestion question) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24, width: 1.5),
      ),
      child: Row(
        children: [
          // Question Progress Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              'Суроо ${_currentIndex + 1} / ${_questions.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(color: Colors.black38, blurRadius: 2, offset: Offset(0, 1)),
                ],
              ),
            ),
          ),

          const Spacer(),

          // Star count / score pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.6), width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: Colors.amberAccent,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  '$_firstTryCorrectCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListenButton() {
    return Center(
      child: ScaleTransition(
        scale: _speakerScaleAnimation,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            key: const Key('section11_listen_button'),
            customBorder: const CircleBorder(),
            onTap: _playTargetSound,
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                border: Border.all(color: Colors.white, width: 3.8),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x40000000),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Color(0x334CAF50),
                    blurRadius: 14,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.volume_up_rounded,
                  color: Colors.white,
                  size: 54,
                  shadows: [
                    Shadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(int index) {
    final option = _currentOptions[index];
    final isCorrect = _correctOptionIndex == index;
    final isFailed = _failedOptionIndices.contains(index);

    Color borderColor = Colors.white;
    Color bgColor = Colors.white.withValues(alpha: 0.95);
    Widget? overlayIcon;

    if (isCorrect) {
      borderColor = const Color(0xFF4CAF50);
      bgColor = const Color(0xFFE8F5E9);
      overlayIcon = Container(
        padding: const EdgeInsets.all(3),
        decoration: const BoxDecoration(
          color: Color(0xFF4CAF50),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_rounded,
          color: Colors.white,
          size: 22,
        ),
      );
    } else if (isFailed) {
      borderColor = const Color(0xFFE53935);
      bgColor = const Color(0xFFFFEBEE);
      overlayIcon = Container(
        padding: const EdgeInsets.all(3),
        decoration: const BoxDecoration(
          color: Color(0xFFE53935),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.close_rounded,
          color: Colors.white,
          size: 22,
        ),
      );
    }

    return GestureDetector(
      key: Key('section11_option_$index'),
      onTap: () => _onOptionTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: isCorrect ? 3.5 : (isFailed ? 3.0 : 2.5)),
          boxShadow: [
            BoxShadow(
              color: isCorrect
                  ? const Color(0x554CAF50)
                  : (isFailed ? const Color(0x35E53935) : const Color(0x28000000)),
              blurRadius: isCorrect ? 10 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
              child: Column(
                children: [
                  // Picture
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Image.asset(
                        option.image,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Word label (large, bold font size)
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      color: isCorrect
                          ? const Color(0xFF2E7D32)
                          : (isFailed ? const Color(0xFFC62828) : const Color(0xFF37474F)),
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        option.word,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
              ),
            ),

            // Correct/Incorrect overlay badge
            if (overlayIcon != null)
              Positioned(
                top: 8,
                right: 8,
                child: overlayIcon,
              ),
          ],
        ),
      ),
    );
  }
}
