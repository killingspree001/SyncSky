import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/weather_models.dart';
import '../services/open_meteo_service.dart';
import 'location_provider.dart';

final openMeteoServiceProvider = Provider<OpenMeteoService>((ref) {
  return OpenMeteoService();
});

class WeatherAsyncNotifier extends AsyncNotifier<WeatherData?> {
  @override
  Future<WeatherData?> build() async {
    final loc = ref.watch(locationProvider);
    if (loc == null) return null;
    final svc = ref.read(openMeteoServiceProvider);
    final result = await svc.fetchWeather(latitude: loc.latitude, longitude: loc.longitude);
    if (result == null) return null;
    final (w, _, __) = result;
    var displayName = loc.name;
    final isCoords = RegExp(r'^\s*-?\d+\.\d{1,}\s*,\s*-?\d+\.\d{1,}\s*$').hasMatch(displayName);
    if (displayName.trim().isEmpty || displayName == 'Current Location' || isCoords) {
      final resolved = await svc.reverseGeocode(loc.latitude, loc.longitude);
      if (resolved != null && resolved.isNotEmpty) {
        displayName = resolved;
        if (displayName != loc.name) {
          await ref.read(locationProvider.notifier).setLocation(
            SelectedLocation(name: displayName, latitude: loc.latitude, longitude: loc.longitude),
          );
        }
      }
    }
    return WeatherData(
      temperature: w.temperature,
      condition: w.condition,
      conditionText: w.conditionText,
      feelsLike: w.feelsLike,
      humidity: w.humidity,
      windSpeed: w.windSpeed,
      windDirection: w.windDirection,
      pressure: w.pressure,
      visibility: w.visibility,
      uvIndex: w.uvIndex,
      sunrise: w.sunrise,
      sunset: w.sunset,
      cityName: displayName,
    );
  }
}

final weatherProvider = AsyncNotifierProvider<WeatherAsyncNotifier, WeatherData?>(
  WeatherAsyncNotifier.new,
);

final hourlyForecastProvider = FutureProvider<List<HourlyForecast>>((ref) async {
  final loc = ref.watch(locationProvider);
  if (loc == null) return [];
  final svc = ref.read(openMeteoServiceProvider);
  final result = await svc.fetchWeather(latitude: loc.latitude, longitude: loc.longitude);
  if (result == null) return [];
  final (_, hours, __) = result;
  return hours;
});

final dailyForecastProvider = FutureProvider<List<DailyForecast>>((ref) async {
  final loc = ref.watch(locationProvider);
  if (loc == null) return [];
  final svc = ref.read(openMeteoServiceProvider);
  final result = await svc.fetchWeather(latitude: loc.latitude, longitude: loc.longitude);
  if (result == null) return [];
  final (_, __, days) = result;
  return days;
});
