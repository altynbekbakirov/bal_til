import 'package:flutter/material.dart';
import '../data/alippe_data.dart';
import '../widgets/alippe_anim_button.dart';
import '../widgets/alippe_book_base.dart';
import '../widgets/alippe_container.dart';

class AlippeBookScreen extends StatelessWidget {
  final int bookId;

  const AlippeBookScreen({super.key, required this.bookId});

  @override
  Widget build(BuildContext context) {
    final book = AlippeData.books[bookId.clamp(0, 5)];

    return AlippeContainer(
      child: AlippeBookBase(
        bookId: book.bookId,
        child: Row(
          children: [
            // Left page: Section 1
            Expanded(
              child: _buildSectionItem(
                context: context,
                sectionId: book.section1Id,
              ),
            ),

            const SizedBox(width: 32),

            // Right page: Section 2
            Expanded(
              child: book.section2Id != null
                  ? _buildSectionItem(
                      context: context,
                      sectionId: book.section2Id!,
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
  }) {
    // Section 5 (Book 3 right icon) has a slightly smaller asset; a 1.35 scale makes it balanced with the left icon
    final scale = (sectionId == 5) ? 1.35 : 1.0;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Transform.scale(
          scale: scale,
          child: AlippeAnimButton(
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
}
