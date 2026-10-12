import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class WordMatrix extends StatelessWidget {
  final List<String> targetWords;
  final Set<String> solvedWords;
  final Map<String, Set<int>> hintedLetters;

  const WordMatrix({
    super.key,
    required this.targetWords,
    required this.solvedWords,
    this.hintedLetters = const {},
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Solved counter badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primaryAmber.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Табылды: ${solvedWords.length} / ${targetWords.length}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryDarkAmber,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: targetWords.map((word) {
            final isSolved = solvedWords.contains(word);
            return Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isSolved ? AppTheme.emeraldGreen : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                ],
                border: Border.all(
                  color: isSolved ? AppTheme.emeraldGreen : const Color(0xFFCBD5E1),
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(word.length, (idx) {
                  final isHinted = hintedLetters[word]?.contains(idx) ?? false;
                  String displayLetter = '';
                  Color boxBg;
                  Color boxBorder;
                  Color textColor;

                  if (isSolved) {
                    displayLetter = word[idx].toUpperCase();
                    boxBg = Colors.white.withValues(alpha: 0.2);
                    boxBorder = Colors.transparent;
                    textColor = Colors.white;
                  } else if (isHinted) {
                    displayLetter = word[idx].toUpperCase();
                    boxBg = AppTheme.sunnyYellow.withValues(alpha: 0.3);
                    boxBorder = AppTheme.primaryAmber;
                    textColor = AppTheme.primaryDarkAmber;
                  } else {
                    boxBg = const Color(0xFFF8FAFC);
                    boxBorder = const Color(0xFFE2E8F0);
                    textColor = const Color(0xFF94A3B8);
                  }

                  return Container(
                    width: 32,
                    height: 36,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: boxBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: boxBorder, width: isHinted && !isSolved ? 1.5 : 1),
                    ),
                    child: Text(
                      displayLetter,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  );
                }),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
