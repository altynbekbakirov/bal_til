import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bal_til/alippe/core/alippe_audio.dart';
import 'package:bal_til/alippe/core/alippe_cubit.dart';
import 'package:bal_til/alippe/data/alippe_data.dart';
import 'package:bal_til/alippe/screens/alippe_home_screen.dart';
import 'package:bal_til/alippe/screens/alippe_book_screen.dart';
import 'package:bal_til/alippe/widgets/alippe_anim_button.dart';
import 'package:bal_til/configs/routes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AlippeAudio().isSoundEnabled = false;
    AlippeAudio().isMusicEnabled = false;
  });

  group('Alippe Sequential Book Unlock & Grey Filter', () {
    testWidgets('Book 0 is unlocked by default, Books 1-5 are locked with grey filter and lock icons', (tester) async {
      tester.view.physicalSize = const Size(800, 360);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        BlocProvider<AlippeCubit>(
          create: (_) => AlippeCubit(),
          child: const MaterialApp(
            home: AlippeHomeScreen(),
            onGenerateRoute: Routers.onGenerateRoute,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find lock icons: Books 1 through 5 should each have a lock icon (5 total)
      final lockIcons = find.byIcon(Icons.lock_rounded);
      expect(lockIcons, findsNWidgets(5));

      // ColorFiltered widgets applied to locked books (5 total)
      final colorFilteredWidgets = find.byType(ColorFiltered);
      expect(colorFilteredWidgets, findsNWidgets(5));
    });

    testWidgets('Tapping locked Book 1 does not navigate, while tapping unlocked Book 0 navigates', (tester) async {
      tester.view.physicalSize = const Size(800, 360);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      String? pushedRoute;
      await tester.pumpWidget(
        BlocProvider<AlippeCubit>(
          create: (_) => AlippeCubit(),
          child: MaterialApp(
            home: const AlippeHomeScreen(),
            onGenerateRoute: (settings) {
              pushedRoute = settings.name;
              return MaterialPageRoute(
                builder: (_) => Scaffold(body: Text('Route: ${settings.name}')),
                settings: settings,
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      final animButtons = find.byType(AlippeAnimButton);
      // animButtons: 0: Settings, 1: Back, 2: Play, 3: Book 0, 4: Book 1 ...
      // Tap locked Book 1 (at index 4)
      await tester.tap(animButtons.at(4));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      // Should not have navigated
      expect(pushedRoute, isNull);
      expect(find.byType(AlippeHomeScreen), findsOneWidget);

      // Now tap unlocked Book 0 (at index 3)
      await tester.tap(animButtons.at(3));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      // Should have navigated to /book with argument 0
      expect(pushedRoute, '/book');
      expect(find.text('Route: /book'), findsOneWidget);
    });

    testWidgets('Earning 3 stars on Book 0 unlocks Book 1 and removes its grey filter', (tester) async {
      tester.view.physicalSize = const Size(800, 360);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final cubit = AlippeCubit();
      await tester.pumpWidget(
        BlocProvider<AlippeCubit>.value(
          value: cubit,
          child: const MaterialApp(
            home: AlippeHomeScreen(),
            onGenerateRoute: Routers.onGenerateRoute,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially 5 locked books
      expect(find.byIcon(Icons.lock_rounded), findsNWidgets(5));

      // Award 2 stars to Book 0 (not completed yet, needs 3 stars)
      await cubit.addScore(0, 2);
      await tester.pumpAndSettle();
      // Still 5 locked books
      expect(find.byIcon(Icons.lock_rounded), findsNWidgets(5));

      // Now award 3 stars to Book 0 (completed!)
      await cubit.addScore(0, 3);
      await tester.pumpAndSettle();

      // Book 1 is now unlocked! Only Books 2, 3, 4, 5 remain locked (4 total)
      expect(find.byIcon(Icons.lock_rounded), findsNWidgets(4));
    });

    testWidgets('Sequential unlocking propagates through all books', (tester) async {
      tester.view.physicalSize = const Size(800, 360);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final cubit = AlippeCubit();
      await tester.pumpWidget(
        BlocProvider<AlippeCubit>.value(
          value: cubit,
          child: const MaterialApp(
            home: AlippeHomeScreen(),
            onGenerateRoute: Routers.onGenerateRoute,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.lock_rounded), findsNWidgets(5));

      // Complete Book 0 -> unlocks Book 1
      await cubit.addScore(0, 3);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.lock_rounded), findsNWidgets(4));

      // Complete Book 1 -> unlocks Book 2
      await cubit.addScore(1, 3);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.lock_rounded), findsNWidgets(3));

      // Complete Book 2 -> unlocks Book 3
      await cubit.addScore(2, 3);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.lock_rounded), findsNWidgets(2));

      // Complete Book 3 -> unlocks Book 4
      await cubit.addScore(3, 3);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.lock_rounded), findsNWidgets(1));

      // Complete Book 4 -> unlocks Book 5
      await cubit.addScore(4, 3);
      await tester.pumpAndSettle();
      // All 6 books are now unlocked!
      expect(find.byIcon(Icons.lock_rounded), findsNothing);
      expect(find.byType(ColorFiltered), findsNothing);
    });

    testWidgets('AlippeBookScreen automatically pops back if opened for a locked book', (tester) async {
      tester.view.physicalSize = const Size(800, 360);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final cubit = AlippeCubit();
      await tester.pumpWidget(
        BlocProvider<AlippeCubit>.value(
          value: cubit,
          child: MaterialApp(
            home: const Scaffold(body: Text('Previous Screen')),
            routes: {
              '/locked_book': (_) => const AlippeBookScreen(bookId: 3),
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to locked book
      final nav = tester.state<NavigatorState>(find.byType(Navigator));
      nav.pushNamed('/locked_book');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // Screen automatically popped back because bookId 3 is locked
      expect(find.text('Previous Screen'), findsOneWidget);
    });
  });
}

