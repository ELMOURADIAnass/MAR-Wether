import 'package:flutter_test/flutter_test.dart';
import 'package:mar_weather/data/cities_repository.dart';
import 'package:mar_weather/data/models/city.dart';

/// Guards the full bundled dataset: every city must be findable by its
/// own French, English and Arabic names (plus aliases), and ids/regions
/// must be consistent.
void main() {
  testWidgets('every bundled city is findable by all of its names', (
    WidgetTester tester,
  ) async {
    final CitiesRepository repo = CitiesRepository();
    final List<City> cities = await repo.load();
    expect(cities.length, greaterThan(70));

    const Set<String> regions = <String>{
      'Tanger-Tétouan-Al Hoceïma',
      "l'Oriental",
      'Fès-Meknès',
      'Rabat-Salé-Kénitra',
      'Béni Mellal-Khénifra',
      'Casablanca-Settat',
      'Marrakech-Safi',
      'Drâa-Tafilalet',
      'Souss-Massa',
      'Guelmim-Oued Noun',
      'Laâyoune-Sakia El Hamra',
      'Dakhla-Oued Ed-Dahab',
    };
    final List<String> failures = <String>[];
    for (final City city in cities) {
      if (!regions.contains(city.region)) {
        failures.add('${city.id}: unexpected region ${city.region}');
      }
      for (final String probe in <String>[
        city.nameFr,
        city.nameEn,
        city.nameAr,
        ...city.aliases,
      ]) {
        final bool found = repo
            .search(cities, probe)
            .any((City c) => c.id == city.id);
        if (!found) {
          failures.add('${city.id}: not found via "$probe"');
        }
      }
    }
    expect(failures, isEmpty, reason: failures.take(10).join('\n'));
  });
}
