// Temperature unit handling. Open-Meteo is always requested in
// Celsius; Fahrenheit conversion happens locally for display.
// Western digits (0-9) are used in all languages — plain
// toStringAsFixed never emits locale-specific digits.
enum TempUnit { celsius, fahrenheit }

/// Converts [celsius] to the display unit.
double displayTemp(double celsius, TempUnit unit) {
  return unit == TempUnit.fahrenheit ? celsius * 9 / 5 + 32 : celsius;
}

/// Formats e.g. `21°` / `70°F`-style compact labels.
String formatTemp(double celsius, TempUnit unit, {bool showSymbol = true}) {
  final double value = displayTemp(celsius, unit);
  final String digits = value.toStringAsFixed(0);
  if (!showSymbol) {
    return digits;
  }
  return unit == TempUnit.fahrenheit ? '$digits°F' : '$digits°C';
}

/// Parses the persisted unit string; unknown values stay Celsius.
TempUnit tempUnitFromString(String? value) {
  return value == TempUnit.fahrenheit.name ? TempUnit.fahrenheit : TempUnit.celsius;
}
