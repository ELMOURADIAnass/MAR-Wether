// Application root: Riverpod + go_router + Material 3 themes +
// trilingual delegates. Watching [effectiveLocaleProvider] here makes
// language switches (including RTL layout direction) instant.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mar_weather/core/theme/app_theme.dart';
import 'package:mar_weather/features/home/home_screen.dart';
import 'package:mar_weather/features/settings/privacy_screen.dart';
import 'package:mar_weather/features/settings/settings_screen.dart';
import 'package:mar_weather/features/splash/splash_screen.dart';
import 'package:mar_weather/features/weather_detail/city_detail_screen.dart';
import 'package:mar_weather/l10n/app_localizations.dart';
import 'package:mar_weather/providers/providers.dart';

final GoRouter _router = GoRouter(
  initialLocation: '/splash',
  routes: <RouteBase>[
    GoRoute(
      path: '/splash',
      builder: (BuildContext context, GoRouterState state) =>
          const SplashScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (BuildContext context, GoRouterState state) =>
          const HomeScreen(),
    ),
    GoRoute(
      path: '/city/:id',
      builder: (BuildContext context, GoRouterState state) =>
          CityDetailScreen(cityId: state.pathParameters['id'] ?? 'casablanca'),
    ),
    GoRoute(
      path: '/settings',
      builder: (BuildContext context, GoRouterState state) =>
          const SettingsScreen(),
    ),
    GoRoute(
      path: '/privacy',
      builder: (BuildContext context, GoRouterState state) =>
          const PrivacyScreen(),
    ),
  ],
);

class MarWeatherApp extends ConsumerWidget {
  const MarWeatherApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Locale locale = ref.watch(effectiveLocaleProvider);
    final ThemeMode themeMode = ref.watch(themeProvider);
    return MaterialApp.router(
      title: 'MAR-Wether',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      locale: locale,
      supportedLocales: const <Locale>[
        Locale('fr'),
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: _router,
    );
  }
}
