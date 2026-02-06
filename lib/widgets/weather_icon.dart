import 'package:flutter/material.dart';
import '../models/weather_models.dart';

class WeatherIcon extends StatelessWidget {
  final WeatherCondition condition;
  final double size;
  final Color? color;

  const WeatherIcon({
    super.key,
    required this.condition,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      _getIcon(),
      size: size,
      color: color ?? Colors.white,
    );
  }

  IconData _getIcon() {
    switch (condition) {
      case WeatherCondition.sunny:
        return Icons.wb_sunny_rounded;
      case WeatherCondition.partlyCloudy:
        return Icons.wb_cloudy_rounded;
      case WeatherCondition.cloudy:
        return Icons.cloud_rounded;
      case WeatherCondition.rain:
        return Icons.beach_access_rounded; // Or weather specific if available
      case WeatherCondition.thunderstorm:
        return Icons.thunderstorm_rounded;
      case WeatherCondition.snow:
        return Icons.ac_unit_rounded;
    }
  }
}
