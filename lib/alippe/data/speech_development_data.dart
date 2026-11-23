import '../core/alippe_cubit.dart';

/// 2-этап: Үн чыгаруу (Үндүү тыбыштар, жаныбарлардын үндөрү жана жөнөкөй үндөр)
class SoundItem {
  final String title;
  final String soundText;
  final String image;
  final String boySound;
  final String girlSound;
  final String description;
  final String category; // 'vowel', 'animal', 'household'

  const SoundItem({
    required this.title,
    required this.soundText,
    required this.image,
    required this.boySound,
    required this.girlSound,
    required this.description,
    required this.category,
  });

  String getSound(bool isBoy) => isBoy ? boySound : girlSound;
}

/// 3-этап: Муун кайталоо (ма, ба, па, та, да, ал, ап жеңил муундар)
class SyllableItem {
  final String syllable;
  final String wordExample;
  final String image;
  final String boySound;
  final String girlSound;

  const SyllableItem({
    required this.syllable,
    required this.wordExample,
    required this.image,
    required this.boySound,
    required this.girlSound,
  });

  String getSound(bool isBoy) => isBoy ? boySound : girlSound;
}

/// 4-этап: Бир сөз айтуу («Сөздү тап» — биринчи муун айтылат, бала калганын табат)
class WordGuessItem {
  final String firstPart;
  final String missingPart;
  final String fullWord;
  final String image;
  final List<String> options;
  final String boySound;
  final String girlSound;

  const WordGuessItem({
    required this.firstPart,
    required this.missingPart,
    required this.fullWord,
    required this.image,
    required this.options,
    required this.boySound,
    required this.girlSound,
  });

  String getSound(bool isBoy) => isBoy ? boySound : girlSound;
}

/// 5-этап: Сөз айкашы (эки сөздү бириктирүү: «суу бер», «кызыл гүл», «чоң топ»)
class PhrasePairItem {
  final String word1;
  final String word2;
  final String fullPhrase;
  final String image1;
  final String image2;
  final String boySound;
  final String girlSound;

  const PhrasePairItem({
    required this.word1,
    required this.word2,
    required this.fullPhrase,
    required this.image1,
    required this.image2,
    required this.boySound,
    required this.girlSound,
  });

  String getSound(bool isBoy) => isBoy ? boySound : girlSound;
}

/// 6-этап: Жөнөкөй сүйлөм жана Сүрөттүү байланыш тактасы (PECS)
class SentenceItem {
  final String sentence;
  final String image;
  final String situation;
  final String boySound;
  final String girlSound;

  const SentenceItem({
    required this.sentence,
    required this.image,
    required this.situation,
    required this.boySound,
    required this.girlSound,
  });

  String getSound(bool isBoy) => isBoy ? boySound : girlSound;
}

class PecsCardItem {
  final String id;
  final String label;
  final String image;
  final String category; // 'need', 'action', 'feeling', 'people'
  final String speechText;

  const PecsCardItem({
    required this.id,
    required this.label,
    required this.image,
    required this.category,
    required this.speechText,
  });
}

class SpeechDevelopmentData {
  // ================= 2-ЭТАП: ҮН ЧЫГАРУУ (8-ОЮН) =================
  static const List<SoundItem> stage2Sounds = [
    SoundItem(
      title: 'Уй',
      soundText: 'Му-у-у!',
      image: 'assets/alippe/images/books/book1/section1/23/pic1.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_uy.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_uy.mp3',
      description: 'Уй кандай үн чыгарат?',
      category: 'animal',
    ),
    SoundItem(
      title: 'Кой',
      soundText: 'Ме-е-е!',
      image: 'assets/alippe/images/books/book1/section1/11/pic1.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_koy.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_koy.mp3',
      description: 'Кой кандай үн чыгарат?',
      category: 'animal',
    ),
    SoundItem(
      title: 'Ат',
      soundText: 'И-го-го!',
      image: 'assets/alippe/images/books/book1/section1/1/pic1.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_at.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_at.mp3',
      description: 'Ат кандай үн чыгарат?',
      category: 'animal',
    ),
    SoundItem(
      title: 'Балык',
      soundText: 'Булп-булп!',
      image: 'assets/alippe/images/books/book1/section1/2/pic2.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_balyk.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_balyk.mp3',
      description: 'Балык сууда сүзөт: Булп-булп!',
      category: 'animal',
    ),
    SoundItem(
      title: 'Тоок',
      soundText: 'Ко-ко-ко!',
      image: 'assets/alippe/images/books/book1/section1/22/pic2.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_took.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_took.mp3',
      description: 'Тоок кандай үн чыгарат?',
      category: 'animal',
    ),
    SoundItem(
      title: 'Өрдөк',
      soundText: 'Бак-бак!',
      image: 'assets/alippe/images/books/book1/section1/18/pic1.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_ordok.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_ordok.mp3',
      description: 'Өрдөк кандай үн чыгарат?',
      category: 'animal',
    ),
    SoundItem(
      title: 'Жөжө',
      soundText: 'Пи-пи-пи!',
      image: 'assets/alippe/images/books/book1/section1/8/pic2.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_jojo.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_jojo.mp3',
      description: 'Жөжө кандай үн чыгарат?',
      category: 'animal',
    ),
    SoundItem(
      title: 'Машина',
      soundText: 'Би-бип!',
      image: 'assets/alippe/images/books/book1/section1/14/pic2.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_mashina.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_mashina.mp3',
      description: 'Машинанын сигналы: Би-бип!',
      category: 'household',
    ),
    SoundItem(
      title: 'А тыбышы',
      soundText: 'А-а-а!',
      image: 'assets/alippe/images/books/book1/section1/1/letter1.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_A.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_A.mp3',
      description: 'Оозуңду чоң ачып, кайтала: А-а-а',
      category: 'vowel',
    ),
    SoundItem(
      title: 'О тыбышы',
      soundText: 'О-о-о!',
      image: 'assets/alippe/images/books/book1/section1/17/letter1.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_O.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_O.mp3',
      description: 'Оозуңду тегеректеп, кайтала: О-о-о',
      category: 'vowel',
    ),
    SoundItem(
      title: 'У тыбышы',
      soundText: 'У-у-у!',
      image: 'assets/alippe/images/books/book1/section1/23/letter1.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_U.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_U.mp3',
      description: 'Эриндерди алдыга созуп: У-у-у',
      category: 'vowel',
    ),
  ];

  // ================= 3-ЭТАП: МУУН КАЙТАЛОО (9-ОЮН) =================
  static const List<SyllableItem> stage3Syllables = [
    SyllableItem(
      syllable: 'БА',
      wordExample: 'Ба-лык',
      image: 'assets/alippe/images/books/book1/section1/2/pic2.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_balyk.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_balyk.mp3',
    ),
    SyllableItem(
      syllable: 'АТ',
      wordExample: 'Ат',
      image: 'assets/alippe/images/books/book1/section1/1/pic1.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_at.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_at.mp3',
    ),
    SyllableItem(
      syllable: 'ТО',
      wordExample: 'То-ок',
      image: 'assets/alippe/images/books/book1/section1/22/pic2.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_took.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_took.mp3',
    ),
    SyllableItem(
      syllable: 'МА',
      wordExample: 'Ма-ши-на',
      image: 'assets/alippe/images/books/book1/section1/14/pic2.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_mashina.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_mashina.mp3',
    ),
    SyllableItem(
      syllable: 'БЕ',
      wordExample: 'Бе-лек',
      image: 'assets/alippe/images/books/book1/section1/2/pic1.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_belek.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_belek.mp3',
    ),
    SyllableItem(
      syllable: 'ДА',
      wordExample: 'Дар-быз',
      image: 'assets/alippe/images/books/book1/section1/5/pic1.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_darbyz.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_darbyz.mp3',
    ),
    SyllableItem(
      syllable: 'ҮК',
      wordExample: 'Ү-кү',
      image: 'assets/alippe/images/books/book1/section1/24/pic1.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_uku.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_uku.mp3',
    ),
    SyllableItem(
      syllable: 'СА',
      wordExample: 'Са-ат',
      image: 'assets/alippe/images/books/book1/section1/21/pic1.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_saat.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_saat.mp3',
    ),
  ];

  // ================= 4-ЭТАП: БИР СӨЗ АЙТУУ («СӨЗДҮ ТАП» - 10-ОЮН) =================
  static const List<WordGuessItem> stage4WordGuesses = [
    WordGuessItem(
      firstPart: 'Ба',
      missingPart: 'лык',
      fullWord: 'Балык',
      image: 'assets/alippe/images/books/book1/section1/2/pic2.png',
      options: ['лык', 'та', 'ра'],
      boySound: 'assets/alippe/audio/alippe/boy/boy_balyk.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_balyk.mp3',
    ),
    WordGuessItem(
      firstPart: 'Бе',
      missingPart: 'лек',
      fullWord: 'Белек',
      image: 'assets/alippe/images/books/book1/section1/2/pic1.png',
      options: ['лек', 'рик', 'тек'],
      boySound: 'assets/alippe/audio/alippe/boy/boy_belek.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_belek.mp3',
    ),
    WordGuessItem(
      firstPart: 'Дар',
      missingPart: 'быз',
      fullWord: 'Дарбыз',
      image: 'assets/alippe/images/books/book1/section1/5/pic1.png',
      options: ['быз', 'сык', 'мак'],
      boySound: 'assets/alippe/audio/alippe/boy/boy_darbyz.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_darbyz.mp3',
    ),
    WordGuessItem(
      firstPart: 'То',
      missingPart: 'ок',
      fullWord: 'Тоок',
      image: 'assets/alippe/images/books/book1/section1/22/pic2.png',
      options: ['ок', 'ор', 'оз'],
      boySound: 'assets/alippe/audio/alippe/boy/boy_took.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_took.mp3',
    ),
    WordGuessItem(
      firstPart: 'Ко',
      missingPart: 'ён',
      fullWord: 'Коён',
      image: 'assets/alippe/images/books/book1/section1/7/pic2.png',
      options: ['ён', 'он', 'юн'],
      boySound: 'assets/alippe/audio/alippe/boy/boy_koyon.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_koyon.mp3',
    ),
    WordGuessItem(
      firstPart: 'Ү',
      missingPart: 'кү',
      fullWord: 'Үкү',
      image: 'assets/alippe/images/books/book1/section1/24/pic1.png',
      options: ['кү', 'тү', 'рү'],
      boySound: 'assets/alippe/audio/alippe/boy/boy_uku.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_uku.mp3',
    ),
    WordGuessItem(
      firstPart: 'Са',
      missingPart: 'ат',
      fullWord: 'Саат',
      image: 'assets/alippe/images/books/book1/section1/21/pic1.png',
      options: ['ат', 'бы', 'ры'],
      boySound: 'assets/alippe/audio/alippe/boy/boy_saat.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_saat.mp3',
    ),
    WordGuessItem(
      firstPart: 'Ко',
      missingPart: 'он',
      fullWord: 'Коон',
      image: 'assets/alippe/images/books/book1/section1/12/pic1.png',
      options: ['он', 'ор', 'оз'],
      boySound: 'assets/alippe/audio/alippe/boy/boy_koon.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_koon.mp3',
    ),
    WordGuessItem(
      firstPart: 'Жө',
      missingPart: 'жө',
      fullWord: 'Жөжө',
      image: 'assets/alippe/images/books/book1/section1/8/pic2.png',
      options: ['жө', 'лө', 'бө'],
      boySound: 'assets/alippe/audio/alippe/boy/boy_jojo.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_jojo.mp3',
    ),
    WordGuessItem(
      firstPart: 'Өр',
      missingPart: 'дөк',
      fullWord: 'Өрдөк',
      image: 'assets/alippe/images/books/book1/section1/18/pic1.png',
      options: ['дөк', 'бөк', 'төк'],
      boySound: 'assets/alippe/audio/alippe/boy/boy_ordok.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_ordok.mp3',
    ),
  ];

  // ================= 5-ЭТАП: СӨЗ АЙКАШЫ (11-ОЮН) =================
  static const List<PhrasePairItem> stage5Phrases = [
    PhrasePairItem(
      word1: 'Суу',
      word2: 'бер',
      fullPhrase: 'Суу бер',
      image1: 'assets/images/map/lake_cropped.png',
      image2: 'assets/alippe/images/books/book4/section1/items/1.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_S.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_S.mp3',
    ),
    PhrasePairItem(
      word1: 'Кызыл',
      word2: 'гүл',
      fullPhrase: 'Кызыл гүл',
      image1: 'assets/alippe/images/books/book5/section2/colors_bg/red.png',
      image2: 'assets/alippe/images/books/book1/section1/4/pic1.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_gul.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_gul.mp3',
    ),
    PhrasePairItem(
      word1: 'Чоң',
      word2: 'топ',
      fullPhrase: 'Чоң топ',
      image1: 'assets/alippe/images/books/book1/section1/19/letter1.png',
      image2: 'assets/alippe/images/books/book1/section1/19/pic2.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_top.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_top.mp3',
    ),
    PhrasePairItem(
      word1: 'Көк',
      word2: 'машина',
      fullPhrase: 'Көк машина',
      image1: 'assets/alippe/images/books/book5/section2/colors_bg/blue.png',
      image2: 'assets/alippe/images/books/book1/section1/14/pic2.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_mashina.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_mashina.mp3',
    ),
    PhrasePairItem(
      word1: 'Нан',
      word2: 'же',
      fullPhrase: 'Нан же',
      image1: 'assets/alippe/images/books/book1/section1/15/pic1.png',
      image2: 'assets/alippe/images/books/book4/section1/items/1.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_nan.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_nan.mp3',
    ),
    PhrasePairItem(
      word1: 'Белек',
      word2: 'ал',
      fullPhrase: 'Белек ал',
      image1: 'assets/alippe/images/books/book1/section1/2/pic1.png',
      image2: 'assets/alippe/images/books/book4/section1/items/1.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_belek.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_belek.mp3',
    ),
  ];

  // ================= 6-ЭТАП: ЖӨНӨКӨЙ СҮЙЛӨМДӨР (12-ОЮН) =================
  static const List<SentenceItem> stage6Sentences = [
    SentenceItem(
      sentence: 'Мен суу ичем.',
      image: 'assets/images/map/lake_cropped.png',
      situation: 'Суусаганда эмне дейбиз?',
      boySound: 'assets/alippe/audio/alippe/boy/boy_S.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_S.mp3',
    ),
    SentenceItem(
      sentence: 'Машина тез жүрөт.',
      image: 'assets/alippe/images/books/book1/section1/14/pic2.png',
      situation: 'Машина жөнүндө айтабыз:',
      boySound: 'assets/alippe/audio/alippe/boy/boy_mashina.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_mashina.mp3',
    ),
    SentenceItem(
      sentence: 'Бул таттуу дарбыз.',
      image: 'assets/alippe/images/books/book1/section1/5/pic1.png',
      situation: 'Дарбыздын даамы кандай?',
      boySound: 'assets/alippe/audio/alippe/boy/boy_darbyz.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_darbyz.mp3',
    ),
    SentenceItem(
      sentence: 'Ат чуркап баратат.',
      image: 'assets/alippe/images/books/book1/section1/1/pic1.png',
      situation: 'Жаныбарды сүрөттөйбүз:',
      boySound: 'assets/alippe/audio/alippe/boy/boy_at.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_at.mp3',
    ),
    SentenceItem(
      sentence: 'Балык сууда сүзөт.',
      image: 'assets/alippe/images/books/book1/section1/2/pic2.png',
      situation: 'Балык кайда жүрөт?',
      boySound: 'assets/alippe/audio/alippe/boy/boy_balyk.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_balyk.mp3',
    ),
    SentenceItem(
      sentence: 'Мага белек беришти.',
      image: 'assets/alippe/images/books/book1/section1/2/pic1.png',
      situation: 'Белек алганда эмне дейбиз?',
      boySound: 'assets/alippe/audio/alippe/boy/boy_belek.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_belek.mp3',
    ),
  ];

  // ================= СҮРӨТТҮҮ БАЙЛАНЫШ ТАКТАСЫ (PECS) =================
  static const List<PecsCardItem> pecsCards = [
    PecsCardItem(
      id: 'suu',
      label: 'Суу',
      image: 'assets/images/map/lake_cropped.png',
      category: 'need',
      speechText: 'Суу',
    ),
    PecsCardItem(
      id: 'ber',
      label: 'Бер',
      image: 'assets/alippe/images/books/book4/section1/items/1.png',
      category: 'action',
      speechText: 'Бер',
    ),
    PecsCardItem(
      id: 'tamak',
      label: 'Нан',
      image: 'assets/alippe/images/books/book1/section1/15/pic1.png',
      category: 'need',
      speechText: 'Нан',
    ),
    PecsCardItem(
      id: 'top',
      label: 'Топ',
      image: 'assets/alippe/images/books/book1/section1/19/pic2.png',
      category: 'action',
      speechText: 'Топ',
    ),
    PecsCardItem(
      id: 'mashina',
      label: 'Машина',
      image: 'assets/alippe/images/books/book1/section1/14/pic2.png',
      category: 'action',
      speechText: 'Машина',
    ),
    PecsCardItem(
      id: 'belek',
      label: 'Белек',
      image: 'assets/alippe/images/books/book1/section1/2/pic1.png',
      category: 'need',
      speechText: 'Белек',
    ),
    PecsCardItem(
      id: 'balyk',
      label: 'Балык',
      image: 'assets/alippe/images/books/book1/section1/2/pic2.png',
      category: 'need',
      speechText: 'Балык',
    ),
    PecsCardItem(
      id: 'darbyz',
      label: 'Дарбыз',
      image: 'assets/alippe/images/books/book1/section1/5/pic1.png',
      category: 'need',
      speechText: 'Дарбыз',
    ),
    PecsCardItem(
      id: 'at',
      label: 'Ат',
      image: 'assets/alippe/images/books/book1/section1/1/pic1.png',
      category: 'need',
      speechText: 'Ат',
    ),
    PecsCardItem(
      id: 'took',
      label: 'Тоок',
      image: 'assets/alippe/images/books/book1/section1/22/pic2.png',
      category: 'need',
      speechText: 'Тоок',
    ),
  ];
}
