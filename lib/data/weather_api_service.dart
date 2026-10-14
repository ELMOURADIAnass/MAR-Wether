// Open-Meteo forecast client (free tier, no API key).
//
// Searched cities use timezone=Africa/Casablanca, GPS positions use
// timezone=auto. Temperatures are always requested in Celsius and
// converted locally. Every failure is a typed [AppFailure]; malformed
// JSON becomes [ParseFailure], never a crash.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/constants/app_constants.dart';
import '../core/errors/app_failure.dart';
import 'models/weather.dart';

/// Fetches forecasts from the Open-Meteo API.
class WeatherApiService {
  WeatherApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Forecast for a searched city (fixed Casablanca timezone).
  Future<Result<WeatherData>> fetchForCity({
    required double lat,
    required double lon,
  }) {
    return _fetch(
      lat: lat,
      lon: lon,
      timezone: ApiConstants.searchedTimezone,
    );
  }

  /// Forecast for exact GPS coordinates (local timezone).
  Future<Result<WeatherData>> fetchForGps({
    required double lat,
    required double lon,
  }) {
    return _fetch(lat: lat, lon: lon, timezone: ApiConstants.gpsTimezone);
  }

  Future<Result<WeatherData>> _fetch({
    required double lat,
    required double lon,
    required String timezone,
  }) async {
    final Uri uri = Uri.https(ApiConstants.host, ApiConstants.forecastPath, <
      String,
      String
    >{
      'latitude': lat.toString(),
      'longitude': lon.toString(),
      'current':
          'temperature_2m,relative_humidity_2m,apparent_temperature,'
          'is_day,weather_code,wind_speed_10m',
      'hourly': 'temperature_2m,weather_code',
      'daily': 'weather_code,temperature_2m_max,temperature_2m_min',
      'timezone': timezone,
      'forecast_days': ApiConstants.forecastDays.toString(),
      'wind_speed_unit': ApiConstants.windSpeedUnit,
    });
    try {
      final http.Response response = await _client
          .get(uri)
          .timeout(ApiConstants.httpTimeout);
      if (response.statusCode != 200) {
        return Err<WeatherData>(
          ServerFailure(response.statusCode, 'HTTP ${response.statusCode}'),
        );
      }
      final Object? decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return const Err<WeatherData>(ParseFailure('Root is not an object'));
      }
      final WeatherData data = WeatherData.fromOpenMeteo(decoded);
      return Ok<WeatherData>(data);
    } on TimeoutException {
      return const Err<WeatherData>(TimeoutFailure());
    } on SocketException catch (e) {
      return Err<WeatherData>(NetworkFailure(e.message));
    } on HttpException catch (e) {
      return Err<WeatherData>(NetworkFailure(e.message));
    } on FormatException catch (e) {
      return Err<WeatherData>(ParseFailure(e.message));
    } catch (e) {
      return Err<WeatherData>(NetworkFailure(e.toString()));
    }
  }

  void dispose() => _client.close();
}
