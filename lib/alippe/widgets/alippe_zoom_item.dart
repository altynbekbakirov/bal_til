import 'package:flutter/material.dart';
import '../core/alippe_audio.dart';
import '../core/alippe_tts.dart';

class AlippeZoomItem extends StatefulWidget {
  final String imageAsset;
  final String spokenText;
  final VoidCallback? onTap;

  const AlippeZoomItem({
    super.key,
    required this.imageAsset,
    required this.spokenText,
    this.onTap,
  });

  @override
  State<AlippeZoomItem> createState() => _AlippeZoomItemState();
}

class _AlippeZoomItemState extends State<AlippeZoomItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    // Zoom out (scale down) -> Zoom in (pop up larger) -> Settle back to 1.0
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.85)
            .chain(CurveTween(curve: Curves.easeInQuad)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.85, end: 1.25)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.25, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOutQuad)),
        weight: 25,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _trigger() {
    _controller.forward(from: 0.0);
    AlippeAudio().playTap();
    if (widget.spokenText.isNotEmpty) {
      AlippeTts().speak(widget.spokenText);
    }
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _trigger,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Image.asset(
            widget.imageAsset,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
