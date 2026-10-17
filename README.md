# 🐝 Бал тил: Алиппе (3-6 жаш)

[![Flutter](https://img.shields.io/badge/Flutter-3.24+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Tablet-green.svg)](https://flutter.dev)
[![Orientation](https://img.shields.io/badge/Orientation-Landscape%20(16:9)-orange.svg)](https://flutter.dev)
[![State Management](https://img.shields.io/badge/State-flutter__bloc-blue.svg)](https://pub.dev/packages/flutter_bloc)
[![Audio](https://img.shields.io/badge/Audio-just__audio-purple.svg)](https://pub.dev/packages/just_audio)
[![Branch](https://img.shields.io/badge/Branch-alippe-yellow.svg)](https://github.com/altynbekbakirov/bal_till/tree/alippe)

**Бал тил: Алиппе (3-6 жаш)** — мектепке чейинки курактагы балдарга кыргыз тилинин тамгаларын, сөздөрүн, түстөрүн жана айлана-чөйрөнү интерактивдүү мини-оюндар аркылуу үйрөтүүчү заманбап Flutter тиркемеси.

> Долбоор мурдагы React Native (`alippe-master`) архитектурасынан Flutter технологиялык стегине толук көчүрүлүп (портолуп), 16:9 альбомдук (landscape) экранына ылайыкташтырылган.

---

## 🎮 Оюн жана Окутуу Бөлүмдөрү (Books & Games)

Тиркеме **6 интерактивдүү китептен** жана **11 бөлүмдөн** турат:

| Китеп / Бөлүм | Түрү | Сүрөттөмөсү |
| :--- | :---: | :--- |
| 📖 **1-китеп: 0-бөлүм** | 🔤 Окутуу | **Алиппе тамгалары**: 36 кыргыз тамгасынын чоң-кичине жазылышы, сүрөттөрү жана барактап окуу карточкалары. |
| 📖 **1-китеп: 1-бөлүм** | 🧩 Мини-оюн | **Сөз кураштыруу (Spelling Drag & Drop)**: 12 кыргыз сөзүн (Ай, Ат, От, Үй, Аюу, Топ, Май, Нан, Гүл, Күн, Пил, Үкү) сүрөт боюнча тамгаларды уячаларга сүйрөп коюу оюну. |
| 📖 **2-китеп: 2 & 3-бөлүм** | 📚 Интерактивдүү китеп | **Таанышуу**: 2 беттүү ачылган китепте баскычты басып жандуу үн жана анимация менен таанышуу (22 карточка). |
| 📖 **3-китеп: 4 & 5-бөлүм** | 📚 Интерактивдүү китеп | **Билим дүйнөсү**: Айлана-чөйрөдөгү буюмдар, жаныбарлар жана өсүмдүктөр тууралуу визуалдык билим берүүчү китеп. |
| 📖 **4-китеп: 6 & 7-бөлүм** | 📚 Интерактивдүү китеп | **Кызыктуу көнүгүүлөр**: Балдардын байкагычтыгын жана сөз байлыгын арттыруучу баракталма карточкалар. |
| 📖 **5-китеп: 8-бөлүм** | 🎯 Мини-оюн | **Шайкештикти табуу (Silhouette Matching)**: 21 түрдүү түстүү буюмду тийиштүү кара көлөкөсүнө (силуэтине) сүйрөп коюу оюну. |
| 📖 **5-китеп: 9-бөлүм** | 🎈 Мини-оюн | **Түстөр жана шарлар (Color Balloon Counting)**: Бала же кыз каарманы сураган түстөгү (кара, көк, кызыл, жашыл) шарларды таап саноо оюну. |
| 📖 **6-китеп: 10-бөлүм** | 🧠 Мини-оюн | **Эстутум оюну (Memory Card Match)**: Карточкаларды ачып окшош түгөйлөрүн табуу оюну (1-деңгээл: 6 карточка, 2-деңгээл: 8 карточка). |
| 🏆 **Жеңиш экраны** | ✨ Сыйлык | Деңгээл аяктаганда айлануучу күн нурлары, 3 жылдыздуу баалоо жана салтанаттуу музыка жаңырат. |
| ⚙️ **Орнотуулар диалогу** | 🎛️ Жөндөө | Музыка менен үн эффекттерин өзүнчө көзөмөлдөөчү слайдерлер жана бала/кыз каарманынын үнүн алмаштыруу баскычтары. |

---

## 🛠️ Технологиялык стек (Tech Stack)

* **Фреймворк**: [Flutter](https://flutter.dev) (Dart 3.x)
* **Абал башкаруу (State Management)**: [`flutter_bloc`](https://pub.dev/packages/flutter_bloc) (`AlippeCubit` аркылуу жылдыздарды жана баптоолорду сактоо)
* **Аудио кыймылдаткыч (Audio Engine)**: [`just_audio`](https://pub.dev/packages/just_audio) (Фондук музыка жана интерактивдүү үн эффекттери)
* **Экран адаптациясы (Screen Scaling)**: 1280x720 16:9 виртуалдык чечилиши (телефон жана планшеттерге ылайыкталган `FittedBox` контейнери)
* **Эстутум (Storage)**: [`shared_preferences`](https://pub.dev/packages/shared_preferences) (Ар бир китептин 0-3 жылдыздуу упайларын сактоо)
* **Анимациялар**: Spring scale анимациялары, 3D карточка айландыруу жана жеңиш нурларынын анимациясы

---

## 📂 Долбоордун түзүмү (Project Structure)

```text
bal_til/ (branch: alippe)
├── assets/
│   └── alippe/
│       ├── audio/                  # Фондук музыка (bg_music.mp3) жана UI үн эффекттери
│       └── images/                 # 480+ китеп, бөлүм, карточка жана UI сүрөттөрү
└── lib/
    ├── alippe/
    │   ├── core/
    │   │   ├── alippe_constants.dart  # Бардык сүрөт жана аудио жолдору
    │   │   ├── alippe_audio.dart      # JustAudio аркылуу музыка жана эффект башкаруучу
    │   │   └── alippe_cubit.dart      # Упайларды, жылдыздарды жана жөндөөлөрдү сактоо
    │   ├── data/
    │   │   └── alippe_data.dart       # 6 китеп жана 11 бөлүмдүн структуралык маалыматы
    │   ├── screens/
    │   │   ├── alippe_splash_screen.dart # Кириш экраны жана аудиону даярдоо
    │   │   ├── alippe_home_screen.dart   # Башкы меню (6 китеп жана упайлар)
    │   │   ├── alippe_book_screen.dart   # Китепти ачуу (1-бөлүм жана 2-бөлүм)
    │   │   ├── alippe_section_screen.dart# Бөлүмдөрдү багыттоочу борбордук роутер
    │   │   ├── dialogs/
    │   │   │   ├── alippe_game_finish_dialog.dart # Жеңиш жана упай диалогу
    │   │   │   ├── alippe_settings_dialog.dart    # Үн жана каарман жөндөөсү
    │   │   │   └── alippe_info_dialog.dart        # Тиркеме тууралуу маалымат
    │   │   └── sections/
    │   │       ├── section0_view.dart     # 36 алиппе тамгалары
    │   │       ├── section1_view.dart     # 12 сөздү кураштыруу оюну
    │   │       ├── section_books_view.dart# 2, 3, 4, 5, 6, 7-бөлүмдөрдүн китептери
    │   │       ├── section8_view.dart     # Көлөкөсүн табуу оюну (21 буюм)
    │   │       ├── section9_view.dart     # Түстөр жана шар саноо оюну
    │   │       └── section10_view.dart    # Эстутум карточкалары оюну (2 деңгээл)
    │   └── widgets/
    │       ├── alippe_container.dart      # 1280x720 альбомдук масштабдоо контейнери
    │       ├── alippe_book_base.dart      # Барактоо баскычтары бар китеп рамкасы
    │       ├── alippe_anim_button.dart    # Секирүү анимациясы бар баскыч
    │       └── alippe_sidebar.dart        # Башкы менюнун каптал тилкеси
    └── main.dart                          # Альбомдук режимдеги AlippeApp кириш чекити
```

---

## 🚀 Баштоо жана иштетүү (Getting Started)

### Талаптар:
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (версия 3.24+)
* Android Studio же VS Code
* Android түзмөгү / эмулятору (API 21+) же iOS түзмөгү / симулятору (iOS 12+)

### Орнотуу жана иштетүү:

1. Репозиторийди көчүрүп, `alippe` бутагына өтүңүз:
   ```bash
   git clone https://github.com/altynbekbakirov/bal_till.git
   cd bal_till
   git checkout alippe
   ```

2. Көз карандылыктарды жүктөп алыңыз:
   ```bash
   flutter pub get
   ```

3. Тиркемени альбомдук режимде иштетиңиз:
   ```bash
   flutter run
   ```

### Сыноо жана Коддун сапаты:

```bash
# Коддун тазалыгын текшерүү (0 issues):
flutter analyze

# Тесттерди жүргүзүү:
flutter test

# Android release APK куруу:
flutter build apk --release
```

---

## 📄 Лицензия

Бул долбоор MIT лицензиясы менен корголгон.
