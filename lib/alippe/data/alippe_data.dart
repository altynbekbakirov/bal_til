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
  final String boyLetterSound;
  final String boyPic1Sound;
  final String? boyPic2Sound;
  final String girlLetterSound;
  final String girlPic1Sound;
  final String? girlPic2Sound;

  const LetterItem({
    required this.key,
    required this.pic1,
    required this.pic2,
    required this.pic3,
    required this.pic4,
    required this.letter,
    required this.word1,
    required this.word2,
    required this.boyLetterSound,
    required this.boyPic1Sound,
    this.boyPic2Sound,
    required this.girlLetterSound,
    required this.girlPic1Sound,
    this.girlPic2Sound,
  });

  String letterSound(bool isBoy) => isBoy ? boyLetterSound : girlLetterSound;
  String pic1Sound(bool isBoy) => isBoy ? boyPic1Sound : girlPic1Sound;
  String? pic2Sound(bool isBoy) => isBoy ? boyPic2Sound : girlPic2Sound;
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
    (letter: 'Б', word1: 'Белек', word2: 'Балык'),
    (letter: 'В', word1: 'Велосипед', word2: 'Вилка'),
    (letter: 'Г', word1: 'Гүл', word2: 'Гезит'),
    (letter: 'Д', word1: 'Дарбыз', word2: 'Доктур'),
    (letter: 'Е', word1: 'Жейрен', word2: 'Енот'),
    (letter: 'Ё', word1: 'Боёк', word2: 'Коён'),
    (letter: 'Ж', word1: 'Желек', word2: 'Жөжө'),
    (letter: 'З', word1: 'Зебра', word2: 'Зым'),
    (letter: 'И', word1: 'Илбирс', word2: 'Ийне'),
    (letter: 'Й', word1: 'Кой', word2: 'Май'),
    (letter: 'К', word1: 'Коон', word2: 'Күн'),
    (letter: 'Л', word1: 'Лимон', word2: 'Лампочка'),
    (letter: 'М', word1: 'Маймыл', word2: 'Машина'),
    (letter: 'Н', word1: 'Нан', word2: 'Нөл'),
    (letter: 'Ң', word1: 'Жаңгак', word2: 'Бадыраң'),
    (letter: 'О', word1: 'От', word2: 'Ооз'),
    (letter: 'Ө', word1: 'Өрдөк', word2: 'Өрүк'),
    (letter: 'П', word1: 'Пил', word2: 'Топ'),
    (letter: 'Р', word1: 'Ракета', word2: 'Карта'),
    (letter: 'С', word1: 'Саат', word2: 'Сүрөт'),
    (letter: 'Т', word1: 'Түндүк', word2: 'Тоок'),
    (letter: 'У', word1: 'Уй', word2: 'Учак'),
    (letter: 'Ү', word1: 'Үкү', word2: 'Үтүк'),
    (letter: 'Ф', word1: 'Футбол', word2: 'Фартук'),
    (letter: 'Х', word1: 'Хоккей', word2: 'Халат'),
    (letter: 'Ц', word1: 'Милиция', word2: 'Мотоцикл'),
    (letter: 'Ч', word1: 'Чана', word2: 'Чымчык'),
    (letter: 'Ш', word1: 'Шахмат', word2: 'Шыпыргы'),
    (letter: 'Щ', word1: 'Щетка', word2: 'Плащ'),
    (letter: 'Ы', word1: 'Ышкырык', word2: 'Кайчы'),
    (letter: 'Э', word1: 'Эшик', word2: 'Эчки'),
    (letter: 'Ю', word1: 'Салют', word2: 'Аюу'),
    (letter: 'Я', word1: 'Пияз', word2: 'Чаян'),
    (letter: 'Ь', word1: 'Дельфин', word2: 'Медаль'),
    (letter: 'Ъ', word1: 'Подъезд', word2: 'Подъезд'),
  ];

  static const List<({String boyLetter, String boyPic1, String? boyPic2, String girlLetter, String girlPic1, String? girlPic2})> _section0Sounds = [
    (boyLetter: 'assets/alippe/audio/alippe/boy/boy_A.mp3', boyPic1: 'assets/alippe/audio/alippe/boy/boy_at.mp3', boyPic2: 'assets/alippe/audio/alippe/boy/boy_ay.mp3', girlLetter: 'assets/alippe/audio/alippe/girl/g_A.mp3', girlPic1: 'assets/alippe/audio/alippe/girl/g_at.mp3', girlPic2: 'assets/alippe/audio/alippe/girl/g_ay.mp3'),
    (boyLetter: 'assets/alippe/audio/alippe/boy/boy_B.mp3', boyPic1: 'assets/alippe/audio/alippe/boy/boy_belek.mp3', boyPic2: 'assets/alippe/audio/alippe/boy/boy_balyk.mp3', girlLetter: 'assets/alippe/audio/alippe/girl/g_B.mp3', girlPic1: 'assets/alippe/audio/alippe/girl/g_belek.mp3', girlPic2: 'assets/alippe/audio/alippe/girl/g_balyk.mp3'),
    (boyLetter: 'assets/alippe/audio/alippe/boy/boy_V.mp3', boyPic1: 'assets/alippe/audio/alippe/boy/boy_velosiped.mp3', boyPic2: 'assets/alippe/audio/alippe/boy/boy_vilka.mp3', girlLetter: 'assets/alippe/audio/alippe/girl/g_V.mp3', girlPic1: 'assets/alippe/audio/alippe/girl/g_velosiped.mp3', girlPic2: 'assets/alippe/audio/alippe/girl/g_vilka.mp3'),
    (boyLetter: 'assets/alippe/audio/alippe/boy/boy_G.mp3', boyPic1: 'assets/alippe/audio/alippe/boy/boy_gul.mp3', boyPic2: 'assets/alippe/audio/alippe/boy/boy_gezit.mp3', girlLetter: 'assets/alippe/audio/alippe/girl/g_G.mp3', girlPic1: 'assets/alippe/audio/alippe/girl/g_gul.mp3', girlPic2: 'assets/alippe/audio/alippe/girl/g_gezit.mp3'),
    (boyLetter: 'assets/alippe/audio/alippe/boy/boy_D.mp3', boyPic1: 'assets/alippe/audio/alippe/boy/boy_darbyz.mp3', boyPic2: 'assets/alippe/audio/alippe/boy/boy_doktur.mp3', girlLetter: 'assets/alippe/audio/alippe/girl/g_D.mp3', girlPic1: 'assets/alippe/audio/alippe/girl/g_darbyz.mp3', girlPic2: 'assets/alippe/audio/alippe/girl/g_doktur.mp3'),
    (boyLetter: 'assets/alippe/audio/alippe/boy/boy_E.mp3', boyPic1: 'assets/alippe/audio/alippe/boy/boy_jeyren.mp3', boyPic2: 'assets/alippe/audio/alippe/boy/boy_enot.mp3', girlLetter: 'assets/alippe/audio/alippe/girl/g_E.mp3', girlPic1: 'assets/alippe/audio/alippe/girl/g_jeyren.mp3', girlPic2: 'assets/alippe/audio/alippe/girl/g_enot.mp3'),
    (boyLetter: 'assets/alippe/audio/alippe/boy/boy_YO.mp3', boyPic1: 'assets/alippe/audio/alippe/boy/boy_boyok.mp3', boyPic2: 'assets/alippe/audio/alippe/boy/boy_koyon.mp3', girlLetter: 'assets/alippe/audio/alippe/girl/g_YO.mp3', girlPic1: 'assets/alippe/audio/alippe/girl/g_boyok.mp3', girlPic2: 'assets/alippe/audio/alippe/girl/g_koyon.mp3'),
    (boyLetter: 'assets/alippe/audio/alippe/boy/boy_J.mp3', boyPic1: 'assets/alippe/audio/alippe/boy/boy_jelek.mp3', boyPic2: 'assets/alippe/audio/alippe/boy/boy_jojo.mp3', girlLetter: 'assets/alippe/audio/alippe/girl/g_J.mp3', girlPic1: 'assets/alippe/audio/alippe/girl/g_jelek.mp3', girlPic2: 'assets/alippe/audio/alippe/girl/g_jojo.mp3'),
    (boyLetter: 'assets/alippe/audio/alippe/boy/boy_Z.mp3', boyPic1: 'assets/alippe/audio/alippe/boy/boy_zebra.mp3', boyPic2: 'assets/alippe/audio/alippe/boy/boy_zym.mp3', girlLetter: 'assets/alippe/audio/alippe/girl/g_Z.mp3', girlPic1: 'assets/alippe/audio/alippe/girl/g_zebra.mp3', girlPic2: 'assets/alippe/audio/alippe/girl/g_zym.mp3'),
    (boyLetter: 'assets/alippe/audio/alippe/boy/boy_I.mp3', boyPic1: 'assets/alippe/audio/alippe/boy/boy_ilbirs.mp3', boyPic2: 'assets/alippe/audio/alippe/boy/boy_iyne.mp3', girlLetter: 'assets/alippe/audio/alippe/girl/g_I.mp3', girlPic1: 'assets/alippe/audio/alippe/girl/g_ilbirs.mp3', girlPic2: 'assets/alippe/audio/alippe/girl/g_iyne.mp3'),
    (boyLetter: 'assets/alippe/audio/alippe/boy/boy_IY.mp3', boyPic1: 'assets/alippe/audio/alippe/boy/boy_koy.mp3', boyPic2: 'assets/alippe/audio/alippe/boy/boy_may.mp3', girlLetter: 'assets/alippe/audio/alippe/girl/g_IY.mp3', girlPic1: 'assets/alippe/audio/alippe/girl/g_koy.mp3', girlPic2: 'assets/alippe/audio/alippe/girl/g_may.mp3'),
    (boyLetter: 'assets/alippe/audio/alippe/boy/boy_K.mp3', boyPic1: 'assets/alippe/audio/alippe/boy/boy_koon.mp3', boyPic2: 'assets/alippe/audio/alippe/boy/boy_kun.mp3', girlLetter: 'assets/alippe/audio/alippe/girl/g_K.mp3', girlPic1: 'assets/alippe/audio/alippe/girl/g_koon.mp3', girlPic2: 'assets/alippe/audio/alippe/girl/g_kun.mp3'),
    (boyLetter: 'assets/alippe/audio/alippe/boy/boy_L.mp3', boyPic1: 'assets/alippe/audio/alippe/boy/boy_limon.mp3', boyPic2: 'assets/alippe/audio/alippe/boy/boy_lampochka.mp3', girlLetter: 'assets/alippe/audio/alippe/girl/g_L.mp3', girlPic1: 'assets/alippe/audio/alippe/girl/g_limon.mp3', girlPic2: 'assets/alippe/audio/alippe/girl/g_lampochka.mp3'),
    (boyLetter: 'assets/alippe/audio/alippe/boy/boy_M.mp3', boyPic1: 'assets/alippe/audio/alippe/boy/boy_maymil.mp3', boyPic2: 'assets/alippe/audio/alippe/boy/boy_mashina.mp3', girlLetter: 'assets/alippe/audio/alippe/girl/g_M.mp3', girlPic1: 'assets/alippe/audio/alippe/girl/g_maymil.mp3', girlPic2: 'assets/alippe/audio/alippe/girl/g_mashina.mp3'),
    (boyLetter: 'assets/alippe/audio/alippe/boy/boy_N.mp3', boyPic1: 'assets/alippe/audio/alippe/boy/boy_nan.mp3', boyPic2: 'assets/alippe/audio/alippe/boy/boy_nol.mp3', girlLetter: 'assets/alippe/audio/alippe/girl/g_N.mp3', girlPic1: 'assets/alippe/audio/alippe/girl/g_nan.mp3', girlPic2: 'assets/alippe/audio/alippe/girl/g_nol.mp3'),
    (boyLetter: 'assets/alippe/audio/alippe/boy/boy_NG.mp3', boyPic1: 'assets/alippe/audio/alippe/boy/boy_jangak.mp3', boyPic2: 'assets/alippe/audio/alippe/boy/boy_badyrang.mp3', girlLetter: 'assets/alippe/audio/alippe/girl/g_NG.mp3', girlPic1: 'assets/alippe/audio/alippe/girl/g_jangak.mp3', girlPic2: 'assets/alippe/audio/alippe/girl/g_badyrang.mp3'),
    (boyLetter: 'assets/alippe/audio/alippe/boy/boy_O.mp3', boyPic1: 'assets/alippe/audio/alippe/boy/boy_ot.mp3', boyPic2: 'assets/alippe/audio/alippe/boy/boy_ooz.mp3', girlLetter: 'assets/alippe/audio/alippe/girl/g_O.mp3', girlPic1: 'assets/alippe/audio/alippe/girl/g_ot.mp3', girlPic2: 'assets/alippe/audio/alippe/girl/g_ooz.mp3'),
    (boyLetter: 'assets/alippe/audio/alippe/boy/boy_OO.mp3', boyPic1: 'assets/alippe/audio/alippe/boy/boy_ordok.mp3', boyPic2: 'assets/alippe/audio/alippe/boy/boy_oruk.mp3', girlLetter: 'assets/alippe/audio/alippe/girl/g_OO.mp3', girlPic1: 'assets/alippe/audio/alippe/girl/g_ordok.mp3', girlPic2: 'assets/alippe/audio/alippe/girl/g_oruk.mp3'),
    (boyLetter: 'assets/alippe/audio/alippe/boy/boy_P.mp3', boyPic1: 'assets/alippe/audio/alippe/boy/boy_pil.mp3', boyPic2: 'assets/alippe/audio/alippe/boy/boy_top.mp3', girlLetter: 'assets/alippe/audio/alippe/girl/g_P.mp3', girlPic1: 'assets/alippe/audio/alippe/girl/g_pil.mp3', girlPic2: 'assets/alippe/audio/alippe/girl/g_top.mp3'),
    (boyLetter: 'assets/alippe/audio/alippe/boy/boy_R.mp3', boyPic1: 'assets/alippe/audio/alippe/boy/boy_raketa.mp3', boyPic2: 'assets/alippe/audio/alippe/boy/boy_karta.mp3', girlLetter: 'assets/alippe/audio/alippe/girl/g_R.mp3', girlPic1: 'assets/alippe/audio/alippe/girl/g_raketa.mp3', girlPic2: 'assets/alippe/audio/alippe/girl/g_karta.mp3'),
    (boyLetter: 'assets/alippe/audio/alippe/boy/boy_S.mp3', boyPic1: 'assets/alippe/audio/alippe/boy/boy_saat.mp3', boyPic2: 'assets/alippe/audio/alippe/boy/boy_surot.mp3', girlLetter: 'assets/alippe/audio/alippe/girl/g_S.mp3', girlPic1: 'assets/alippe/audio/alippe/girl/g_saat.mp3', girlPic2: 'assets/alippe/audio/alippe/girl/g_surot.mp3'),
    (boyLetter: 'assets/alippe/audio/alippe/boy/boy_T.mp3', boyPic1: 'assets/alippe/audio/alippe/boy/boy_tunduk.mp3', boyPic2: 'assets/alippe/audio/alippe/boy/boy_took.mp3', girlLetter: 'assets/alippe/audio/alippe/girl/g_T.mp3', girlPic1: 'assets/alippe/audio/alippe/girl/g_tunduk.mp3', girlPic2: 'assets/alippe/audio/alippe/girl/g_took.mp3'),
    (boyLetter: 'assets/alippe/audio/alippe/boy/boy_U.mp3', boyPic1: 'assets/alippe/audio/alippe/boy/boy_uy.mp3', boyPic2: 'assets/alippe/audio/alippe/boy/boy_uchak.mp3', girlLetter: 'assets/alippe/audio/alippe/girl/g_U.mp3', girlPic1: 'assets/alippe/audio/alippe/girl/g_uy.mp3', girlPic2: 'assets/alippe/audio/alippe/girl/g_uchak.mp3'),
    (boyLetter: 'assets/alippe/audio/alippe/boy/boy_UU.mp3', boyPic1: 'assets/alippe/audio/alippe/boy/boy_uku.mp3', boyPic2: 'assets/alippe/audio/alippe/boy/boy_utuk.mp3', girlLetter: 'assets/alippe/audio/alippe/girl/g_UU.mp3', girlPic1: 'assets/alippe/audio/alippe/girl/g_uku.mp3', girlPic2: 'assets/alippe/audio/alippe/girl/g_utuk.mp3'),
    (boyLetter: 'assets/alippe/audio/alippe/boy/boy_F.mp3', boyPic1: 'assets/alippe/audio/alippe/boy/boy_futbol.mp3', boyPic2: 'assets/alippe/audio/alippe/boy/boy_fartuk.mp3', girlLetter: 'assets/alippe/audio/alippe/girl/g_F.mp3', girlPic1: 'assets/alippe/audio/alippe/girl/g_futbol.mp3', girlPic2: 'assets/alippe/audio/alippe/girl/g_fartuk.mp3'),
    (boyLetter: 'assets/alippe/audio/alippe/boy/boy_H.mp3', boyPic1: 'assets/alippe/audio/alippe/boy/boy_hokey.mp3', boyPic2: 'assets/alippe/audio/alippe/boy/boy_halat.mp3', girlLetter: 'assets/alippe/audio/alippe/girl/g_H.mp3', girlPic1: 'assets/alippe/audio/alippe/girl/g_hokey.mp3', girlPic2: 'assets/alippe/audio/alippe/girl/g_halat.mp3'),
    (boyLetter: 'assets/alippe/audio/alippe/boy/boy_TS.mp3', boyPic1: 'assets/alippe/audio/alippe/boy/boy_militsia.mp3', boyPic2: 'assets/alippe/audio/alippe/boy/boy_mototsikl.mp3', girlLetter: 'assets/alippe/audio/alippe/girl/g_TS.mp3', girlPic1: 'assets/alippe/audio/alippe/girl/g_militsia.mp3', girlPic2: 'assets/alippe/audio/alippe/girl/g_mototsikl.mp3'),
    (boyLetter: 'assets/alippe/audio/alippe/boy/boy_CH.mp3', boyPic1: 'assets/alippe/audio/alippe/boy/boy_chana.mp3', boyPic2: 'assets/alippe/audio/alippe/boy/boy_chymchyk.mp3', girlLetter: 'assets/alippe/audio/alippe/girl/g_CH.mp3', girlPic1: 'assets/alippe/audio/alippe/girl/g_chana.mp3', girlPic2: 'assets/alippe/audio/alippe/girl/g_chymchyk.mp3'),
    (boyLetter: 'assets/alippe/audio/alippe/boy/boy_SH.mp3', boyPic1: 'assets/alippe/audio/alippe/boy/boy_shahmat.mp3', boyPic2: 'assets/alippe/audio/alippe/boy/boy_shypyrgy.mp3', girlLetter: 'assets/alippe/audio/alippe/girl/g_SH.mp3', girlPic1: 'assets/alippe/audio/alippe/girl/g_shahmat.mp3', girlPic2: 'assets/alippe/audio/alippe/girl/g_shypyrgy.mp3'),
    (boyLetter: 'assets/alippe/audio/alippe/boy/boy_SHA.mp3', boyPic1: 'assets/alippe/audio/alippe/boy/boy_shetka.mp3', boyPic2: 'assets/alippe/audio/alippe/boy/boy_plash.mp3', girlLetter: 'assets/alippe/audio/alippe/girl/g_SHA.mp3', girlPic1: 'assets/alippe/audio/alippe/girl/g_shetka.mp3', girlPic2: 'assets/alippe/audio/alippe/girl/g_plash.mp3'),
    (boyLetter: 'assets/alippe/audio/alippe/boy/boy_Y.mp3', boyPic1: 'assets/alippe/audio/alippe/boy/boy_yshkyryk.mp3', boyPic2: 'assets/alippe/audio/alippe/boy/boy_kaychy.mp3', girlLetter: 'assets/alippe/audio/alippe/girl/g_Y.mp3', girlPic1: 'assets/alippe/audio/alippe/girl/g_yshkyryk.mp3', girlPic2: 'assets/alippe/audio/alippe/girl/g_kaychy.mp3'),
    (boyLetter: 'assets/alippe/audio/alippe/boy/boy_EE.mp3', boyPic1: 'assets/alippe/audio/alippe/boy/boy_eshik.mp3', boyPic2: 'assets/alippe/audio/alippe/boy/boy_echki.mp3', girlLetter: 'assets/alippe/audio/alippe/girl/g_EE.mp3', girlPic1: 'assets/alippe/audio/alippe/girl/g_eshik.mp3', girlPic2: 'assets/alippe/audio/alippe/girl/g_echki.mp3'),
    (boyLetter: 'assets/alippe/audio/alippe/boy/boy_YU.mp3', boyPic1: 'assets/alippe/audio/alippe/boy/boy_salyut.mp3', boyPic2: 'assets/alippe/audio/alippe/boy/boy_ayu.mp3', girlLetter: 'assets/alippe/audio/alippe/girl/g_YU.mp3', girlPic1: 'assets/alippe/audio/alippe/girl/g_salyut.mp3', girlPic2: 'assets/alippe/audio/alippe/girl/g_ayu.mp3'),
    (boyLetter: 'assets/alippe/audio/alippe/boy/boy_YA.mp3', boyPic1: 'assets/alippe/audio/alippe/boy/boy_piyaz.mp3', boyPic2: 'assets/alippe/audio/alippe/boy/boy_chayan.mp3', girlLetter: 'assets/alippe/audio/alippe/girl/g_YA.mp3', girlPic1: 'assets/alippe/audio/alippe/girl/g_piyaz.mp3', girlPic2: 'assets/alippe/audio/alippe/girl/g_chayan.mp3'),
    (boyLetter: 'assets/alippe/audio/alippe/boy/boy_ICHKERTUU.mp3', boyPic1: 'assets/alippe/audio/alippe/boy/boy_delphin.mp3', boyPic2: 'assets/alippe/audio/alippe/boy/boy_medal.mp3', girlLetter: 'assets/alippe/audio/alippe/girl/g_ICHKERTUU.mp3', girlPic1: 'assets/alippe/audio/alippe/girl/g_delphin.mp3', girlPic2: 'assets/alippe/audio/alippe/girl/g_medal.mp3'),
    (boyLetter: 'assets/alippe/audio/alippe/boy/boy_azhyratuu.mp3', boyPic1: 'assets/alippe/audio/alippe/boy/boy_podyezd.mp3', boyPic2: null, girlLetter: 'assets/alippe/audio/alippe/girl/g_ajyratuu.mp3', girlPic1: 'assets/alippe/audio/alippe/girl/g_podyezd.mp3', girlPic2: null),
  ];


  // Section 0: 36 alphabet letter items
  static List<LetterItem> get section0Items {
    return List.generate(36, (index) {
      final folder = index + 1;
      final info = _section0LetterDetails[index];
      final sounds = _section0Sounds[index];
      return LetterItem(
        key: 'letter_$folder',
        pic1: 'assets/alippe/images/books/book1/section1/$folder/letter1.png',
        pic2: 'assets/alippe/images/books/book1/section1/$folder/letter2.png',
        pic3: 'assets/alippe/images/books/book1/section1/$folder/pic1.png',
        pic4: 'assets/alippe/images/books/book1/section1/$folder/pic2.png',
        letter: info.letter,
        word1: info.word1,
        word2: info.word2,
        boyLetterSound: sounds.boyLetter,
        boyPic1Sound: sounds.boyPic1,
        boyPic2Sound: sounds.boyPic2,
        girlLetterSound: sounds.girlLetter,
        girlPic1Sound: sounds.girlPic1,
        girlPic2Sound: sounds.girlPic2,
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

  // Section 2: items 1..10 (Colors)
  static List<String> get section2Items =>
      List.generate(10, (i) => 'assets/alippe/images/books/book2/section1/items/${i + 1}.png');

  // Section 3: items 1..12 (Shapes)
  static List<String> get section3Items =>
      List.generate(12, (i) => 'assets/alippe/images/books/book2/section2/items/${i + 1}.png');

  // Section 4: items 0..9 (Numbers)
  static List<String> get section4Items =>
      List.generate(10, (i) => 'assets/alippe/images/books/book3/section1/items/$i.png');

  // Section 5: items 1..18 (Measures)
  static List<String> get section5Items =>
      List.generate(18, (i) => 'assets/alippe/images/books/book3/section2/items/${i + 1}.png');

  // Section 6: 4 items (Body Parts 1 - Boy on left, Hand, Foot, Head on right)
  static List<String> get section6Items => const [
    'assets/alippe/images/books/book4/section1/items/0.png',
    'assets/alippe/images/books/book4/section1/items/1.png',
    'assets/alippe/images/books/book4/section1/items/2.png',
    'assets/alippe/images/books/book4/section1/items/3.png',
  ];

  // Section 7: items 0..8 (Body Parts 2)
  static List<String> get section7Items =>
      List.generate(9, (i) => 'assets/alippe/images/books/book4/section2/items/$i.png');

  static List<String> getSectionSounds(int sectionId, bool isBoy) {
    switch (sectionId) {
      case 2:
        return isBoy
            ? const [
                'assets/alippe/audio/alippe/boy/colors/boy_AK.mp3',
                'assets/alippe/audio/alippe/boy/colors/boy_kara.mp3',
                'assets/alippe/audio/alippe/boy/colors/boy_kyzyl.mp3',
                'assets/alippe/audio/alippe/boy/colors/boy_jashyl.mp3',
                'assets/alippe/audio/alippe/boy/colors/boy_sary.mp3',
                'assets/alippe/audio/alippe/boy/colors/boy_kok.mp3',
                'assets/alippe/audio/alippe/boy/colors/boy_kurong.mp3',
                'assets/alippe/audio/alippe/boy/colors/boy_boz.mp3',
                'assets/alippe/audio/alippe/boy/colors/boy_kulgun.mp3',
                'assets/alippe/audio/alippe/boy/colors/boy_kogultur.mp3',
              ]
            : const [
                'assets/alippe/audio/alippe/girl/colors/g_ak.mp3',
                'assets/alippe/audio/alippe/girl/colors/g_kara.mp3',
                'assets/alippe/audio/alippe/girl/colors/g_kyzyl.mp3',
                'assets/alippe/audio/alippe/girl/colors/g_jashyl.mp3',
                'assets/alippe/audio/alippe/girl/colors/g_sary.mp3',
                'assets/alippe/audio/alippe/girl/colors/g_kok.mp3',
                'assets/alippe/audio/alippe/girl/colors/g_kurong.mp3',
                'assets/alippe/audio/alippe/girl/colors/g_boz.mp3',
                'assets/alippe/audio/alippe/girl/colors/g_kulgun.mp3',
                'assets/alippe/audio/alippe/girl/colors/g_kogultur.mp3',
              ];
      case 3:
        return isBoy
            ? const [
                'assets/alippe/audio/alippe/boy/shapes/boy_uchburchtuk.mp3',
                'assets/alippe/audio/alippe/boy/shapes/boy_tortburchtuk.mp3',
                'assets/alippe/audio/alippe/boy/shapes/boy_tegerek.mp3',
                'assets/alippe/audio/alippe/boy/shapes/boy_jyldyz.mp3',
                'assets/alippe/audio/alippe/boy/shapes/boy_romb.mp3',
                'assets/alippe/audio/alippe/boy/shapes/boy_beshburchtuk.mp3',
                'assets/alippe/audio/alippe/boy/shapes/boy_ay.mp3',
                'assets/alippe/audio/alippe/boy/shapes/boy_jurok.mp3',
                'assets/alippe/audio/alippe/boy/shapes/boy_togolok.mp3',
                'assets/alippe/audio/alippe/boy/shapes/boy_piramida.mp3',
                'assets/alippe/audio/alippe/boy/shapes/boy_konus.mp3',
                'assets/alippe/audio/alippe/boy/shapes/boy_cilyndr.mp3',
              ]
            : const [
                'assets/alippe/audio/alippe/girl/shapes/g_uchburchtuk.mp3',
                'assets/alippe/audio/alippe/girl/shapes/g_tortburchtuk.mp3',
                'assets/alippe/audio/alippe/girl/shapes/g_tegerek.mp3',
                'assets/alippe/audio/alippe/girl/shapes/g_jyldyz.mp3',
                'assets/alippe/audio/alippe/girl/shapes/g_romb.mp3',
                'assets/alippe/audio/alippe/girl/shapes/g_beshburchtuk.mp3',
                'assets/alippe/audio/alippe/girl/shapes/g_ay.mp3',
                'assets/alippe/audio/alippe/girl/shapes/g_jurok.mp3',
                'assets/alippe/audio/alippe/girl/shapes/g_togolok.mp3',
                'assets/alippe/audio/alippe/girl/shapes/g_piramida.mp3',
                'assets/alippe/audio/alippe/girl/shapes/g_konus.mp3',
                'assets/alippe/audio/alippe/girl/shapes/g_cilyndr.mp3',
              ];
      case 4:
        return isBoy
            ? const [
                'assets/alippe/audio/alippe/boy/numbers/boy_0.mp3',
                'assets/alippe/audio/alippe/boy/numbers/boy_1.mp3',
                'assets/alippe/audio/alippe/boy/numbers/boy_2.mp3',
                'assets/alippe/audio/alippe/boy/numbers/boy_3.mp3',
                'assets/alippe/audio/alippe/boy/numbers/boy_4.mp3',
                'assets/alippe/audio/alippe/boy/numbers/boy_5.mp3',
                'assets/alippe/audio/alippe/boy/numbers/boy_6.mp3',
                'assets/alippe/audio/alippe/boy/numbers/boy_7.mp3',
                'assets/alippe/audio/alippe/boy/numbers/boy_8.mp3',
                'assets/alippe/audio/alippe/boy/numbers/boy_9.mp3',
              ]
            : const [
                'assets/alippe/audio/alippe/girl/numbers/g_nol.mp3',
                'assets/alippe/audio/alippe/girl/numbers/g_bir.mp3',
                'assets/alippe/audio/alippe/girl/numbers/g_eki.mp3',
                'assets/alippe/audio/alippe/girl/numbers/g_uch.mp3',
                'assets/alippe/audio/alippe/girl/numbers/g_tort.mp3',
                'assets/alippe/audio/alippe/girl/numbers/g_besh.mp3',
                'assets/alippe/audio/alippe/girl/numbers/g_alty.mp3',
                'assets/alippe/audio/alippe/girl/numbers/g_jeti.mp3',
                'assets/alippe/audio/alippe/girl/numbers/g_segiz.mp3',
                'assets/alippe/audio/alippe/girl/numbers/g_toguz.mp3',
              ];
      case 5:
        return isBoy
            ? const [
                'assets/alippe/audio/alippe/boy/measures/boy_solgo.mp3',
                'assets/alippe/audio/alippe/boy/measures/boy_ongo.mp3',
                'assets/alippe/audio/alippe/boy/measures/boy_ildiy.mp3',
                'assets/alippe/audio/alippe/boy/measures/boy_oido.mp3',
                'assets/alippe/audio/alippe/boy/measures/boy_jumshak.mp3',
                'assets/alippe/audio/alippe/boy/measures/boy_katuu.mp3',
                'assets/alippe/audio/alippe/boy/measures/boy_chon.mp3',
                'assets/alippe/audio/alippe/boy/measures/boy_kichine.mp3',
                'assets/alippe/audio/alippe/boy/measures/boy_jaryk.mp3',
                'assets/alippe/audio/alippe/boy/measures/boy_karangy.mp3',
                'assets/alippe/audio/alippe/boy/measures/boy_alys.mp3',
                'assets/alippe/audio/alippe/boy/measures/boy_jakyn.mp3',
                'assets/alippe/audio/alippe/boy/measures/boy_jengil.mp3',
                'assets/alippe/audio/alippe/boy/measures/boy_oor.mp3',
                'assets/alippe/audio/alippe/boy/measures/boy_ysyk.mp3',
                'assets/alippe/audio/alippe/boy/measures/boy_muzdak.mp3',
                'assets/alippe/audio/alippe/boy/measures/boy_az.mp3',
                'assets/alippe/audio/alippe/boy/measures/boy_kop.mp3',
              ]
            : const [
                'assets/alippe/audio/alippe/girl/measures/g_solgo.mp3',
                'assets/alippe/audio/alippe/girl/measures/g_ongo.mp3',
                'assets/alippe/audio/alippe/girl/measures/g_ildiy.mp3',
                'assets/alippe/audio/alippe/girl/measures/g_oido.mp3',
                'assets/alippe/audio/alippe/girl/measures/g_jumshak.mp3',
                'assets/alippe/audio/alippe/girl/measures/g_katuu.mp3',
                'assets/alippe/audio/alippe/girl/measures/g_chon.mp3',
                'assets/alippe/audio/alippe/girl/measures/g_kichine.mp3',
                'assets/alippe/audio/alippe/girl/measures/g_jaryk.mp3',
                'assets/alippe/audio/alippe/girl/measures/g_karangy.mp3',
                'assets/alippe/audio/alippe/girl/measures/g_alys.mp3',
                'assets/alippe/audio/alippe/girl/measures/g_jakyn.mp3',
                'assets/alippe/audio/alippe/girl/measures/g_jengil.mp3',
                'assets/alippe/audio/alippe/girl/measures/g_oor.mp3',
                'assets/alippe/audio/alippe/girl/measures/g_ysyk.mp3',
                'assets/alippe/audio/alippe/girl/measures/g_muzdak.mp3',
                'assets/alippe/audio/alippe/girl/measures/g_az.mp3',
                'assets/alippe/audio/alippe/girl/measures/g_kop.mp3',
              ];
      case 6:
        return isBoy
            ? const [
                'assets/alippe/audio/alippe/boy/body_parts/boy_bash.mp3',
                'assets/alippe/audio/alippe/boy/body_parts/boy_kol.mp3',
                'assets/alippe/audio/alippe/boy/body_parts/boy_but.mp3',
                'assets/alippe/audio/alippe/boy/body_parts/boy_bash.mp3',
              ]
            : const [
                'assets/alippe/audio/alippe/girl/body_parts/g_bash.mp3',
                'assets/alippe/audio/alippe/girl/body_parts/g_kol.mp3',
                'assets/alippe/audio/alippe/girl/body_parts/g_but.mp3',
                'assets/alippe/audio/alippe/girl/body_parts/g_bash.mp3',
              ];
      case 7:
        return isBoy
            ? const [
                'assets/alippe/audio/alippe/boy/body_parts/boy_bash.mp3',
                'assets/alippe/audio/alippe/boy/body_parts/boy_koz.mp3',
                'assets/alippe/audio/alippe/boy/body_parts/boy_murun.mp3',
                'assets/alippe/audio/alippe/boy/body_parts/boy_ooz.mp3',
                'assets/alippe/audio/alippe/boy/body_parts/boy_kulak.mp3',
                'assets/alippe/audio/alippe/boy/body_parts/boy_chach.mp3',
                'assets/alippe/audio/alippe/boy/body_parts/boy_til.mp3',
                'assets/alippe/audio/alippe/boy/body_parts/boy_kash.mp3',
                'assets/alippe/audio/alippe/boy/body_parts/boy_tish.mp3',
              ]
            : const [
                'assets/alippe/audio/alippe/girl/body_parts/g_bash.mp3',
                'assets/alippe/audio/alippe/girl/body_parts/g_koz.mp3',
                'assets/alippe/audio/alippe/girl/body_parts/g_murun.mp3',
                'assets/alippe/audio/alippe/girl/body_parts/g_ooz.mp3',
                'assets/alippe/audio/alippe/girl/body_parts/g_kulak.mp3',
                'assets/alippe/audio/alippe/girl/body_parts/g_chach.mp3',
                'assets/alippe/audio/alippe/girl/body_parts/g_til.mp3',
                'assets/alippe/audio/alippe/girl/body_parts/g_kash.mp3',
                'assets/alippe/audio/alippe/girl/body_parts/g_tish.mp3',
              ];
      default:
        return const [];
    }
  }

  static List<String> getSectionSpokenTexts(int sectionId) {
    switch (sectionId) {
      case 2:
        return const [
          'Ак', 'Кара', 'Кызыл', 'Жашыл', 'Сары',
          'Көк', 'Күрөң', 'Боз', 'Күлгүн', 'Көгүлтүр',
        ];
      case 3:
        return const [
          'Үч бурчтук', 'Төрт бурчтук', 'Тегерек', 'Жылдыз', 'Ромб', 'Беш бурчтук',
          'Ай', 'Жүрөк', 'Тоголок', 'Пирамида', 'Конус', 'Цилиндр',
        ];
      case 4:
        return const [
          'Нөл', 'Бир', 'Эки', 'Үч', 'Төрт',
          'Беш', 'Алты', 'Жети', 'Сегиз', 'Тогуз',
        ];
      case 5:
        return const [
          'Солго', 'Оңго',
          'Ылдый', 'Өйдө',
          'Жумшак', 'Катуу',
          'Чоң', 'Кичине',
          'Жарык', 'Караңгы',
          'Алыс', 'Жакын',
          'Жеңил', 'Оор',
          'Ысык', 'Муздак',
          'Аз', 'Көп',
        ];
      case 6:
        return const [
          'Бала',
          'Кол',
          'Бут',
          'Баш',
        ];
      case 7:
        return const [
          'Баш', 'Көз', 'Мурун', 'Ооз', 'Кулак', 'Чач', 'Тил', 'Каш', 'Тиш',
        ];
      default:
        return const [];
    }
  }

  // Section 1: Spelling word game
  static const String section1PicBg = 'assets/alippe/images/books/book1/section2/items/pic_bg.png';

  // Section 8: 27 silhouette items
  static const String section8Bg = 'assets/alippe/images/books/book5/section1/bg.png';
  static List<String> get section8Items =>
      List.generate(27, (i) => 'assets/alippe/images/books/book5/section1/items/${i + 1}.png');
  static List<String> get section8Placeholders =>
      List.generate(27, (i) => 'assets/alippe/images/books/book5/section1/placeholders/${i + 1}.png');

  // Section 10: Memory cards
  static const String cardFront = 'assets/alippe/images/books/book6/section1/card_front.png';
  static const String cardBack = 'assets/alippe/images/books/book6/section1/card_back.png';

  static List<String> get section10Items => [
    ...List.generate(10, (i) => 'assets/alippe/images/books/book6/section1/items1/${i + 1}.png'),
    ...List.generate(8, (i) => 'assets/alippe/images/books/book6/section1/items2/${i + 1}.png'),
    ...List.generate(10, (i) => 'assets/alippe/images/books/book6/section1/items3/${i + 1}.png'),
  ];
}
