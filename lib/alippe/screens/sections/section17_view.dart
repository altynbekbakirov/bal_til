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

class Section17View extends StatefulWidget {
  const Section17View({super.key});

  @override
  State<Section17View> createState() => _Section17ViewState();
}

class _Section17ViewState extends State<Section17View> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // --- Mode 1: Sentences ---
  late final List<SentenceItem> _sentenceItems;
  int _sentenceIndex = 0;
  bool _hasRepeatedSentence = false;
  Timer? _autoPlayTimer;
  Timer? _transitionTimer;

  // --- Mode 2: Communication Board (PECS) ---
  final List<PecsCardItem> _selectedCards = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _sentenceItems = List.from(SpeechDevelopmentData.stage6Sentences);

    _tabController.addListener(() {
      setState(() {});
    });

    _autoPlayTimer = Timer(const Duration(milliseconds: 350), () {
      if (mounted && _tabController.index == 0) {
        _playCurrentSentence();
      }
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _transitionTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void _playCurrentSentence() {
    if (!mounted) return;
    final current = _sentenceItems[_sentenceIndex];
    final isBoy = context.read<AlippeCubit>().state.boyActive;
    final sound = current.getSound(isBoy);
    AlippeAudio().playSfx(sound);
    AlippeTts().speak(current.sentence);
  }

  void _onRepeatSentenceTap() {
    AlippeAudio().playGood();
    setState(() {
      _hasRepeatedSentence = true;
    });

    _transitionTimer?.cancel();
    _transitionTimer = Timer(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      if (_sentenceIndex < _sentenceItems.length - 1) {
        AlippeAudio().playNext();
        setState(() {
          _sentenceIndex++;
          _hasRepeatedSentence = false;
        });
        _playCurrentSentence();
      } else {
        _finishGame();
      }
    });
  }

  void _onPecsCardTap(PecsCardItem card) {
    AlippeAudio().playTap();
    AlippeTts().speak(card.speechText);
    setState(() {
      if (_selectedCards.length < 5) {
        _selectedCards.add(card);
      }
    });
  }

  void _playPecsSentence() {
    if (_selectedCards.isEmpty) return;
    AlippeAudio().playGood();
    final fullText = _selectedCards.map((c) => c.speechText).join(' ');
    AlippeTts().speak(fullText);
  }

  void _clearPecs() {
    AlippeAudio().playReset();
    setState(() {
      _selectedCards.clear();
    });
  }

  void _finishGame() {
    final cubit = context.read<AlippeCubit>();
    cubit.completeSection(17);
    cubit.addScore(11, 3);

    AlippeGameFinishDialog.show(
      context: context,
      score: 3,
      onRestart: () {
        AlippeAudio().playReset();
        setState(() {
          _sentenceIndex = 0;
          _hasRepeatedSentence = false;
          _selectedCards.clear();
        });
        _playCurrentSentence();
      },
      onNext: () => AlippeGameFinishDialog.navigateToAlippeHome(context),
      onHome: () => AlippeGameFinishDialog.navigateToAlippeHome(context),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    key: const Key('section17_restart_button'),
                    width: 75,
                    height: 75,
                    scaleFactor: 1.3,
                    imageAsset: AlippeAssets.sideRestart,
                    onPress: () {
                      AlippeAudio().playReset();
                      setState(() {
                        _sentenceIndex = 0;
                        _hasRepeatedSentence = false;
                        _selectedCards.clear();
                      });
                      if (_tabController.index == 0) _playCurrentSentence();
                    },
                  ),
                  const Spacer(),
                  AlippeAnimButton(
                    key: const Key('section17_back_button'),
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
            top: 14,
            bottom: 14,
            child: Column(
              children: [
                // Top Tab Bar
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                    ],
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: const Color(0xFF673AB7),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: const Color(0xFF5E35B1),
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    tabs: const [
                      Tab(text: '1. Жөнөкөй сүйлөмдөр'),
                      Tab(text: '2. Сүрөттүү байланыш тактасы (PECS)'),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Tab Views
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildSentencesView(),
                      _buildPecsBoardView(),
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

  Widget _buildSentencesView() {
    final current = _sentenceItems[_sentenceIndex];

    return Column(
      children: [
        // Status text
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Сүйлөм: ${_sentenceIndex + 1}/${_sentenceItems.length}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF673AB7),
                ),
              ),
            ),
            Text(
              current.situation,
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
        const SizedBox(height: 8),

        // Content
        Expanded(
          child: Row(
            children: [
              // Illustration card
              Expanded(
                flex: 5,
                child: GestureDetector(
                  onTap: _playCurrentSentence,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFF9575CD), width: 3),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
                      ],
                    ),
                    child: Image.asset(current.image, fit: BoxFit.contain),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Speech Bubble & Controls
              Expanded(
                flex: 6,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE7F6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF7E57C2), width: 2.5),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
                        ],
                      ),
                      child: Text(
                        '«${current.sentence}»',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4527A0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            key: const Key('sentence_listen_button'),
                            onPressed: _playCurrentSentence,
                            icon: const Icon(Icons.volume_up_rounded, size: 24),
                            label: const Text(
                              'Угуу',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5E35B1),
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
                            key: const Key('sentence_repeat_button'),
                            onPressed: _onRepeatSentenceTap,
                            icon: const Icon(Icons.check_circle_rounded, size: 26),
                            label: Text(
                              _hasRepeatedSentence ? 'Азамат! 👍' : 'Кайталадым! 🗣️',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _hasRepeatedSentence
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
    );
  }

  Widget _buildPecsBoardView() {
    return Column(
      children: [
        // Top Message Strip (sentence builder)
        Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF673AB7), width: 2),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _selectedCards.isEmpty
                  ? const Text(
                      'Карточкаларды басып, каалооңду айт...',
                      style: TextStyle(fontSize: 15, color: Colors.grey, fontStyle: FontStyle.italic),
                    )
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedCards.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final card = _selectedCards[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDE7F6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF7E57C2)),
                          ),
                          child: Row(
                            children: [
                              Image.asset(card.image, width: 28, height: 28, fit: BoxFit.contain),
                              const SizedBox(width: 6),
                              Text(
                                card.label,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4527A0),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
              ),
              const SizedBox(width: 8),
              // Read Aloud button
              ElevatedButton.icon(
                key: const Key('pecs_speak_button'),
                onPressed: _selectedCards.isNotEmpty ? _playPecsSentence : null,
                icon: const Icon(Icons.volume_up_rounded, size: 22),
                label: const Text('Айт!', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(width: 6),
              // Clear button
              IconButton(
                key: const Key('pecs_clear_button'),
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                tooltip: 'Тазалоо',
                onPressed: _selectedCards.isNotEmpty ? _clearPecs : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Grid of PECS Cards
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              childAspectRatio: 1.25,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: SpeechDevelopmentData.pecsCards.length,
            itemBuilder: (context, index) {
              final card = SpeechDevelopmentData.pecsCards[index];
              return InkWell(
                key: Key('pecs_card_${card.id}'),
                onTap: () => _onPecsCardTap(card),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: card.category == 'need'
                          ? const Color(0xFF42A5F5)
                          : card.category == 'action'
                              ? const Color(0xFF66BB6A)
                              : const Color(0xFFFFA726),
                      width: 2,
                    ),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Image.asset(card.image, fit: BoxFit.contain),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        card.label,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF37474F),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
