import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bal_til/alippe/core/alippe_audio.dart';
import 'package:bal_til/alippe/core/alippe_cubit.dart';
import 'package:bal_til/alippe/data/speech_development_data.dart';
import 'package:bal_til/alippe/screens/sections/section13_view.dart';
import 'package:bal_til/alippe/screens/sections/section14_view.dart';
import 'package:bal_til/alippe/screens/sections/section15_view.dart';
import 'package:bal_til/alippe/screens/sections/section16_view.dart';
import 'package:bal_til/alippe/screens/sections/section17_view.dart';
import 'package:bal_til/core/services/common_services.dart';

Widget _wrapWithApp(Widget child, AlippeCubit cubit) {
  return BlocProvider<AlippeCubit>.value(
    value: cubit,
    child: MaterialApp(
      home: child,
    ),
  );
}

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

  group('Speech Development Data Tests', () {
    test('Stage 2 to 6 data structures are populated and valid', () {
      expect(SpeechDevelopmentData.stage2Sounds, isNotEmpty);
      expect(SpeechDevelopmentData.stage3Syllables, isNotEmpty);
      expect(SpeechDevelopmentData.stage4WordGuesses, isNotEmpty);
      expect(SpeechDevelopmentData.stage5Phrases, isNotEmpty);
      expect(SpeechDevelopmentData.stage6Sentences, isNotEmpty);
      expect(SpeechDevelopmentData.pecsCards, isNotEmpty);

      // Verify boy and girl sounds exist for sample item
      final s2 = SpeechDevelopmentData.stage2Sounds.first;
      expect(s2.getSound(true), isNotEmpty);
      expect(s2.getSound(false), isNotEmpty);
    });
  });

  group('Stage 2 (Section13View - Sound Production)', () {
    testWidgets('Renders sound item and responds to repeat button', (tester) async {
      tester.view.physicalSize = const Size(800, 480);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final cubit = AlippeCubit();
      await tester.pumpWidget(_wrapWithApp(const Section13View(), cubit));
      await tester.pumpAndSettle();

      expect(find.textContaining('Үн чыгаруу: 1/'), findsOneWidget);
      expect(find.byKey(const Key('repeat_done_button')), findsOneWidget);

      await tester.tap(find.byKey(const Key('repeat_done_button')));
      await tester.pump();
      expect(find.textContaining('Азамат!'), findsOneWidget);
    });
  });

  group('Stage 3 (Section14View - Syllable Repetition)', () {
    testWidgets('Renders syllable card and handles repetition bubbles', (tester) async {
      tester.view.physicalSize = const Size(800, 480);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final cubit = AlippeCubit();
      await tester.pumpWidget(_wrapWithApp(const Section14View(), cubit));
      await tester.pumpAndSettle();

      expect(find.textContaining('Муун кайталоо: 1/'), findsOneWidget);
      expect(find.byKey(const Key('syllable_repeat_button')), findsOneWidget);

      await tester.tap(find.byKey(const Key('syllable_repeat_button')));
      await tester.pumpAndSettle();
      expect(find.text('Дагы бир жолу!'), findsOneWidget);
    });
  });

  group('Stage 4 (Section15View - Word Completion)', () {
    testWidgets('Renders puzzle and allows picking options', (tester) async {
      tester.view.physicalSize = const Size(800, 480);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final cubit = AlippeCubit();
      await tester.pumpWidget(_wrapWithApp(const Section15View(), cubit));
      await tester.pumpAndSettle();

      expect(find.textContaining('Сөздү тап: 1/'), findsOneWidget);

      // Tap correct option for first word ("Ба-" -> "лык")
      final correctOptKey = Key('word_guess_opt_${SpeechDevelopmentData.stage4WordGuesses.first.missingPart}');
      expect(find.byKey(correctOptKey), findsOneWidget);

      await tester.tap(find.byKey(correctOptKey));
      await tester.pump();
      expect(find.textContaining('= Балык!'), findsOneWidget);
    });
  });

  group('Stage 5 (Section16View - Phrase Pairing)', () {
    testWidgets('Renders two cards and combines them into a phrase', (tester) async {
      tester.view.physicalSize = const Size(800, 480);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final cubit = AlippeCubit();
      await tester.pumpWidget(_wrapWithApp(const Section16View(), cubit));
      await tester.pumpAndSettle();

      expect(find.textContaining('Сөз айкашы: 1/'), findsOneWidget);
      expect(find.byKey(const Key('combine_words_button')), findsOneWidget);

      await tester.tap(find.byKey(const Key('combine_words_button')));
      await tester.pump();
      expect(find.text('«Суу бер»'), findsOneWidget);
    });
  });

  group('Stage 6 (Section17View - Sentences & PECS Board)', () {
    testWidgets('Switches between sentences tab and PECS board tab', (tester) async {
      tester.view.physicalSize = const Size(800, 480);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final cubit = AlippeCubit();
      await tester.pumpWidget(_wrapWithApp(const Section17View(), cubit));
      await tester.pumpAndSettle();

      // Sentences tab
      expect(find.textContaining('Сүйлөм: 1/'), findsOneWidget);
      expect(find.byKey(const Key('sentence_listen_button')), findsOneWidget);

      // Switch to PECS tab
      await tester.tap(find.text('2. Сүрөттүү байланыш тактасы (PECS)'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('pecs_card_suu')), findsOneWidget);
      expect(find.byKey(const Key('pecs_card_ber')), findsOneWidget);

      // Tap cards
      await tester.tap(find.byKey(const Key('pecs_card_suu')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('pecs_card_ber')));
      await tester.pumpAndSettle();

      // Speak button should be enabled
      expect(find.byKey(const Key('pecs_speak_button')), findsOneWidget);
      await tester.tap(find.byKey(const Key('pecs_speak_button')));
      await tester.pump();

      // Clear button
      await tester.tap(find.byKey(const Key('pecs_clear_button')));
      await tester.pumpAndSettle();
      expect(find.text('Карточкаларды басып, каалооңду айт...'), findsOneWidget);
    });
  });
}
