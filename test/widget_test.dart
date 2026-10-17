import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bal_til/main.dart';
import 'package:bal_til/features/map/screens/map_screen.dart';

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
}
