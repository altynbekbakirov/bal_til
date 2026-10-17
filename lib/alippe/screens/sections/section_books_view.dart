import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/alippe_cubit.dart';
import '../../data/alippe_data.dart';
import '../../widgets/alippe_anim_button.dart';
import '../../widgets/alippe_book_base.dart';
import '../../widgets/alippe_container.dart';
import '../dialogs/alippe_game_finish_dialog.dart';

class SectionBooksView extends StatefulWidget {
  final int sectionId;

  const SectionBooksView({super.key, required this.sectionId});

  @override
  State<SectionBooksView> createState() => _SectionBooksViewState();
}

class _SectionBooksViewState extends State<SectionBooksView> {
  int _pageIndex = 0;
  late List<String> _items;
  late int _bookId;

  @override
  void initState() {
    super.initState();
    _loadSectionData();
  }

  void _loadSectionData() {
    switch (widget.sectionId) {
      case 2:
        _bookId = 1;
        _items = AlippeData.section2Items;
        break;
      case 3:
        _bookId = 1;
        _items = AlippeData.section3Items;
        break;
      case 4:
        _bookId = 2;
        _items = AlippeData.section4Items;
        break;
      case 5:
        _bookId = 2;
        _items = AlippeData.section5Items;
        break;
      case 6:
        _bookId = 3;
        _items = AlippeData.section6Items;
        break;
      case 7:
        _bookId = 3;
        _items = AlippeData.section7Items;
        break;
      default:
        _bookId = 1;
        _items = AlippeData.section2Items;
    }
  }

  int get _totalPages => (_items.length / 2).ceil();

  void _nextPage() {
    if (_pageIndex < _totalPages - 1) {
      setState(() {
        _pageIndex++;
      });
    } else {
      // Completed this section!
      context.read<AlippeCubit>().addScore(_bookId, 3);
      AlippeGameFinishDialog.show(
        context: context,
        score: 3,
        onRestart: () {
          setState(() {
            _pageIndex = 0;
          });
        },
        onNext: () {
          final nextSec = widget.sectionId + 1;
          Navigator.of(context).pushReplacementNamed('/section', arguments: nextSec);
        },
        onHome: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      );
    }
  }

  void _prevPage() {
    if (_pageIndex > 0) {
      setState(() {
        _pageIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final leftIdx = _pageIndex * 2;
    final rightIdx = leftIdx + 1;

    final leftItem = leftIdx < _items.length ? _items[leftIdx] : null;
    final rightItem = rightIdx < _items.length ? _items[rightIdx] : null;

    return AlippeContainer(
      child: AlippeBookBase(
        bookId: _bookId,
        onLeftPress: _pageIndex > 0 ? _prevPage : null,
        onRightPress: _nextPage,
        child: Row(
          children: [
            // Left Page
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: leftItem != null
                    ? AlippeAnimButton(
                        imageAsset: leftItem,
                      )
                    : const SizedBox.shrink(),
              ),
            ),

            const SizedBox(width: 40),

            // Right Page
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: rightItem != null
                    ? AlippeAnimButton(
                        imageAsset: rightItem,
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
