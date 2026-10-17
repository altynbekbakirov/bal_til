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
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: AlippeAnimButton(
                    imageAsset: AlippeData.getSectionIcon(book.section1Id),
                    onPress: () {
                      Navigator.of(context).pushNamed(
                        '/section',
                        arguments: book.section1Id,
                      );
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(width: 40),

            // Right page: Section 2
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: book.section2Id != null
                      ? AlippeAnimButton(
                          imageAsset: AlippeData.getSectionIcon(book.section2Id!),
                          onPress: () {
                            Navigator.of(context).pushNamed(
                              '/section',
                              arguments: book.section2Id,
                            );
                          },
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
