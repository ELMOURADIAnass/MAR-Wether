// Weather models mirroring the Open-Meteo forecast response.
//
// Temperatures are stored in Celsius; conversion to Fahrenheit happens
// in the presentation layer. All factories validate their input and
// throw [FormatException] on malformed data — the API service catches
// it and surfaces a [ParseFailure] instead of crashing.
import 'package:flutter/foundation.dart';

/// Current conditions block (`current=…`).
@immutable
final class CurrentWeather {
  const CurrentWeather({
    required this.time,
    required this.temperatureC,
    required this.humidity,
    required this.feelsLikeC,
    required this.weatherCode,
    required this.windSpeedKmh,
    required this.isDay,
  });

  final DateTime time;
  final double temperatureC;
  final int humidity;
  final double feelsLikeC;
  final int weatherCode;
  final double windSpeedKmh;
  final bool isDay;

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    final Object? time = json['time'];
    final Object? temp = json['temperature_2m'];
    final Object? humidity = json['relative_humidity_2m'];
    final Object? feels = json['apparent_temperature'];
    final Object? code = json['weather_code'];
    final Object? wind = json['wind_speed_10m'];
    final Object? isDay = json['is_day'];
    if (time is! String ||
        temp is! num ||
        humidity is! num ||
        feels is! num ||
        code is! num ||
        wind is! num ||
        isDay is! num) {
      throw const FormatException('Invalid current weather block');
    }
    return CurrentWeather(
      time: DateTime.tryParse(time) ?? DateTime.now(),
      temperatureC: temp.toDouble(),
      humidity: humidity.toInt(),
      feelsLikeC: feels.toDouble(),
      weatherCode: code.toInt(),
      windSpeedKmh: wind.toDouble(),
      isDay: isDay.toInt() == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'time': time.toIso8601String(),
      'temperature_2m': temperatureC,
      'relative_humidity_2m': humidity,
      'apparent_temperature': feelsLikeC,
      'weather_code': weatherCode,
      'wind_speed_10m': windSpeedKmh,
      'is_day': isDay ? 1 : 0,
    };
  }
}

/// One hourly sample.
@immutable
final class HourlyPoint {
  const HourlyPoint({
    required this.time,
    required this.temperatureC,
    required this.weatherCode,
  });

  final DateTime time;
  final double temperatureC;
  final int weatherCode;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'time': time.toIso8601String(),
      'temperatureC': temperatureC,
      'weatherCode': weatherCode,
    };
  }

  factory HourlyPoint.fromJson(Map<String, dynamic> json) {
    final Object? time = json['time'];
    final Object? temp = json['temperatureC'];
    final Object? code = json['weatherCode'];
    if (time is! String || temp is! num || code is! num) {
      throw const FormatException('Invalid hourly point');
    }
    return HourlyPoint(
      time: DateTime.tryParse(time) ?? DateTime.now(),
      temperatureC: temp.toDouble(),
      weatherCode: code.toInt(),
    );
  }
}

/// One daily sample.
@immutable
final class DailyPoint {
  const DailyPoint({
    required this.date,
    required this.weatherCode,
    required this.maxC,
    required this.minC,
  });

  final DateTime date;
  final int weatherCode;
  final double maxC;
  final double minC;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'date': date.toIso8601String(),
      'weatherCode': weatherCode,
      'maxC': maxC,
      'minC': minC,
    };
  }

  factory DailyPoint.fromJson(Map<String, dynamic> json) {
    final Object? date = json['date'];
    final Object? code = json['weatherCode'];
    final Object? max = json['maxC'];
    final Object? min = json['minC'];
    if (date is! String || code is! num || max is! num || min is! num) {
      throw const FormatException('Invalid daily point');
    }
    return DailyPoint(
      date: DateTime.tryParse(date) ?? DateTime.now(),
      weatherCode: code.toInt(),
      maxC: max.toDouble(),
      minC: min.toDouble(),
    );
  }
}

/// Full forecast payload kept in memory and in the offline cache.
@immutable
final class WeatherData {
  const WeatherData({
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.current,
    required this.hourly,
    required this.daily,
    required this.fetchedAt,
  });

  final double latitude;
  final double longitude;
  final String timezone;
  final CurrentWeather current;
  final List<HourlyPoint> hourly;
  final List<DailyPoint> daily;

  /// When this payload was fetched (UTC). Used for the 30-minute
  /// refresh rule and the "last updated" label.
  final DateTime fetchedAt;

  /// Hourly strip starting at the current hour (not midnight).
  List<HourlyPoint> next24Hours() {
    final DateTime now = current.time;
    final List<HourlyPoint> upcoming = hourly
        .where((HourlyPoint p) => !p.time.isBefore(now))
        .toList(growable: false);
    if (upcoming.length <= 24) {
      return upcoming;
    }
    return upcoming.sublist(0, 24);
  }

  factory WeatherData.fromOpenMeteo(Map<String, dynamic> json) {
    final Object? lat = json['latitude'];
    final Object? lon = json['longitude'];
    final Object? tz = json['timezone'];
    final Object? current = json['current'];
    final Object? hourly = json['hourly'];
    final Object? daily = json['daily'];
    if (lat is! num ||
        lon is! num ||
        current is! Map<String, dynamic> ||
        hourly is! Map<String, dynamic> ||
        daily is! Map<String, dynamic>) {
      throw const FormatException('Invalid Open-Meteo envelope');
    }
    return WeatherData(
      latitude: lat.toDouble(),
      longitude: lon.toDouble(),
      timezone: tz is String ? tz : 'UTC',
      current: CurrentWeather.fromJson(current),
      hourly: _parseHourly(hourly),
      daily: _parseDaily(daily),
      fetchedAt: DateTime.now().toUtc(),
    );
  }

  /// Zips the parallel `hourly.time / temperature_2m / weather_code`
  /// arrays into [HourlyPoint]s, skipping ragged entries instead of
  /// throwing so one bad sample never drops the whole payload.
  static List<HourlyPoint> _parseHourly(Map<String, dynamic> json) {
    final Object? times = json['time'];
    final Object? temps = json['temperature_2m'];
    final Object? codes = json['weather_code'];
    if (times is! List || temps is! List || codes is! List) {
      throw const FormatException('Invalid hourly block');
    }
    final int length = <int>[times.length, temps.length, codes.length]
        .reduce((int a, int b) => a < b ? a : b);
    final List<HourlyPoint> points = <HourlyPoint>[];
    for (int i = 0; i < length; i++) {
      final Object? t = times[i];
      final Object? temp = temps[i];
      final Object? code = codes[i];
      if (t is! String || temp is! num || code is! num) {
        continue;
      }
      points.add(
        HourlyPoint(
          time: DateTime.tryParse(t) ?? DateTime.now(),
          temperatureC: temp.toDouble(),
          weatherCode: code.toInt(),
        ),
      );
    }
    if (points.isEmpty) {
      throw const FormatException('Empty hourly block');
    }
    return List<HourlyPoint>.unmodifiable(points);
  }

  /// Zips the parallel `daily.*` arrays; same ragged-array policy.
  static List<DailyPoint> _parseDaily(Map<String, dynamic> json) {
    final Object? times = json['time'];
    final Object? codes = json['weather_code'];
    final Object? max = json['temperature_2m_max'];
    final Object? min = json['temperature_2m_min'];
    if (times is! List || codes is! List || max is! List || min is! List) {
      throw const FormatException('Invalid daily block');
    }
    final int length = <int>[
      times.length,
      codes.length,
      max.length,
      min.length,
    ].reduce((int a, int b) => a < b ? a : b);
    final List<DailyPoint> points = <DailyPoint>[];
    for (int i = 0; i < length; i++) {
      final Object? t = times[i];
      final Object? code = codes[i];
      final Object? hi = max[i];
      final Object? lo = min[i];
      if (t is! String || code is! num || hi is! num || lo is! num) {
        continue;
      }
      points.add(
        DailyPoint(
          date: DateTime.tryParse(t) ?? DateTime.now(),
          weatherCode: code.toInt(),
          maxC: hi.toDouble(),
          minC: lo.toDouble(),
        ),
      );
    }
    if (points.isEmpty) {
      throw const FormatException('Empty daily block');
    }
    return List<DailyPoint>.unmodifiable(points);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      'timezone': timezone,
      'current': current.toJson(),
      'hourly': hourly.map((HourlyPoint p) => p.toJson()).toList(),
      'daily': daily.map((DailyPoint p) => p.toJson()).toList(),
      'fetchedAt': fetchedAt.toIso8601String(),
    };
  }

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    try {
      final Object? lat = json['latitude'];
      final Object? lon = json['longitude'];
      final Object? tz = json['timezone'];
      final Object? current = json['current'];
      final Object? hourly = json['hourly'];
      final Object? daily = json['daily'];
      final Object? fetchedAt = json['fetchedAt'];
      if (lat is! num ||
          lon is! num ||
          current is! Map<String, dynamic> ||
          hourly is! List ||
          daily is! List) {
        throw const FormatException('Invalid cached weather');
      }
      return WeatherData(
        latitude: lat.toDouble(),
        longitude: lon.toDouble(),
        timezone: tz is String ? tz : 'UTC',
        current: CurrentWeather.fromJson(current),
        hourly: hourly
            .whereType<Map<String, dynamic>>()
            .map(HourlyPoint.fromJson)
            .toList(growable: false),
        daily: daily
            .whereType<Map<String, dynamic>>()
            .map(DailyPoint.fromJson)
            .toList(growable: false),
        fetchedAt: fetchedAt is String
            ? DateTime.tryParse(fetchedAt) ?? DateTime.now().toUtc()
            : DateTime.now().toUtc(),
      );
    } on FormatException {
      rethrow;
    } catch (_) {
      throw const FormatException('Invalid cached weather');
    }
  }

  /// True when the payload is older than [maxAge].
  bool isStale(Duration maxAge) {
    return DateTime.now().toUtc().difference(fetchedAt) > maxAge;
  }
}
