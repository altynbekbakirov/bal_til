import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../../core/utils/asset_paths.dart';

class NatureRepository {
  Future<List<AnimalModel>> loadAnimals() async {
    final jsonString = await rootBundle.loadString(AssetPaths.animalsJson);
    final data = json.decode(jsonString) as Map<String, dynamic>;
    final items = data['Items'] as List<dynamic>? ?? [];
    return items.map((e) => AnimalModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<PlantModel>> loadPlants() async {
    final jsonString = await rootBundle.loadString(AssetPaths.plantsJson);
    final data = json.decode(jsonString) as Map<String, dynamic>;
    final items = data['Items'] as List<dynamic>? ?? [];
    return items.map((e) => PlantModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}

class MapRepository {
  List<RegionModel> getRegions() {
    return const [
      RegionModel(
        id: 'bishkek',
        name: 'Бишкек',
        title: 'Борбор калаа',
        description: 'Кыргыз Республикасынын баш калаасы. Өлкөнүн эң ири илимий, маданий жана саясий борбору.',
        x: 0.48,
        y: 0.20,
        landmarkImage: 'assets/images/map/bishkek_arch.png',
      ),
      RegionModel(
        id: 'chuy',
        name: 'Чүй (Бурана)',
        title: 'Бурана мунарасы',
        description: 'Байыркы Баласагын шаарынын мурасы, X-XI кылымдарга таандык тарыхый-архитектуралык эстелик.',
        x: 0.58,
        y: 0.25,
        landmarkImage: 'assets/images/map/burana.png',
      ),
      RegionModel(
        id: 'issyk_kul',
        name: 'Ысык-Көл',
        title: 'Көгүлтүр бермет',
        description: 'Дүйнөдөгү эң терең тоо көлдөрүнүн бири. Жайкысын миллиондогон туристтерди өзүнө тарткан керемет жер.',
        x: 0.82,
        y: 0.33,
        landmarkImage: 'assets/images/map/issyk_kul.png',
      ),
      RegionModel(
        id: 'naryn',
        name: 'Нарын',
        title: 'Теңир-Тоо жери',
        description: 'Кыргызстандын эң бийик тоолуу аймагы. Таш-Рабат кербен сарайы жана көк жайык жайлоолору менен белгилүү.',
        x: 0.64,
        y: 0.54,
        landmarkImage: 'assets/images/map/tash_rabat.png',
      ),
      RegionModel(
        id: 'talas',
        name: 'Талас',
        title: 'Манас атанын мекени',
        description: 'Айкөл Манастын баяны жашаган жер. «Манас Ордо» улуттук тарыхый-маданий комплекси жайгашкан.',
        x: 0.22,
        y: 0.32,
        landmarkImage: 'assets/images/map/manas_ordo.png',
      ),
      RegionModel(
        id: 'jalal_abad',
        name: 'Жалал-Абад',
        title: 'Арстанбап & Сары-Челек',
        description: 'Дүйнөдөгү эң чоң табигый жаңгак токою Арстанбап жана кооз Сары-Челек биосфералык коругу жайгашкан аймак.',
        x: 0.35,
        y: 0.52,
      ),
      RegionModel(
        id: 'osh',
        name: 'Ош',
        title: 'Сулайман-Тоо калаасы',
        description: 'Үч миң жылдан ашуун тарыхы бар байыркы калаа. ЮНЕСКОнун мурастар тизмесине кирген ыйык Сулайман-Тоо жайгашкан.',
        x: 0.34,
        y: 0.74,
        landmarkImage: 'assets/images/map/sulaiman_too.png',
      ),
      RegionModel(
        id: 'batken',
        name: 'Баткен',
        title: 'Айгүл гүлү & Өрүкзар',
        description: 'Кыргызстандын түштүк дарбазасы. Уникалдуу Айгүл гүлү жана таттуу Баткен өрүгү менен атагы чыккан.',
        x: 0.15,
        y: 0.76,
        landmarkImage: 'assets/images/map/batken_apricot.png',
      ),
    ];
  }
}

class WordGameRepository {
  Future<List<WordGame1Pack>> loadWordGame1Packs() async {
    final jsonString = await rootBundle.loadString(AssetPaths.wordGame1Json);
    final data = json.decode(jsonString) as Map<String, dynamic>;
    final items = data['Items'] as List<dynamic>? ?? [];
    final List<WordGame1Pack> packs = [];
    for (final item in items) {
      final packsRaw = item['packs'] as List<dynamic>? ?? [];
      for (final p in packsRaw) {
        packs.add(WordGame1Pack.fromJson(p as Map<String, dynamic>));
      }
    }
    return packs;
  }

  Future<List<WordGame2Category>> loadWordGame2Categories() async {
    final jsonString = await rootBundle.loadString(AssetPaths.wordGame2Json);
    final data = json.decode(jsonString) as Map<String, dynamic>;
    final items = data['Items'] as List<dynamic>? ?? [];
    return items.map((e) => WordGame2Category.fromJson(e as Map<String, dynamic>)).toList();
  }
}

