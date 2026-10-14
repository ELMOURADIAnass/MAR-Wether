import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mar_weather/core/utils/wmo_mapping.dart';

void main() {
  group('wmoInfo', () {
    test('maps representative codes to description keys', () {
      expect(wmoInfo(0).descriptionKey, 'wmoClear');
      expect(wmoInfo(1).descriptionKey, 'wmoClear');
      expect(wmoInfo(2).descriptionKey, 'wmoPartlyCloudy');
      expect(wmoInfo(3).descriptionKey, 'wmoOvercast');
      expect(wmoInfo(45).descriptionKey, 'wmoFog');
      expect(wmoInfo(48).descriptionKey, 'wmoFog');
      expect(wmoInfo(53).descriptionKey, 'wmoDrizzle');
      expect(wmoInfo(63).descriptionKey, 'wmoRain');
      expect(wmoInfo(81).descriptionKey, 'wmoRain');
      expect(wmoInfo(73).descriptionKey, 'wmoSnow');
      expect(wmoInfo(86).descriptionKey, 'wmoSnow');
      expect(wmoInfo(95).descriptionKey, 'wmoThunderstorm');
      expect(wmoInfo(99).descriptionKey, 'wmoThunderstorm');
    });

    test('unknown codes fall back instead of throwing', () {
      expect(wmoInfo(999).descriptionKey, 'wmoUnknown');
      expect(wmoInfo(-1).descriptionKey, 'wmoUnknown');
    });

    test('day and night icons differ for clear skies', () {
      expect(wmoIcon(0, isDay: true), isNot(wmoIcon(0, isDay: false)));
      expect(wmoIcon(0, isDay: true), Icons.wb_sunny);
      expect(wmoIcon(0, isDay: false), Icons.nights_stay);
    });
  });
}
