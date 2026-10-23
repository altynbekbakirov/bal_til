import 'package:upgrader/upgrader.dart';

/// Kyrgyz (ky) localization for the upgrader alert dialog.
class UpgraderMessagesKy extends UpgraderMessages {
  UpgraderMessagesKy() : super(code: 'ky');

  @override
  String get body =>
      '{{appName}} тиркемесинин жаңы версиясы жеткиликтүү! '
      'Жаңы версиясы: {{currentAppStoreVersion}}, учурдагы версиясы: '
      '{{currentInstalledVersion}}.';

  @override
  String get buttonTitleIgnore => 'ЖОК';

  @override
  String get buttonTitleLater => 'КИЙИН';

  @override
  String get buttonTitleUpdate => 'ЖАҢЫРТУУ';

  @override
  String get prompt => 'Азыр жаңыртууну каалайсызбы?';

  @override
  String get releaseNotes => 'Өзгөрүүлөр тизмеси';

  @override
  String get title => 'Жаңыртуу керекпи?';
}
