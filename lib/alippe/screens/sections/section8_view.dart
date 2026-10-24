import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/alippe_audio.dart';
import '../../core/alippe_constants.dart';
import '../../core/alippe_cubit.dart';
import '../../data/alippe_data.dart';
import '../../widgets/alippe_anim_button.dart';
import '../../widgets/alippe_container.dart';
import '../dialogs/alippe_game_finish_dialog.dart';

class Section8View extends StatefulWidget {
  const Section8View({super.key});

  @override
  State<Section8View> createState() => _Section8ViewState();
}

class _Section8ViewState extends State<Section8View> {
  int _round = 0;
  static const int _itemsPerRound = 3;
  static const int _totalRounds = 9; // 27 items / 3 items per round

  late List<int> _currentPlaceholders;
  late List<int> _currentItems;
  late List<bool> _matched;
  late Set<int> _availableItemIds;

  @override
  void initState() {
    super.initState();
    _setupRound();
  }

  void _setupRound() {
    final start = (_round * _itemsPerRound) % AlippeData.section8Items.length;
    final itemIndices = List.generate(
      _itemsPerRound,
      (i) => (start + i) % AlippeData.section8Items.length,
    );

    // Placeholders are randomly ordered among the 3
    _currentPlaceholders = List<int>.from(itemIndices)..shuffle();

    // Answers are ALWAYS shown in wrong order (no item aligns with its placeholder column)
    // For 3 items, shift by 1 or 2 to produce a complete derangement
    final shift = math.Random().nextBool() ? 1 : 2;
    _currentItems = List.generate(
      _itemsPerRound,
      (i) => _currentPlaceholders[(i + shift) % _itemsPerRound],
    );

    _matched = List.filled(_itemsPerRound, false);
    _availableItemIds = Set<int>.from(itemIndices);
  }

  void _onMatched(int slotIdx, int itemIdx) {
    AlippeAudio().playSuccessPin();

    setState(() {
      _matched[slotIdx] = true;
      _availableItemIds.remove(itemIdx);
    });

    if (!_matched.contains(false)) {
      // All 3 items matched in current round!
      AlippeAudio().playGood();

      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        if (_round < _totalRounds - 1) {
          setState(() {
            _round++;
            _setupRound();
          });
        } else {
          // Section 8 completed!
          context.read<AlippeCubit>().addScore(4, 2);
          AlippeGameFinishDialog.show(
            context: context,
            score: 3,
            onRestart: () {
              AlippeAudio().playReset();
              setState(() {
                _round = 0;
                _setupRound();
              });
            },
            onNext: () {
              Navigator.of(context).pushReplacementNamed('/section', arguments: 9);
            },
            onHome: () {
              AlippeGameFinishDialog.navigateToAlippeHome(context);
            },
          );
        }
      });
    }
  }

  void _onItemTapped(int itemIdx) {
    if (!_availableItemIds.contains(itemIdx)) return;
    for (int i = 0; i < _itemsPerRound; i++) {
      if (!_matched[i] && _currentPlaceholders[i] == itemIdx) {
        _onMatched(i, itemIdx);
        return;
      }
    }
  }

  void _onSlotTapped(int slotIdx) {
    if (_matched[slotIdx]) return;
    final itemIdx = _currentPlaceholders[slotIdx];
    if (_availableItemIds.contains(itemIdx)) {
      _onMatched(slotIdx, itemIdx);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlippeContainer(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sidebar with Restart and Back buttons (matches React Section 8)
          Container(
            width: 100,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Column(
              children: [
                AlippeAnimButton(
                  width: 75,
                  height: 75,
                  scaleFactor: 1.3,
                  imageAsset: AlippeAssets.sideRestart,
                  onPress: () {
                    AlippeAudio().playReset();
                    setState(() {
                      _round = 0;
                      _setupRound();
                    });
                  },
                ),
                const Spacer(),
                AlippeAnimButton(
                  width: 75,
                  height: 75,
                  scaleFactor: 1.3,
                  imageAsset: AlippeAssets.sideBack,
                  onPress: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Main Game Area (Top Row: Silhouettes on BG, Bottom Row: Draggable Items)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 16, 24, 16),
              child: Column(
                children: [
                  // Top Row: 3 Placeholders with frame background
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: List.generate(_itemsPerRound, (slotIdx) {
                        final id = _currentPlaceholders[slotIdx];
                        final isSlotMatched = _matched[slotIdx];

                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: DragTarget<int>(
                              hitTestBehavior: HitTestBehavior.opaque,
                              onWillAcceptWithDetails: (details) =>
                                  !isSlotMatched && details.data == id,
                              onAcceptWithDetails: (details) =>
                                  _onMatched(slotIdx, details.data),
                              builder: (context, candidateData, rejectedData) {
                                final isHovering = candidateData.isNotEmpty;
                                return GestureDetector(
                                  onTap: () => _onSlotTapped(slotIdx),
                                  child: Center(
                                    child: AnimatedScale(
                                      scale: isHovering ? 1.08 : 1.0,
                                      duration: const Duration(milliseconds: 150),
                                      child: AspectRatio(
                                        aspectRatio: 256 / 300,
                                        child: Container(
                                          decoration: isHovering
                                              ? BoxDecoration(
                                                  borderRadius: BorderRadius.circular(20),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.amber.withValues(alpha: 0.6),
                                                      blurRadius: 16,
                                                      spreadRadius: 4,
                                                    ),
                                                  ],
                                                )
                                              : null,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            fit: StackFit.expand,
                                            children: [
                                              // Frame background
                                              Image.asset(
                                                AlippeData.section8Bg,
                                                fit: BoxFit.contain,
                                              ),

                                              // Silhouette image
                                              Padding(
                                                padding: const EdgeInsets.all(20.0),
                                                child: Image.asset(
                                                  AlippeData.section8Placeholders[id],
                                                  fit: BoxFit.contain,
                                                ),
                                              ),

                                              // Color image overlay on match with elastic pop animation
                                              if (isSlotMatched)
                                                TweenAnimationBuilder<double>(
                                                  key: ValueKey('matched_${slotIdx}_$id'),
                                                  tween: Tween<double>(begin: 0.0, end: 1.0),
                                                  duration: const Duration(milliseconds: 350),
                                                  curve: Curves.elasticOut,
                                                  builder: (context, scale, child) {
                                                    return Transform.scale(
                                                      scale: scale,
                                                      child: child,
                                                    );
                                                  },
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(20.0),
                                                    child: Image.asset(
                                                      AlippeData.section8Items[id],
                                                      fit: BoxFit.contain,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Bottom Row: 3 Draggable items
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: List.generate(_itemsPerRound, (itemIdx) {
                        final id = _currentItems[itemIdx];
                        final isAvailable = _availableItemIds.contains(id);

                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: isAvailable
                                ? Center(
                                    child: AspectRatio(
                                      aspectRatio: 256 / 300,
                                      child: Draggable<int>(
                                        data: id,
                                        dragAnchorStrategy: pointerDragAnchorStrategy,
                                        onDragStarted: () => AlippeAudio().playPickUp(),
                                        onDraggableCanceled: (velocity, offset) =>
                                            AlippeAudio().playBackSwoosh(),
                                        feedback: Material(
                                          color: Colors.transparent,
                                          child: Transform.scale(
                                            scale: 1.25,
                                            child: SizedBox(
                                              width: 140,
                                              height: 140,
                                              child: Image.asset(
                                                AlippeData.section8Items[id],
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                        ),
                                        childWhenDragging: const Opacity(
                                          opacity: 0.0,
                                          child: SizedBox.shrink(),
                                        ),
                                        child: AlippeAnimButton(
                                          width: 140,
                                          height: 140,
                                          scaleFactor: 1.2,
                                          noTapSnd: true,
                                          noTimeout: true,
                                          imageAsset: AlippeData.section8Items[id],
                                          onPress: () => _onItemTapped(id),
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        );
                      }),
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
}
