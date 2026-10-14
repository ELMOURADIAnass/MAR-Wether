// City weather detail: current conditions, 24-hour strip, 7-day
// list, favorite star, pull-to-refresh, offline banner.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:mar_weather/core/utils/temperature.dart';
import 'package:mar_weather/core/utils/time_format.dart';
import 'package:mar_weather/data/models/city.dart';
import 'package:mar_weather/data/models/weather.dart';
import 'package:mar_weather/data/weather_repository.dart';
import 'package:mar_weather/features/common/error_view.dart';
import 'package:mar_weather/features/common/failure_message.dart';
import 'package:mar_weather/features/common/loading_skeleton.dart';
import 'package:mar_weather/features/common/offline_banner.dart';
import 'package:mar_weather/features/common/weather_icon.dart';
import 'package:mar_weather/features/common/wmo_label.dart';
import 'package:mar_weather/l10n/app_localizations.dart';
import 'package:mar_weather/providers/providers.dart';

/// Daytime heuristic for hourly points (Open-Meteo gives is_day for
/// current only): 06:00–20:00 counts as day.
bool _isDayHour(int hour) => hour >= 6 && hour < 20;

class CityDetailScreen extends ConsumerWidget {
  const CityDetailScreen({super.key, required this.cityId});

  final String cityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<List<City>> citiesAsync = ref.watch(allCitiesProvider);
    final AsyncValue<CachedWeather> weatherAsync = ref.watch(
      cityWeatherProvider(cityId),
    );
    final bool isFav = ref.watch(favoritesProvider).contains(cityId);
    final TempUnit unit = ref.watch(unitProvider);
    final String lang = Localizations.localeOf(context).languageCode;

    final City? city = citiesAsync.maybeWhen(
      data: (List<City> list) =>
          ref.watch(citiesRepositoryProvider).byId(list, cityId),
      orElse: () => null,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(city?.nameFor(lang) ?? cityId),
        actions: <Widget>[
          IconButton(
            tooltip: isFav ? l10n.removeFavorite : l10n.addFavorite,
            icon: Icon(
              isFav ? Icons.star : Icons.star_border,
              color: isFav
                  ? const Color(0xFFD4A017)
                  : Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () =>
                ref.read(favoritesProvider.notifier).toggle(cityId),
          ),
        ],
      ),
      body: weatherAsync.when(
        loading: () => const SingleChildScrollView(
          child: Padding(
            padding: EdgeInsetsDirectional.all(8),
            child: WeatherCardSkeleton(),
          ),
        ),
        error: (Object e, _) => ListView(
          padding: const EdgeInsetsDirectional.all(8),
          children: <Widget>[
            ErrorView(
              message: failureMessage(context, e),
              onRetry: () => ref.invalidate(cityWeatherProvider(cityId)),
            ),
          ],
        ),
        data: (CachedWeather cached) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(cityWeatherProvider(cityId));
            try {
              await ref.read(cityWeatherProvider(cityId).future);
            } catch (_) {
              // Error surfaces through the provider state.
            }
          },
          child: ListView(
            padding: const EdgeInsetsDirectional.all(8),
            children: <Widget>[
              if (cached.fromCache)
                OfflineBanner(
                  text: l10n.offlineBanner(
                    formatClockTime(context, cached.data.fetchedAt),
                  ),
                ),
              _CurrentCard(
                city: city,
                lang: lang,
                cached: cached,
                unit: unit,
              ),
              _HourlyStrip(weather: cached.data, unit: unit),
              _DailyList(weather: cached.data, unit: unit),
            ],
          ),
        ),
      ),
    );
  }
}

class _CurrentCard extends StatelessWidget {
  const _CurrentCard({
    required this.city,
    required this.lang,
    required this.cached,
    required this.unit,
  });

  final City? city;
  final String lang;
  final CachedWeather cached;
  final TempUnit unit;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final CurrentWeather current = cached.data.current;
    final List<DailyPoint> daily = cached.data.daily;
    final String minMax = daily.isEmpty
        ? ''
        : l10n.todayMinMax(
            formatTemp(daily.first.minC, unit),
            formatTemp(daily.first.maxC, unit),
          );
    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(20),
        child: Column(
          children: <Widget>[
            if (city != null)
              Text(city!.region, style: theme.textTheme.bodyMedium),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  formatTemp(current.temperatureC, unit),
                  style: theme.textTheme.displayLarge,
                ),
                WeatherIcon(
                  code: current.weatherCode,
                  isDay: current.isDay,
                  semanticLabel: wmoLabel(l10n, current.weatherCode),
                  size: 72,
                ),
              ],
            ),
            Text(
              wmoLabel(l10n, current.weatherCode),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(l10n.feelsLike(formatTemp(current.feelsLikeC, unit))),
            if (minMax.isNotEmpty) Text(minMax),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _Fact(
                  icon: Icons.water_drop_outlined,
                  label: l10n.humidity,
                  value: l10n.humidityValue(current.humidity.toString()),
                ),
                _Fact(
                  icon: Icons.air_outlined,
                  label: l10n.windSpeed,
                  value: l10n.windValue(
                    current.windSpeedKmh.toStringAsFixed(0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.lastUpdated(
                '${formatClockTime(context, cached.data.fetchedAt)}'
                ' · ${updatedAgoLabel(l10n, cached.data.fetchedAt)}',
              ),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      children: <Widget>[
        Icon(icon, semanticLabel: label),
        Text(label, style: theme.textTheme.bodySmall),
        Text(value, style: theme.textTheme.titleSmall),
      ],
    );
  }
}

class _HourlyStrip extends StatelessWidget {
  const _HourlyStrip({required this.weather, required this.unit});

  final WeatherData weather;
  final TempUnit unit;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String locale = Localizations.localeOf(context).toString();
    final List<HourlyPoint> hours = weather.next24Hours();
    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              l10n.hourlyTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: hours.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (BuildContext context, int i) {
                  final HourlyPoint point = hours[i];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(DateFormat.H(locale).format(point.time)),
                      const SizedBox(height: 4),
                      WeatherIcon(
                        code: point.weatherCode,
                        isDay: _isDayHour(point.time.hour),
                        semanticLabel: wmoLabel(l10n, point.weatherCode),
                        size: 28,
                      ),
                      const SizedBox(height: 4),
                      Text(formatTemp(point.temperatureC, unit)),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyList extends StatelessWidget {
  const _DailyList({required this.weather, required this.unit});

  final WeatherData weather;
  final TempUnit unit;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String locale = Localizations.localeOf(context).toString();
    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              l10n.dailyTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            for (int i = 0; i < weather.daily.length; i++)
              Builder(
                builder: (BuildContext context) {
                  final DailyPoint day = weather.daily[i];
                  final String title = i == 0
                      ? l10n.today
                      : DateFormat.EEEE(locale).format(day.date);
                  return ListTile(
                    contentPadding: EdgeInsetsDirectional.zero,
                    leading: WeatherIcon(
                      code: day.weatherCode,
                      isDay: true,
                      semanticLabel: wmoLabel(l10n, day.weatherCode),
                      size: 32,
                    ),
                    title: Text(title),
                    subtitle: Text(
                      DateFormat.MMMd(locale).format(day.date),
                    ),
                    trailing: Text(
                      '${formatTemp(day.minC, unit)} / '
                      '${formatTemp(day.maxC, unit)}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
