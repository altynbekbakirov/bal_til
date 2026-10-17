import 'package:flutter/material.dart';
import '../core/alippe_audio.dart';
import '../core/alippe_tts.dart';

class AlippeAnimButton extends StatefulWidget {
  final VoidCallback? onPress;
  final String? imageAsset;
  final Widget? child;
  final double scaleFactor;
  final double? width;
  final double? height;
  final String? spokenText;
  final String? soundAsset;

  const AlippeAnimButton({
    super.key,
    this.onPress,
    this.imageAsset,
    this.child,
    this.scaleFactor = 1.5,
    this.width,
    this.height,
    this.spokenText,
    this.soundAsset,
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
      duration: const Duration(milliseconds: 160),
      reverseDuration: const Duration(milliseconds: 220),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scaleFactor).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeOutQuad,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _hasTriggeredTap = false;

  void _playSoundAndAction() {
    if (_hasTriggeredTap) return;
    _hasTriggeredTap = true;

    if (widget.soundAsset != null && widget.soundAsset!.isNotEmpty) {
      AlippeAudio().playSfx(widget.soundAsset!).catchError((_) {
        AlippeAudio().playTap();
        if (widget.spokenText != null && widget.spokenText!.isNotEmpty) {
          AlippeTts().speak(widget.spokenText!);
        }
      });
    } else {
      AlippeAudio().playTap();
      if (widget.spokenText != null && widget.spokenText!.isNotEmpty) {
        AlippeTts().speak(widget.spokenText!);
      }
    }

    final remainingMs = ((1.0 - _controller.value) * 160).round();
    Future.delayed(Duration(milliseconds: remainingMs + 80), () {
      if (mounted) {
        _controller.reverse();
      }
    });

    if (widget.onPress != null) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          widget.onPress?.call();
        }
      });
    }
  }

  void _handleTapDown(TapDownDetails details) {
    _hasTriggeredTap = false;
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _playSoundAndAction();
  }

  void _handleTap() {
    _playSoundAndAction();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTap: _handleTap,
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
