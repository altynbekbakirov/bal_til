import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

/// Modern, stylish in-app exit notification overlay.
class ExitNotificationOverlay {
  static OverlayEntry? _currentEntry;
  static Timer? _dismissTimer;

  static void show(
    BuildContext context, {
    String message = 'Чыгуу үчүн артка баскычын кайра басыңыз',
  }) {
    hide();

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) {
      // Fallback for environments where Overlay is not available
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color(0xFF1E293B),
        textColor: Colors.white,
        fontSize: 14.0,
      );
      return;
    }

    _currentEntry = OverlayEntry(
      builder: (context) => _ExitToastWidget(
        message: message,
      ),
    );

    overlay.insert(_currentEntry!);

    _dismissTimer = Timer(const Duration(milliseconds: 2000), () {
      hide();
    });
  }

  static void hide() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    try {
      _currentEntry?.remove();
    } catch (_) {}
    _currentEntry = null;
  }
}

class _ExitToastWidget extends StatelessWidget {
  final String message;

  const _ExitToastWidget({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Positioned(
      bottom: bottomPadding + 28,
      left: 20,
      right: 20,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: const Color(0xFFEA580C).withValues(alpha: 0.55),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: const Color(0xFFEA580C).withValues(alpha: 0.25),
                  blurRadius: 14,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFEA580C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.exit_to_app_rounded,
                    color: Colors.white,
                    size: 17,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    message,
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 180.ms)
            .slideY(begin: 0.35, end: 0, duration: 240.ms, curve: Curves.easeOutBack),
      ),
    );
  }
}

/// Handles back button pop invocation:
/// Double back press within 2 seconds exits the app,
/// otherwise displays a modern in-app warning notification.
Future<DateTime?> handlePopInvoked(
  BuildContext context,
  bool didPop,
  DateTime? lastPressed, {
  String message = 'Чыгуу үчүн артка баскычын кайра басыңыз',
}) async {
  if (didPop) {
    return null;
  }

  final now = DateTime.now();
  final isExitWarning = lastPressed == null ||
      now.difference(lastPressed) >= const Duration(seconds: 2);

  if (isExitWarning) {
    ExitNotificationOverlay.show(context, message: message);
    return now;
  }

  ExitNotificationOverlay.hide();
  Fluttertoast.cancel();
  SystemNavigator.pop();
  return null;
}
