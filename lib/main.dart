import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'alippe/core/alippe_cubit.dart';
import 'alippe/screens/alippe_book_screen.dart';
import 'alippe/screens/alippe_home_screen.dart';
import 'alippe/screens/alippe_section_screen.dart';
import 'alippe/screens/alippe_splash_screen.dart';
import 'configs/routes.dart';
import 'core/audio/audio_cubit.dart';
import 'core/score/score_cubit.dart';
import 'core/theme/app_theme.dart';

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

  // Default orientation is portrait for Bal Til; Alippe manages landscape mode on demand
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AudioCubit>(create: (_) => AudioCubit()),
        BlocProvider<ScoreCubit>(create: (_) => ScoreCubit()..loadScores()),
        BlocProvider<AlippeCubit>(create: (_) => AlippeCubit()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Бал тил & Алиппе',
        theme: AppTheme.lightTheme,
        initialRoute: Routers.home,
        routes: Routers.routes,
        onGenerateRoute: Routers.onGenerateRoute,
      ),
    );
  }
}

/// Standalone AlippeApp widget for test isolation and direct execution
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
