// Condition icon with day/night variant and a semantic label.
import 'package:flutter/material.dart';

import 'package:mar_weather/core/utils/wmo_mapping.dart';

/// Material condition icon sized for the given context.
class WeatherIcon extends StatelessWidget {
  const WeatherIcon({
    super.key,
    required this.code,
    required this.isDay,
    required this.semanticLabel,
    this.size = 48,
  });

  final int code;
  final bool isDay;
  final String semanticLabel;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      wmoIcon(code, isDay: isDay),
      size: size,
      color: wmoColor(code, isDay: isDay),
      semanticLabel: semanticLabel,
    );
  }
}
