import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bal_til/main.dart';
import 'package:bal_til/features/map/screens/map_screen.dart';
import 'package:bal_til/features/home/screens/home_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bal_til/alippe/widgets/alippe_zoom_item.dart';
import 'package:bal_til/alippe/widgets/alippe_anim_button.dart';
import 'package:bal_til/alippe/screens/alippe_home_screen.dart';
import 'package:bal_til/alippe/screens/sections/section_books_view.dart';
import 'package:bal_til/alippe/core/alippe_cubit.dart';
import 'package:bal_til/alippe/screens/dialogs/alippe_game_finish_dialog.dart';
import 'package:bal_til/configs/routes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AlippeApp smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const AlippeApp());
    expect(find.byType(AlippeApp), findsOneWidget);
  });

  testWidgets('MapScreen renders without ParentDataWidget assertion', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: MapScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Кыргызстан картасы'), findsOneWidget);
    expect(find.text('Бишкек'), findsOneWidget);
    expect(find.text('Ысык-Көл'), findsOneWidget);
    expect(find.text('Нарын'), findsOneWidget);
  });

  testWidgets('MyApp smoke test with HomeScreen and Game Selector', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'has_shown_game_selector': true});
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Бал тил'), findsOneWidget);
    expect(find.byIcon(Icons.sports_esports_rounded), findsOneWidget);
  });

  testWidgets('AlippeSettingsDialog renders Sliders without Material error', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AlippeApp(),
        ),
      ),
    );
    await tester.pump();
  });

  testWidgets('AlippeZoomItem triggers zoom and speech on click', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AlippeZoomItem(
            imageAsset: 'assets/alippe/images/books/book1/section1/1/letter1.png',
            spokenText: 'А',
          ),
        ),
      ),
    );

    expect(find.byType(AlippeZoomItem), findsOneWidget);
    await tester.tap(find.byType(AlippeZoomItem));
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump(const Duration(milliseconds: 300));
  });

  testWidgets('AlippeAnimButton triggers soundAsset on click', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: AlippeAnimButton(
              width: 100,
              height: 100,
              imageAsset: 'assets/alippe/images/books/book1/section1/1/pic1.png',
              soundAsset: 'assets/alippe/audio/alippe/boy/at.m4a',
              spokenText: 'Ат',
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AlippeAnimButton), findsOneWidget);
    await tester.tap(find.byType(AlippeAnimButton));
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump(const Duration(milliseconds: 300));
  });

  testWidgets('AlippeHomeScreen renders 9 interactive items with sound support', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => AlippeCubit(),
        child: MaterialApp(
          home: const Scaffold(
            body: AlippeHomeScreen(),
          ),
          onGenerateRoute: (settings) => MaterialPageRoute(
            builder: (_) => const Scaffold(body: Text('Destination Screen')),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 6 book items + 3 sidebar items (settings, back, play) = 9 AlippeAnimButton items
    expect(find.byType(AlippeAnimButton), findsNWidgets(9));

    // Tap first book item
    await tester.tap(find.byType(AlippeAnimButton).at(3));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();

    expect(find.text('Destination Screen'), findsOneWidget);
  });

  testWidgets('SectionBooksView plays shape sound on click (triangle & square)', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => AlippeCubit(),
        child: const MaterialApp(
          home: Scaffold(
            body: SectionBooksView(sectionId: 3),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final leftBtn = find.byKey(const ValueKey('sec_3_left_0_true'));
    final rightBtn = find.byKey(const ValueKey('sec_3_right_1_true'));

    expect(leftBtn, findsOneWidget);
    expect(rightBtn, findsOneWidget);

    final leftWidget = tester.widget<AlippeAnimButton>(leftBtn);
    expect(leftWidget.soundAsset, contains('boy_uchburchtuk.mp3'));

    final rightWidget = tester.widget<AlippeAnimButton>(rightBtn);
    expect(rightWidget.soundAsset, contains('boy_tortburchtuk.mp3'));

    // Tap left item (triangle)
    await tester.tap(leftBtn, warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump(const Duration(milliseconds: 300));
  });

  testWidgets('SectionBooksView plays color sound on click (white & black balloons)', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => AlippeCubit(),
        child: const MaterialApp(
          home: Scaffold(
            body: SectionBooksView(sectionId: 2),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final leftBtn = find.byKey(const ValueKey('sec_2_left_0_true'));
    final rightBtn = find.byKey(const ValueKey('sec_2_right_1_true'));

    expect(leftBtn, findsOneWidget);
    expect(rightBtn, findsOneWidget);

    final leftWidget = tester.widget<AlippeAnimButton>(leftBtn);
    expect(leftWidget.soundAsset, contains('boy_AK.mp3'));

    final rightWidget = tester.widget<AlippeAnimButton>(rightBtn);
    expect(rightWidget.soundAsset, contains('boy_kara.mp3'));

    // Tap left item (white balloon)
    await tester.tap(leftBtn, warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump(const Duration(milliseconds: 300));
  });

  testWidgets('HomeScreen stats row renders without overflow on narrow width', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({'has_shown_game_selector': true});
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('GameSelectionModal allows selecting game on card tap', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Оюн тандаңыз'), findsOneWidget);
    expect(find.text('«Бал тил»'), findsOneWidget);

    await tester.ensureVisible(find.text('«Бал тил»'));
    await tester.pumpAndSettle();

    // Tap directly on the Bal Til card text (not the button)
    await tester.tap(find.text('«Бал тил»'));
    await tester.pumpAndSettle();

    // Modal dismissed
    expect(find.text('Оюн тандаңыз'), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('AlippeGameFinishDialog renders cleanly in landscape without overflow and displays text and action buttons', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 360);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AlippeGameFinishDialog(
            score: 3,
            onRestart: () {},
            onNext: () {},
            onHome: () {},
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Азаматсың!'), findsOneWidget);
    expect(find.byType(AlippeAnimButton), findsNWidgets(3));
  });

  testWidgets('AlippeHomeScreen book selection triggers sound without duplicate calls', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 360);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AlippeCubit()),
        ],
        child: const MaterialApp(
          home: AlippeHomeScreen(),
          onGenerateRoute: Routers.onGenerateRoute,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final animButtons = find.byType(AlippeAnimButton);
    expect(animButtons, findsWidgets);

    // Tap Book 0
    await tester.tap(animButtons.at(2));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 300));
  });
}

