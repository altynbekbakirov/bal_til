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

      // Verify human syllable prompt sounds exist for all Stage 4 items and prompt is 1-2 letters
      for (final wg in SpeechDevelopmentData.stage4WordGuesses) {
        expect(wg.firstPart.length, lessThanOrEqualTo(2),
            reason: '${wg.firstPart} must be at most 2 letters');
        expect(wg.getPromptSound(true), isNotNull);
        expect(wg.getPromptSound(true)!, endsWith('.mp3'));
        expect(wg.getPromptSound(false), isNotNull);
        expect(wg.getPromptSound(false)!, endsWith('.mp3'));
      }

      // Verify human syllable sounds exist for all Stage 3 items and syllable is 2 letters
      for (final syl in SpeechDevelopmentData.stage3Syllables) {
        expect(syl.syllable.length, equals(2),
            reason: '${syl.syllable} must be 2 letters');
        expect(syl.getSound(true), endsWith('.mp3'));
        expect(syl.getSound(false), endsWith('.mp3'));
      }

      // Verify original sounds exist for all Stage 5 phrase items
      for (final p in SpeechDevelopmentData.stage5Phrases) {
        expect(p.getWord1Sound(true), endsWith('.mp3'));
        expect(p.getWord1Sound(false), endsWith('.mp3'));
        expect(p.getWord2Sound(true), endsWith('.mp3'));
        expect(p.getWord2Sound(false), endsWith('.mp3'));
        expect(p.getSound(true), endsWith('.mp3'));
        expect(p.getSound(false), endsWith('.mp3'));
      }
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
    test('WordGuessItem options have right answers distributed across positions', () {
      final firstPositions = SpeechDevelopmentData.stage4WordGuesses
          .where((item) => item.options.first == item.missingPart)
          .length;
      // Right answer is not always in the first position across all 10 items
      expect(firstPositions, lessThan(SpeechDevelopmentData.stage4WordGuesses.length));
    });

    testWidgets('Renders puzzle, handles wrong tap, and advances on correct option', (tester) async {
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

      final firstItem = SpeechDevelopmentData.stage4WordGuesses.first;
      final wrongOption = firstItem.options.firstWhere((opt) => opt != firstItem.missingPart);
      final wrongKey = Key('word_guess_opt_$wrongOption');
      final correctOptKey = Key('word_guess_opt_${firstItem.missingPart}');

      // Tap wrong option first
      await tester.tap(find.byKey(wrongKey));
      await tester.pumpAndSettle();

      // Wrong button is now disabled (onPressed is null)
      final ElevatedButton wrongButton = tester.widget(find.byKey(wrongKey));
      expect(wrongButton.onPressed, isNull);

      // Now tap correct option ("Ба-" -> "лык")
      expect(find.byKey(correctOptKey), findsOneWidget);
      await tester.tap(find.byKey(correctOptKey));
      await tester.pump();
      expect(find.textContaining('= Балык!'), findsOneWidget);

      // Advance to Question 2 after transition timer
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pumpAndSettle();
      expect(find.textContaining('Сөздү тап: 2/'), findsOneWidget);
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
      expect(find.byKey(const Key('section16_word1_card')), findsOneWidget);
      expect(find.byKey(const Key('section16_word2_card')), findsOneWidget);
      expect(find.byKey(const Key('combine_words_button')), findsOneWidget);

      // Verify enlarged card size (at least twice the size of original 160x160 cards)
      final card1Size = tester.getSize(find.byKey(const Key('section16_word1_card')));
      expect(card1Size.width, greaterThanOrEqualTo(240.0));
      expect(card1Size.height, greaterThanOrEqualTo(240.0));
      expect(card1Size.width * card1Size.height, greaterThanOrEqualTo(2 * (160.0 * 160.0)),
          reason: 'Item area must be at least twice as large as original 160x160 card');

      // Tap word 1 card
      await tester.tap(find.byKey(const Key('section16_word1_card')));
      await tester.pump();

      // Tap word 2 card
      await tester.tap(find.byKey(const Key('section16_word2_card')));
      await tester.pump();

      // Tap combine words button
      await tester.tap(find.byKey(const Key('combine_words_button')));
      await tester.pump();
      expect(find.text('«Кызыл гүл»'), findsOneWidget);
      expect(find.byKey(const Key('section16_phrase_banner')), findsOneWidget);

      // Tap phrase banner to replay sound
      await tester.tap(find.byKey(const Key('section16_phrase_banner')));
      await tester.pump();
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
