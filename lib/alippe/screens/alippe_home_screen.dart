import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../configs/routes.dart';
import '../../core/audio/audio_controller.dart';
import '../../core/services/common_services.dart';
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
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
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

  static const ColorFilter _grayscaleFilter = ColorFilter.matrix(<double>[
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0,      0,      0,      1, 0,
  ]);

  @override
  void dispose() {
    _pageController.dispose();
    ExitNotificationOverlay.hide();
    // When leaving Alippe, restore portrait mode and standard UI overlay
    AppOrientation.forcePortrait();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  bool _isBookUnlocked(int bookId, List<int> scores) {
    if (bookId == 0) return true;
    if (bookId > 0 && bookId < scores.length) {
      return scores[bookId - 1] >= 3 || scores[bookId] > 0;
    }
    return false;
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
    if (book.isComingSoon) {
      AlippeAudio().playTap();
      ExitNotificationOverlay.show(
        context,
        message: 'Бул оюн жакында кошулат!',
      );
      return;
    }
    if (book.section2Id != null) {
      Navigator.of(context).pushNamed('/book', arguments: book.bookId);
    } else {
      Navigator.of(context).pushNamed('/section', arguments: book.section1Id);
    }
  }

  void _onScrollButtonTap() {
    if (!_pageController.hasClients) return;
    if (_currentPage == 0) {
      _pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
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
                // Left Sidebar (Settings and Back)
                AlippeSidebar(
                  onSettings: () => AlippeSettingsDialog.show(context),
                  onBack: () => _exitAlippe(context),
                ),

                // Center Games Grid (Horizontal PageView with 6 games per page)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        Expanded(
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: 2,
                            onPageChanged: (index) {
                              setState(() {
                                _currentPage = index;
                              });
                            },
                            itemBuilder: (context, pageIndex) {
                              final startIndex = pageIndex * 6;
                              final pageBooks = AlippeData.books.sublist(
                                startIndex,
                                (startIndex + 6).clamp(0, AlippeData.books.length),
                              );
                              return _buildBooksGrid(context, pageBooks, state.scores);
                            },
                          ),
                        ),
                        const SizedBox(height: 4),
                        _buildPageIndicator(),
                      ],
                    ),
                  ),
                ),

                // Right Autoplay / Navigation Button to scroll horizontally
                _buildRightNavButton(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBooksGrid(
    BuildContext context,
    List<AlippeBookModel> pageBooks,
    List<int> scores,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        children: [
          // Top row (up to 3 games)
          Expanded(
            child: Row(
              children: [
                for (int i = 0; i < 3; i++)
                  if (i < pageBooks.length)
                    _buildBookItem(
                      context,
                      pageBooks[i],
                      pageBooks[i].bookId < scores.length ? scores[pageBooks[i].bookId] : 0,
                      _isBookUnlocked(pageBooks[i].bookId, scores),
                    )
                  else
                    const Expanded(child: SizedBox.shrink()),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Bottom row (up to 3 games)
          Expanded(
            child: Row(
              children: [
                for (int i = 3; i < 6; i++)
                  if (i < pageBooks.length)
                    _buildBookItem(
                      context,
                      pageBooks[i],
                      pageBooks[i].bookId < scores.length ? scores[pageBooks[i].bookId] : 0,
                      _isBookUnlocked(pageBooks[i].bookId, scores),
                    )
                  else
                    const Expanded(child: SizedBox.shrink()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: _currentPage == 0 ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == 0 ? const Color(0xFFFFC107) : Colors.white60,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: _currentPage == 1 ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == 1 ? const Color(0xFFFFC107) : Colors.white60,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildRightNavButton(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isCompact = screenHeight < 360;
    final playSize = isCompact ? 80.0 : 92.0;

    return Container(
      width: isCompact ? 116 : 134,
      padding: EdgeInsets.symmetric(
        vertical: isCompact ? 10 : 14,
        horizontal: isCompact ? 8 : 10,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Transform.flip(
            flipX: _currentPage == 1,
            child: AlippeAnimButton(
              key: const Key('alippe_autoplay_button'),
              width: playSize,
              height: playSize,
              imageAsset: AlippeAssets.sidePlay,
              onPress: _onScrollButtonTap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookItem(
    BuildContext context,
    AlippeBookModel book,
    int score,
    bool isUnlocked,
  ) {
    final bookIcon = Image.asset(
      book.icon,
      fit: BoxFit.contain,
    );

    Widget bookDisplay = Column(
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
          child: isUnlocked
              ? bookIcon
              : Stack(
                  alignment: Alignment.center,
                  children: [
                    bookIcon,
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.52),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white70, width: 1.5),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.lock_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );

    if (!isUnlocked) {
      bookDisplay = ColorFiltered(
        colorFilter: _grayscaleFilter,
        child: Opacity(
          opacity: 0.65,
          child: bookDisplay,
        ),
      );
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
        child: AlippeAnimButton(
          key: Key('alippe_book_${book.bookId}'),
          scaleFactor: isUnlocked ? 1.2 : 1.04,
          noTapSnd: !isUnlocked,
          onPress: isUnlocked
              ? () => _onBookTap(context, book)
              : () {
                  AlippeAudio().playFail();
                  ExitNotificationOverlay.show(
                    context,
                    message: 'Адегенде мурунку бөлүмдү аяктаңыз!',
                  );
                },
          child: bookDisplay,
        ),
      ),
    );
  }
}
