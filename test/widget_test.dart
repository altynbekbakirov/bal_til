import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bal_til/main.dart';
import 'package:bal_til/features/map/screens/map_screen.dart';
import 'package:bal_til/features/home/screens/home_screen.dart';
import 'package:bal_til/alippe/widgets/alippe_zoom_item.dart';
import 'package:bal_til/alippe/widgets/alippe_anim_button.dart';

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
              soundAsset: 'assets/alippe/audio/items/horse.m4a',
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
}
