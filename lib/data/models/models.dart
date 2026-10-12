class AnimalModel {
  final String name;
  final String image;

  const AnimalModel({required this.name, required this.image});

  factory AnimalModel.fromJson(Map<String, dynamic> json) {
    return AnimalModel(
      name: json['name'] as String? ?? '',
      image: json['image'] as String? ?? '',
    );
  }

  String get imagePath => 'assets/images/animals/$image.png';
}

class PlantModel {
  final String name;
  final String image;
  final String description;

  const PlantModel({
    required this.name,
    required this.image,
    required this.description,
  });

  factory PlantModel.fromJson(Map<String, dynamic> json) {
    return PlantModel(
      name: json['name'] as String? ?? '',
      image: json['image'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  String get imagePath => 'assets/images/plants/$image.png';
}

class RegionModel {
  final String id;
  final String name;
  final String title;
  final String description;
  final double x; // Percent 0..1 on map
  final double y; // Percent 0..1 on map

  const RegionModel({
    required this.id,
    required this.name,
    required this.title,
    required this.description,
    required this.x,
    required this.y,
  });
}

class WordGame1Level {
  final List<String> letters;
  final List<String> words;
  final bool bonus;

  const WordGame1Level({
    required this.letters,
    required this.words,
    this.bonus = false,
  });

  factory WordGame1Level.fromJson(Map<String, dynamic> json) {
    final lettersRaw = (json['letters'] as String? ?? '').split(',').map((e) => e.trim().toLowerCase()).where((e) => e.isNotEmpty).toList();
    final wordsRaw = (json['words'] as String? ?? '').split(',').map((e) => e.trim().toLowerCase()).where((e) => e.isNotEmpty).toList();
    return WordGame1Level(
      letters: lettersRaw,
      words: wordsRaw,
      bonus: json['bonus'] as bool? ?? false,
    );
  }
}

class WordGame1Pack {
  final String title;
  final int maxLetters;
  final List<WordGame1Level> levels;

  const WordGame1Pack({
    required this.title,
    required this.maxLetters,
    required this.levels,
  });

  factory WordGame1Pack.fromJson(Map<String, dynamic> json) {
    final levelsList = (json['levels'] as List<dynamic>? ?? [])
        .map((e) => WordGame1Level.fromJson(e as Map<String, dynamic>))
        .toList();
    return WordGame1Pack(
      title: json['title'] as String? ?? '',
      maxLetters: json['maxletters'] as int? ?? 4,
      levels: levelsList,
    );
  }
}

class WordGame2Category {
  final String name;
  final List<String> words;

  const WordGame2Category({required this.name, required this.words});

  factory WordGame2Category.fromJson(Map<String, dynamic> json) {
    final wordsList = (json['words'] as String? ?? '')
        .split(',')
        .map((e) => e.trim().toLowerCase())
        .where((e) => e.isNotEmpty)
        .toList();
    return WordGame2Category(
      name: json['name'] as String? ?? '',
      words: wordsList,
    );
  }
}

