import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/services/common_services.dart';
import '../core/alippe_audio.dart';
import '../core/alippe_cubit.dart';
import '../data/alippe_data.dart';
import '../widgets/alippe_anim_button.dart';
import '../widgets/alippe_book_base.dart';
import '../widgets/alippe_container.dart';

class AlippeBookScreen extends StatelessWidget {
  final int bookId;

  const AlippeBookScreen({super.key, required this.bookId});

  static const ColorFilter _grayscaleFilter = ColorFilter.matrix(<double>[
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0,      0,      0,      1, 0,
  ]);

  @override
  Widget build(BuildContext context) {
    final book = AlippeData.books[bookId.clamp(0, AlippeData.books.length - 1)];
    final cubit = context.watch<AlippeCubit>();
    final isUnlocked = cubit.isBookUnlocked(book.bookId);

    if (!isUnlocked) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      });
      return const SizedBox.shrink();
    }

    final isSection2Unlocked = book.section2Id != null &&
        cubit.isSectionCompleted(book.section1Id);

    return AlippeContainer(
      child: AlippeBookBase(
        bookId: book.bookId,
        child: Row(
          children: [
            // Left page: Section 1 (always unlocked once book is unlocked)
            Expanded(
              child: _buildSectionItem(
                context: context,
                sectionId: book.section1Id,
                isUnlocked: true,
              ),
            ),

            const SizedBox(width: 32),

            // Right page: Section 2 (unlocked ONLY after Section 1 is completed)
            Expanded(
              child: book.section2Id != null
                  ? _buildSectionItem(
                      context: context,
                      sectionId: book.section2Id!,
                      isUnlocked: isSection2Unlocked,
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionItem({
    required BuildContext context,
    required int sectionId,
    required bool isUnlocked,
  }) {
    // Section 5 (Book 3 right icon) has a slightly smaller asset; a 1.35 scale makes it balanced with the left icon
    final scale = (sectionId == 5) ? 1.35 : 1.0;

    if (isUnlocked) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Transform.scale(
            scale: scale,
            child: AlippeAnimButton(
              key: Key('book_${bookId}_section_$sectionId'),
              scaleFactor: 1.25,
              imageAsset: AlippeData.getSectionIcon(sectionId),
              onPress: () {
                Navigator.of(context).pushNamed(
                  '/section',
                  arguments: sectionId,
                );
              },
            ),
          ),
        ),
      );
    }

    final iconWidget = Image.asset(
      AlippeData.getSectionIcon(sectionId),
      fit: BoxFit.contain,
    );

    final lockedContent = Stack(
      alignment: Alignment.center,
      children: [
        ColorFiltered(
          colorFilter: _grayscaleFilter,
          child: Opacity(
            opacity: 0.65,
            child: iconWidget,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white70, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(
            Icons.lock_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ],
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Transform.scale(
          scale: scale,
          child: AlippeAnimButton(
            key: Key('book_${bookId}_section_$sectionId'),
            scaleFactor: 1.04,
            noTapSnd: true,
            onPress: () {
              AlippeAudio().playFail();
              ExitNotificationOverlay.show(
                context,
                message: 'Адегенде 1-бөлүмдү аяктаңыз!',
              );
            },
            child: lockedContent,
          ),
        ),
      ),
    );
  }
}
