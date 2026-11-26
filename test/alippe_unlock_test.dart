import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bal_til/alippe/core/alippe_audio.dart';
import 'package:bal_til/alippe/core/alippe_cubit.dart';
import 'package:bal_til/alippe/screens/alippe_home_screen.dart';
import 'package:bal_til/alippe/screens/alippe_book_screen.dart';
import 'package:bal_til/alippe/widgets/alippe_anim_button.dart';
import 'package:bal_til/alippe/screens/sections/section11_view.dart';
import 'package:bal_til/alippe/screens/sections/section13_view.dart';
import 'package:bal_til/core/services/common_services.dart';
import 'package:bal_til/alippe/screens/alippe_section_screen.dart';
import 'package:bal_til/alippe/screens/dialogs/alippe_game_finish_dialog.dart';
import 'package:bal_til/configs/routes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AlippeAudio().isSoundEnabled = false;
    AlippeAudio().isMusicEnabled = false;
    addTearDown(() {
      ExitNotificationOverlay.hide();
    });
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

      // Tap locked Book 1
      await tester.tap(find.byKey(const Key('alippe_book_1')));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      // Should not have navigated
      expect(pushedRoute, isNull);
      expect(find.byType(AlippeHomeScreen), findsOneWidget);

      // Now tap unlocked Book 0
      await tester.tap(find.byKey(const Key('alippe_book_0')));
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

    testWidgets('Autoplay button is positioned on the right and scrolls horizontally to reveal extra 6 games', (tester) async {
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

      // On Page 0 initially: Books 0..5 are present
      expect(find.byKey(const Key('alippe_book_0')), findsOneWidget);
      expect(find.byKey(const Key('alippe_book_5')), findsOneWidget);
      expect(find.byKey(const Key('alippe_book_6')), findsNothing);

      // Autoplay button exists on the right
      final autoplayButton = find.byKey(const Key('alippe_autoplay_button'));
      expect(autoplayButton, findsOneWidget);

      // Verify the autoplay button is positioned on the right half of the screen
      final autoplayOffset = tester.getCenter(autoplayButton);
      expect(autoplayOffset.dx, greaterThan(400));

      // Tap autoplay button to scroll to Page 1
      await tester.tap(autoplayButton);
      await tester.pumpAndSettle();

      // Page 1 is now displayed: Books 6..11 are visible, Books 0..5 are offscreen
      expect(find.byKey(const Key('alippe_book_0')), findsNothing);
      expect(find.byKey(const Key('alippe_book_6')), findsOneWidget);
      expect(find.byKey(const Key('alippe_book_11')), findsOneWidget);

      // Tap locked Book 6 -> shows locked notification
      await tester.tap(find.byKey(const Key('alippe_book_6')));
      await tester.pumpAndSettle();
      expect(find.text('Адегенде мурунку бөлүмдү аяктаңыз!'), findsOneWidget);

      // Tap autoplay button again to scroll back to Page 0
      await tester.tap(autoplayButton);
      await tester.pumpAndSettle();

      // Page 0 is visible again
      expect(find.byKey(const Key('alippe_book_0')), findsOneWidget);
      expect(find.byKey(const Key('alippe_book_6')), findsNothing);
    });

    testWidgets('Tapping unlocked Book 6 navigates to Game 7 (Section11View), and Book 7 navigates to Game 8 (Section13View)', (tester) async {
      tester.view.physicalSize = const Size(800, 360);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final cubit = AlippeCubit();
      // Unlock all books up to book 5 (complete book 5 with 3 stars so book 6 is unlocked)
      for (int i = 0; i <= 5; i++) {
        await cubit.addScore(i, 3);
      }

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

      // Tap autoplay button to scroll to Page 1
      await tester.tap(find.byKey(const Key('alippe_autoplay_button')));
      await tester.pumpAndSettle();

      // Book 6 is now unlocked because Book 5 has 3 stars!
      expect(find.byKey(const Key('alippe_book_6')), findsOneWidget);

      // Tap unlocked Book 6 -> navigates to Game 7 (Section 11)
      await tester.tap(find.byKey(const Key('alippe_book_6')));
      await tester.pumpAndSettle();

      // We should now be in Section 11 (Sound Quiz Game)!
      expect(find.byType(Section11View), findsOneWidget);
      expect(find.text('Суроо 1 / 15'), findsOneWidget);

      // Pop back to AlippeHomeScreen
      Navigator.of(tester.element(find.byType(Section11View))).pop();
      await tester.pumpAndSettle();

      // Award 3 stars to Book 6 so Book 7 unlocks
      await cubit.addScore(6, 3);
      await tester.pumpAndSettle();

      // Tap unlocked Book 7 -> navigates to Game 8 (Section 13: Үн чыгаруу)
      await tester.tap(find.byKey(const Key('alippe_book_7')));
      await tester.pumpAndSettle();
      expect(find.byType(Section13View), findsOneWidget);
    });

    testWidgets('Horizontal drag/swipe scrolls between pages', (tester) async {
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

      expect(find.byKey(const Key('alippe_book_0')), findsOneWidget);
      expect(find.byKey(const Key('alippe_book_6')), findsNothing);

      // Drag left to scroll to Page 1
      await tester.drag(find.byType(PageView), const Offset(-500, 0));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('alippe_book_6')), findsOneWidget);
      expect(find.byKey(const Key('alippe_book_0')), findsNothing);

      // Drag right to scroll back to Page 0
      await tester.drag(find.byType(PageView), const Offset(500, 0));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('alippe_book_0')), findsOneWidget);
      expect(find.byKey(const Key('alippe_book_6')), findsNothing);
    });
  });

  group('Section11View (Game 7: Sound Quiz)', () {
    testWidgets('Renders 4 picture option cards, header, and listen button without overflow', (tester) async {
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
            home: Scaffold(body: Section11View()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Progress text for first question
      expect(find.text('Суроо 1 / 15'), findsOneWidget);

      // Listen button exists and is large (min 120x120, scales with screen height)
      final listenButton = find.byKey(const Key('section11_listen_button'));
      expect(listenButton, findsOneWidget);
      final RenderBox buttonBox = tester.renderObject(listenButton);
      expect(buttonBox.size.width, greaterThanOrEqualTo(120.0));
      expect(buttonBox.size.height, greaterThanOrEqualTo(120.0));

      final iconFinder = find.descendant(of: listenButton, matching: find.byIcon(Icons.volume_up_rounded));
      expect(iconFinder, findsOneWidget);
      final Icon iconWidget = tester.widget(iconFinder);
      expect(iconWidget.size, greaterThanOrEqualTo(76.0));

      // 4 option cards are rendered
      expect(find.byKey(const Key('section11_option_0')), findsOneWidget);
      expect(find.byKey(const Key('section11_option_1')), findsOneWidget);
      expect(find.byKey(const Key('section11_option_2')), findsOneWidget);
      expect(find.byKey(const Key('section11_option_3')), findsOneWidget);

      // Sidebar buttons
      expect(find.byKey(const Key('section11_restart_button')), findsOneWidget);
      expect(find.byKey(const Key('section11_back_button')), findsOneWidget);
    });

    testWidgets('Tapping incorrect card marks it with cancel icon, and tapping correct card advances question', (tester) async {
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
            home: Scaffold(body: Section11View()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Question 1: target word is "Ат", distractors are "Балык", "Белек", "Ай"
      expect(find.text('Суроо 1 / 15'), findsOneWidget);
      expect(find.text('Ат'), findsOneWidget);
      expect(find.text('Балык'), findsOneWidget);

      // Tap incorrect card "Балык"
      await tester.tap(find.text('Балык'));
      await tester.pumpAndSettle();

      // Close/cancel icon should appear on the failed card
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      // Still on Question 1
      expect(find.text('Суроо 1 / 15'), findsOneWidget);

      // Now tap the correct card "Ат"
      await tester.tap(find.text('Ат'));
      await tester.pumpAndSettle();

      // Checkmark icon appears on the correct card
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);

      // Wait for delay to advance to next question
      await tester.pump(const Duration(milliseconds: 1600));
      await tester.pumpAndSettle();

      // Successfully advanced to Question 2!
      expect(find.text('Суроо 2 / 15'), findsOneWidget);
    });

    testWidgets('Tapping restart button resets back to question 1', (tester) async {
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
            home: Scaffold(body: Section11View()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Answer question 1 correctly
      await tester.tap(find.text('Ат'));
      await tester.pump(const Duration(milliseconds: 1600));
      await tester.pumpAndSettle();

      // Now on Question 2
      expect(find.text('Суроо 2 / 15'), findsOneWidget);

      // Tap restart button
      await tester.tap(find.byKey(const Key('section11_restart_button')));
      await tester.pumpAndSettle();

      // Resets back to Question 1!
      expect(find.text('Суроо 1 / 15'), findsOneWidget);
    });

    testWidgets('Tapping listen button replays sound without crashing', (tester) async {
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
            home: Scaffold(body: Section11View()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap listen button
      await tester.tap(find.byKey(const Key('section11_listen_button')));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('section11_listen_button')), findsOneWidget);
    });

    testWidgets('Completing all 15 questions awards 3 stars to bookId 6 and opens AlippeGameFinishDialog', (tester) async {
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
            home: Scaffold(body: Section11View()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final correctWords = [
        'Ат', 'Балык', 'Үкү', 'Маймыл', 'Аюу',
        'Пил', 'Тоок', 'Уй', 'Машина', 'Учак',
        'Өрүк', 'Дарбыз', 'Гүл', 'Саат', 'Топ',
      ];

      for (int i = 0; i < correctWords.length; i++) {
        expect(find.text('Суроо ${i + 1} / 15'), findsOneWidget);
        await tester.tap(find.text(correctWords[i]));
        await tester.pump(const Duration(milliseconds: 1600));
        if (i < correctWords.length - 1) {
          await tester.pumpAndSettle();
        } else {
          // Final question opens AlippeGameFinishDialog which has rotating animations
          await tester.pump(const Duration(milliseconds: 500));
        }
      }

      // Finish dialog is shown
      expect(find.byType(AlippeGameFinishDialog), findsOneWidget);
      // Cubit received 3 stars for bookId 6!
      expect(cubit.state.scores[6], 3);
    });
  });

  group('Alippe Strict Sequential Section Unlock and Protected Navigation', () {
    testWidgets('In Book 0: Section 0 is unlocked, Section 1 has lock badge and grey filter', (tester) async {
      tester.view.physicalSize = const Size(800, 360);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final cubit = AlippeCubit();
      Object? pushedArguments;

      await tester.pumpWidget(
        BlocProvider<AlippeCubit>.value(
          value: cubit,
          child: MaterialApp(
            home: const AlippeBookScreen(bookId: 0),
            onGenerateRoute: (settings) {
              pushedArguments = settings.arguments;
              return MaterialPageRoute(
                builder: (_) => Scaffold(body: Text('Section: ${settings.arguments}')),
                settings: settings,
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Section 1 has a lock icon and color filter
      expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
      expect(find.byType(ColorFiltered), findsOneWidget);

      // Section 1 is locked -> Calling its onPress should NOT navigate
      final section1Btn = tester.widget<AlippeAnimButton>(find.byKey(const Key('book_0_section_1')));
      section1Btn.onPress?.call();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(pushedArguments, isNull);

      // Section 0 is unlocked -> Calling its onPress navigates to Section 0
      final section0Btn = tester.widget<AlippeAnimButton>(find.byKey(const Key('book_0_section_0')));
      section0Btn.onPress?.call();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(pushedArguments, 0);

      // Pump past notification dismiss timer
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('Completing Section 0 unlocks Section 1, but leaves Book 1 locked (only 1 star)', (tester) async {
      tester.view.physicalSize = const Size(800, 360);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final cubit = AlippeCubit();
      // Complete section 0 with 1 star
      await cubit.completeSection(0);
      await cubit.addScore(0, 1);

      // Book 1 is NOT unlocked yet because Book 0 only has 1 star (< 3)
      expect(cubit.isBookUnlocked(1), isFalse);

      Object? pushedArguments;
      await tester.pumpWidget(
        BlocProvider<AlippeCubit>.value(
          value: cubit,
          child: MaterialApp(
            home: const AlippeBookScreen(bookId: 0),
            onGenerateRoute: (settings) {
              pushedArguments = settings.arguments;
              return MaterialPageRoute(
                builder: (_) => Scaffold(body: Text('Section: ${settings.arguments}')),
                settings: settings,
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Lock icon is gone because Section 1 is now unlocked
      expect(find.byIcon(Icons.lock_rounded), findsNothing);

      // Section 1 is unlocked -> Calling its onPress navigates to Section 1
      final section1Btn = tester.widget<AlippeAnimButton>(find.byKey(const Key('book_0_section_1')));
      section1Btn.onPress?.call();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(pushedArguments, 1);
    });

    testWidgets('Completing Section 1 awards 3 stars to Book 0, unlocking Book 1', (tester) async {
      final cubit = AlippeCubit();
      await cubit.completeSection(0);
      await cubit.addScore(0, 1);
      expect(cubit.isBookUnlocked(1), isFalse);

      await cubit.completeSection(1);
      await cubit.addScore(0, 3);
      expect(cubit.isBookUnlocked(1), isTrue);

      // In Book 1, Section 2 is unlocked, Section 3 is locked until Section 2 is completed
      expect(cubit.isSectionUnlocked(2), isTrue);
      expect(cubit.isSectionUnlocked(3), isFalse);

      await cubit.completeSection(2);
      await cubit.addScore(1, 1);
      // Section 3 is now unlocked, but Book 2 is still locked
      expect(cubit.isSectionUnlocked(3), isTrue);
      expect(cubit.isBookUnlocked(2), isFalse);

      await cubit.completeSection(3);
      await cubit.addScore(1, 3);
      // Completing both sections awards 3 stars, Book 2 is now unlocked
      expect(cubit.isBookUnlocked(2), isTrue);
    });

    testWidgets('In 5th Game (Book 4): Section 8 is unlocked, Section 9 is locked until Section 8 is completed', (tester) async {
      tester.view.physicalSize = const Size(800, 360);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final cubit = AlippeCubit();
      // Unlock up to Book 4 (5th game)
      await cubit.addScore(0, 3);
      await cubit.addScore(1, 3);
      await cubit.addScore(2, 3);
      await cubit.addScore(3, 3);

      expect(cubit.isBookUnlocked(4), isTrue);
      // In 5th game: Section 8 is unlocked, Section 9 is locked initially
      expect(cubit.isSectionUnlocked(8), isTrue);
      expect(cubit.isSectionUnlocked(9), isFalse);

      Object? pushedArguments;
      await tester.pumpWidget(
        BlocProvider<AlippeCubit>.value(
          value: cubit,
          child: MaterialApp(
            home: const AlippeBookScreen(bookId: 4),
            onGenerateRoute: (settings) {
              pushedArguments = settings.arguments;
              return MaterialPageRoute(
                builder: (_) => Scaffold(body: Text('Section: ${settings.arguments}')),
                settings: settings,
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Right page (Section 9) has a lock icon and grey filter
      expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
      expect(find.byType(ColorFiltered), findsOneWidget);

      // Section 9 is locked -> Calling its onPress should NOT navigate
      final section9Btn = tester.widget<AlippeAnimButton>(find.byKey(const Key('book_4_section_9')));
      section9Btn.onPress?.call();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(pushedArguments, isNull);

      // Section 8 is unlocked -> Calling its onPress navigates to Section 8
      final section8Btn = tester.widget<AlippeAnimButton>(find.byKey(const Key('book_4_section_8')));
      section8Btn.onPress?.call();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(pushedArguments, 8);

      // Pop back from pushed route
      final nav = tester.state<NavigatorState>(find.byType(Navigator));
      nav.pop();
      await tester.pumpAndSettle();

      // Complete Section 8
      await cubit.completeSection(8);
      await cubit.addScore(4, 1);
      expect(cubit.isSectionUnlocked(9), isTrue);
      // Book 5 is still locked (Book 4 only has 1 star)
      expect(cubit.isBookUnlocked(5), isFalse);

      // Re-pump Book 4 screen now that Section 8 is completed
      pushedArguments = null;
      await tester.pumpWidget(
        BlocProvider<AlippeCubit>.value(
          value: cubit,
          child: MaterialApp(
            home: const AlippeBookScreen(bookId: 4),
            onGenerateRoute: (settings) {
              pushedArguments = settings.arguments;
              return MaterialPageRoute(
                builder: (_) => Scaffold(body: Text('Section: ${settings.arguments}')),
                settings: settings,
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Lock icon is gone because Section 9 is now unlocked
      expect(find.byIcon(Icons.lock_rounded), findsNothing);

      // Section 9 is now unlocked -> Calling its onPress navigates to Section 9
      final section9UnlockedBtn = tester.widget<AlippeAnimButton>(find.byKey(const Key('book_4_section_9')));
      section9UnlockedBtn.onPress?.call();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(pushedArguments, 9);

      // Complete Section 9
      await cubit.completeSection(9);
      await cubit.addScore(4, 3);
      // Both sections completed -> Book 5 is now unlocked!
      expect(cubit.isBookUnlocked(5), isTrue);
    });

    testWidgets('In 4th Game (Book 3): Section 6 is unlocked, Section 7 is locked until Section 6 is completed', (tester) async {
      tester.view.physicalSize = const Size(800, 360);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final cubit = AlippeCubit();
      // Unlock up to Book 3 (4th game)
      await cubit.addScore(0, 3);
      await cubit.addScore(1, 3);
      await cubit.addScore(2, 3);

      expect(cubit.isBookUnlocked(3), isTrue);
      // In 4th game: Section 6 is unlocked, Section 7 is locked initially
      expect(cubit.isSectionUnlocked(6), isTrue);
      expect(cubit.isSectionUnlocked(7), isFalse);

      Object? pushedArguments;
      await tester.pumpWidget(
        BlocProvider<AlippeCubit>.value(
          value: cubit,
          child: MaterialApp(
            home: const AlippeBookScreen(bookId: 3),
            onGenerateRoute: (settings) {
              pushedArguments = settings.arguments;
              return MaterialPageRoute(
                builder: (_) => Scaffold(body: Text('Section: ${settings.arguments}')),
                settings: settings,
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Right page (Section 7) has a lock icon and grey filter
      expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
      expect(find.byType(ColorFiltered), findsOneWidget);

      // Section 7 is locked -> Calling its onPress should NOT navigate
      final section7Btn = tester.widget<AlippeAnimButton>(find.byKey(const Key('book_3_section_7')));
      section7Btn.onPress?.call();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(pushedArguments, isNull);

      // Section 6 is unlocked -> Calling its onPress navigates to Section 6
      final section6Btn = tester.widget<AlippeAnimButton>(find.byKey(const Key('book_3_section_6')));
      section6Btn.onPress?.call();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(pushedArguments, 6);

      // Pop back from pushed route
      final nav = tester.state<NavigatorState>(find.byType(Navigator));
      nav.pop();
      await tester.pumpAndSettle();

      // Complete Section 6
      await cubit.completeSection(6);
      await cubit.addScore(3, 1);
      expect(cubit.isSectionUnlocked(7), isTrue);
      // Book 4 is still locked (Book 3 only has 1 star)
      expect(cubit.isBookUnlocked(4), isFalse);

      // Re-pump Book 3 screen now that Section 6 is completed
      pushedArguments = null;
      await tester.pumpWidget(
        BlocProvider<AlippeCubit>.value(
          value: cubit,
          child: MaterialApp(
            home: const AlippeBookScreen(bookId: 3),
            onGenerateRoute: (settings) {
              pushedArguments = settings.arguments;
              return MaterialPageRoute(
                builder: (_) => Scaffold(body: Text('Section: ${settings.arguments}')),
                settings: settings,
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Lock icon is gone because Section 7 is now unlocked
      expect(find.byIcon(Icons.lock_rounded), findsNothing);

      // Section 7 is now unlocked -> Calling its onPress navigates to Section 7
      final section7UnlockedBtn = tester.widget<AlippeAnimButton>(find.byKey(const Key('book_3_section_7')));
      section7UnlockedBtn.onPress?.call();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(pushedArguments, 7);

      // Complete Section 7
      await cubit.completeSection(7);
      await cubit.addScore(3, 3);
      // Both sections completed -> Book 4 is now unlocked!
      expect(cubit.isBookUnlocked(4), isTrue);
    });

    testWidgets('Book 5 (Game 6: Эстутум оюну) has 2 sequential games: Level 1 on left, Level 2 on right locked until Level 1 completes', (tester) async {
      tester.view.physicalSize = const Size(800, 360);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final cubit = AlippeCubit();
      // Unlock up to Book 5 (complete books 0..4 with 3 stars)
      for (int i = 0; i <= 4; i++) {
        await cubit.addScore(i, 3);
      }
      expect(cubit.isBookUnlocked(5), isTrue);

      // Section 10 is unlocked, Section 12 is locked
      expect(cubit.isSectionUnlocked(10), isTrue);
      expect(cubit.isSectionUnlocked(12), isFalse);

      Object? pushedArguments;
      await tester.pumpWidget(
        BlocProvider<AlippeCubit>.value(
          value: cubit,
          child: MaterialApp(
            home: const AlippeBookScreen(bookId: 5),
            onGenerateRoute: (settings) {
              pushedArguments = settings.arguments;
              return MaterialPageRoute(
                builder: (_) => Scaffold(body: Text('Section: ${settings.arguments}')),
                settings: settings,
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Left page has Section 10 button (unlocked)
      expect(find.byKey(const Key('book_5_section_10')), findsOneWidget);
      // Right page has locked Section 12 with lock icon and grey filter
      expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
      expect(find.byType(ColorFiltered), findsOneWidget);

      // Section 12 is locked -> Calling its onPress should NOT navigate
      final section12LockedBtn = tester.widget<AlippeAnimButton>(find.byKey(const Key('book_5_section_12')));
      section12LockedBtn.onPress?.call();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(pushedArguments, isNull);

      // Tap Section 10 button -> navigates to Section 10
      final section10Btn = tester.widget<AlippeAnimButton>(find.byKey(const Key('book_5_section_10')));
      section10Btn.onPress?.call();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(pushedArguments, 10);

      // Pop back
      Navigator.of(tester.element(find.text('Section: 10'))).pop();
      await tester.pumpAndSettle();

      // Complete Section 10 (Level 1)
      await cubit.completeSection(10);
      await cubit.addScore(5, 1);
      expect(cubit.isSectionUnlocked(12), isTrue);
      // Book 6 is still locked (Book 5 only has 1 star)
      expect(cubit.isBookUnlocked(6), isFalse);

      // Re-pump Book 5 screen now that Section 10 is completed
      pushedArguments = null;
      await tester.pumpWidget(
        BlocProvider<AlippeCubit>.value(
          value: cubit,
          child: MaterialApp(
            home: const AlippeBookScreen(bookId: 5),
            onGenerateRoute: (settings) {
              pushedArguments = settings.arguments;
              return MaterialPageRoute(
                builder: (_) => Scaffold(body: Text('Section: ${settings.arguments}')),
                settings: settings,
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Lock icon is gone because Section 12 is now unlocked
      expect(find.byIcon(Icons.lock_rounded), findsNothing);
      expect(find.byKey(const Key('book_5_section_12')), findsOneWidget);

      // Tap Section 12 button
      final section12Btn = tester.widget<AlippeAnimButton>(find.byKey(const Key('book_5_section_12')));
      section12Btn.onPress?.call();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(pushedArguments, 12);

      // Complete Section 12 (Level 2)
      await cubit.completeSection(12);
      await cubit.addScore(5, 3);
      // Both sections completed -> Book 6 (Sound Quiz) is now unlocked!
      expect(cubit.isBookUnlocked(6), isTrue);
    });

    testWidgets('AlippeSectionScreen rejects direct entry to a locked section and pops back', (tester) async {
      tester.view.physicalSize = const Size(800, 360);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final cubit = AlippeCubit();
      // Section 1 is locked because section 0 has not been completed
      expect(cubit.isSectionUnlocked(1), isFalse);

      await tester.pumpWidget(
        BlocProvider<AlippeCubit>.value(
          value: cubit,
          child: MaterialApp(
            home: const Scaffold(body: Text('RootScreen')),
            routes: {
              '/section_test': (_) => const AlippeSectionScreen(sectionId: 1),
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to locked Section 1
      final navKey = tester.state<NavigatorState>(find.byType(Navigator));
      navKey.pushNamed('/section_test');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // Should have automatically popped back to RootScreen
      expect(find.text('RootScreen'), findsOneWidget);

      // Pump past notification dismiss timer
      await tester.pump(const Duration(seconds: 3));
    });
  });
}

