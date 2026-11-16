import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/services/common_services.dart';
import '../core/alippe_audio.dart';
import '../core/alippe_cubit.dart';
import 'sections/section0_view.dart';
import 'sections/section1_view.dart';
import 'sections/section_books_view.dart';
import 'sections/section8_view.dart';
import 'sections/section9_view.dart';
import 'sections/section10_view.dart';
import 'sections/section11_view.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cubit = context.read<AlippeCubit>();
      if (!cubit.isSectionUnlocked(widget.sectionId)) {
        AlippeAudio().playFail();
        ExitNotificationOverlay.show(
          context,
          message: 'Адегенде мурунку бөлүмдү аяктаңыз!',
        );
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        return;
      }
      cubit.setLastSection(widget.sectionId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isUnlocked = context.watch<AlippeCubit>().isSectionUnlocked(widget.sectionId);
    if (!isUnlocked) {
      return const SizedBox.shrink();
    }

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
        return const Section10View(initialLevel: 1);
      case 11:
        return const Section11View();
      case 12:
        return const Section10View(initialLevel: 2);
      default:
        return const Section0View();
    }
  }
}
