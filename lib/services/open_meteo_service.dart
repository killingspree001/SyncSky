import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_models.dart';

class CityResult {
  final String name;
  final double latitude;
  final double longitude;
  final String countryCode;

  CityResult({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.countryCode,
  });
}

class OpenMeteoService {
  static const _geocodeBase = 'https://geocoding-api.open-meteo.com/v1/search';
  static const _forecastBase = 'https://api.open-meteo.com/v1/forecast';
  static const _reverseBase = 'https://geocoding-api.open-meteo.com/v1/reverse';

  Future<List<CityResult>> searchCities(String query, {int count = 10, String language = 'en'}) async {
    final uri = Uri.parse('$_geocodeBase?name=$query&count=$count&language=$language&format=json');
    final res = await http.get(uri);
    if (res.statusCode != 200) return [];
    final data = json.decode(res.body) as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>?;
    if (results == null) return [];
    return results.map((e) {
      return CityResult(
        name: e['name'],
        latitude: (e['latitude'] as num).toDouble(),
        longitude: (e['longitude'] as num).toDouble(),
        countryCode: (e['country_code'] ?? '') as String,
      );
    }).toList();
  }

  Future<String?> reverseGeocode(double latitude, double longitude, {String language = 'en'}) async {
    // Try Open-Meteo first - get just the city name
    try {
      final uri = Uri.parse('$_reverseBase?latitude=$latitude&longitude=$longitude&language=$language&format=json');
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final data = json.decode(res.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>?;
        if (results != null && results.isNotEmpty) {
          final r = results.first as Map<String, dynamic>;
          final name = (r['name'] ?? '') as String;
          // Return just the city/town name, not the full address
          if (name.isNotEmpty) return name;
        }
      }
    } catch (e) {
      // Continue to fallback
    }

    // Fallback to OpenStreetMap Nominatim - get just the local area name
    try {
      final nominatimUri = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude&zoom=18&addressdetails=1');
      final res = await http.get(nominatimUri, headers: {'User-Agent': 'SyncSkyWeatherApp/1.0'});
      if (res.statusCode == 200) {
        final data = json.decode(res.body) as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>?;
        if (address != null) {
          // Get just the most specific local name, not the full address
          final village = address['village'] as String?;
          final town = address['town'] as String?;
          final city = address['city'] as String?;
          final municipality = address['municipality'] as String?;
          
          // Return only the most specific local name
          if (village?.isNotEmpty == true) return village!;
          if (town?.isNotEmpty == true) return town!;
          if (city?.isNotEmpty == true) return city!;
          if (municipality?.isNotEmpty == true) return municipality!;
        }
      }
    } catch (e) {
      // Continue to next fallback
    }

    // Final fallback: Use Google Maps API - extract just the city name
    try {
      final googleUri = Uri.parse('https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&result_type=locality');
      final res = await http.get(googleUri);
      if (res.statusCode == 200) {
        final data = json.decode(res.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>?;
        if (results != null && results.isNotEmpty) {
          final firstResult = results.first as Map<String, dynamic>;
          final addressComponents = firstResult['address_components'] as List<dynamic>?;
          if (addressComponents != null) {
            // Look for locality component (city/town name)
            for (final component in addressComponents) {
              final comp = component as Map<String, dynamic>;
              final types = comp['types'] as List<dynamic>?;
              if (types != null && types.contains('locality')) {
                final name = comp['long_name'] as String?;
                if (name?.isNotEmpty == true) return name!;
              }
            }
          }
        }
      }
    } catch (e) {
      // All fallbacks failed
    }

    return null;
  }


  Future<(WeatherData, List<HourlyForecast>, List<DailyForecast>)?> fetchWeather({
    required double latitude,
    required double longitude,
    String timezone = 'auto',
  }) async {
    final params = {
      'latitude': latitude.toStringAsFixed(6),
      'longitude': longitude.toStringAsFixed(6),
      'timezone': timezone,
      'current': [
        'temperature_2m',
        'relative_humidity_2m',
        'pressure_msl',
        'wind_speed_10m',
        'wind_direction_10m',
        'weather_code',
        'visibility',
        'uv_index',
      ].join(','),
      'hourly': [
        'temperature_2m',
        'precipitation_probability',
      ].join(','),
      'daily': [
        'temperature_2m_max',
        'temperature_2m_min',
        'precipitation_probability_mean',
        'sunrise',
        'sunset',
      ].join(','),
    };
    final uri = Uri.parse(_forecastBase).replace(queryParameters: params);
    final res = await http.get(uri);
    if (res.statusCode != 200) return null;
    final data = json.decode(res.body) as Map<String, dynamic>;

    final current = data['current'] as Map<String, dynamic>;
    final daily = data['daily'] as Map<String, dynamic>;
    final hourly = data['hourly'] as Map<String, dynamic>;
    final utcOffsetSeconds = (data['utc_offset_seconds'] ?? 0) as int;
    final nowLocal = DateTime.now().toUtc().add(Duration(seconds: utcOffsetSeconds));
    final nowHourLocal = DateTime(nowLocal.year, nowLocal.month, nowLocal.day, nowLocal.hour);

    final sunriseIso = (daily['sunrise'] as List).isNotEmpty ? (daily['sunrise'] as List).first as String : '';
    final sunsetIso = (daily['sunset'] as List).isNotEmpty ? (daily['sunset'] as List).first as String : '';

    final visibilityMeters = (current['visibility'] ?? 10000) as num;
    final visibilityKm = visibilityMeters.toDouble() / 1000.0;

    final weatherCode = ((current['weather_code'] ?? 2) as num).toInt();
    var cond = _mapWeatherCode(weatherCode);
    final tempC = (current['temperature_2m'] as num).toDouble();
    if (cond == WeatherCondition.partlyCloudy && tempC >= 32.0) {
      cond = WeatherCondition.sunny;
    }

    final w = WeatherData(
      temperature: tempC,
      condition: cond,
      conditionText: _textFromCondition(cond),
      feelsLike: tempC,
      humidity: (current['relative_humidity_2m'] as num).toInt(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      windDirection: _dirText((current['wind_direction_10m'] as num).toDouble()),
      pressure: (current['pressure_msl'] as num).toInt(),
      visibility: visibilityKm,
      uvIndex: ((current['uv_index'] ?? 5) as num).toInt(),
      sunrise: sunriseIso.isNotEmpty ? _formatHm(sunriseIso) : '',
      sunset: sunsetIso.isNotEmpty ? _formatHm(sunsetIso) : '',
      cityName: '',
    );

    final hours = <HourlyForecast>[];
    final hTimes = (hourly['time'] as List).cast<String>();
    final hTemps = (hourly['temperature_2m'] as List).cast<num>();
    final hPrecips = (hourly['precipitation_probability'] as List).cast<num>();
    int startIdx = 0;
    for (var i = 0; i < hTimes.length; i++) {
      final t = DateTime.parse(hTimes[i]);
      final tHour = DateTime(t.year, t.month, t.day, t.hour);
      if (!tHour.isBefore(nowHourLocal)) {
        startIdx = i;
        break;
      }
    }
    final endIdx = (startIdx + 24).clamp(startIdx, hTimes.length);
    for (var i = startIdx; i < endIdx; i++) {
      hours.add(HourlyForecast(
        time: i == startIdx ? 'Now' : _formatHour(hTimes[i]),
        condition: cond,
        temperature: hTemps[i].toDouble(),
        precipitationChance: hPrecips[i].toInt(),
      ));
    }

    final days = <DailyForecast>[];
    final dTimes = (daily['time'] as List).cast<String>();
    final dMax = (daily['temperature_2m_max'] as List).cast<num>();
    final dMin = (daily['temperature_2m_min'] as List).cast<num>();
    final dPrecip = (daily['precipitation_probability_mean'] as List).cast<num>();
    for (var i = 0; i < dTimes.length && i < 7; i++) {
      days.add(DailyForecast(
        day: _weekday(dTimes[i]),
        date: _formatDate(dTimes[i]),
        precipitationChance: dPrecip[i].toInt(),
        condition: cond,
        highTemp: dMax[i].toDouble(),
        lowTemp: dMin[i].toDouble(),
      ));
    }

    return (w, hours, days);
  }

  WeatherCondition _mapWeatherCode(int code) {
    if (code == 0 || code == 1) return WeatherCondition.sunny;
    if (code == 2) return WeatherCondition.partlyCloudy;
    if ([3].contains(code)) return WeatherCondition.cloudy;
    if ([51, 53, 55, 61, 63, 65].contains(code)) return WeatherCondition.rain;
    if ([95, 96, 99].contains(code)) return WeatherCondition.thunderstorm;
    if ([71, 73, 75, 77, 85, 86].contains(code)) return WeatherCondition.snow;
    return WeatherCondition.cloudy;
  }

  String _textFromCondition(WeatherCondition c) {
    switch (c) {
      case WeatherCondition.sunny:
        return 'Sunny';
      case WeatherCondition.partlyCloudy:
        return 'Partly Cloudy';
      case WeatherCondition.cloudy:
        return 'Cloudy';
      case WeatherCondition.rain:
        return 'Rain';
      case WeatherCondition.thunderstorm:
        return 'Thunderstorm';
      case WeatherCondition.snow:
        return 'Snow';
    }
  }

  String _dirText(double deg) {
    const dirs = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final idx = ((deg / 45) % 8).round() % 8;
    return dirs[idx];
  }

  String _formatHour(String iso) {
    final t = DateTime.parse(iso);
    final h = t.hour;
    final suffix = h >= 12 ? 'PM' : 'AM';
    final hour = h % 12 == 0 ? 12 : h % 12;
    return '$hour $suffix';
  }

  String _formatHm(String iso) {
    final t = DateTime.parse(iso);
    final h = t.hour;
    final m = t.minute.toString().padLeft(2, '0');
    final suffix = h >= 12 ? 'PM' : 'AM';
    final hour = h % 12 == 0 ? 12 : h % 12;
    return '$hour:$m $suffix';
  }

  String _formatDate(String iso) {
    final t = DateTime.parse(iso);
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[t.month - 1]} ${t.day}';
  }

  String _weekday(String iso) {
    final t = DateTime.parse(iso);
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[t.weekday - 1];
  }
}
