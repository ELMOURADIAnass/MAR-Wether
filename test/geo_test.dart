import 'package:flutter_test/flutter_test.dart';
import 'package:mar_weather/core/utils/haversine.dart';
import 'package:mar_weather/core/utils/morocco_bounds.dart';
import 'package:mar_weather/data/models/city.dart';

const City _casa = City(
  id: 'casablanca',
  nameFr: 'Casablanca',
  nameAr: 'الدار البيضاء',
  nameEn: 'Casablanca',
  region: 'Casablanca-Settat',
  lat: 33.5731,
  lon: -7.5898,
);
const City _rabat = City(
  id: 'rabat',
  nameFr: 'Rabat',
  nameAr: 'الرباط',
  nameEn: 'Rabat',
  region: 'Rabat-Salé-Kénitra',
  lat: 34.0209,
  lon: -6.8416,
);
const City _dakhla = City(
  id: 'dakhla',
  nameFr: 'Dakhla',
  nameAr: 'الداخلة',
  nameEn: 'Dakhla',
  region: 'Dakhla-Oued Ed-Dahab',
  lat: 23.722,
  lon: -15.9341,
);

void main() {
  group('haversineKm', () {
    test('Casablanca–Rabat is about 87 km', () {
      final double dist = haversineKm(
        _casa.lat,
        _casa.lon,
        _rabat.lat,
        _rabat.lon,
      );
      expect(dist, inInclusiveRange(80, 95));
    });

    test('same point is zero', () {
      expect(haversineKm(_casa.lat, _casa.lon, _casa.lat, _casa.lon), 0);
    });
  });

  group('nearestCity', () {
    test('finds Rabat for a point near Rabat', () {
      final result = nearestCity(
        const <City>[_casa, _rabat, _dakhla],
        34.03,
        -6.83,
      );
      expect(result.city.id, 'rabat');
      expect(result.distanceKm, lessThan(5));
    });
  });

  group('isInsideMorocco (approximate polygon)', () {
    test('Moroccan cities are inside', () {
      expect(isInsideMorocco(_casa.lat, _casa.lon), isTrue);
      expect(isInsideMorocco(_dakhla.lat, _dakhla.lon), isTrue);
      expect(isInsideMorocco(31.6295, -7.9811), isTrue); // Marrakech
    });

    test('foreign cities are outside', () {
      expect(isInsideMorocco(48.8566, 2.3522), isFalse); // Paris
      expect(isInsideMorocco(40.4168, -3.7038), isFalse); // Madrid
      expect(isInsideMorocco(35.6762, 139.6503), isFalse); // Tokyo
    });
  });
}
