import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bal_til/main.dart';
import 'package:bal_til/features/map/screens/map_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(find.text('Бал тил'), findsOneWidget);
  });

  testWidgets('MapScreen renders without ParentDataWidget assertion', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: MapScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Кыргызстан картасы'), findsOneWidget);
    expect(find.text('Бишкек'), findsOneWidget);
    expect(find.text('Ысык-Көл'), findsOneWidget);
    expect(find.text('Нарын'), findsOneWidget);
  });
}
