import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/local_storage.dart';
import 'providers/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final LocalStorage storage = await LocalStorage.load();
  runApp(
    ProviderScope(
      overrides: <Override>[
        localStorageProvider.overrideWithValue(storage),
      ],
      child: const MarWeatherApp(),
    ),
  );
}
