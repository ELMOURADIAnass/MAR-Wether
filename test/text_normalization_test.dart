import 'package:flutter_test/flutter_test.dart';
import 'package:mar_weather/core/utils/text_normalization.dart';

void main() {
  group('normalizeLatin', () {
    test('lowercases and strips French diacritics', () {
      expect(normalizeLatin('Fès'), 'fes');
      expect(normalizeLatin('FES'), 'fes');
      expect(normalizeLatin('Meknès'), 'meknes');
      expect(normalizeLatin('Tétouan'), 'tetouan');
      expect(normalizeLatin('Kénitra'), 'kenitra');
      expect(normalizeLatin('Laâyoune'), 'laayoune');
      expect(normalizeLatin('Al Hoceïma'), 'al hoceima');
      expect(normalizeLatin('Béni Mellal'), 'beni mellal');
    });

    test('hyphens and apostrophes become spaces', () {
      expect(normalizeLatin("l'Oriental"), 'l oriental');
      expect(normalizeLatin('Sidi-Ifni'), 'sidi ifni');
    });
  });

  group('normalizeArabic', () {
    test('strips tashkeel', () {
      expect(normalizeArabic('الدَّارُ الْبَيْضَاء'), 'الدار البيضاء');
    });

    test('unifies alef forms to bare alef', () {
      expect(normalizeArabic('إفران'), 'افران');
      expect(normalizeArabic('أكادير'), 'اكادير');
      expect(normalizeArabic('آسفي'), 'اسفي');
    });

    test('unifies teh marbuta to heh and alef maksura to yeh', () {
      expect(normalizeArabic('الجديدة'), 'الجديده');
      expect(normalizeArabic('مراكش'), 'مراكش');
      // ى → ي
      expect(normalizeArabic('موسى'), 'موسي');
    });
  });
}
