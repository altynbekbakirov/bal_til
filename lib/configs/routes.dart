import 'package:flutter/material.dart';
import '../features/home/screens/home_screen.dart';
import '../features/nature/screens/animals_screen.dart';
import '../features/nature/screens/plants_screen.dart';
import '../features/map/screens/map_screen.dart';
import '../features/map/screens/anthem_screen.dart';
import '../features/word_connect/screens/word_connect_screen.dart';
import '../features/word_search/screens/word_search_screen.dart';

class Routers {
  static const home = '/';
  static const wordConnect = '/word_connect';
  static const wordSearch = '/word_search';
  static const animals = '/animals';
  static const plants = '/plants';
  static const map = '/map';
  static const anthem = '/anthem';

  static Map<String, WidgetBuilder> routes = {
    home: (context) => const HomeScreen(),
    wordConnect: (context) => const WordConnectScreen(),
    wordSearch: (context) => const WordSearchScreen(),
    animals: (context) => const AnimalsScreen(),
    plants: (context) => const PlantsScreen(),
    map: (context) => const MapScreen(),
    anthem: (context) => const AnthemScreen(),
  };
}
