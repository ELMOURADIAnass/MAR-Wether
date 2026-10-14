// "Updated … ago" labels and local time formatting with intl.
//
// Western digits are guaranteed: counts are formatted with plain
// toString and clock times with DateFormat.Hm on the active locale
// (fr/ar/en all render Latin digits via these patterns).
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'package:mar_weather/l10n/app_localizations.dart';

/// Relative label such as "il y a 5 min" in the active locale.
String updatedAgoLabel(AppLocalizations l10n, DateTime fetchedAtUtc) {
  final int minutes = DateTime.now()
      .toUtc()
      .difference(fetchedAtUtc)
      .inMinutes;
  if (minutes < 1) {
    return l10n.updatedJustNow;
  }
  if (minutes < 60) {
    return l10n.updatedMinutesAgo(minutes.toString());
  }
  return l10n.updatedHoursAgo((minutes ~/ 60).toString());
}

/// Local clock time (HH:mm) in the active locale.
String formatClockTime(BuildContext context, DateTime fetchedAtUtc) {
  final String locale = Localizations.localeOf(context).toString();
  return DateFormat.Hm(locale).format(fetchedAtUtc.toLocal());
}
