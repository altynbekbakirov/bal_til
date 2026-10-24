import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/audio/audio_controller.dart';
import '../../../data/repositories/repositories.dart';

enum NatureGameType {
  animals,
  plants,
}

class NatureSpellingItem {
  final String name;
  final String imagePath;
  final String? description;

  const NatureSpellingItem({
    required this.name,
    required this.imagePath,
    this.description,
  });
}

class _DraggableLetterEntry {
  final int id;
  final String char;
  final double rotation;

  const _DraggableLetterEntry({
    required this.id,
    required this.char,
    required this.rotation,
  });
}

class _SpellingSlot {
  final int index;
  final String char;
  final int wordIndex;
  _DraggableLetterEntry? placed;
  bool isHinted;

  _SpellingSlot({
    required this.index,
    required this.char,
    required this.wordIndex,
  }) : isHinted = false;

  bool get isFilled => placed != null;
}

class NatureSpellingScreen extends StatefulWidget {
  final NatureGameType gameType;

  const NatureSpellingScreen({
    super.key,
    required this.gameType,
  });

  @override
  State<NatureSpellingScreen> createState() => _NatureSpellingScreenState();
}

class _NatureSpellingScreenState extends State<NatureSpellingScreen> {
  final NatureRepository _repository = NatureRepository();
  bool _isLoading = true;
  List<NatureSpellingItem> _items = [];
  int _currentIndex = 0;

  static const int maxHintsPerItem = 3;
  int _hintsRemaining = maxHintsPerItem;

  bool get _canUseHint => _hintsRemaining > 0 && !_isWordCompleted;

  late List<List<_SpellingSlot>> _wordSlotRows;
  late List<_SpellingSlot> _flatSlots;
  late List<_DraggableLetterEntry> _availableEntries;
  bool _isWordCompleted = false;
  bool _isWordWrong = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      if (widget.gameType == NatureGameType.animals) {
        final list = await _repository.loadAnimals();
        _items = list
            .map((a) => NatureSpellingItem(name: a.name, imagePath: a.imagePath))
            .toList();
      } else {
        final list = await _repository.loadPlants();
        _items = list
            .map((p) => NatureSpellingItem(
                  name: p.name,
                  imagePath: p.imagePath,
                  description: p.description,
                ))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading nature items: $e');
      _items = [];
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (_items.isNotEmpty) {
          _currentIndex = 0;
          _loadCurrentItem();
        }
      });
    }
  }

  void _loadCurrentItem() {
    if (_items.isEmpty) return;
    final item = _items[_currentIndex];
    final random = math.Random();
    _isWordCompleted = false;
    _isWordWrong = false;
    _hintsRemaining = maxHintsPerItem;

    // Split into uppercase words
    final rawWords = item.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .map((w) => w.toUpperCase())
        .toList();

    int globalSlotIdx = 0;
    _wordSlotRows = [];
    _flatSlots = [];
    final List<_DraggableLetterEntry> entries = [];

    for (int wIdx = 0; wIdx < rawWords.length; wIdx++) {
      final word = rawWords[wIdx];
      final List<_SpellingSlot> row = [];
      for (int cIdx = 0; cIdx < word.length; cIdx++) {
        final char = word[cIdx];
        final slot = _SpellingSlot(
          index: globalSlotIdx,
          char: char,
          wordIndex: wIdx,
        );
        row.add(slot);
        _flatSlots.add(slot);

        final deg = (random.nextDouble() * 20 - 10); // -10deg .. +10deg
        entries.add(_DraggableLetterEntry(
          id: globalSlotIdx,
          char: char,
          rotation: deg * math.pi / 180,
        ));

        globalSlotIdx++;
      }
      _wordSlotRows.add(row);
    }

    // Scramble the available letter entries
    if (entries.length > 1) {
      final targetSpell = _flatSlots.map((s) => s.char).join('');
      String currentSpell(List<_DraggableLetterEntry> list) =>
          list.map((e) => e.char).join('');

      int attempts = 0;
      while (currentSpell(entries) == targetSpell && attempts < 30) {
        entries.shuffle(random);
        attempts++;
      }

      if (currentSpell(entries) == targetSpell) {
        for (int i = 0; i < entries.length - 1; i++) {
          if (entries[i].char != entries[i + 1].char) {
            final temp = entries[i];
            entries[i] = entries[i + 1];
            entries[i + 1] = temp;
            break;
          }
        }
      }
    }

    _availableEntries = entries;
  }

  void _onLetterPlaced(_SpellingSlot slot, _DraggableLetterEntry entry) {
    AudioController.instance.playLetterSelect();

    setState(() {
      slot.placed = entry;
      _availableEntries.removeWhere((e) => e.id == entry.id);
      _isWordWrong = false;
    });

    _checkCompletion();
  }

  void _onLetterTapped(_DraggableLetterEntry entry) {
    // Put into the next empty slot in queue order (left to right)
    for (final slot in _flatSlots) {
      if (!slot.isFilled && !slot.isHinted) {
        _onLetterPlaced(slot, entry);
        return;
      }
    }
  }

  void _resetCurrentWord() {
    AudioController.instance.playButtonClick();
    setState(() {
      for (final slot in _flatSlots) {
        if (slot.placed != null && !slot.isHinted) {
          _availableEntries.add(slot.placed!);
          slot.placed = null;
        }
      }
      _isWordCompleted = false;
      _isWordWrong = false;
    });
  }

  void _onSlotTapped(_SpellingSlot slot) {
    if (slot.isFilled && !slot.isHinted) {
      AudioController.instance.playButtonClick();
      setState(() {
        final entry = slot.placed!;
        slot.placed = null;
        _availableEntries.add(entry);
        _isWordCompleted = false;
        _isWordWrong = false;
      });
    }
  }

  void _useHint() {
    if (!_canUseHint) {
      AudioController.instance.playWrongWord();
      return;
    }

    // 1. Find the first unhinted slot that is empty or has a wrong letter
    _SpellingSlot? targetSlot;
    for (final slot in _flatSlots) {
      if (!slot.isHinted && (slot.placed == null || slot.placed!.char != slot.char)) {
        targetSlot = slot;
        break;
      }
    }

    // If all incorrect slots are hinted, find any unhinted slot
    if (targetSlot == null) {
      for (final slot in _flatSlots) {
        if (!slot.isHinted) {
          targetSlot = slot;
          break;
        }
      }
    }

    if (targetSlot == null) return;

    // If targetSlot already has the correct letter placed by user, lock it as hinted
    if (targetSlot.placed != null && targetSlot.placed!.char == targetSlot.char) {
      setState(() {
        targetSlot!.isHinted = true;
        _hintsRemaining--;
      });
      AudioController.instance.playHint();
      AudioController.instance.playLetterSelect();
      _checkCompletion();
      return;
    }

    // If targetSlot has a wrong letter, release it back to available entries
    _DraggableLetterEntry? wrongEntry;
    if (targetSlot.placed != null) {
      wrongEntry = targetSlot.placed!;
      targetSlot.placed = null;
    }

    // Find the matching letter entry (matching targetSlot.char)
    _DraggableLetterEntry? matchingEntry;
    final availIdx = _availableEntries.indexWhere((e) => e.char == targetSlot!.char);
    if (availIdx != -1) {
      matchingEntry = _availableEntries.removeAt(availIdx);
    } else {
      // Find in other unhinted slots where user placed it wrongly
      for (final otherSlot in _flatSlots) {
        if (otherSlot != targetSlot && !otherSlot.isHinted && otherSlot.placed?.char == targetSlot.char) {
          matchingEntry = otherSlot.placed;
          otherSlot.placed = null;
          break;
        }
      }
    }

    if (wrongEntry != null) {
      _availableEntries.add(wrongEntry);
    }

    matchingEntry ??= _DraggableLetterEntry(
      id: targetSlot.index + 1000,
      char: targetSlot.char,
      rotation: 0,
    );

    setState(() {
      targetSlot!.placed = matchingEntry;
      targetSlot.isHinted = true;
      _hintsRemaining--;
      _isWordWrong = false;
    });

    AudioController.instance.playHint();
    AudioController.instance.playLetterSelect();
    _checkCompletion();
  }

  void _checkCompletion() {
    if (_flatSlots.every((s) => s.isFilled)) {
      final bool allCorrect = _flatSlots.every((s) => s.placed?.char == s.char);
      if (allCorrect) {
        setState(() {
          _isWordCompleted = true;
          _isWordWrong = false;
        });
        AudioController.instance.playWordSolved();

        Future.delayed(const Duration(milliseconds: 950), () {
          if (!mounted) return;
          if (_currentIndex < _items.length - 1) {
            setState(() {
              _currentIndex++;
              _loadCurrentItem();
            });
          } else {
            AudioController.instance.playLevelComplete();
            _showFinishedDialog();
          }
        });
      } else {
        setState(() {
          _isWordWrong = true;
        });
        AudioController.instance.playWrongWord();
      }
    } else {
      if (_isWordWrong) {
        setState(() {
          _isWordWrong = false;
        });
      }
    }
  }

  void _showFinishedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Container(
            width: 360,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x35000000),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEF3C7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    color: Color(0xFFEA580C),
                    size: 56,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Азаматсың!',
                  style: TextStyle(
                    fontFamily: GoogleFonts.nunito().fontFamily,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.gameType == NatureGameType.animals
                      ? 'Бардык жаныбарларды ийгиликтүү таптың!'
                      : 'Бардык өсүмдүктөрдү ийгиликтүү таптың!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: GoogleFonts.nunito().fontFamily,
                    fontSize: 15,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF1F5F9),
                          foregroundColor: const Color(0xFF475569),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Башкы бетке',
                          style: TextStyle(
                            fontFamily: GoogleFonts.nunito().fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEA580C),
                          foregroundColor: Colors.white,
                          elevation: 2,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          setState(() {
                            _currentIndex = 0;
                            _loadCurrentItem();
                          });
                        },
                        child: Text(
                          'Кайра баштоо',
                          style: TextStyle(
                            fontFamily: GoogleFonts.nunito().fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _goToIndex(int newIndex) {
    if (newIndex >= 0 && newIndex < _items.length) {
      AudioController.instance.playButtonClick();
      setState(() {
        _currentIndex = newIndex;
        _loadCurrentItem();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAnimals = widget.gameType == NatureGameType.animals;
    final bgColor = isAnimals ? const Color(0xFFF0FDF4) : const Color(0xFFFEFCE8);
    final themeColor = isAnimals ? const Color(0xFF0284C7) : const Color(0xFF15803D);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: CircularProgressIndicator(color: themeColor),
        ),
      );
    }

    if (_items.isEmpty) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Маалымат табылган жок'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Артка'),
              ),
            ],
          ),
        ),
      );
    }

    final item = _items[_currentIndex];
    final totalLetters = _flatSlots.length;

    // Sizing suited for portrait mode
    final double slotSize = totalLetters <= 4
        ? 62.0
        : (totalLetters <= 6
            ? 52.0
            : (totalLetters <= 8 ? 44.0 : 38.0));
    final double slotFontSize = totalLetters <= 4
        ? 30.0
        : (totalLetters <= 6
            ? 25.0
            : (totalLetters <= 8 ? 21.0 : 18.0));

    final double letterTileSize = totalLetters <= 4
        ? 58.0
        : (totalLetters <= 6
            ? 48.0
            : (totalLetters <= 8 ? 42.0 : 36.0));
    final double letterFontSize = totalLetters <= 4
        ? 28.0
        : (totalLetters <= 6
            ? 23.0
            : (totalLetters <= 8 ? 20.0 : 17.0));

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          isAnimals ? 'Жаныбарлар' : 'Өсүмдүктөр',
          style: TextStyle(
            fontFamily: GoogleFonts.nunito().fontFamily,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B), size: 22),
          onPressed: () {
            AudioController.instance.playButtonClick();
            Navigator.pop(context);
          },
        ),
        actions: [
          _CircleHintButton(
            key: const ValueKey('hint_button_appbar'),
            hintsRemaining: _hintsRemaining,
            isEnabled: _canUseHint,
            onTap: _useHint,
            size: 38,
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFFEA580C), size: 24),
            tooltip: 'Тазалоо',
            onPressed: _resetCurrentWord,
          ),
          IconButton(
            icon: const Icon(Icons.shuffle_rounded, color: Color(0xFFEA580C), size: 24),
            tooltip: 'Аралаштыруу',
            onPressed: () {
              AudioController.instance.playShuffle();
              setState(() {
                _availableEntries.shuffle();
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              // Subtitle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  isAnimals
                      ? 'Кыргызстанда жашаган керемет жаныбарлар менен таанышкыла!'
                      : 'Кыргыз жериндеги дары чөптөр жана тоо өсүмдүктөрү',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: GoogleFonts.nunito().fontFamily,
                    fontSize: 13,
                    color: Colors.blueGrey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Image Card with paperclip design matching screenshot
              Expanded(
                flex: 5,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1.15,
                    child: Stack(
                      alignment: Alignment.center,
                      fit: StackFit.expand,
                      children: [
                        // Card with clip background
                        Image.asset(
                          'assets/alippe/images/books/book1/section2/items/pic_bg.png',
                          fit: BoxFit.contain,
                        ),
                        // Animal or Plant Image
                        Padding(
                          padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
                          child: Image.asset(
                            item.imagePath,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              isAnimals ? Icons.pets_rounded : Icons.eco_rounded,
                              size: 70,
                              color: themeColor,
                            ),
                          ),
                        ),
                        // Solved badge banner overlay
                        if (_isWordCompleted)
                          Positioned(
                            bottom: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x25000000),
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    item.name.toUpperCase(),
                                    style: TextStyle(
                                      fontFamily: GoogleFonts.nunito().fontFamily,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Optional plant description when solved
              if (!isAnimals && item.description != null && item.description!.isNotEmpty)
                AnimatedOpacity(
                  opacity: _isWordCompleted ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    height: _isWordCompleted ? 48 : 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Text(
                        item.description!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: GoogleFonts.nunito().fontFamily,
                          fontSize: 12,
                          color: const Color(0xFF475569),
                          fontWeight: FontWeight.w500,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ),
                ),

              // SPELLING GAME AREA (Matching the screenshot)
              Expanded(
                flex: 5,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFFDE68A),
                      width: 1.5,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Status indicator above result boxes: Right or Wrong on complete
                      SizedBox(
                        height: 28,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: _isWordCompleted
                              ? Container(
                                  key: const ValueKey('status_right'),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDCFCE7),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: const Color(0xFF22C55E), width: 1.5),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 16),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Туура!',
                                        style: TextStyle(
                                          fontFamily: GoogleFonts.nunito().fontFamily,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF15803D),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : _isWordWrong
                                  ? Container(
                                      key: const ValueKey('status_wrong'),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEE2E2),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: const Color(0xFFEF4444), width: 1.5),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.cancel_rounded, color: Color(0xFFDC2626), size: 16),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Туура эмес!',
                                            style: TextStyle(
                                              fontFamily: GoogleFonts.nunito().fontFamily,
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFFB91C1C),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : const SizedBox.shrink(key: ValueKey('status_empty')),
                        ),
                      ),

                      // Target Slots in one row
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (int wIdx = 0; wIdx < _wordSlotRows.length; wIdx++) ...[
                              if (wIdx > 0) const SizedBox(width: 14),
                              ..._wordSlotRows[wIdx].map((slot) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                  child: DragTarget<_DraggableLetterEntry>(
                                    hitTestBehavior: HitTestBehavior.translucent,
                                    onWillAcceptWithDetails: (details) =>
                                        !slot.isFilled && !slot.isHinted,
                                    onAcceptWithDetails: (details) =>
                                        _onLetterPlaced(slot, details.data),
                                    builder: (context, candidateData, rejectedData) {
                                      final isHovering = candidateData.isNotEmpty;

                                      return GestureDetector(
                                        onTap: () => _onSlotTapped(slot),
                                        behavior: HitTestBehavior.translucent,
                                        child: AnimatedScale(
                                          scale: isHovering ? 1.15 : 1.0,
                                          duration: const Duration(milliseconds: 140),
                                          curve: Curves.easeOutBack,
                                          child: SizedBox(
                                            width: slotSize,
                                            height: slotSize,
                                            child: slot.isFilled
                                                ? _buildPlacedLetterTile(
                                                    slot.placed!.char,
                                                    size: slotSize,
                                                    fontSize: slotFontSize,
                                                    isHinted: slot.isHinted,
                                                  )
                                                : _buildSlotPlaceholder(
                                                    size: slotSize,
                                                  ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              }),
                            ],
                          ],
                        ),
                      ),

                      // Scrambled Available Letter Tiles
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: _availableEntries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Transform.rotate(
                                angle: entry.rotation,
                                child: Draggable<_DraggableLetterEntry>(
                                  data: entry,
                                  onDragStarted: () => AudioController.instance.playButtonClick(),
                                  feedback: Material(
                                    color: Colors.transparent,
                                    child: Transform.scale(
                                      scale: 1.25,
                                      child: _buildDraggableLetterTile(
                                        entry.char,
                                        size: letterTileSize,
                                        fontSize: letterFontSize,
                                      ),
                                    ),
                                  ),
                                  childWhenDragging: Opacity(
                                    opacity: 0.15,
                                    child: SizedBox(
                                      width: letterTileSize,
                                      height: letterTileSize,
                                    ),
                                  ),
                                  child: GestureDetector(
                                    onTap: () => _onLetterTapped(entry),
                                    child: _buildDraggableLetterTile(
                                      entry.char,
                                      size: letterTileSize,
                                      fontSize: letterFontSize,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Bottom Navigation & Counter Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, size: 28),
                      color: _currentIndex > 0 ? const Color(0xFFEA580C) : const Color(0xFFCBD5E1),
                      onPressed: _currentIndex > 0 ? () => _goToIndex(_currentIndex - 1) : null,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x10000000),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            '${_currentIndex + 1} / ${_items.length}',
                            style: TextStyle(
                              fontFamily: GoogleFonts.nunito().fontFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF9A3412),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _CircleHintButton(
                          key: const ValueKey('hint_button_bottom'),
                          hintsRemaining: _hintsRemaining,
                          isEnabled: _canUseHint,
                          onTap: _useHint,
                          size: 34,
                        ),
                        const SizedBox(width: 2),
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded, size: 22, color: Color(0xFFEA580C)),
                          tooltip: 'Тазалоо',
                          onPressed: _resetCurrentWord,
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_rounded, size: 28),
                      color: _currentIndex < _items.length - 1
                          ? const Color(0xFFEA580C)
                          : const Color(0xFFCBD5E1),
                      onPressed: _currentIndex < _items.length - 1
                          ? () => _goToIndex(_currentIndex + 1)
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Empty placeholder slot for result boxes (without hint letters)
  Widget _buildSlotPlaceholder({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7).withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFBBF24).withValues(alpha: 0.8),
          width: 2.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
    );
  }

  /// Draggable letter tile matching the bottom row in the screenshot (orange 3D block with outlined letter)
  Widget _buildDraggableLetterTile(String char, {required double size, required double fontSize}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFB923C),
            Color(0xFFEA580C),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white,
          width: 2.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x30000000),
            offset: Offset(0, 3),
            blurRadius: 4,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // White stroke outline
          Text(
            char,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              fontFamily: GoogleFonts.nunito().fontFamily,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 3.0
                ..color = Colors.white,
            ),
          ),
          // Vibrant red/coral letter fill
          Text(
            char,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              fontFamily: GoogleFonts.nunito().fontFamily,
              color: const Color(0xFFDC2626),
            ),
          ),
        ],
      ),
    );
  }

  /// Letter tile placed inside the slot
  Widget _buildPlacedLetterTile(
    String char, {
    required double size,
    required double fontSize,
    bool isHinted = false,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isHinted
              ? const [
                  Color(0xFFFDBA74),
                  Color(0xFFEA580C),
                ]
              : const [
                  Color(0xFFFB923C),
                  Color(0xFFEA580C),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHinted ? const Color(0xFFFDE047) : Colors.white,
          width: isHinted ? 2.5 : 2.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isHinted ? const Color(0x35F59E0B) : const Color(0x20000000),
            offset: const Offset(0, 2),
            blurRadius: isHinted ? 5 : 3,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            char,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              fontFamily: GoogleFonts.nunito().fontFamily,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 3.0
                ..color = Colors.white,
            ),
          ),
          Text(
            char,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              fontFamily: GoogleFonts.nunito().fontFamily,
              color: const Color(0xFFDC2626),
            ),
          ),
          if (isHinted)
            Positioned(
              top: 3,
              right: 3,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Color(0xFFF59E0B),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lightbulb_rounded,
                  size: 9,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CircleHintButton extends StatelessWidget {
  final int hintsRemaining;
  final bool isEnabled;
  final VoidCallback onTap;
  final double size;

  const _CircleHintButton({
    super.key,
    required this.hintsRemaining,
    required this.isEnabled,
    required this.onTap,
    this.size = 38,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Кеңеш (калды: $hintsRemaining)',
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: isEnabled ? Colors.white : const Color(0xFFF1F5F9),
            shape: const CircleBorder(),
            elevation: isEnabled ? 2.5 : 0.5,
            shadowColor: const Color(0x20000000),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: isEnabled ? onTap : null,
              child: SizedBox(
                width: size,
                height: size,
                child: Center(
                  child: Icon(
                    Icons.lightbulb_rounded,
                    color: isEnabled ? const Color(0xFFD97706) : const Color(0xFF94A3B8),
                    size: size * 0.56,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.all(3.5),
              decoration: BoxDecoration(
                color: isEnabled ? const Color(0xFFF59E0B) : const Color(0xFF94A3B8),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Center(
                child: Text(
                  '$hintsRemaining',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9.0,
                    fontWeight: FontWeight.bold,
                    height: 1.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
