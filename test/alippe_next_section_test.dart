import 'package:bal_til/alippe/data/alippe_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Play after stage 1 opens stage 2; after last stage opens next game', () {
    const expected = <int, int?>{
      0: 1, 1: 2, // Game 1
      2: 3, 3: 4, // Game 2
      4: 5, 5: 6, // Game 3
      6: 7, 7: 8, // Game 4
      8: 9, 9: 10, // Game 5
      10: 12, 12: 11, // Game 6 (two levels)
      11: 13, // Game 7
      13: 14, // Game 8
      14: 15, // Game 9
      15: 16, // Game 10
      16: 17, // Game 11
      17: null, // Game 12 -> home
    };
    expected.forEach((section, next) {
      expect(AlippeData.nextSectionAfter(section), next, reason: 'section $section');
    });
  });
}
