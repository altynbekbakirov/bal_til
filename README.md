# 🐝 Бал тил 2.0 (Alippe 2.0)

[![Flutter](https://img.shields.io/badge/Flutter-3.47+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.13+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green.svg)](https://flutter.dev)
[![State Management](https://img.shields.io/badge/State-flutter__bloc-blue.svg)](https://pub.dev/packages/flutter_bloc)
[![License](https://img.shields.io/badge/License-MIT-amber.svg)](LICENSE)

**Бал тил 2.0** — мектепке чейинки жана башталгыч класстагы балдар үчүн кыргыз тилин, жаратылышын жана географиясын кызыктуу интерактивдүү оюндар аркылуу үйрөтүүчү заманбап мобилдик тиркеме.

---

## ✨ Өзгөчөлүктөрү (Features)

| Модуль | Сүрөттөмөсү |
| :--- | :--- |
| 🔤 **Сөздү тап (Word Connect)** | Тегерек тамга дөңгөлөгүндө манжа менен сызып сөз кураштыруучу табышмак оюну (`CustomPainter` интерактивдүү кыймылдаткычы). |
| 🔍 **Сөз издөө (Word Search)** | $6 \times 6$ торчодон кыргызча сөздөрдү издөө жана табуу оюну. |
| 🐾 **Жаныбарлар (Animals)** | Кыргызстандын жапайы жана үй жаныбарларынын сүрөттүү карточкалары жана аталыштары. |
| 🌿 **Өсүмдүктөр (Plants)** | Кыргыз тоолорундагы дары чөптөр жана өсүмдүктөр тууралуу баяндамалар (Ала гүл, Миң тамыр, Ышкын ж.б.). |
| 🗺️ **Кыргызстан картасы (Map)** | Өлкөнүн 7 облусу, борбор калаасы жана тарыхый эстеликтери тууралуу интерактивдүү маалымат баракчалары. |
| 🎶 **Мамлекеттик гимн (Anthem)** | Кыргыз Республикасынын улуттук гимнинин толук тексти жана аудио ойнотуучусу. |
| ⚙️ **Орнотуулар (Settings)** | Музыка жана үн эффекттерин өзүнчө күйгүзүп/өчүрүү жөндөөсү. |

---

## 🛠️ Технологиялык стек (Tech Stack)

* **Фреймворк**: [Flutter](https://flutter.dev) (Dart 3.x)
* **Абал башкаруу (State Management)**: [`flutter_bloc`](https://pub.dev/packages/flutter_bloc) (Cubit)
* **Аудио кыймылдаткыч (Audio)**: [`just_audio`](https://pub.dev/packages/just_audio) + [`audio_session`](https://pub.dev/packages/audio_session)
* **Анимациялар**: [`flutter_animate`](https://pub.dev/packages/flutter_animate)
* **Ариптер (Typography)**: [Google Fonts](https://pub.dev/packages/google_fonts) (`Comfortaa`)
* **Эстутум (Storage)**: [`shared_preferences`](https://pub.dev/packages/shared_preferences)
* **Графика & Жесттер**: Flutter `CustomPainter` + `GestureDetector`

---

## 📂 Долбоордун түзүмү (Project Structure)

```text
ball_til/
├── assets/
│   ├── audio/              # Үн эффекттери, фондук музыка жана гимн
│   ├── data/               # Кыргызча деңгээлдер жана маалыматтар (JSON)
│   └── images/             # Жаныбарлар, өсүмдүктөр, карта жана UI сүрөттөрү
└── lib/
    ├── configs/            # Маршруттар (Routers) жана глобалдык конфигурациялар
    ├── core/
    │   ├── audio/          # AudioController жана AudioCubit
    │   ├── theme/          # AppTheme (түстөр палитрасы, шрифтер)
    │   └── utils/          # AssetPaths туруктуулары
    ├── data/
    │   ├── models/         # Маалымат моделдери (Animal, Plant, Region, Level)
    │   └── repositories/   # Репозиторийлер (Nature, Map, WordGame)
    ├── features/
    │   ├── home/           # Башкы экран жана меню баскычтары
    │   ├── map/            # Интерактивдүү карта жана гимн экраны
    │   ├── nature/         # Жаныбарлар жана өсүмдүктөр карусели
    │   ├── word_connect/   # Сөздү тап оюну (CustomPainter дөңгөлөгү)
    │   └── word_search/    # Сөз издөө торчосу
    └── main.dart           # Тиркеменин кириш чекити
```

---

## 🚀 Баштоо жана иштетүү (Getting Started)

### Талаптар:
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (версия 3.24+)
* Android Studio же VS Code
* Android SDK (API 34+) же iOS Xcode

### Орнотуу:
1. Репозиторийди көчүрүп алыңыз:
   ```bash
   git clone https://github.com/<your-username>/ball_til.git
   cd ball_til
   ```

2. Көз карандылыктарды (пакеттерди) жүктөп алыңыз:
   ```bash
   flutter pub get
   ```

3. Тиркемени иштетиңиз:
   ```bash
   flutter run
   ```

### Тестирлөө жана Анализ:
```bash
# Кодду текшерүү:
flutter analyze

# Тесттерди жүргүзүү:
flutter test

# Android APK куруу:
flutter build apk --release
```

---

## 📱 Платформалар

* **Android**: Android 5.0 (API 21) жана андан жогору.
* **iOS**: iOS 12.0 жана андан жогору.
* **Web / Desktop**: Колдоого алынат.

---

## 📄 Лицензия

Бул долбоор MIT лицензиясы менен корголгон.
