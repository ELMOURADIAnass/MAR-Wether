// Widget test: the home search bar filters cities as the user types.
//
// hermetic: cities, weather and storage are overridden so no asset,
// network or platform channel is touched.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mar_weather/app.dart';
import 'package:mar_weather/data/local_storage.dart';
import 'package:mar_weather/data/models/city.dart';
import 'package:mar_weather/data/models/weather.dart';
import 'package:mar_weather/data/weather_repository.dart';
import 'package:mar_weather/providers/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

const List<City> _fakeCities = <City>[
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
];

final CachedWeather _fakeWeather = CachedWeather(
  data: WeatherData(
    latitude: 33.5731,
    longitude: -7.5898,
    timezone: 'Africa/Casablanca',
    current: CurrentWeather(
      time: DateTime.utc(2026, 10, 14, 12),
      temperatureC: 0,
      humidity: 0,
      feelsLikeC: 0,
      weatherCode: 0,
      windSpeedKmh: 0,
      isDay: true,
    ),
    hourly: const <HourlyPoint>[],
    daily: const <DailyPoint>[],
    fetchedAt: DateTime.utc(2026, 10, 14, 12),
  ),
  fromCache: false,
);

void main() {
  testWidgets('search bar filters results as the user types', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          localStorageProvider.overrideWithValue(LocalStorage(prefs)),
          effectiveLocaleProvider.overrideWithValue(const Locale('fr')),
          allCitiesProvider.overrideWith((Ref ref) async => _fakeCities),
          cityWeatherProvider.overrideWith(
            (Ref ref, String id) async => _fakeWeather,
          ),
        ],
        child: const MarWeatherApp(),
      ),
    );
    // Splash (1.4 s timer) → home. pumpAndSettle alone does not advance
    // the fake clock past bare timers, so pump the delay explicitly.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('searchField')), findsOneWidget);

    // Tapping the field opens the browsable full-city list.
    await tester.tap(find.byKey(const Key('searchField')));
    await tester.pump();
    expect(find.byType(ListTile), findsWidgets);

    await tester.enterText(find.byKey(const Key('searchField')), 'fes');
    // 300 ms debounce + build.
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Fès'), findsWidgets);
    expect(find.text('Casablanca'), findsNothing);

    // No-results state.
    await tester.enterText(find.byKey(const Key('searchField')), 'xyz');
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Casablanca'), findsNothing);
  });
}
