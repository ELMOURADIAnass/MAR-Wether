import 'package:flutter_test/flutter_test.dart';
import 'package:mar_weather/data/cities_repository.dart';
import 'package:mar_weather/data/models/city.dart';
import 'package:mar_weather/data/models/weather.dart';

const List<City> _sample = <City>[
  City(
    id: 'fes',
    nameFr: 'Fès',
    nameAr: 'فاس',
    nameEn: 'Fez',
    region: 'Fès-Meknès',
    lat: 34.0181,
    lon: -5.0078,
    aliases: <String>['Fez'],
  ),
  City(
    id: 'casablanca',
    nameFr: 'Casablanca',
    nameAr: 'الدار البيضاء',
    nameEn: 'Casablanca',
    region: 'Casablanca-Settat',
    lat: 33.5731,
    lon: -7.5898,
  ),
  City(
    id: 'marrakech',
    nameFr: 'Marrakech',
    nameAr: 'مراكش',
    nameEn: 'Marrakesh',
    region: 'Marrakech-Safi',
    lat: 31.6295,
    lon: -7.9811,
    aliases: <String>['Marrakesh'],
  ),
];

List<String> _ids(List<City> cities) => cities.map((c) => c.id).toList();

void main() {
  final CitiesRepository repo = CitiesRepository();

  group('search matching', () {
    test('fes, Fès and FES all match Fès', () {
      expect(_ids(repo.search(_sample, 'fes')), contains('fes'));
      expect(_ids(repo.search(_sample, 'Fès')), contains('fes'));
      expect(_ids(repo.search(_sample, 'FES')), contains('fes'));
    });

    test('aliases match (Fez, Marrakesh)', () {
      expect(_ids(repo.search(_sample, 'Fez')), contains('fes'));
      expect(_ids(repo.search(_sample, 'Marrakesh')), contains('marrakech'));
    });

    test('Arabic queries match Arabic names', () {
      expect(_ids(repo.search(_sample, 'فاس')), contains('fes'));
      // With tashkeel and alef variants.
      expect(_ids(repo.search(_sample, 'الدَّار الْبَيْضَاء')), contains('casablanca'));
    });

    test('empty query returns empty list', () {
      expect(repo.search(_sample, ''), isEmpty);
      expect(repo.search(_sample, '   '), isEmpty);
    });

    test('no match returns empty list', () {
      expect(repo.search(_sample, 'xyz'), isEmpty);
    });

    test('prefix matches rank before contains matches', () {
      final List<City> results = repo.search(_sample, 'mar');
      expect(results.first.id, 'marrakech');
    });
  });

  group('Open-Meteo parsing', () {
    Map<String, dynamic> envelope() => <String, dynamic>{
      'latitude': 33.5731,
      'longitude': -7.5898,
      'timezone': 'Africa/Casablanca',
      'current': <String, dynamic>{
        'time': '2026-10-14T12:00',
        'temperature_2m': 24.5,
        'relative_humidity_2m': 55,
        'apparent_temperature': 25.1,
        'is_day': 1,
        'weather_code': 2,
        'wind_speed_10m': 14.2,
      },
      'hourly': <String, dynamic>{
        'time': <String>['2026-10-14T12:00', '2026-10-14T13:00'],
        'temperature_2m': <num>[24.5, 25.0],
        'weather_code': <num>[2, 1],
      },
      'daily': <String, dynamic>{
        'time': <String>['2026-10-14', '2026-10-15'],
        'weather_code': <num>[2, 0],
        'temperature_2m_max': <num>[27.0, 28.0],
        'temperature_2m_min': <num>[17.0, 18.0],
      },
    };

    test('parses a valid envelope', () {
      final WeatherData data = WeatherData.fromOpenMeteo(envelope());
      expect(data.current.temperatureC, 24.5);
      expect(data.current.isDay, isTrue);
      expect(data.current.weatherCode, 2);
      expect(data.hourly, hasLength(2));
      expect(data.daily, hasLength(2));
      expect(data.next24Hours(), hasLength(2));
    });

    test('malformed JSON throws FormatException (never crashes callers)', () {
      expect(
        () => WeatherData.fromOpenMeteo(<String, dynamic>{'foo': 'bar'}),
        throwsFormatException,
      );
      expect(
        () => WeatherData.fromOpenMeteo(
          <String, dynamic>{...envelope(), 'hourly': <String, dynamic>{}},
        ),
        throwsFormatException,
      );
    });

    test('cache round-trip preserves data', () {
      final WeatherData data = WeatherData.fromOpenMeteo(envelope());
      final WeatherData restored = WeatherData.fromJson(data.toJson());
      expect(restored.current.temperatureC, data.current.temperatureC);
      expect(restored.daily.first.maxC, 27.0);
    });

    test('stale detection follows the 30-minute rule', () {
      final WeatherData fresh = WeatherData.fromOpenMeteo(envelope());
      expect(fresh.isStale(const Duration(minutes: 30)), isFalse);
      final WeatherData old = WeatherData(
        latitude: fresh.latitude,
        longitude: fresh.longitude,
        timezone: fresh.timezone,
        current: fresh.current,
        hourly: fresh.hourly,
        daily: fresh.daily,
        fetchedAt: DateTime.now().toUtc().subtract(const Duration(hours: 2)),
      );
      expect(old.isStale(const Duration(minutes: 30)), isTrue);
    });
  });
}
