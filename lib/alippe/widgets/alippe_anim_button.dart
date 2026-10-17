import 'package:flutter/material.dart';
import '../core/alippe_audio.dart';

class AlippeAnimButton extends StatefulWidget {
  final VoidCallback? onPress;
  final String? imageAsset;
  final Widget? child;
  final double scaleFactor;
  final double? width;
  final double? height;

  const AlippeAnimButton({
    super.key,
    this.onPress,
    this.imageAsset,
    this.child,
    this.scaleFactor = 1.15,
    this.width,
    this.height,
  });

  @override
  State<AlippeAnimButton> createState() => _AlippeAnimButtonState();
}

class _AlippeAnimButtonState extends State<AlippeAnimButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scaleFactor).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPress != null) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPress != null) {
      _controller.reverse();
      AlippeAudio().playTap();
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          widget.onPress?.call();
        }
      });
    }
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: widget.child ??
              (widget.imageAsset != null
                  ? Image.asset(widget.imageAsset!, fit: BoxFit.contain)
                  : const SizedBox.shrink()),
        ),
      ),
    );
  }
}
