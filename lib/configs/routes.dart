import 'package:flutter/material.dart';
import '../features/home/screens/home_screen.dart';
import '../features/nature/screens/animals_screen.dart';
import '../features/nature/screens/plants_screen.dart';
import '../features/map/screens/map_screen.dart';
import '../features/map/screens/anthem_screen.dart';
import '../features/word_connect/screens/word_connect_screen.dart';
import '../features/word_search/screens/word_search_screen.dart';

import '../alippe/screens/alippe_book_screen.dart';
import '../alippe/screens/alippe_home_screen.dart';
import '../alippe/screens/alippe_section_screen.dart';
import '../alippe/screens/alippe_splash_screen.dart';

class Routers {
  static const home = '/';
  static const wordConnect = '/word_connect';
  static const wordSearch = '/word_search';
  static const animals = '/animals';
  static const plants = '/plants';
  static const map = '/map';
  static const anthem = '/anthem';
  static const alippe = '/alippe';
  static const alippeHome = '/alippe_home';

  static Map<String, WidgetBuilder> routes = {
    home: (context) => const HomeScreen(),
    wordConnect: (context) => const WordConnectScreen(),
    wordSearch: (context) => const WordSearchScreen(),
    animals: (context) => const AnimalsScreen(),
    plants: (context) => const PlantsScreen(),
    map: (context) => const MapScreen(),
    anthem: (context) => const AnthemScreen(),
    alippe: (context) => const AlippeSplashScreen(),
    alippeHome: (context) => const AlippeHomeScreen(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/home':
        return MaterialPageRoute(
          builder: (_) => const AlippeHomeScreen(),
          settings: settings,
        );
      case '/book':
        final bookId = settings.arguments as int? ?? 0;
        return MaterialPageRoute(
          builder: (_) => AlippeBookScreen(bookId: bookId),
          settings: settings,
        );
      case '/section':
        final sectionId = settings.arguments as int? ?? 0;
        return MaterialPageRoute(
          builder: (_) => AlippeSectionScreen(sectionId: sectionId),
          settings: settings,
        );
      default:
        return null;
    }
  }
}
