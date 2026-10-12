import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class WordMatrix extends StatelessWidget {
  final List<String> targetWords;
  final Set<String> solvedWords;

  const WordMatrix({
    super.key,
    required this.targetWords,
    required this.solvedWords,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: targetWords.map((word) {
        final isSolved = solvedWords.contains(word);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
              return Container(
                width: 24,
                alignment: Alignment.center,
                child: Text(
                  isSolved ? word[idx].toUpperCase() : '•',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isSolved ? Colors.white : const Color(0xFF94A3B8),
                  ),
                ),
              );
            }),
          ),
        );
      }).toList(),
    );
  }
}

