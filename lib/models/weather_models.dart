import 'package:flutter/foundation.dart';

enum WeatherCondition {
  sunny,
  partlyCloudy,
  cloudy,
  rain,
  thunderstorm,
  snow,
}

class WeatherData {
  final double temperature;
  final WeatherCondition condition;
  final String conditionText;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final String windDirection;
  final int pressure;
  final double visibility;
  final int uvIndex;
  final String sunrise;
  final String sunset;
  final String cityName;

  WeatherData({
    required this.temperature,
    required this.condition,
    required this.conditionText,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.pressure,
    required this.visibility,
    required this.uvIndex,
    required this.sunrise,
    required this.sunset,
    required this.cityName,
  });
}

class HourlyForecast {
  final String time;
  final WeatherCondition condition;
  final double temperature;
  final int precipitationChance;

  HourlyForecast({
    required this.time,
    required this.condition,
    required this.temperature,
    required this.precipitationChance,
  });
}

class DailyForecast {
  final String day;
  final String date;
  final int precipitationChance;
  final WeatherCondition condition;
  final double highTemp;
  final double lowTemp;

  DailyForecast({
    required this.day,
    required this.date,
    required this.precipitationChance,
    required this.condition,
    required this.highTemp,
    required this.lowTemp,
  });
}

class LocationData {
  final String name;
  final bool isFavorite;

  LocationData({
    required this.name,
    this.isFavorite = false,
  });
}
