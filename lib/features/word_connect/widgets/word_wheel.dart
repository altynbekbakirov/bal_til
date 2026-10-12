import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/audio/audio_controller.dart';
import '../../../core/theme/app_theme.dart';

class WordWheel extends StatefulWidget {
  final List<String> letters;
  final ValueChanged<String> onWordChanged;
  final VoidCallback onWordCompleted;

  const WordWheel({
    super.key,
    required this.letters,
    required this.onWordChanged,
    required this.onWordCompleted,
  });

  @override
  State<WordWheel> createState() => _WordWheelState();
}

class _WordWheelState extends State<WordWheel> {
  final List<int> _selectedIndices = [];
  Offset? _currentTouch;
  bool _isDragging = false;

  List<Offset> _calculateNodeCenters(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 38;
    final count = widget.letters.length;
    final List<Offset> positions = [];

    for (int i = 0; i < count; i++) {
      final angle = -pi / 2 + (2 * pi * i / count);
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      positions.add(Offset(x, y));
    }
    return positions;
  }

  void _handleTouch(Offset localPos, Size size) {
    final centers = _calculateNodeCenters(size);
    const nodeRadius = 34.0;

    for (int i = 0; i < centers.length; i++) {
      if ((localPos - centers[i]).distance <= nodeRadius) {
        if (!_selectedIndices.contains(i)) {
          HapticFeedback.lightImpact();
          AudioController.instance.playLetterSelect();
          setState(() {
            _selectedIndices.add(i);
          });
          final word = _selectedIndices.map((idx) => widget.letters[idx]).join();
          widget.onWordChanged(word);
        }
        break;
      }
    }
  }

  void clearSelection() {
    setState(() {
      _selectedIndices.clear();
      _currentTouch = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final centers = _calculateNodeCenters(size);

        return GestureDetector(
          onPanStart: (details) {
            _isDragging = false;
            _selectedIndices.clear();
            _currentTouch = details.localPosition;
            _handleTouch(details.localPosition, size);
          },
          onPanUpdate: (details) {
            _isDragging = true;
            setState(() {
              _currentTouch = details.localPosition;
            });
            _handleTouch(details.localPosition, size);
          },
          onPanEnd: (_) {
            setState(() {
              _currentTouch = null;
            });
            // Auto submit if dragged across 2 or more letters
            if (_selectedIndices.length >= 2) {
                            setState(() {
                _selectedIndices.clear();
              });
              widget.onWordCompleted();
            } else if (!_isDragging && _selectedIndices.isNotEmpty) {
              // Single tap mode: keep selected so user can tap next letters
            } else {
              setState(() {
                _selectedIndices.clear();
              });
            }
          },
          child: CustomPaint(
            size: size,
            painter: _WordWheelPainter(
              centers: centers,
              selectedIndices: List.from(_selectedIndices),
              currentTouch: _currentTouch,
              letters: widget.letters,
            ),
          ),
        );
      },
    );
  }
}

class _WordWheelPainter extends CustomPainter {
  final List<Offset> centers;
  final List<int> selectedIndices;
  final Offset? currentTouch;
  final List<String> letters;

  _WordWheelPainter({
    required this.centers,
    required this.selectedIndices,
    required this.currentTouch,
    required this.letters,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final wheelRadius = min(size.width, size.height) / 2;

    // Outer glow / border
    final platePaint = Paint()
      ..color = const Color(0xFFF8FAFC)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, wheelRadius - 6, platePaint);

    final plateBorderPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawCircle(center, wheelRadius - 6, plateBorderPaint);

    // Connecting lines
    final linePaint = Paint()
      ..color = AppTheme.primaryAmber
      ..strokeWidth = 14.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (int i = 0; i < selectedIndices.length - 1; i++) {
      final start = centers[selectedIndices[i]];
      final end = centers[selectedIndices[i + 1]];
      canvas.drawLine(start, end, linePaint);
    }

    if (selectedIndices.isNotEmpty && currentTouch != null) {
      final last = centers[selectedIndices.last];
      canvas.drawLine(last, currentTouch!, linePaint);
    }

    // Letter nodes
    const nodeRadius = 32.0;
    final defaultNodePaint = Paint()..color = Colors.white;
    final selectedNodePaint = Paint()..color = AppTheme.primaryAmber;
    final nodeShadowPaint = Paint()
      ..color = Colors.black12
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    for (int i = 0; i < centers.length; i++) {
      final pos = centers[i];
      final isSelected = selectedIndices.contains(i);

      // Shadow
      canvas.drawCircle(pos + const Offset(0, 3), nodeRadius, nodeShadowPaint);
      // Circle
      canvas.drawCircle(pos, nodeRadius, isSelected ? selectedNodePaint : defaultNodePaint);

      // Border
      final borderPaint = Paint()
        ..color = isSelected ? AppTheme.primaryDarkAmber : const Color(0xFFCBD5E1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawCircle(pos, nodeRadius, borderPaint);

      // Letter text
      final textPainter = TextPainter(
        text: TextSpan(
          text: letters[i].toUpperCase(),
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        pos - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WordWheelPainter oldDelegate) => true;
}

