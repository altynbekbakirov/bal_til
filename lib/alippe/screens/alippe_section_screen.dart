import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/alippe_cubit.dart';
import 'sections/section0_view.dart';
import 'sections/section1_view.dart';
import 'sections/section_books_view.dart';
import 'sections/section8_view.dart';
import 'sections/section9_view.dart';
import 'sections/section10_view.dart';

class AlippeSectionScreen extends StatefulWidget {
  final int sectionId;

  const AlippeSectionScreen({super.key, required this.sectionId});

  @override
  State<AlippeSectionScreen> createState() => _AlippeSectionScreenState();
}

class _AlippeSectionScreenState extends State<AlippeSectionScreen> {
  @override
  void initState() {
    super.initState();
    // Update last played section
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AlippeCubit>().setLastSection(widget.sectionId);
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.sectionId) {
      case 0:
        return const Section0View();
      case 1:
        return const Section1View();
      case 2:
      case 3:
      case 4:
      case 5:
      case 6:
      case 7:
        return SectionBooksView(sectionId: widget.sectionId);
      case 8:
        return const Section8View();
      case 9:
        return const Section9View();
      case 10:
        return const Section10View();
      default:
        return const Section0View();
    }
  }
}
