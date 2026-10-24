import 'package:flutter/material.dart';
import 'nature_spelling_screen.dart';

class AnimalsScreen extends StatelessWidget {
  const AnimalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const NatureSpellingScreen(gameType: NatureGameType.animals);
  }
}
