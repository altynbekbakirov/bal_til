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

/// 5-этап: Сөз айкашы (эки сөздү бириктирүү: «суу бер», «апа кел», «кызыл алма»)
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
  // ================= 2-ЭТАП: ҮН ЧЫГАРУУ =================
  static const List<SoundItem> stage2Sounds = [
    SoundItem(
      title: 'Уй',
      soundText: 'Му-у-у!',
      image: 'assets/images/animals/1.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_U.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_U.mp3',
      description: 'Уй кандай үн чыгарат?',
      category: 'animal',
    ),
    SoundItem(
      title: 'Кой',
      soundText: 'Ме-е-е!',
      image: 'assets/images/animals/2.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_E.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_E.mp3',
      description: 'Кой кандай үн чыгарат?',
      category: 'animal',
    ),
    SoundItem(
      title: 'А тыбышы',
      soundText: 'А-а-а!',
      image: 'assets/alippe/images/books/book1/section1/1/pic1.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_A.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_A.mp3',
      description: 'Оозуңду чоң ачып, кайтала: А-а-а',
      category: 'vowel',
    ),
    SoundItem(
      title: 'О тыбышы',
      soundText: 'О-о-о!',
      image: 'assets/alippe/images/books/book1/section1/1/pic2.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_O.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_O.mp3',
      description: 'Оозуңду тегеректеп, кайтала: О-о-о',
      category: 'vowel',
    ),
    SoundItem(
      title: 'У тыбышы',
      soundText: 'У-у-у!',
      image: 'assets/alippe/images/books/book1/section1/2/pic1.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_U.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_U.mp3',
      description: 'Эриндерди алдыга созуп: У-у-у',
      category: 'vowel',
    ),
    SoundItem(
      title: 'Мышык',
      soundText: 'Мияу-мияу!',
      image: 'assets/alippe/images/books/book1/section1/2/pic2.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_M.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_M.mp3',
      description: 'Мышык кандай үн чыгарат?',
      category: 'animal',
    ),
    SoundItem(
      title: 'Ит',
      soundText: 'Ваф-ваф!',
      image: 'assets/alippe/images/books/book1/section1/3/pic1.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_I.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_I.mp3',
      description: 'Күчүк кандай үн чыгарат?',
      category: 'animal',
    ),
    SoundItem(
      title: 'Машина',
      soundText: 'Би-бип!',
      image: 'assets/alippe/images/books/book1/section1/3/pic2.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_B.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_B.mp3',
      description: 'Машинанын сигналы: Би-бип!',
      category: 'household',
    ),
  ];

  // ================= 3-ЭТАП: МУУН КАЙТАЛОО =================
  static const List<SyllableItem> stage3Syllables = [
    SyllableItem(
      syllable: 'МА',
      wordExample: 'Ма-ма',
      image: 'assets/alippe/images/books/book1/section1/1/pic1.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_M.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_M.mp3',
    ),
    SyllableItem(
      syllable: 'БА',
      wordExample: 'Ба-ла',
      image: 'assets/alippe/images/books/book1/section1/2/pic2.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_B.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_B.mp3',
    ),
    SyllableItem(
      syllable: 'ПА',
      wordExample: 'Па-па',
      image: 'assets/alippe/images/books/book1/section1/3/pic1.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_P.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_P.mp3',
    ),
    SyllableItem(
      syllable: 'ТА',
      wordExample: 'Та-як',
      image: 'assets/alippe/images/books/book1/section1/4/pic1.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_T.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_T.mp3',
    ),
    SyllableItem(
      syllable: 'ДА',
      wordExample: 'Да-рак',
      image: 'assets/alippe/images/books/book1/section1/5/pic1.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_D.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_D.mp3',
    ),
    SyllableItem(
      syllable: 'АЛ',
      wordExample: 'Ал-ма',
      image: 'assets/alippe/images/books/book1/section1/1/pic2.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_A.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_A.mp3',
    ),
    SyllableItem(
      syllable: 'АП',
      wordExample: 'Ап-пак',
      image: 'assets/alippe/images/books/book1/section1/2/pic1.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_A.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_A.mp3',
    ),
    SyllableItem(
      syllable: 'СУ',
      wordExample: 'Суу',
      image: 'assets/alippe/images/books/book1/section1/6/pic1.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_S.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_S.mp3',
    ),
  ];

  // ================= 4-ЭТАП: БИР СӨЗ АЙТУУ («СӨЗДҮ ТАП») =================
  static const List<WordGuessItem> stage4WordGuesses = [
    WordGuessItem(
      firstPart: 'Ал-',
      missingPart: 'ма',
      fullWord: 'Алма',
      image: 'assets/alippe/images/books/book1/section1/1/pic2.png',
      options: ['ма', 'та', 'ла'],
      boySound: 'assets/alippe/audio/alippe/boy/boy_at.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_at.mp3',
    ),
    WordGuessItem(
      firstPart: 'Ба-',
      missingPart: 'лык',
      fullWord: 'Балык',
      image: 'assets/alippe/images/books/book1/section1/2/pic2.png',
      options: ['лык', 'ла', 'ты'],
      boySound: 'assets/alippe/audio/alippe/boy/boy_balyk.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_balyk.mp3',
    ),
    WordGuessItem(
      firstPart: 'Бе-',
      missingPart: 'лек',
      fullWord: 'Белек',
      image: 'assets/alippe/images/books/book1/section1/2/pic1.png',
      options: ['лек', 'рик', 'тек'],
      boySound: 'assets/alippe/audio/alippe/boy/boy_belek.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_belek.mp3',
    ),
    WordGuessItem(
      firstPart: 'То-',
      missingPart: 'ок',
      fullWord: 'Тоок',
      image: 'assets/alippe/images/books/book1/section1/7/pic1.png',
      options: ['ок', 'ор', 'оз'],
      boySound: 'assets/alippe/audio/alippe/boy/boy_T.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_T.mp3',
    ),
    WordGuessItem(
      firstPart: 'Кү-',
      missingPart: 'чүк',
      fullWord: 'Күчүк',
      image: 'assets/alippe/images/books/book1/section1/3/pic1.png',
      options: ['чүк', 'лөк', 'нөк'],
      boySound: 'assets/alippe/audio/alippe/boy/boy_K.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_K.mp3',
    ),
    WordGuessItem(
      firstPart: 'Ки-',
      missingPart: 'теп',
      fullWord: 'Китеп',
      image: 'assets/alippe/images/books/book1/section1/4/pic2.png',
      options: ['теп', 'лем', 'рин'],
      boySound: 'assets/alippe/audio/alippe/boy/boy_K.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_K.mp3',
    ),
  ];

  // ================= 5-ЭТАП: СӨЗ АЙКАШЫ =================
  static const List<PhrasePairItem> stage5Phrases = [
    PhrasePairItem(
      word1: 'Суу',
      word2: 'бер',
      fullPhrase: 'Суу бер',
      image1: 'assets/alippe/images/books/book1/section1/6/pic1.png',
      image2: 'assets/alippe/images/books/book1/section1/1/pic1.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_S.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_S.mp3',
    ),
    PhrasePairItem(
      word1: 'Апа',
      word2: 'кел',
      fullPhrase: 'Апа кел',
      image1: 'assets/alippe/images/books/book1/section1/1/pic1.png',
      image2: 'assets/alippe/images/books/book1/section1/2/pic2.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_A.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_A.mp3',
    ),
    PhrasePairItem(
      word1: 'Кызыл',
      word2: 'алма',
      fullPhrase: 'Кызыл алма',
      image1: 'assets/alippe/images/books/book5/section2/colors_bg/red.png',
      image2: 'assets/alippe/images/books/book1/section1/1/pic2.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_K.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_K.mp3',
    ),
    PhrasePairItem(
      word1: 'Чоң',
      word2: 'топ',
      fullPhrase: 'Чоң топ',
      image1: 'assets/alippe/images/books/book1/section1/7/pic2.png',
      image2: 'assets/alippe/images/books/book1/section1/3/pic2.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_CH.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_CH.mp3',
    ),
    PhrasePairItem(
      word1: 'Нан',
      word2: 'же',
      fullPhrase: 'Нан же',
      image1: 'assets/alippe/images/books/book1/section1/5/pic2.png',
      image2: 'assets/alippe/images/books/book1/section1/2/pic1.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_N.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_N.mp3',
    ),
  ];

  // ================= 6-ЭТАП: ЖӨНӨКӨЙ СҮЙЛӨМДӨР =================
  static const List<SentenceItem> stage6Sentences = [
    SentenceItem(
      sentence: 'Мен суу ичем.',
      image: 'assets/alippe/images/books/book1/section1/6/pic1.png',
      situation: 'Суусаганда эмне дейбиз?',
      boySound: 'assets/alippe/audio/alippe/boy/boy_S.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_S.mp3',
    ),
    SentenceItem(
      sentence: 'Мага жардам бериңизчи.',
      image: 'assets/alippe/images/books/book1/section1/2/pic1.png',
      situation: 'Жардам сураганда кандай сылык айтабыз?',
      boySound: 'assets/alippe/audio/alippe/boy/boy_M.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_M.mp3',
    ),
    SentenceItem(
      sentence: 'Мен ойнойм!',
      image: 'assets/alippe/images/books/book1/section1/3/pic2.png',
      situation: 'Оюнчуктар менен ойногубуз келгенде:',
      boySound: 'assets/alippe/audio/alippe/boy/boy_O.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_O.mp3',
    ),
    SentenceItem(
      sentence: 'Апамды жакшы көрөм.',
      image: 'assets/alippe/images/books/book1/section1/1/pic1.png',
      situation: 'Үй-бүлөбүзгө жылуу сөз айтабыз:',
      boySound: 'assets/alippe/audio/alippe/boy/boy_A.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_A.mp3',
    ),
  ];

  // ================= СҮРӨТТҮҮ БАЙЛАНЫШ ТАКТАСЫ (PECS) =================
  static const List<PecsCardItem> pecsCards = [
    PecsCardItem(
      id: 'suu',
      label: 'Суу',
      image: 'assets/alippe/images/books/book1/section1/6/pic1.png',
      category: 'need',
      speechText: 'Суу',
    ),
    PecsCardItem(
      id: 'tamak',
      label: 'Тамак',
      image: 'assets/alippe/images/books/book1/section1/5/pic2.png',
      category: 'need',
      speechText: 'Тамак',
    ),
    PecsCardItem(
      id: 'jardam',
      label: 'Жардам',
      image: 'assets/alippe/images/books/book1/section1/2/pic1.png',
      category: 'need',
      speechText: 'Жардам',
    ),
    PecsCardItem(
      id: 'ber',
      label: 'Бер',
      image: 'assets/alippe/images/books/book1/section1/1/pic1.png',
      category: 'action',
      speechText: 'Бер',
    ),
    PecsCardItem(
      id: 'oyno',
      label: 'Ойно',
      image: 'assets/alippe/images/books/book1/section1/3/pic2.png',
      category: 'action',
      speechText: 'Ойно',
    ),
    PecsCardItem(
      id: 'ukta',
      label: 'Уйку',
      image: 'assets/alippe/images/books/book1/section1/4/pic1.png',
      category: 'need',
      speechText: 'Уйку',
    ),
    PecsCardItem(
      id: 'dagi',
      label: 'Дагы',
      image: 'assets/alippe/images/books/book1/section1/7/pic2.png',
      category: 'feeling',
      speechText: 'Дагы',
    ),
    PecsCardItem(
      id: 'boldu',
      label: 'Болду',
      image: 'assets/alippe/images/books/book1/section1/7/pic1.png',
      category: 'feeling',
      speechText: 'Болду',
    ),
    PecsCardItem(
      id: 'kel',
      label: 'Кел',
      image: 'assets/alippe/images/books/book1/section1/2/pic2.png',
      category: 'action',
      speechText: 'Кел',
    ),
    PecsCardItem(
      id: 'kaalaym',
      label: 'Каалайм',
      image: 'assets/alippe/images/books/book1/section1/1/pic2.png',
      category: 'feeling',
      speechText: 'Каалайм',
    ),
  ];
}
