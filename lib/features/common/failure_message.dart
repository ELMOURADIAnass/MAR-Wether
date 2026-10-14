// Maps typed failures to localized user-facing messages.
import 'package:flutter/widgets.dart';

import 'package:mar_weather/core/errors/app_failure.dart';
import 'package:mar_weather/l10n/app_localizations.dart';
import 'package:mar_weather/providers/providers.dart';

/// Short message for inline error views with a retry button.
String failureMessage(BuildContext context, Object error) {
  final AppLocalizations l10n = AppLocalizations.of(context);
  final AppFailure? failure = error is WeatherFailure
      ? error.failure
      : null;
  return switch (failure) {
    NetworkFailure() || TimeoutFailure() => l10n.errorNetwork,
    ServerFailure() || ParseFailure() => l10n.errorServer,
    LocationFailure() => l10n.errorNetwork,
    null => l10n.errorServer,
  };
}
