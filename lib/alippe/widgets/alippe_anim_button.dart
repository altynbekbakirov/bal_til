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
  final bool noTimeout;
  final bool noTapSnd;

  const AlippeAnimButton({
    super.key,
    this.onPress,
    this.imageAsset,
    this.child,
    this.scaleFactor = 1.45,
    this.width,
    this.height,
    this.spokenText,
    this.soundAsset,
    this.noTimeout = false,
    this.noTapSnd = false,
  });

  @override
  State<AlippeAnimButton> createState() => _AlippeAnimButtonState();
}

class _AlippeAnimButtonState extends State<AlippeAnimButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _hasTriggeredSound = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
      reverseDuration: const Duration(milliseconds: 220),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scaleFactor).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant AlippeAnimButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scaleFactor != widget.scaleFactor) {
      _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scaleFactor).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeOutBack,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _playSoundAndAction() {
    if (!_hasTriggeredSound) {
      _hasTriggeredSound = true;
      Future.delayed(const Duration(milliseconds: 250), () {
        if (mounted) {
          _hasTriggeredSound = false;
        }
      });

      if (!widget.noTapSnd) {
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
      }
    }

    if (widget.onPress != null) {
      if (widget.noTimeout) {
        widget.onPress?.call();
      } else {
        Future.delayed(const Duration(milliseconds: 220), () {
          if (mounted) {
            widget.onPress?.call();
          }
        });
      }
    }
  }

  void _triggerPop() {
    _controller.forward(from: 0.0).then((_) {
      if (mounted) {
        _controller.reverse();
      }
    });
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    // onTap will handle the pop sequence
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  void _handleTap() {
    _triggerPop();
    _playSoundAndAction();
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
