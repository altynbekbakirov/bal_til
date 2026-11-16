class SoundQuizOption {
  final String word;
  final String image;
  final bool isCorrect;

  const SoundQuizOption({
    required this.word,
    required this.image,
    required this.isCorrect,
  });
}

class SoundQuizQuestion {
  final String word;
  final String image;
  final String boySound;
  final String girlSound;
  final List<SoundQuizOption> options;

  const SoundQuizQuestion({
    required this.word,
    required this.image,
    required this.boySound,
    required this.girlSound,
    required this.options,
  });

  String getSound(bool isBoy) => isBoy ? boySound : girlSound;
}

class SoundQuizData {
  static const List<SoundQuizQuestion> questions = [
    // 1. Ат (Horse)
    SoundQuizQuestion(
      word: 'Ат',
      image: 'assets/alippe/images/books/book1/section1/1/pic1.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_at.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_at.mp3',
      options: [
        SoundQuizOption(
          word: 'Ат',
          image: 'assets/alippe/images/books/book1/section1/1/pic1.png',
          isCorrect: true,
        ),
        SoundQuizOption(
          word: 'Балык',
          image: 'assets/alippe/images/books/book1/section1/2/pic2.png',
          isCorrect: false,
        ),
        SoundQuizOption(
          word: 'Белек',
          image: 'assets/alippe/images/books/book1/section1/2/pic1.png',
          isCorrect: false,
        ),
        SoundQuizOption(
          word: 'Ай',
          image: 'assets/alippe/images/books/book1/section1/1/pic2.png',
          isCorrect: false,
        ),
      ],
    ),

    // 2. Балык (Fish)
    SoundQuizQuestion(
      word: 'Балык',
      image: 'assets/alippe/images/books/book1/section1/2/pic2.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_balyk.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_balyk.mp3',
      options: [
        SoundQuizOption(
          word: 'Балык',
          image: 'assets/alippe/images/books/book1/section1/2/pic2.png',
          isCorrect: true,
        ),
        SoundQuizOption(
          word: 'Үкү',
          image: 'assets/alippe/images/books/book1/section1/24/pic1.png',
          isCorrect: false,
        ),
        SoundQuizOption(
          word: 'Дарбыз',
          image: 'assets/alippe/images/books/book1/section1/5/pic1.png',
          isCorrect: false,
        ),
        SoundQuizOption(
          word: 'Гүл',
          image: 'assets/alippe/images/books/book1/section1/4/pic1.png',
          isCorrect: false,
        ),
      ],
    ),

    // 3. Үкү (Owl)
    SoundQuizQuestion(
      word: 'Үкү',
      image: 'assets/alippe/images/books/book1/section1/24/pic1.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_uku.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_uku.mp3',
      options: [
        SoundQuizOption(
          word: 'Үкү',
          image: 'assets/alippe/images/books/book1/section1/24/pic1.png',
          isCorrect: true,
        ),
        SoundQuizOption(
          word: 'Тоок',
          image: 'assets/alippe/images/books/book1/section1/22/pic2.png',
          isCorrect: false,
        ),
        SoundQuizOption(
          word: 'Пил',
          image: 'assets/alippe/images/books/book1/section1/19/pic1.png',
          isCorrect: false,
        ),
        SoundQuizOption(
          word: 'Маймыл',
          image: 'assets/alippe/images/books/book1/section1/14/pic1.png',
          isCorrect: false,
        ),
      ],
    ),

    // 4. Маймыл (Monkey)
    SoundQuizQuestion(
      word: 'Маймыл',
      image: 'assets/alippe/images/books/book1/section1/14/pic1.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_maymil.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_maymil.mp3',
      options: [
        SoundQuizOption(
          word: 'Маймыл',
          image: 'assets/alippe/images/books/book1/section1/14/pic1.png',
          isCorrect: true,
        ),
        SoundQuizOption(
          word: 'Аюу',
          image: 'assets/alippe/images/books/book1/section1/33/pic2.png',
          isCorrect: false,
        ),
        SoundQuizOption(
          word: 'Илбирс',
          image: 'assets/alippe/images/books/book1/section1/10/pic1.png',
          isCorrect: false,
        ),
        SoundQuizOption(
          word: 'Зебра',
          image: 'assets/alippe/images/books/book1/section1/9/pic1.png',
          isCorrect: false,
        ),
      ],
    ),

    // 5. Аюу (Bear)
    SoundQuizQuestion(
      word: 'Аюу',
      image: 'assets/alippe/images/books/book1/section1/33/pic2.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_ayu.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_ayu.mp3',
      options: [
        SoundQuizOption(
          word: 'Аюу',
          image: 'assets/alippe/images/books/book1/section1/33/pic2.png',
          isCorrect: true,
        ),
        SoundQuizOption(
          word: 'Уй',
          image: 'assets/alippe/images/books/book1/section1/23/pic1.png',
          isCorrect: false,
        ),
        SoundQuizOption(
          word: 'Эчки',
          image: 'assets/alippe/images/books/book1/section1/32/pic2.png',
          isCorrect: false,
        ),
        SoundQuizOption(
          word: 'Кой',
          image: 'assets/alippe/images/books/book1/section1/11/pic1.png',
          isCorrect: false,
        ),
      ],
    ),

    // 6. Пил (Elephant)
    SoundQuizQuestion(
      word: 'Пил',
      image: 'assets/alippe/images/books/book1/section1/19/pic1.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_pil.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_pil.mp3',
      options: [
        SoundQuizOption(
          word: 'Пил',
          image: 'assets/alippe/images/books/book1/section1/19/pic1.png',
          isCorrect: true,
        ),
        SoundQuizOption(
          word: 'Ракета',
          image: 'assets/alippe/images/books/book1/section1/20/pic1.png',
          isCorrect: false,
        ),
        SoundQuizOption(
          word: 'Машина',
          image: 'assets/alippe/images/books/book1/section1/14/pic2.png',
          isCorrect: false,
        ),
        SoundQuizOption(
          word: 'Учак',
          image: 'assets/alippe/images/books/book1/section1/23/pic2.png',
          isCorrect: false,
        ),
      ],
    ),

    // 7. Тоок (Chicken)
    SoundQuizQuestion(
      word: 'Тоок',
      image: 'assets/alippe/images/books/book1/section1/22/pic2.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_took.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_took.mp3',
      options: [
        SoundQuizOption(
          word: 'Тоок',
          image: 'assets/alippe/images/books/book1/section1/22/pic2.png',
          isCorrect: true,
        ),
        SoundQuizOption(
          word: 'Өрдөк',
          image: 'assets/alippe/images/books/book1/section1/18/pic1.png',
          isCorrect: false,
        ),
        SoundQuizOption(
          word: 'Чымчык',
          image: 'assets/alippe/images/books/book1/section1/28/pic2.png',
          isCorrect: false,
        ),
        SoundQuizOption(
          word: 'Жөжө',
          image: 'assets/alippe/images/books/book1/section1/8/pic2.png',
          isCorrect: false,
        ),
      ],
    ),

    // 8. Уй (Cow)
    SoundQuizQuestion(
      word: 'Уй',
      image: 'assets/alippe/images/books/book1/section1/23/pic1.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_uy.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_uy.mp3',
      options: [
        SoundQuizOption(
          word: 'Уй',
          image: 'assets/alippe/images/books/book1/section1/23/pic1.png',
          isCorrect: true,
        ),
        SoundQuizOption(
          word: 'Ат',
          image: 'assets/alippe/images/books/book1/section1/1/pic1.png',
          isCorrect: false,
        ),
        SoundQuizOption(
          word: 'Эчки',
          image: 'assets/alippe/images/books/book1/section1/32/pic2.png',
          isCorrect: false,
        ),
        SoundQuizOption(
          word: 'Балык',
          image: 'assets/alippe/images/books/book1/section1/2/pic2.png',
          isCorrect: false,
        ),
      ],
    ),

    // 9. Машина (Car)
    SoundQuizQuestion(
      word: 'Машина',
      image: 'assets/alippe/images/books/book1/section1/14/pic2.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_mashina.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_mashina.mp3',
      options: [
        SoundQuizOption(
          word: 'Машина',
          image: 'assets/alippe/images/books/book1/section1/14/pic2.png',
          isCorrect: true,
        ),
        SoundQuizOption(
          word: 'Велосипед',
          image: 'assets/alippe/images/books/book1/section1/3/pic1.png',
          isCorrect: false,
        ),
        SoundQuizOption(
          word: 'Мотоцикл',
          image: 'assets/alippe/images/books/book1/section1/27/pic2.png',
          isCorrect: false,
        ),
        SoundQuizOption(
          word: 'Ракета',
          image: 'assets/alippe/images/books/book1/section1/20/pic1.png',
          isCorrect: false,
        ),
      ],
    ),

    // 10. Учак (Airplane)
    SoundQuizQuestion(
      word: 'Учак',
      image: 'assets/alippe/images/books/book1/section1/23/pic2.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_uchak.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_uchak.mp3',
      options: [
        SoundQuizOption(
          word: 'Учак',
          image: 'assets/alippe/images/books/book1/section1/23/pic2.png',
          isCorrect: true,
        ),
        SoundQuizOption(
          word: 'Машина',
          image: 'assets/alippe/images/books/book1/section1/14/pic2.png',
          isCorrect: false,
        ),
        SoundQuizOption(
          word: 'Ракета',
          image: 'assets/alippe/images/books/book1/section1/20/pic1.png',
          isCorrect: false,
        ),
        SoundQuizOption(
          word: 'Велосипед',
          image: 'assets/alippe/images/books/book1/section1/3/pic1.png',
          isCorrect: false,
        ),
      ],
    ),

    // 11. Өрүк (Apricot)
    SoundQuizQuestion(
      word: 'Өрүк',
      image: 'assets/alippe/images/books/book1/section1/18/pic2.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_oruk.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_oruk.mp3',
      options: [
        SoundQuizOption(
          word: 'Өрүк',
          image: 'assets/alippe/images/books/book1/section1/18/pic2.png',
          isCorrect: true,
        ),
        SoundQuizOption(
          word: 'Дарбыз',
          image: 'assets/alippe/images/books/book1/section1/5/pic1.png',
          isCorrect: false,
        ),
        SoundQuizOption(
          word: 'Лимон',
          image: 'assets/alippe/images/books/book1/section1/13/pic1.png',
          isCorrect: false,
        ),
        SoundQuizOption(
          word: 'Коон',
          image: 'assets/alippe/images/books/book1/section1/12/pic1.png',
          isCorrect: false,
        ),
      ],
    ),

    // 12. Дарбыз (Watermelon)
    SoundQuizQuestion(
      word: 'Дарбыз',
      image: 'assets/alippe/images/books/book1/section1/5/pic1.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_darbyz.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_darbyz.mp3',
      options: [
        SoundQuizOption(
          word: 'Дарбыз',
          image: 'assets/alippe/images/books/book1/section1/5/pic1.png',
          isCorrect: true,
        ),
        SoundQuizOption(
          word: 'Өрүк',
          image: 'assets/alippe/images/books/book1/section1/18/pic2.png',
          isCorrect: false,
        ),
        SoundQuizOption(
          word: 'Нан',
          image: 'assets/alippe/images/books/book1/section1/15/pic1.png',
          isCorrect: false,
        ),
        SoundQuizOption(
          word: 'Жаңгак',
          image: 'assets/alippe/images/books/book1/section1/16/pic1.png',
          isCorrect: false,
        ),
      ],
    ),

    // 13. Гүл (Flower)
    SoundQuizQuestion(
      word: 'Гүл',
      image: 'assets/alippe/images/books/book1/section1/4/pic1.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_gul.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_gul.mp3',
      options: [
        SoundQuizOption(
          word: 'Гүл',
          image: 'assets/alippe/images/books/book1/section1/4/pic1.png',
          isCorrect: true,
        ),
        SoundQuizOption(
          word: 'Желек',
          image: 'assets/alippe/images/books/book1/section1/8/pic1.png',
          isCorrect: false,
        ),
        SoundQuizOption(
          word: 'Салют',
          image: 'assets/alippe/images/books/book1/section1/33/pic1.png',
          isCorrect: false,
        ),
        SoundQuizOption(
          word: 'Белек',
          image: 'assets/alippe/images/books/book1/section1/2/pic1.png',
          isCorrect: false,
        ),
      ],
    ),

    // 14. Саат (Clock)
    SoundQuizQuestion(
      word: 'Саат',
      image: 'assets/alippe/images/books/book1/section1/21/pic1.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_saat.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_saat.mp3',
      options: [
        SoundQuizOption(
          word: 'Саат',
          image: 'assets/alippe/images/books/book1/section1/21/pic1.png',
          isCorrect: true,
        ),
        SoundQuizOption(
          word: 'Лампочка',
          image: 'assets/alippe/images/books/book1/section1/13/pic2.png',
          isCorrect: false,
        ),
        SoundQuizOption(
          word: 'Карта',
          image: 'assets/alippe/images/books/book1/section1/20/pic2.png',
          isCorrect: false,
        ),
        SoundQuizOption(
          word: 'Топ',
          image: 'assets/alippe/images/books/book1/section1/19/pic2.png',
          isCorrect: false,
        ),
      ],
    ),

    // 15. Топ (Ball)
    SoundQuizQuestion(
      word: 'Топ',
      image: 'assets/alippe/images/books/book1/section1/19/pic2.png',
      boySound: 'assets/alippe/audio/alippe/boy/boy_top.mp3',
      girlSound: 'assets/alippe/audio/alippe/girl/g_top.mp3',
      options: [
        SoundQuizOption(
          word: 'Топ',
          image: 'assets/alippe/images/books/book1/section1/19/pic2.png',
          isCorrect: true,
        ),
        SoundQuizOption(
          word: 'Шахмат',
          image: 'assets/alippe/images/books/book1/section1/29/pic1.png',
          isCorrect: false,
        ),
        SoundQuizOption(
          word: 'Чана',
          image: 'assets/alippe/images/books/book1/section1/28/pic1.png',
          isCorrect: false,
        ),
        SoundQuizOption(
          word: 'Велосипед',
          image: 'assets/alippe/images/books/book1/section1/3/pic1.png',
          isCorrect: false,
        ),
      ],
    ),
  ];
}

