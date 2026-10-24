import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../configs/routes.dart';
import '../../core/audio/audio_controller.dart';
import '../../core/utils/app_orientation.dart';
import '../core/alippe_audio.dart';
import '../core/alippe_constants.dart';
import '../core/alippe_cubit.dart';
import '../data/alippe_data.dart';
import '../widgets/alippe_anim_button.dart';
import '../widgets/alippe_container.dart';
import '../widgets/alippe_sidebar.dart';
import 'dialogs/alippe_settings_dialog.dart';

class AlippeHomeScreen extends StatefulWidget {
  const AlippeHomeScreen({super.key});

  @override
  State<AlippeHomeScreen> createState() => _AlippeHomeScreenState();
}

class _AlippeHomeScreenState extends State<AlippeHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Only Alippe should be in landscape; engage landscape & immersive mode on entry
    AppOrientation.forceLandscape();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Initialize Cubit & Audio when entering Alippe
    final cubit = context.read<AlippeCubit>();
    cubit.init();
    AlippeAudio().init().then((_) {
      if (AlippeAudio().isMusicEnabled && mounted) {
        AlippeAudio().startMusic();
      }
    });
  }

  @override
  void dispose() {
    // When leaving Alippe, restore portrait mode and standard UI overlay
    AppOrientation.forcePortrait();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Widget _buildStars(int score) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final starHeight = constraints.maxHeight;
        final shift = (starHeight * 0.22).clamp(4.0, 14.0);

        Widget buildSingleStar({
          required bool isEarned,
          required String enabledAsset,
          required String disabledAsset,
          required double offsetX,
        }) {
          final star = Opacity(
            opacity: isEarned ? 1.0 : 0.32,
            child: Image.asset(
              isEarned ? enabledAsset : disabledAsset,
              height: starHeight,
              fit: BoxFit.contain,
            ),
          );

          if (offsetX == 0) return star;
          return Transform.translate(
            offset: Offset(offsetX, 0),
            child: star,
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildSingleStar(
              isEarned: score >= 1,
              enabledAsset: AlippeAssets.starOneEn,
              disabledAsset: AlippeAssets.starOneDis,
              offsetX: shift,
            ),
            buildSingleStar(
              isEarned: score >= 2,
              enabledAsset: AlippeAssets.starTwoEn,
              disabledAsset: AlippeAssets.starTwoDis,
              offsetX: 0,
            ),
            buildSingleStar(
              isEarned: score >= 3,
              enabledAsset: AlippeAssets.starThreeEn,
              disabledAsset: AlippeAssets.starThreeDis,
              offsetX: -shift,
            ),
          ],
        );
      },
    );
  }

  void _onBookTap(BuildContext context, AlippeBookModel book) {
    if (book.section2Id != null) {
      Navigator.of(context).pushNamed('/book', arguments: book.bookId);
    } else {
      Navigator.of(context).pushNamed('/section', arguments: book.section1Id);
    }
  }

  Future<void> _exitAlippe(BuildContext context) async {
    AlippeAudio().isAlippeActive = false;
    AudioController.instance.isBalTilActive = false;
    await AlippeAudio().stopAll();
    await AppOrientation.forcePortrait();
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    if (context.mounted) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pushNamedAndRemoveUntil(Routers.gameSelect, (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  padding: const EdgeInsets.fromLTRB(6, 8, 14, 8),
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
                      const SizedBox(height: 8),
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
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
        child: AlippeAnimButton(
          scaleFactor: 1.2,
          onPress: () => _onBookTap(context, book),
          child: Column(
            children: [
              // Stars on the top of the game card (flex 1)
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: _buildStars(score),
                ),
              ),
              const SizedBox(height: 2),
              // Book icon below the stars (flex 3)
              Expanded(
                flex: 3,
                child: Image.asset(
                  book.icon,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
