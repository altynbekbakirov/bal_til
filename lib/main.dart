import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'alippe/core/alippe_cubit.dart';
import 'alippe/screens/alippe_book_screen.dart';
import 'alippe/screens/alippe_home_screen.dart';
import 'alippe/screens/alippe_section_screen.dart';
import 'alippe/screens/alippe_splash_screen.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  // Lock orientation to landscape for Alippe (3-6 years) game
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const AlippeApp());
}

class AlippeApp extends StatelessWidget {
  const AlippeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AlippeCubit>(
      create: (_) => AlippeCubit(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Алиппе',
        theme: ThemeData(
          fontFamily: 'Comfortaa',
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF8F00)),
        ),
        initialRoute: '/',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(builder: (_) => const AlippeSplashScreen());
            case '/home':
              return MaterialPageRoute(builder: (_) => const AlippeHomeScreen());
            case '/book':
              final bookId = settings.arguments as int? ?? 0;
              return MaterialPageRoute(
                builder: (_) => AlippeBookScreen(bookId: bookId),
              );
            case '/section':
              final sectionId = settings.arguments as int? ?? 0;
              return MaterialPageRoute(
                builder: (_) => AlippeSectionScreen(sectionId: sectionId),
              );
            default:
              return MaterialPageRoute(builder: (_) => const AlippeHomeScreen());
          }
        },
      ),
    );
  }
}
