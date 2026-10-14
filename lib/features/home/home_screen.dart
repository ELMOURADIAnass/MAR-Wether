// Home: search bar with GPS button, selected-city card, GPS card,
// favorites strip, last-updated timestamp.
//
// Search results replace the body while the query is non-empty.
// All insets/alignment are directional for full RTL support.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mar_weather/core/errors/app_failure.dart';
import 'package:mar_weather/core/theme/app_theme.dart';
import 'package:mar_weather/core/utils/temperature.dart';
import 'package:mar_weather/core/utils/time_format.dart';
import 'package:mar_weather/data/models/city.dart';
import 'package:mar_weather/data/weather_repository.dart';
import 'package:mar_weather/features/common/error_view.dart';
import 'package:mar_weather/features/common/failure_message.dart';
import 'package:mar_weather/features/common/loading_skeleton.dart';
import 'package:mar_weather/features/common/offline_banner.dart';
import 'package:mar_weather/features/common/weather_icon.dart';
import 'package:mar_weather/features/common/wmo_label.dart';
import 'package:mar_weather/features/common/zellige_header.dart';
import 'package:mar_weather/l10n/app_localizations.dart';
import 'package:mar_weather/providers/providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String query = ref.watch(searchQueryProvider);
    final bool searchOpen =
        ref.watch(searchActiveProvider) || query.isNotEmpty;
    return Scaffold(
      body: Column(
        children: <Widget>[
          const _Header(),
          if (searchOpen)
            const Expanded(child: _SearchResults())
          else
            const Expanded(child: _HomeBody()),
        ],
      ),
    );
  }
}

/// Gradient header with zellige pattern, title row and search row.
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);
    // Gradient + pattern wrap the content (instead of a Stack with an
    // empty background box, which collapses to zero size and leaves
    // the white title on the light background).
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.headerGradient(theme.brightness),
        borderRadius: const BorderRadiusDirectional.only(
          bottomStart: Radius.circular(24),
          bottomEnd: Radius.circular(24),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: ZelligeBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 16),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text(
                      'MAR-Wether',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.settings,
                      icon: const Icon(
                        Icons.settings_outlined,
                        color: Colors.white,
                      ),
                      onPressed: () => context.push('/settings'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const _SearchRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Search field (300 ms debounce) + GPS button.
class _SearchRow extends ConsumerStatefulWidget {
  const _SearchRow();

  @override
  ConsumerState<_SearchRow> createState() => _SearchRowState();
}

class _SearchRowState extends ConsumerState<_SearchRow> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(searchQueryProvider.notifier).set(value);
    });
  }

  Future<void> _onLocate() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    await ref.read(gpsProvider.notifier).locate();
    if (!mounted) {
      return;
    }
    final AsyncValue<GpsWeather?> state = ref.read(gpsProvider);
    if (!state.hasError) {
      return;
    }
    final Object? error = state.error;
    final AppFailure? failure = error is WeatherFailure
        ? error.failure
        : null;
    if (failure is! LocationFailure) {
      _showNotice(l10n.errorTitle, failureMessage(context, error ?? ''));
      return;
    }
    switch (failure.kind) {
      case LocationFailureKind.permissionDenied:
        _showAsk(
          l10n.permissionDeniedTitle,
          l10n.permissionDeniedMessage,
          l10n.requestAgain,
          () => ref.read(gpsProvider.notifier).locate(),
        );
      case LocationFailureKind.permissionDeniedForever:
        _showAsk(
          l10n.permissionDeniedForeverTitle,
          l10n.permissionDeniedForeverMessage,
          l10n.openAppSettings,
          () => ref.read(locationServiceProvider).openAppSettings(),
        );
      case LocationFailureKind.serviceDisabled:
        _showAsk(
          l10n.serviceDisabledTitle,
          l10n.serviceDisabledMessage,
          l10n.openLocationSettings,
          () => ref.read(locationServiceProvider).openLocationSettings(),
        );
      case LocationFailureKind.timeout:
      case LocationFailureKind.unknown:
        _showNotice(l10n.errorTitle, failureMessage(context, error ?? ''));
    }
  }

  void _showNotice(String title, String message) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  void _showAsk(
    String title,
    String message,
    String action,
    Future<void> Function() onAction,
  ) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              onAction();
            },
            child: Text(action),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String query = ref.watch(searchQueryProvider);
    final bool searchOpen = ref.watch(searchActiveProvider);
    if (_controller.text != query && query.isEmpty) {
      _controller.clear();
    }

    void closeSearch() {
      _controller.clear();
      _debounce?.cancel();
      ref.read(searchQueryProvider.notifier).clear();
      ref.read(searchActiveProvider.notifier).setActive(false);
    }

    return Row(
      children: <Widget>[
        Expanded(
          child: TextField(
            key: const Key('searchField'),
            controller: _controller,
            onChanged: _onChanged,
            onTap: () =>
                ref.read(searchActiveProvider.notifier).setActive(true),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: l10n.searchHint,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: query.isEmpty && !searchOpen
                  ? null
                  : IconButton(
                      tooltip: l10n.cancel,
                      icon: const Icon(Icons.clear),
                      onPressed: closeSearch,
                    ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: IconButton(
            tooltip: l10n.locateMe,
            icon: const Icon(Icons.my_location),
            onPressed: _onLocate,
          ),
        ),
      ],
    );
  }
}

/// Results overlay list under the search bar.
class _SearchResults extends ConsumerWidget {
  const _SearchResults();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<List<City>> citiesAsync = ref.watch(allCitiesProvider);
    return citiesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object e, _) => ListView(
        padding: const EdgeInsetsDirectional.all(8),
        children: <Widget>[
          ErrorView(
            message: failureMessage(context, e),
            onRetry: () => ref.invalidate(allCitiesProvider),
          ),
        ],
      ),
      data: (_) {
        final List<City> results = ref.watch(searchResultsProvider);
        final String query = ref.watch(searchQueryProvider);
        if (query.trim().isEmpty) {
          // Browse mode: every city, in dataset (region-grouped) order.
          final List<City> all = ref.watch(allCitiesProvider).maybeWhen(
            data: (List<City> list) => list,
            orElse: () => const <City>[],
          );
          if (all.isEmpty) {
            return Center(child: Text(l10n.emptySearch));
          }
          return _CityList(cities: all);
        }
        if (results.isEmpty) {
          return Center(child: Text(l10n.noResults));
        }
        return _CityList(cities: results);
      },
    );
  }
}

/// Scrollable city list shared by browse-all and filtered results.
class _CityList extends ConsumerWidget {
  const _CityList({required this.cities});

  final List<City> cities;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String lang = Localizations.localeOf(context).languageCode;
    return ListView.separated(
      padding: const EdgeInsetsDirectional.all(8),
      itemCount: cities.length,
      separatorBuilder: (_, _) => const SizedBox(height: 4),
      itemBuilder: (BuildContext context, int i) {
        final City city = cities[i];
        return Card(
          child: ListTile(
            title: Text(city.nameFor(lang)),
            subtitle: Text(city.region),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              ref.read(searchQueryProvider.notifier).clear();
              ref.read(searchActiveProvider.notifier).setActive(false);
              ref.read(selectedCityProvider.notifier).select(city.id);
              context.push('/city/${city.id}');
            },
          ),
        );
      },
    );
  }
}

/// Default body: selected-city card, GPS card, favorites, timestamp.
class _HomeBody extends ConsumerWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String selectedId = ref.watch(selectedCityProvider);
    final AsyncValue<CachedWeather> weatherAsync = ref.watch(
      cityWeatherProvider(selectedId),
    );
    final AsyncValue<GpsWeather?> gps = ref.watch(gpsProvider);
    final bool showGps =
        gps.isLoading || gps.hasValue && gps.value != null || gps.hasError;
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(cityWeatherProvider(selectedId));
        try {
          await ref.read(cityWeatherProvider(selectedId).future);
        } catch (_) {
          // Error surfaces through the provider state.
        }
      },
      child: ListView(
        padding: const EdgeInsetsDirectional.all(8),
        children: <Widget>[
          if (showGps) const _GpsCard(),
          _SelectedCityCard(weatherAsync: weatherAsync),
          const _FavoritesStrip(),
          Center(
            child: Padding(
              padding: const EdgeInsetsDirectional.all(8),
              child: weatherAsync.maybeWhen(
                data: (CachedWeather cached) => Text(
                  l10n.lastUpdated(
                    '${formatClockTime(context, cached.data.fetchedAt)}'
                    ' · ${updatedAgoLabel(l10n, cached.data.fetchedAt)}',
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                orElse: () => const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Large card for the selected city (tap → detail).
class _SelectedCityCard extends ConsumerWidget {
  const _SelectedCityCard({required this.weatherAsync});

  final AsyncValue<CachedWeather> weatherAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String selectedId = ref.watch(selectedCityProvider);
    final TempUnit unit = ref.watch(unitProvider);
    final String lang = Localizations.localeOf(context).languageCode;
    final City? city = ref
        .watch(allCitiesProvider)
        .maybeWhen(
          data: (List<City> list) =>
              ref.watch(citiesRepositoryProvider).byId(list, selectedId),
          orElse: () => null,
        );
    return weatherAsync.when(
      loading: () => const WeatherCardSkeleton(),
      error: (Object e, _) => ErrorView(
        message: failureMessage(context, e),
        onRetry: () => ref.invalidate(cityWeatherProvider(selectedId)),
      ),
      data: (CachedWeather cached) {
        final current = cached.data.current;
        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => context.push('/city/$selectedId'),
            child: Padding(
              padding: const EdgeInsetsDirectional.all(20),
              child: Column(
                children: <Widget>[
                  if (cached.fromCache)
                    OfflineBanner(
                      text: l10n.offlineBanner(
                        formatClockTime(context, cached.data.fetchedAt),
                      ),
                    ),
                  Text(
                    city?.nameFor(lang) ?? selectedId,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  if (city != null) Text(city.region),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text(
                        formatTemp(current.temperatureC, unit),
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      WeatherIcon(
                        code: current.weatherCode,
                        isDay: current.isDay,
                        semanticLabel: wmoLabel(l10n, current.weatherCode),
                        size: 64,
                      ),
                    ],
                  ),
                  Text(wmoLabel(l10n, current.weatherCode)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// GPS result card: "My location" + nearest city + distance, or the
/// outside/fallback notices.
class _GpsCard extends ConsumerWidget {
  const _GpsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<GpsWeather?> gps = ref.watch(gpsProvider);
    final TempUnit unit = ref.watch(unitProvider);
    final String lang = Localizations.localeOf(context).languageCode;
    return gps.when(
      loading: () => const WeatherCardSkeleton(),
      error: (Object e, _) => ErrorView(
        message: failureMessage(context, e),
        onRetry: () => ref.read(gpsProvider.notifier).locate(),
      ),
      data: (GpsWeather? data) {
        if (data == null) {
          return const SizedBox.shrink();
        }
        final current = data.weather.data.current;
        final List<String> notices = <String>[];
        if (!data.insideMorocco) {
          notices.add(l10n.outsideMoroccoNotice);
        } else if (data.fallbackCityId != null) {
          notices.add(l10n.fallbackCityNotice);
        } else {
          if (data.usedFallbackPosition) {
            notices.add(l10n.fallbackPositionNotice);
          }
          final City? near = data.nearestCity;
          if (near != null) {
            notices.add(
              l10n.nearestCityIs(
                near.nameFor(lang),
                (data.distanceKm ?? 0).toStringAsFixed(1),
              ),
            );
          }
        }
        return Card(
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: Padding(
            padding: const EdgeInsetsDirectional.all(16),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        l10n.myLocation,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    Text(
                      formatTemp(current.temperatureC, unit),
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    WeatherIcon(
                      code: current.weatherCode,
                      isDay: current.isDay,
                      semanticLabel: wmoLabel(l10n, current.weatherCode),
                      size: 48,
                    ),
                  ],
                ),
                for (final String notice in notices)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(top: 4),
                    child: Text(
                      notice,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Horizontal list of favorite cities with live temperatures.
class _FavoritesStrip extends ConsumerWidget {
  const _FavoritesStrip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<String> favorites = ref.watch(favoritesProvider);
    final TempUnit unit = ref.watch(unitProvider);
    final String lang = Localizations.localeOf(context).languageCode;
    if (favorites.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 4),
          child: Text(
            l10n.favorites,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        SizedBox(
          height: 132,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 8),
            itemCount: favorites.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (BuildContext context, int i) {
              final String id = favorites[i];
              final City? city = ref
                  .watch(allCitiesProvider)
                  .maybeWhen(
                    data: (List<City> list) => ref
                        .watch(citiesRepositoryProvider)
                        .byId(list, id),
                    orElse: () => null,
                  );
              final AsyncValue<CachedWeather> weather = ref.watch(
                cityWeatherProvider(id),
              );
              return SizedBox(
                width: 150,
                child: Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => context.push('/city/$id'),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            city?.nameFor(lang) ?? id,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 4),
                          weather.maybeWhen(
                            data: (CachedWeather cached) => Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                WeatherIcon(
                                  code: cached.data.current.weatherCode,
                                  isDay: cached.data.current.isDay,
                                  semanticLabel: wmoLabel(
                                    l10n,
                                    cached.data.current.weatherCode,
                                  ),
                                  size: 28,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  formatTemp(
                                    cached.data.current.temperatureC,
                                    unit,
                                  ),
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                              ],
                            ),
                            orElse: () => const SizedBox(
                              height: 28,
                              width: 28,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
