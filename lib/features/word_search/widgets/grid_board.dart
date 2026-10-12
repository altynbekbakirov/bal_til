import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/audio/audio_controller.dart';
import '../../../core/theme/app_theme.dart';

class GridBoard extends StatefulWidget {
  final List<List<String>> grid;
  final ValueChanged<String> onWordSelected;

  const GridBoard({
    super.key,
    required this.grid,
    required this.onWordSelected,
  });

  @override
  State<GridBoard> createState() => _GridBoardState();
}

class _GridBoardState extends State<GridBoard> {
  final List<Point<int>> _selectedCells = [];

  void _handleTouch(Offset localPos, Size size) {
    final rows = widget.grid.length;
    final cols = widget.grid[0].length;
    final cellWidth = size.width / cols;
    final cellHeight = size.height / rows;

    final c = (localPos.dx / cellWidth).floor();
    final r = (localPos.dy / cellHeight).floor();

    if (r >= 0 && r < rows && c >= 0 && c < cols) {
      final point = Point(r, c);
      if (!_selectedCells.contains(point)) {
        HapticFeedback.selectionClick();
        AudioController.instance.playLetterSelect();
        setState(() {
          _selectedCells.add(point);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rows = widget.grid.length;
    final cols = widget.grid[0].length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        return GestureDetector(
          onPanStart: (details) {
            _selectedCells.clear();
            _handleTouch(details.localPosition, size);
          },
          onPanUpdate: (details) {
            _handleTouch(details.localPosition, size);
          },
          onPanEnd: (_) {
            final word = _selectedCells.map((p) => widget.grid[p.x][p.y]).join();
            setState(() {
              _selectedCells.clear();
            });
            if (word.isNotEmpty) {
              widget.onWordSelected(word);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
              ],
            ),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rows * cols,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemBuilder: (context, index) {
                final r = index ~/ cols;
                final c = index % cols;
                final letter = widget.grid[r][c];
                final isSelected = _selectedCells.contains(Point(r, c));

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.emeraldGreen : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? AppTheme.emeraldGreen : const Color(0xFFE2E8F0),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    letter.toUpperCase(),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class Point<T> {
  final T x;
  final T y;
  Point(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Point && runtimeType == other.runtimeType && x == other.x && y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}

