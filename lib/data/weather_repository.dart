// Weather repository: network first, cache fallback.
//
// - Last successful response per city is cached in SharedPreferences.
// - Any network error/timeout falls back to cache (stale data is
//   flagged via [CachedWeather.isStale] so the UI can show the
//   offline banner + "last updated" time).
// - At most 20 cached cities; the oldest is evicted first.
// - Refresh automatically when cached data is older than 30 minutes.
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../core/constants/app_constants.dart';
import '../core/errors/app_failure.dart';
import 'local_storage.dart';
import 'models/weather.dart';
import 'weather_api_service.dart';

/// Weather payload together with its offline provenance.
class CachedWeather {
  const CachedWeather({required this.data, required this.fromCache});

  final WeatherData data;

  /// True when served from cache because the network failed.
  final bool fromCache;

  bool get isStale => data.isStale(CacheConstants.maxAge);
}

/// Coordinates network fetch + offline cache.
class WeatherRepository {
  WeatherRepository({
    required WeatherApiService api,
    required LocalStorage storage,
    Connectivity? connectivity,
  }) : _api = api,
       _storage = storage,
       _connectivity = connectivity ?? Connectivity();

  final WeatherApiService _api;
  final LocalStorage _storage;
  final Connectivity _connectivity;

  static String cacheKey(String id) => '${CacheConstants.keyPrefix}$id';
  static const String _indexKey = '${CacheConstants.keyPrefix}__index';

  /// Forecast for a searched city. Set [forceRefresh] for pull-to-refresh.
  Future<Result<CachedWeather>> forCity({
    required String cacheId,
    required double lat,
    required double lon,
    bool forceRefresh = false,
  }) async {
    final WeatherData? cached = readCache(cacheId);
    if (!forceRefresh && cached != null && !cached.isStale(CacheConstants.maxAge)) {
      return Ok<CachedWeather>(
        CachedWeather(data: cached, fromCache: false),
      );
    }
    if (!await _hasConnection() && cached != null) {
      return Ok<CachedWeather>(CachedWeather(data: cached, fromCache: true));
    }
    final Result<WeatherData> fresh = await _api.fetchForCity(
      lat: lat,
      lon: lon,
    );
    switch (fresh) {
      case Ok<WeatherData>(:final WeatherData value):
        await writeCache(cacheId, value);
        return Ok<CachedWeather>(
          CachedWeather(data: value, fromCache: false),
        );
      case Err<WeatherData>():
        if (cached != null) {
          return Ok<CachedWeather>(
            CachedWeather(data: cached, fromCache: true),
          );
        }
        return Err<CachedWeather>(fresh.failure);
    }
  }

  /// Forecast for exact GPS coordinates (cached under 'gps').
  Future<Result<CachedWeather>> forGps({
    required double lat,
    required double lon,
    bool forceRefresh = false,
  }) async {
    final WeatherData? cached = readCache('gps');
    if (!forceRefresh && cached != null && !cached.isStale(CacheConstants.maxAge)) {
      return Ok<CachedWeather>(
        CachedWeather(data: cached, fromCache: false),
      );
    }
    if (!await _hasConnection() && cached != null) {
      return Ok<CachedWeather>(CachedWeather(data: cached, fromCache: true));
    }
    final Result<WeatherData> fresh = await _api.fetchForGps(
      lat: lat,
      lon: lon,
    );
    switch (fresh) {
      case Ok<WeatherData>(:final WeatherData value):
        await writeCache('gps', value);
        return Ok<CachedWeather>(
          CachedWeather(data: value, fromCache: false),
        );
      case Err<WeatherData>():
        if (cached != null) {
          return Ok<CachedWeather>(
            CachedWeather(data: cached, fromCache: true),
          );
        }
        return Err<CachedWeather>(fresh.failure);
    }
  }

  /// Reads cached payload or null. Corrupt entries are dropped, never
  /// thrown.
  WeatherData? readCache(String id) {
    final String? raw = _storage.readString(cacheKey(id));
    if (raw == null) {
      return null;
    }
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      return WeatherData.fromJson(decoded);
    } catch (_) {
      unawaitedRemove(cacheKey(id));
      return null;
    }
  }

  /// Stores the payload and prunes oldest entries beyond the cap.
  Future<void> writeCache(String id, WeatherData data) async {
    await _storage.writeString(cacheKey(id), jsonEncode(data.toJson()));
    final List<String> index = _index().toList();
    index.remove(id);
    index.add(id);
    while (index.length > CacheConstants.maxEntries) {
      final String evicted = index.removeAt(0);
      await _storage.remove(cacheKey(evicted));
    }
    await _storage.writeString(_indexKey, jsonEncode(index));
  }

  List<String> _index() {
    final String? raw = _storage.readString(_indexKey);
    if (raw == null) {
      return <String>[];
    }
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! List) {
        return <String>[];
      }
      return decoded.whereType<String>().toList();
    } catch (_) {
      return <String>[];
    }
  }

  void unawaitedRemove(String key) {
    _storage.remove(key);
  }

  Future<bool> _hasConnection() async {
    try {
      final List<ConnectivityResult> results = await _connectivity
          .checkConnectivity()
          .timeout(const Duration(seconds: 5));
      return results.any(
        (ConnectivityResult r) =>
            r != ConnectivityResult.none,
      );
    } catch (_) {
      // When the check itself fails, attempt the request anyway and
      // let the normal network-error path handle it.
      return true;
    }
  }
}
