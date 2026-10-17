import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../configs/routes.dart';
import '../../core/audio/audio_controller.dart';
import '../core/alippe_audio.dart';
import '../core/alippe_constants.dart';
import '../core/alippe_cubit.dart';
import '../data/alippe_data.dart';
import '../widgets/alippe_anim_button.dart';
import '../widgets/alippe_container.dart';
import '../widgets/alippe_sidebar.dart';
import 'dialogs/alippe_settings_dialog.dart';

class AlippeHomeScreen extends StatelessWidget {
  const AlippeHomeScreen({super.key});

  String _getStarAsset(int score) {
    switch (score) {
      case 1:
        return AlippeAssets.starOneEn;
      case 2:
        return AlippeAssets.starTwoEn;
      case 3:
        return AlippeAssets.starThreeEn;
      default:
        return AlippeAssets.starOneDis;
    }
  }

  void _onBookTap(BuildContext context, AlippeBookModel book) {
    AlippeAudio().playTap();
    if (book.section2Id != null) {
      Navigator.of(context).pushNamed('/book', arguments: book.bookId);
    } else {
      Navigator.of(context).pushNamed('/section', arguments: book.section1Id);
    }
  }

  Future<void> _exitAlippe(BuildContext context) async {
    AlippeAudio().isAlippeActive = false;
    AudioController.instance.isBalTilActive = true;
    await AlippeAudio().stopAll();
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(Routers.home, (route) => false);
      if (AudioController.instance.isMusicEnabled && AudioController.instance.isBalTilActive) {
        AudioController.instance.playMenuMusic();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    AlippeAudio().init();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _exitAlippe(context);
      },
      child: BlocBuilder<AlippeCubit, AlippeState>(
        builder: (context, state) {
          return AlippeContainer(
            child: Row(
              children: [
                // Sidebar
                AlippeSidebar(
                  onSettings: () => AlippeSettingsDialog.show(context),
                  onBack: () => _exitAlippe(context),
                  onPlay: () {
                    final lastSec = state.lastSection;
                    Navigator.of(context).pushNamed('/section', arguments: lastSec);
                  },
                ),

              // 6 Books Grid (2 rows of 3 books)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  child: Column(
                    children: [
                      // Top row: Books 0, 1, 2
                      Expanded(
                        child: Row(
                          children: [
                            _buildBookItem(context, AlippeData.books[0], state.scores[0]),
                            _buildBookItem(context, AlippeData.books[1], state.scores[1]),
                            _buildBookItem(context, AlippeData.books[2], state.scores[2]),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Bottom row: Books 3, 4, 5
                      Expanded(
                        child: Row(
                          children: [
                            _buildBookItem(context, AlippeData.books[3], state.scores[3]),
                            _buildBookItem(context, AlippeData.books[4], state.scores[4]),
                            _buildBookItem(context, AlippeData.books[5], state.scores[5]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

  Widget _buildBookItem(BuildContext context, AlippeBookModel book, int score) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: AlippeAnimButton(
          scaleFactor: 1.15,
          onPress: () => _onBookTap(context, book),
          child: Column(
            children: [
              Expanded(
                child: Image.asset(
                  book.icon,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 8),
              Image.asset(
                _getStarAsset(score),
                height: 28,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
