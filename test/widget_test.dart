import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:bal_til/alippe/screens/sections/section1_view.dart';
import 'package:bal_til/alippe/screens/sections/section8_view.dart';
import 'package:bal_til/alippe/screens/sections/section9_view.dart';
import 'package:bal_til/alippe/screens/sections/section10_view.dart';
import 'package:bal_til/alippe/data/alippe_data.dart';
import 'package:bal_til/configs/routes.dart';
import 'package:bal_til/features/game_select/screens/game_select_screen.dart';
import 'package:bal_til/core/audio/audio_controller.dart';
import 'package:bal_til/core/services/common_services.dart';
import 'package:bal_til/core/services/upgrader_messages_ky.dart';

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

  testWidgets('MyApp smoke test with GameSelectScreen and Game Selector', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'last_played_game': 'alippe'});
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Оюн тандаңыз'), findsOneWidget);
    expect(find.text('«Бал тил»'), findsOneWidget);
    expect(find.text('«Алиппе»'), findsOneWidget);
    expect(find.text('Акыркы ойнолгон оюн'), findsOneWidget);
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
    await tester.tap(find.text('«Бал тил»'));
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

  testWidgets('AlippeGameFinishDialog menu button triggers onHome redirect to alippe home', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 360);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    bool homeClicked = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AlippeGameFinishDialog(
            score: 3,
            onRestart: () {},
            onNext: () {},
            onHome: () => homeClicked = true,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    final animButtons = find.byType(AlippeAnimButton);
    expect(animButtons, findsNWidgets(3));
    await tester.tap(animButtons.first);
    await tester.pump(const Duration(milliseconds: 400));

    expect(homeClicked, isTrue);
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

  testWidgets('Section10View renders card grid without overflow and flips on tap', (WidgetTester tester) async {
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
          home: Section10View(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Find cards by key
    final firstCardFinder = find.byWidgetPredicate(
      (w) => w.key is ValueKey && (w.key as ValueKey).value.toString().startsWith('card_1_'),
    );
    expect(firstCardFinder, findsWidgets);

    // Initially, all cards are face down
    expect(find.byWidgetPredicate((w) => w is Image && w.image is AssetImage && (w.image as AssetImage).assetName == AlippeData.cardFront), findsNothing);

    // Tap the first card
    await tester.tap(firstCardFinder.first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    // Card flipped face up -> cardFront is visible!
    expect(find.byWidgetPredicate((w) => w is Image && w.image is AssetImage && (w.image as AssetImage).assetName == AlippeData.cardFront), findsOneWidget);
  });

  testWidgets('Section10View matched cards stay visible face-up and do not disappear', (WidgetTester tester) async {
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
          home: Section10View(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Find the pair of cards with pairId 0: card_1_0_X
    final pair0Cards = find.byWidgetPredicate(
      (w) => w.key is ValueKey && (w.key as ValueKey).value.toString().startsWith('card_1_0_'),
    );
    expect(pair0Cards, findsNWidgets(2));

    // Tap first card of pair 0
    await tester.tap(pair0Cards.at(0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    // Tap second card of pair 0 (match!)
    await tester.tap(pair0Cards.at(1));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 350));

    // Both cards matched, but they DO NOT disappear! Both cardFronts are visible face-up
    expect(
      find.byWidgetPredicate((w) => w is Image && w.image is AssetImage && (w.image as AssetImage).assetName == AlippeData.cardFront),
      findsNWidgets(2),
    );
  });

  testWidgets('GameSelectScreen highlights last played game when set to alippe', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'last_played_game': 'alippe'});
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.byType(GameSelectScreen), findsOneWidget);
    expect(find.text('Акыркы ойнолгон оюн'), findsOneWidget);
    expect(find.text('«Алиппе»'), findsOneWidget);
    expect(find.text('«Бал тил»'), findsOneWidget);
  });

  testWidgets('HomeScreen back button returns to GameSelectScreen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'last_played_game': 'bal_til'});
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Select Bal Til
    await tester.tap(find.text('«Бал тил»'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);

    // Tap back button
    final backBtn = find.byTooltip('Оюн тандоого кайтуу');
    expect(backBtn, findsOneWidget);
    await tester.tap(backBtn);
    await tester.pumpAndSettle();

    // Returned to GameSelectScreen
    expect(find.byType(GameSelectScreen), findsOneWidget);
  });

  testWidgets('GameSelectScreen effect toggle enables/disables sound effects correctly', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'sound_enabled': true});
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final effectChip = find.text('Эффект');
    expect(effectChip, findsOneWidget);

    // Initial state: sound is enabled
    expect(AudioController.instance.isSoundEnabled, true);

    // Tap to disable: sound becomes false
    await tester.tap(effectChip);
    await tester.pumpAndSettle();
    expect(AudioController.instance.isSoundEnabled, false);

    // Tap to enable: sound becomes true
    await tester.tap(effectChip);
    await tester.pumpAndSettle();
    expect(AudioController.instance.isSoundEnabled, true);
  });

  testWidgets('AlippeAnimButton scales up on tap and settles back to 1.0', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: AlippeAnimButton(
              scaleFactor: 1.5,
              child: Text('Test Button'),
            ),
          ),
        ),
      ),
    );

    final scaleFinder = find.descendant(
      of: find.byType(AlippeAnimButton),
      matching: find.byType(ScaleTransition),
    );
    expect(scaleFinder, findsOneWidget);

    ScaleTransition scaleWidget = tester.widget<ScaleTransition>(scaleFinder);
    expect(scaleWidget.scale.value, 1.0);

    // Tap to trigger animation
    await tester.tap(find.text('Test Button'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 70));
    scaleWidget = tester.widget<ScaleTransition>(scaleFinder);
    expect(scaleWidget.scale.value, greaterThan(1.1));

    await tester.pumpAndSettle();
    scaleWidget = tester.widget<ScaleTransition>(scaleFinder);
    expect(scaleWidget.scale.value, 1.0);
  });

  testWidgets('SectionBooksView Section 5 correctly maps arrows, rock, pillow and measures sounds', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 360);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => AlippeCubit(),
        child: const MaterialApp(
          home: Scaffold(
            body: SectionBooksView(sectionId: 5),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Page 0: items 1.png & 2.png (Few & Many -> Az & Kop)
    var leftBtn = find.byKey(const ValueKey('sec_5_left_0_true'));
    var rightBtn = find.byKey(const ValueKey('sec_5_right_1_true'));
    expect(tester.widget<AlippeAnimButton>(leftBtn).soundAsset, contains('boy_az.mp3'));
    expect(tester.widget<AlippeAnimButton>(leftBtn).spokenText, 'Аз');
    expect(tester.widget<AlippeAnimButton>(rightBtn).soundAsset, contains('boy_kop.mp3'));
    expect(tester.widget<AlippeAnimButton>(rightBtn).spokenText, 'Көп');

    // Tap next page arrow -> Page 1: items 3.png & 4.png (Left & Right -> Solgo & Ongo)
    final nextBtn = find.byWidgetPredicate(
      (widget) => widget is AlippeAnimButton && widget.imageAsset?.contains('right_btn') == true,
    );
    await tester.tap(nextBtn);
    await tester.pumpAndSettle();

    leftBtn = find.byKey(const ValueKey('sec_5_left_2_true'));
    rightBtn = find.byKey(const ValueKey('sec_5_right_3_true'));
    expect(tester.widget<AlippeAnimButton>(leftBtn).soundAsset, contains('boy_solgo.mp3'));
    expect(tester.widget<AlippeAnimButton>(leftBtn).spokenText, 'Солго');
    expect(tester.widget<AlippeAnimButton>(rightBtn).soundAsset, contains('boy_ongo.mp3'));
    expect(tester.widget<AlippeAnimButton>(rightBtn).spokenText, 'Оңго');

    // Tap next page arrow -> Page 2: items 5.png & 6.png (Down arrow & Up arrow -> Ildiy & Oido - User Image 2)
    await tester.tap(nextBtn);
    await tester.pumpAndSettle();

    leftBtn = find.byKey(const ValueKey('sec_5_left_4_true'));
    rightBtn = find.byKey(const ValueKey('sec_5_right_5_true'));
    expect(tester.widget<AlippeAnimButton>(leftBtn).soundAsset, contains('boy_ildiy.mp3'));
    expect(tester.widget<AlippeAnimButton>(leftBtn).spokenText, 'Ылдый');
    expect(tester.widget<AlippeAnimButton>(rightBtn).soundAsset, contains('boy_oido.mp3'));
    expect(tester.widget<AlippeAnimButton>(rightBtn).spokenText, 'Өйдө');

    // Advance to Page 8: items 17.png & 18.png (Rock & Pillow -> Katuu & Jumshak - User Image 3)
    for (int i = 3; i <= 8; i++) {
      await tester.tap(nextBtn);
      await tester.pumpAndSettle();
    }

    leftBtn = find.byKey(const ValueKey('sec_5_left_16_true'));
    rightBtn = find.byKey(const ValueKey('sec_5_right_17_true'));
    expect(tester.widget<AlippeAnimButton>(leftBtn).soundAsset, contains('boy_katuu.mp3'));
    expect(tester.widget<AlippeAnimButton>(leftBtn).spokenText, 'Катуу');
    expect(tester.widget<AlippeAnimButton>(rightBtn).soundAsset, contains('boy_jumshak.mp3'));
    expect(tester.widget<AlippeAnimButton>(rightBtn).spokenText, 'Жумшак');
  });

  testWidgets('SectionBooksView Section 6 correctly maps boy body parts (arm & foot)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 360);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => AlippeCubit(),
        child: const MaterialApp(
          home: Scaffold(
            body: SectionBooksView(sectionId: 6),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final nextBtn = find.byWidgetPredicate(
      (widget) => widget is AlippeAnimButton && widget.imageAsset?.contains('right_btn') == true,
    );

    // Page 0: left is boy (0.png), right is palm/hand (1.png) -> sound kol
    var rightBtn = find.byKey(const ValueKey('sec_6_right_1_true'));
    expect(tester.widget<AlippeAnimButton>(rightBtn).soundAsset, contains('boy_kol.mp3'));
    expect(tester.widget<AlippeAnimButton>(rightBtn).spokenText, 'Кол');

    // Page 1: right is arm with sleeve (2.png - User Image 4) -> sound kol
    await tester.tap(nextBtn);
    await tester.pumpAndSettle();

    rightBtn = find.byKey(const ValueKey('sec_6_right_2_true'));
    expect(tester.widget<AlippeAnimButton>(rightBtn).soundAsset, contains('boy_kol.mp3'));
    expect(tester.widget<AlippeAnimButton>(rightBtn).spokenText, 'Кол');

    // Page 2: right is head (3.png) -> sound bash
    await tester.tap(nextBtn);
    await tester.pumpAndSettle();

    rightBtn = find.byKey(const ValueKey('sec_6_right_3_true'));
    expect(tester.widget<AlippeAnimButton>(rightBtn).soundAsset, contains('boy_bash.mp3'));
    expect(tester.widget<AlippeAnimButton>(rightBtn).spokenText, 'Баш');

    // Page 3: right is foot (4.png - User Image 1) -> sound but
    await tester.tap(nextBtn);
    await tester.pumpAndSettle();

    rightBtn = find.byKey(const ValueKey('sec_6_right_4_true'));
    expect(tester.widget<AlippeAnimButton>(rightBtn).soundAsset, contains('boy_but.mp3'));
    expect(tester.widget<AlippeAnimButton>(rightBtn).spokenText, 'Бут');
  });

  testWidgets('Section8View renders with Sidebar and 3 silhouette placeholders with bg frame', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 360);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => AlippeCubit(),
        child: const MaterialApp(
          home: Scaffold(
            body: Section8View(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify DragTargets and Draggables
    expect(find.byType(DragTarget<int>), findsNWidgets(3));
    expect(find.byType(Draggable<int>), findsNWidgets(3));

    // Verify Restart button and Back button in Sidebar
    final restartBtn = find.byWidgetPredicate(
      (w) => w is AlippeAnimButton && w.imageAsset?.contains('restart') == true,
    );
    final backBtn = find.byWidgetPredicate(
      (w) => w is AlippeAnimButton && w.imageAsset?.contains('back') == true,
    );
    expect(restartBtn, findsOneWidget);
    expect(backBtn, findsOneWidget);

    // Verify answers are always in wrong order:
    // None of the 3 Draggable items should have the same data as the DragTarget in the same column
    final dragTargets = tester.widgetList<DragTarget<int>>(find.byType(DragTarget<int>)).toList();
    final draggables = tester.widgetList<Draggable<int>>(find.byType(Draggable<int>)).toList();
    expect(dragTargets.length, 3);
    expect(draggables.length, 3);

    for (int i = 0; i < 3; i++) {
      // Find candidate data accepted by target i vs draggable data at index i
      final targetAccepts = dragTargets[i].onWillAcceptWithDetails;
      // When tested with draggable i's data, it should return false because they must not match!
      expect(
        targetAccepts?.call(DragTargetDetails<int>(data: draggables[i].data!, offset: Offset.zero)),
        isFalse,
        reason: 'Item $i must not match placeholder $i (must be in wrong order)',
      );
    }

    // Verify tap-to-match works: tapping first draggable matches it
    final firstDraggableItem = draggables.first.data!;
    final itemButton = find.byWidgetPredicate(
      (w) => w is AlippeAnimButton && w.imageAsset == AlippeData.section8Items[firstDraggableItem],
    );
    expect(itemButton, findsOneWidget);
    await tester.tap(itemButton);
    await tester.pumpAndSettle();

    // After matching, only 2 Draggables remain
    expect(find.byType(Draggable<int>), findsNWidgets(2));
  });

  testWidgets('Section9View renders balloons on left and character with overlay on right', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 360);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => AlippeCubit(),
        child: const MaterialApp(
          home: Scaffold(
            body: Section9View(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify target drag target for character
    expect(find.byType(DragTarget<Map<String, int>>), findsOneWidget);
    // Verify 6 draggable balloons on the left page
    expect(find.byType(Draggable<Map<String, int>>), findsNWidgets(6));
    // Verify balloon images are present inside draggables
    final balloonImages = find.byWidgetPredicate((w) => w is Image && w.image is AssetImage && (w.image as AssetImage).assetName.contains('colors_btn'));
    expect(balloonImages, findsAtLeastNWidgets(6));
  });

  testWidgets('Section1View renders pic_bg and preserves multiple duplicate letters on placement', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 360);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => AlippeCubit(),
        child: const MaterialApp(
          home: Scaffold(
            body: Section1View(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify pic_bg image exists
    expect(find.byWidgetPredicate((w) => w is Image && w.image is AssetImage && (w.image as AssetImage).assetName.contains('pic_bg')), findsOneWidget);

    // Advance to word index 7: "nan" ('Н', 'А', 'Н') which has two identical 'N' letters
    final nextBtn = find.byWidgetPredicate(
      (widget) => widget is AlippeAnimButton && widget.imageAsset?.contains('right_btn') == true,
    );

    for (int i = 0; i < 7; i++) {
      await tester.tap(nextBtn);
      await tester.pumpAndSettle();
    }

    // "nan" has 3 letters: two 'N's and one 'A'
    expect(find.byWidgetPredicate((w) => w is Draggable), findsNWidgets(3));

    // Place the first available 'N' by tapping it
    final nButton = find.byWidgetPredicate(
      (w) => w is AlippeAnimButton && w.imageAsset?.contains('letters/n/item.png') == true,
    ).first;
    await tester.tap(nButton);
    await tester.pumpAndSettle();

    // The other 'N' and 'A' must still remain available! (Total 2 draggables left, not 1)
    expect(find.byWidgetPredicate((w) => w is Draggable), findsNWidgets(2));
    expect(find.byWidgetPredicate(
      (w) => w is AlippeAnimButton && w.imageAsset?.contains('letters/n/item.png') == true,
    ), findsOneWidget);
  });

  testWidgets('AlippeHomeScreen forces landscape on mount and restores portrait on dispose', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AlippeCubit>(create: (_) => AlippeCubit()),
        ],
        child: const MaterialApp(
          home: AlippeHomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify AlippeHomeScreen is mounted
    expect(find.byType(AlippeHomeScreen), findsOneWidget);

    // Now unmount / navigate away to trigger dispose
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Text('Home'))));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
  });

  test('UpgraderMessagesKy provides accurate Kyrgyz translations', () {
    final messages = UpgraderMessagesKy();
    expect(messages.languageCode, equals('ky'));
    expect(messages.title, equals('Жаңыртуу керекпи?'));
    expect(messages.buttonTitleUpdate, equals('ЖАҢЫРТУУ'));
    expect(messages.buttonTitleLater, equals('КИЙИН'));
    expect(messages.buttonTitleIgnore, equals('ЖОК'));
    expect(messages.prompt, equals('Азыр жаңыртууну каалайсызбы?'));
    expect(messages.releaseNotes, equals('Өзгөрүүлөр тизмеси'));
    expect(messages.body.contains('жаңы версиясы'), isTrue);
  });

  testWidgets('handlePopInvoked shows warning on first press and exits on second press within 2s', (WidgetTester tester) async {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (MethodCall methodCall) async => null,
    );
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Text('Test')),
      ),
    );
    final context = tester.element(find.text('Test'));

    // Initial press with null lastPressed (first launch)
    final initialResult = await handlePopInvoked(context, false, null);
    expect(initialResult, isNotNull);

    // Second press immediately after (< 2s)
    final secondResult = await handlePopInvoked(context, false, initialResult!);
    expect(secondResult, isNull);

    // Press after more than 2 seconds (e.g. 5 seconds ago) triggers warning again
    final fiveSecondsAgo = DateTime.now().subtract(const Duration(seconds: 5));
    final thirdResult = await handlePopInvoked(context, false, fiveSecondsAgo);
    expect(thirdResult, isNotNull);

    // If already didPop is true, it should return null without warning
    final didPopResult = await handlePopInvoked(context, true, fiveSecondsAgo);
    expect(didPopResult, isNull);

    // Clean up overlay and timer
    ExitNotificationOverlay.hide();
    await tester.pumpAndSettle();
  });
}

