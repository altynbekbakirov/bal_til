import '../core/alippe_constants.dart';

enum BookTheme { orange, red, blue }

class AlippeBookModel {
  final int bookId;
  final String icon;
  final BookTheme theme;
  final int section1Id;
  final int? section2Id;
  final String title;

  const AlippeBookModel({
    required this.bookId,
    required this.icon,
    required this.theme,
    required this.section1Id,
    this.section2Id,
    required this.title,
  });

  String get bgImage {
    switch (theme) {
      case BookTheme.orange:
        return AlippeAssets.bookOrangeBg;
      case BookTheme.red:
        return AlippeAssets.bookRedBg;
      case BookTheme.blue:
        return AlippeAssets.bookBlueBg;
    }
  }

  String get leftBtn {
    switch (theme) {
      case BookTheme.orange:
        return AlippeAssets.bookOrangeLeft;
      case BookTheme.red:
        return AlippeAssets.bookRedLeft;
      case BookTheme.blue:
        return AlippeAssets.bookBlueLeft;
    }
  }

  String get rightBtn {
    switch (theme) {
      case BookTheme.orange:
        return AlippeAssets.bookOrangeRight;
      case BookTheme.red:
        return AlippeAssets.bookRedRight;
      case BookTheme.blue:
        return AlippeAssets.bookBlueRight;
    }
  }

  String get leftBtnNoArr {
    switch (theme) {
      case BookTheme.orange:
        return AlippeAssets.bookOrangeLeftNoArr;
      case BookTheme.red:
        return AlippeAssets.bookRedLeftNoArr;
      case BookTheme.blue:
        return AlippeAssets.bookBlueLeftNoArr;
    }
  }

  String get rightBtnNoArr {
    switch (theme) {
      case BookTheme.orange:
        return AlippeAssets.bookOrangeRightNoArr;
      case BookTheme.red:
        return AlippeAssets.bookRedRightNoArr;
      case BookTheme.blue:
        return AlippeAssets.bookBlueRightNoArr;
    }
  }
}

class LetterItem {
  final String key;
  final String pic1;
  final String pic2;
  final String pic3;
  final String pic4;
  final String letter;
  final String word1;
  final String word2;

  const LetterItem({
    required this.key,
    required this.pic1,
    required this.pic2,
    required this.pic3,
    required this.pic4,
    required this.letter,
    required this.word1,
    required this.word2,
  });
}

class SpellingLetter {
  final String key;
  final String placeholder;
  final String item;

  const SpellingLetter({
    required this.key,
    required this.placeholder,
    required this.item,
  });
}

class SpellingWord {
  final String pic;
  final String word;
  final List<SpellingLetter> letters;

  const SpellingWord({
    required this.pic,
    required this.word,
    required this.letters,
  });
}

class AlippeData {
  static const List<AlippeBookModel> books = [
    AlippeBookModel(
      bookId: 0,
      icon: 'assets/alippe/images/books/book1/icon.png',
      theme: BookTheme.orange,
      section1Id: 0,
      section2Id: 1,
      title: 'Ариптер жана Сөздөр',
    ),
    AlippeBookModel(
      bookId: 1,
      icon: 'assets/alippe/images/books/book2/icon.png',
      theme: BookTheme.red,
      section1Id: 2,
      section2Id: 3,
      title: 'Таанышуу',
    ),
    AlippeBookModel(
      bookId: 2,
      icon: 'assets/alippe/images/books/book3/icon.png',
      theme: BookTheme.blue,
      section1Id: 4,
      section2Id: 5,
      title: 'Билим дүйнөсү',
    ),
    AlippeBookModel(
      bookId: 3,
      icon: 'assets/alippe/images/books/book4/icon.png',
      theme: BookTheme.orange,
      section1Id: 6,
      section2Id: 7,
      title: 'Кызыктуу көнүгүүлөр',
    ),
    AlippeBookModel(
      bookId: 4,
      icon: 'assets/alippe/images/books/book5/icon.png',
      theme: BookTheme.red,
      section1Id: 8,
      section2Id: 9,
      title: 'Шайкештик жана Түстөр',
    ),
    AlippeBookModel(
      bookId: 5,
      icon: 'assets/alippe/images/books/book6/icon.png',
      theme: BookTheme.blue,
      section1Id: 10,
      section2Id: null,
      title: 'Эстутум оюну',
    ),
  ];

  static String getSectionIcon(int sectionId) {
    switch (sectionId) {
      case 0:
        return 'assets/alippe/images/books/book1/section1/icon.png';
      case 1:
        return 'assets/alippe/images/books/book1/section2/icon.png';
      case 2:
        return 'assets/alippe/images/books/book2/section1/icon.png';
      case 3:
        return 'assets/alippe/images/books/book2/section2/icon.png';
      case 4:
        return 'assets/alippe/images/books/book3/section1/icon.png';
      case 5:
        return 'assets/alippe/images/books/book3/section2/icon.png';
      case 6:
        return 'assets/alippe/images/books/book4/section1/icon.png';
      case 7:
        return 'assets/alippe/images/books/book4/section2/icon.png';
      case 8:
        return 'assets/alippe/images/books/book5/section1/icon.png';
      case 9:
        return 'assets/alippe/images/books/book5/section2/icon.png';
      case 10:
        return 'assets/alippe/images/books/book6/section1/icon.png';
      default:
        return 'assets/alippe/images/books/book1/icon.png';
    }
  }

  static final List<({String letter, String word1, String word2})> _section0LetterDetails = [
    (letter: 'А', word1: 'Ат', word2: 'Ай'),
    (letter: 'Б', word1: 'Бант', word2: 'Балык'),
    (letter: 'В', word1: 'Велосипед', word2: 'Вилка'),
    (letter: 'Г', word1: 'Гүл', word2: 'Гитара'),
    (letter: 'Д', word1: 'Дарбыз', word2: 'Дарак'),
    (letter: 'Е', word1: 'Енот', word2: 'Ель'),
    (letter: 'Ё', word1: 'Ёлка', word2: 'Ёж'),
    (letter: 'Ж', word1: 'Жылкы', word2: 'Жылдыз'),
    (letter: 'З', word1: 'Зебра', word2: 'Зонтик'),
    (letter: 'И', word1: 'Ит', word2: 'Ийне'),
    (letter: 'Й', word1: 'Йогурт', word2: 'Йод'),
    (letter: 'К', word1: 'Көпөлөк', word2: 'Китеп'),
    (letter: 'Л', word1: 'Лимон', word2: 'Лампочка'),
    (letter: 'М', word1: 'Машина', word2: 'Мышык'),
    (letter: 'Н', word1: 'Нан', word2: 'Нокот'),
    (letter: 'Ң', word1: 'Коңгуроо', word2: 'Торпоң'),
    (letter: 'О', word1: 'Орок', word2: 'Оюнчук'),
    (letter: 'Ө', word1: 'Өрдөк', word2: 'Өрүк'),
    (letter: 'П', word1: 'Пил', word2: 'Поезд'),
    (letter: 'Р', word1: 'Ракета', word2: 'Радио'),
    (letter: 'С', word1: 'Саат', word2: 'Сабиз'),
    (letter: 'Т', word1: 'Төө', word2: 'Топ'),
    (letter: 'У', word1: 'Улак', word2: 'Учак'),
    (letter: 'Ү', word1: 'Үй', word2: 'Үтүк'),
    (letter: 'Ф', word1: 'Флаг', word2: 'Футбол'),
    (letter: 'Х', word1: 'Халат', word2: 'Хлеб'),
    (letter: 'Ц', word1: 'Цирк', word2: 'Цветок'),
    (letter: 'Ч', word1: 'Чака', word2: 'Чөйчөк'),
    (letter: 'Ш', word1: 'Шахмат', word2: 'Шыпыргы'),
    (letter: 'Щ', word1: 'Щетка', word2: 'Щит'),
    (letter: 'Ъ', word1: 'Ажыратуу белгиси', word2: 'Ажыратуу белгиси'),
    (letter: 'Ы', word1: 'Ымыркай', word2: 'Ышкын'),
    (letter: 'Ь', word1: 'Ичкертүү белгиси', word2: 'Ичкертүү белгиси'),
    (letter: 'Э', word1: 'Эчки', word2: 'Элик'),
    (letter: 'Ю', word1: 'Юбка', word2: 'Юрта'),
    (letter: 'Я', word1: 'Яблоко', word2: 'Якорь'),
  ];

  // Section 0: 36 alphabet letter items
  static List<LetterItem> get section0Items {
    return List.generate(36, (index) {
      final folder = index + 1;
      final info = _section0LetterDetails[index];
      return LetterItem(
        key: 'letter_$folder',
        pic1: 'assets/alippe/images/books/book1/section1/$folder/letter1.png',
        pic2: 'assets/alippe/images/books/book1/section1/$folder/letter2.png',
        pic3: 'assets/alippe/images/books/book1/section1/$folder/pic1.png',
        pic4: 'assets/alippe/images/books/book1/section1/$folder/pic2.png',
        letter: info.letter,
        word1: info.word1,
        word2: info.word2,
      );
    });
  }

  // Section 1: Alphabet tiles
  static const Map<String, SpellingLetter> alphabetLetters = {
    'a': SpellingLetter(
      key: 'a',
      placeholder: 'assets/alippe/images/books/book1/section2/items/letters/a/placeholder.png',
      item: 'assets/alippe/images/books/book1/section2/items/letters/a/item.png',
    ),
    'g': SpellingLetter(
      key: 'g',
      placeholder: 'assets/alippe/images/books/book1/section2/items/letters/g/placeholder.png',
      item: 'assets/alippe/images/books/book1/section2/items/letters/g/item.png',
    ),
    'i': SpellingLetter(
      key: 'i',
      placeholder: 'assets/alippe/images/books/book1/section2/items/letters/i/placeholder.png',
      item: 'assets/alippe/images/books/book1/section2/items/letters/i/item.png',
    ),
    'yi': SpellingLetter(
      key: 'yi',
      placeholder: 'assets/alippe/images/books/book1/section2/items/letters/yi/placeholder.png',
      item: 'assets/alippe/images/books/book1/section2/items/letters/yi/item.png',
    ),
    'k': SpellingLetter(
      key: 'k',
      placeholder: 'assets/alippe/images/books/book1/section2/items/letters/k/placeholder.png',
      item: 'assets/alippe/images/books/book1/section2/items/letters/k/item.png',
    ),
    'l': SpellingLetter(
      key: 'l',
      placeholder: 'assets/alippe/images/books/book1/section2/items/letters/l/placeholder.png',
      item: 'assets/alippe/images/books/book1/section2/items/letters/l/item.png',
    ),
    'm': SpellingLetter(
      key: 'm',
      placeholder: 'assets/alippe/images/books/book1/section2/items/letters/m/placeholder.png',
      item: 'assets/alippe/images/books/book1/section2/items/letters/m/item.png',
    ),
    'n': SpellingLetter(
      key: 'n',
      placeholder: 'assets/alippe/images/books/book1/section2/items/letters/n/placeholder.png',
      item: 'assets/alippe/images/books/book1/section2/items/letters/n/item.png',
    ),
    'o': SpellingLetter(
      key: 'o',
      placeholder: 'assets/alippe/images/books/book1/section2/items/letters/o/placeholder.png',
      item: 'assets/alippe/images/books/book1/section2/items/letters/o/item.png',
    ),
    'p': SpellingLetter(
      key: 'p',
      placeholder: 'assets/alippe/images/books/book1/section2/items/letters/p/placeholder.png',
      item: 'assets/alippe/images/books/book1/section2/items/letters/p/item.png',
    ),
    't': SpellingLetter(
      key: 't',
      placeholder: 'assets/alippe/images/books/book1/section2/items/letters/t/placeholder.png',
      item: 'assets/alippe/images/books/book1/section2/items/letters/t/item.png',
    ),
    'u': SpellingLetter(
      key: 'u',
      placeholder: 'assets/alippe/images/books/book1/section2/items/letters/u/placeholder.png',
      item: 'assets/alippe/images/books/book1/section2/items/letters/u/item.png',
    ),
    'eu': SpellingLetter(
      key: 'eu',
      placeholder: 'assets/alippe/images/books/book1/section2/items/letters/eu/placeholder.png',
      item: 'assets/alippe/images/books/book1/section2/items/letters/eu/item.png',
    ),
    'iu': SpellingLetter(
      key: 'iu',
      placeholder: 'assets/alippe/images/books/book1/section2/items/letters/iu/placeholder.png',
      item: 'assets/alippe/images/books/book1/section2/items/letters/iu/item.png',
    ),
  };

  // Section 1: 12 Spelling words
  static List<SpellingWord> get section1Items => [
    SpellingWord(
      pic: 'assets/alippe/images/books/book1/section2/items/1.png',
      word: 'Ай',
      letters: [alphabetLetters['a']!, alphabetLetters['yi']!],
    ),
    SpellingWord(
      pic: 'assets/alippe/images/books/book1/section2/items/2.png',
      word: 'Ат',
      letters: [alphabetLetters['a']!, alphabetLetters['t']!],
    ),
    SpellingWord(
      pic: 'assets/alippe/images/books/book1/section2/items/3.png',
      word: 'От',
      letters: [alphabetLetters['o']!, alphabetLetters['t']!],
    ),
    SpellingWord(
      pic: 'assets/alippe/images/books/book1/section2/items/4.png',
      word: 'Үй',
      letters: [alphabetLetters['u']!, alphabetLetters['yi']!],
    ),
    SpellingWord(
      pic: 'assets/alippe/images/books/book1/section2/items/5.png',
      word: 'Аюу',
      letters: [alphabetLetters['a']!, alphabetLetters['iu']!],
    ),
    SpellingWord(
      pic: 'assets/alippe/images/books/book1/section2/items/6.png',
      word: 'Топ',
      letters: [alphabetLetters['t']!, alphabetLetters['o']!, alphabetLetters['p']!],
    ),
    SpellingWord(
      pic: 'assets/alippe/images/books/book1/section2/items/7.png',
      word: 'Май',
      letters: [alphabetLetters['m']!, alphabetLetters['a']!, alphabetLetters['yi']!],
    ),
    SpellingWord(
      pic: 'assets/alippe/images/books/book1/section2/items/8.png',
      word: 'Нан',
      letters: [alphabetLetters['n']!, alphabetLetters['a']!, alphabetLetters['n']!],
    ),
    SpellingWord(
      pic: 'assets/alippe/images/books/book1/section2/items/9.png',
      word: 'Гүл',
      letters: [alphabetLetters['g']!, alphabetLetters['eu']!, alphabetLetters['l']!],
    ),
    SpellingWord(
      pic: 'assets/alippe/images/books/book1/section2/items/10.png',
      word: 'Күн',
      letters: [alphabetLetters['k']!, alphabetLetters['eu']!, alphabetLetters['n']!],
    ),
    SpellingWord(
      pic: 'assets/alippe/images/books/book1/section2/items/11.png',
      word: 'Пил',
      letters: [alphabetLetters['p']!, alphabetLetters['i']!, alphabetLetters['l']!],
    ),
    SpellingWord(
      pic: 'assets/alippe/images/books/book1/section2/items/12.png',
      word: 'Үкү',
      letters: [alphabetLetters['eu']!, alphabetLetters['k']!, alphabetLetters['eu']!],
    ),
  ];

  // Section 2: items 1..10
  static List<String> get section2Items =>
      List.generate(10, (i) => 'assets/alippe/images/books/book2/section1/items/${i + 1}.png');

  // Section 3: items 1..12
  static List<String> get section3Items =>
      List.generate(12, (i) => 'assets/alippe/images/books/book2/section2/items/${i + 1}.png');

  // Section 4: items 0..9
  static List<String> get section4Items =>
      List.generate(10, (i) => 'assets/alippe/images/books/book3/section1/items/$i.png');

  // Section 5: items 1..17
  static List<String> get section5Items =>
      List.generate(17, (i) => 'assets/alippe/images/books/book3/section2/items/${i + 1}.png');

  // Section 6: items 0..4
  static List<String> get section6Items =>
      List.generate(5, (i) => 'assets/alippe/images/books/book4/section1/items/$i.png');

  // Section 7: items 0..8
  static List<String> get section7Items =>
      List.generate(9, (i) => 'assets/alippe/images/books/book4/section2/items/$i.png');

  // Section 8: 21 silhouette items
  static List<String> get section8Items =>
      List.generate(21, (i) => 'assets/alippe/images/books/book5/section1/items/${i + 1}.png');
  static List<String> get section8Placeholders =>
      List.generate(21, (i) => 'assets/alippe/images/books/book5/section1/placeholders/${i + 1}.png');

  // Section 10: Memory cards
  static const String cardFront = 'assets/alippe/images/books/book6/section1/card_front.png';
  static const String cardBack = 'assets/alippe/images/books/book6/section1/card_back.png';

  static List<String> get section10Items => [
    ...List.generate(10, (i) => 'assets/alippe/images/books/book6/section1/items1/${i + 1}.png'),
    ...List.generate(8, (i) => 'assets/alippe/images/books/book6/section1/items2/${i + 1}.png'),
    ...List.generate(2, (i) => 'assets/alippe/images/books/book6/section1/items3/${i + 1}.png'),
  ];
}
