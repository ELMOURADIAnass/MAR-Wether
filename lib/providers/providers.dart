// Riverpod providers: settings, cities, weather, favorites, GPS.
//
// Uses Notifier/AsyncNotifier/FutureProvider only (no StateNotifier).
// Persistence lives in LocalStorage; raw GPS coordinates are never
// persisted.
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../core/errors/app_failure.dart';
import '../core/utils/haversine.dart';
import '../core/utils/morocco_bounds.dart';
import '../core/utils/temperature.dart';
import '../data/cities_repository.dart';
import '../data/local_storage.dart';
import '../data/location_service.dart';
import '../data/models/city.dart';
import '../data/weather_api_service.dart';
import '../data/weather_repository.dart';

// Infrastructure (overridden in main with real instances).
final Provider<LocalStorage> localStorageProvider = Provider<LocalStorage>(
  (Ref ref) => throw UnimplementedError('localStorageProvider not overridden'),
);
final Provider<CitiesRepository> citiesRepositoryProvider =
    Provider<CitiesRepository>((Ref ref) => CitiesRepository());
final Provider<WeatherApiService> weatherApiProvider = Provider<WeatherApiService>(
  (Ref ref) => WeatherApiService(),
);
final Provider<LocationService> locationServiceProvider =
    Provider<LocationService>((Ref ref) => const LocationService());
final Provider<WeatherRepository> weatherRepositoryProvider =
    Provider<WeatherRepository>(
      (Ref ref) => WeatherRepository(
        api: ref.watch(weatherApiProvider),
        storage: ref.watch(localStorageProvider),
      ),
    );

// Cities.
final FutureProvider<List<City>> allCitiesProvider =
    FutureProvider<List<City>>((Ref ref) {
      return ref.watch(citiesRepositoryProvider).load();
    });

// Settings: language (null = device default), unit, theme.
class LanguageNotifier extends Notifier<String?> {
  @override
  String? build() => ref.watch(localStorageProvider).languageCode();

  Future<void> set(String? code) async {
    await ref.read(localStorageProvider).setLanguageCode(code);
    ref.invalidateSelf();
  }
}

final NotifierProvider<LanguageNotifier, String?> languageProvider =
    NotifierProvider<LanguageNotifier, String?>(LanguageNotifier.new);

class UnitNotifier extends Notifier<TempUnit> {
  @override
  TempUnit build() => ref.watch(localStorageProvider).tempUnit();

  Future<void> set(TempUnit unit) async {
    await ref.read(localStorageProvider).setTempUnit(unit);
    ref.invalidateSelf();
  }
}

final NotifierProvider<UnitNotifier, TempUnit> unitProvider =
    NotifierProvider<UnitNotifier, TempUnit>(UnitNotifier.new);

class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ref.watch(localStorageProvider).themeMode();

  Future<void> set(ThemeMode mode) async {
    await ref.read(localStorageProvider).setThemeMode(mode);
    ref.invalidateSelf();
  }
}

final NotifierProvider<ThemeNotifier, ThemeMode> themeProvider =
    NotifierProvider<ThemeNotifier, ThemeMode>(ThemeNotifier.new);

/// Effective locale: stored choice, else device locale when it is ar/fr/en,
/// else French. Changing it rebuilds MaterialApp instantly (incl. RTL).
final Provider<Locale> effectiveLocaleProvider = Provider<Locale>((Ref ref) {
  final String? stored = ref.watch(languageProvider);
  if (stored != null) {
    return Locale(stored);
  }
  final String device = PlatformDispatcher.instance.locale.languageCode;
  if (LocaleConstants.supportedCodes.contains(device)) {
    return Locale(device);
  }
  return const Locale(LocaleConstants.fallbackCode);
});

// Favorites (persisted city ids).
class FavoritesNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => ref.watch(localStorageProvider).favoriteIds();

  Future<void> toggle(String id) async {
    final List<String> current = List<String>.of(state);
    if (current.contains(id)) {
      current.remove(id);
    } else {
      current.add(id);
    }
    await ref.read(localStorageProvider).setFavoriteIds(current);
    ref.invalidateSelf();
  }

  bool isFavorite(String id) => state.contains(id);
}

final NotifierProvider<FavoritesNotifier, List<String>> favoritesProvider =
    NotifierProvider<FavoritesNotifier, List<String>>(FavoritesNotifier.new);

// Selected city (persisted as last viewed).
class SelectedCityNotifier extends Notifier<String> {
  @override
  String build() {
    return ref.watch(localStorageProvider).lastCityId() ??
        LocationConstants.defaultCityId;
  }

  Future<void> select(String id) async {
    await ref.read(localStorageProvider).setLastCityId(id);
    ref.invalidateSelf();
  }
}

final NotifierProvider<SelectedCityNotifier, String> selectedCityProvider =
    NotifierProvider<SelectedCityNotifier, String>(SelectedCityNotifier.new);

/// Exception wrapper so FutureProviders carry typed failures.
class WeatherFailure implements Exception {
  const WeatherFailure(this.failure);
  final AppFailure failure;
}

/// Forecast for a city id. Pull-to-refresh invalidates this provider.
final FutureProviderFamily<CachedWeather, String> cityWeatherProvider =
    FutureProvider.family<CachedWeather, String>((Ref ref, String cityId) async {
      final List<City> cities = await ref.watch(allCitiesProvider.future);
      final CitiesRepository repo = ref.watch(citiesRepositoryProvider);
      final City? city = repo.byId(cities, cityId);
      if (city == null) {
        throw const WeatherFailure(ParseFailure('Unknown city'));
      }
      final Result<CachedWeather> result = await ref
          .watch(weatherRepositoryProvider)
          .forCity(cacheId: city.id, lat: city.lat, lon: city.lon);
      return switch (result) {
        Ok<CachedWeather>(:final CachedWeather value) => value,
        Err<CachedWeather>(:final AppFailure failure) => throw WeatherFailure(
          failure,
        ),
      };
    });

// Search.
final NotifierProvider<SearchQueryNotifier, String> searchQueryProvider =
    NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void set(String value) => state = value;
  void clear() => state = '';
}

final Provider<List<City>> searchResultsProvider = Provider<List<City>>((
  Ref ref,
) {
  final String query = ref.watch(searchQueryProvider);
  final AsyncValue<List<City>> cities = ref.watch(allCitiesProvider);
  return cities.maybeWhen(
    data: (List<City> list) =>
        ref.watch(citiesRepositoryProvider).search(list, query),
    orElse: () => const <City>[],
  );
});

/// Whether the search field is engaged. Tapping the field opens the
/// full browsable city list; typing filters it; ✕ closes it.
class SearchActiveNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setActive(bool value) => state = value;
}

final NotifierProvider<SearchActiveNotifier, bool> searchActiveProvider =
    NotifierProvider<SearchActiveNotifier, bool>(SearchActiveNotifier.new);

// GPS.
class GpsWeather {
  const GpsWeather({
    required this.lat,
    required this.lon,
    required this.weather,
    required this.insideMorocco,
    this.nearestCity,
    this.distanceKm,
    this.usedFallbackPosition = false,
    this.fallbackCityId,
  });

  final double lat;
  final double lon;
  final CachedWeather weather;

  /// False → "Outside Morocco" notice, no nearest city.
  final bool insideMorocco;
  final City? nearestCity;
  final double? distanceKm;

  /// True when the exact fix timed out and the last known position
  /// (or default city) was used instead.
  final bool usedFallbackPosition;
  final String? fallbackCityId;
}

class GpsNotifier extends AsyncNotifier<GpsWeather?> {
  @override
  Future<GpsWeather?> build() async => null;

  /// Runs the documented fallback chain: exact fix → last known
  /// position → default city (Casablanca).
  Future<void> locate({bool forceRefresh = false}) async {
    state = const AsyncValue<GpsWeather?>.loading();
    state = await AsyncValue.guard(() => _locate(forceRefresh: forceRefresh));
  }

  Future<GpsWeather?> _locate({required bool forceRefresh}) async {
    final LocationService location = ref.read(locationServiceProvider);
    final List<City> cities = await ref.read(allCitiesProvider.future);
    final WeatherRepository repo = ref.read(weatherRepositoryProvider);

    final Result<GeoPoint> fix = await location.currentPosition();
    switch (fix) {
      case Ok<GeoPoint>(:final GeoPoint value):
        return _weatherForFix(
          cities,
          repo,
          value.lat,
          value.lon,
          forceRefresh: forceRefresh,
        );
      case Err<GeoPoint>(:final AppFailure failure):
        if (failure is LocationFailure &&
            failure.kind == LocationFailureKind.timeout) {
          final GeoPoint? last = await location.lastKnownPosition();
          if (last != null) {
            final GpsWeather? data = await _weatherForFix(
              cities,
              repo,
              last.lat,
              last.lon,
              forceRefresh: forceRefresh,
            );
            if (data != null) {
              return GpsWeather(
                lat: data.lat,
                lon: data.lon,
                weather: data.weather,
                insideMorocco: data.insideMorocco,
                nearestCity: data.nearestCity,
                distanceKm: data.distanceKm,
                usedFallbackPosition: true,
              );
            }
          }
          // Final fallback: default city weather, labelled as fallback.
          return _fallbackCity(cities, repo, forceRefresh: forceRefresh);
        }
        throw WeatherFailure(failure);
    }
  }

  Future<GpsWeather?> _weatherForFix(
    List<City> cities,
    WeatherRepository repo,
    double lat,
    double lon, {
    required bool forceRefresh,
  }) async {
    final Result<CachedWeather> result = await repo.forGps(
      lat: lat,
      lon: lon,
      forceRefresh: forceRefresh,
    );
    final CachedWeather weather = switch (result) {
      Ok<CachedWeather>(:final CachedWeather value) => value,
      Err<CachedWeather>(:final AppFailure failure) => throw WeatherFailure(
        failure,
      ),
    };
    final bool inside = isInsideMorocco(lat, lon);
    if (!inside) {
      return GpsWeather(
        lat: lat,
        lon: lon,
        weather: weather,
        insideMorocco: false,
      );
    }
    final ({City city, double distanceKm}) near = nearestCity(
      cities,
      lat,
      lon,
    );
    return GpsWeather(
      lat: lat,
      lon: lon,
      weather: weather,
      insideMorocco: true,
      nearestCity: near.city,
      distanceKm: near.distanceKm,
    );
  }

  Future<GpsWeather?> _fallbackCity(
    List<City> cities,
    WeatherRepository repo, {
    required bool forceRefresh,
  }) async {
    final CitiesRepository citiesRepo = ref.read(citiesRepositoryProvider);
    final City? city = citiesRepo.byId(cities, LocationConstants.defaultCityId);
    if (city == null) {
      return null;
    }
    final Result<CachedWeather> result = await repo.forCity(
      cacheId: city.id,
      lat: city.lat,
      lon: city.lon,
      forceRefresh: forceRefresh,
    );
    final CachedWeather weather = switch (result) {
      Ok<CachedWeather>(:final CachedWeather value) => value,
      Err<CachedWeather>(:final AppFailure failure) => throw WeatherFailure(
        failure,
      ),
    };
    return GpsWeather(
      lat: city.lat,
      lon: city.lon,
      weather: weather,
      insideMorocco: true,
      nearestCity: city,
      distanceKm: 0,
      usedFallbackPosition: true,
      fallbackCityId: city.id,
    );
  }

  void clear() {
    state = const AsyncValue<GpsWeather?>.data(null);
  }
}

final AsyncNotifierProvider<GpsNotifier, GpsWeather?> gpsProvider =
    AsyncNotifierProvider<GpsNotifier, GpsWeather?>(GpsNotifier.new);
