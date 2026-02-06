import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import '../services/open_meteo_service.dart';

class SelectedLocation {
  final String name;
  final double latitude;
  final double longitude;
  const SelectedLocation({required this.name, required this.latitude, required this.longitude});
}

class LocationNotifier extends Notifier<SelectedLocation?> {
  static const _nameKey = 'selected_location_name';
  static const _latKey = 'selected_location_lat';
  static const _lonKey = 'selected_location_lon';
  static const _useGpsKey = 'use_device_location';
  static const _favoritesKey = 'favorite_locations';

  @override
  SelectedLocation? build() {
    _load();
    return null;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_nameKey);
    final lat = prefs.getDouble(_latKey);
    final lon = prefs.getDouble(_lonKey);
    if (name != null && lat != null && lon != null) {
      state = SelectedLocation(name: name, latitude: lat, longitude: lon);
    }
    final useGps = prefs.getBool(_useGpsKey) ?? false;
    if (useGps && state == null) {
      await detectCurrentLocation();
    }
  }

  Future<void> setLocation(SelectedLocation loc) async {
    state = loc;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, loc.name);
    await prefs.setDouble(_latKey, loc.latitude);
    await prefs.setDouble(_lonKey, loc.longitude);
  }

  Future<void> setUseDeviceLocation(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_useGpsKey, enabled);
    if (enabled) {
      await detectCurrentLocation();
    }
  }

  Future<void> detectCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
      return;
    }
    final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
    final svc = OpenMeteoService();
    
    // Try to get the actual city name with better error handling
    String locationName;
    try {
      final cityName = await svc.reverseGeocode(pos.latitude, pos.longitude);
      if (cityName != null && cityName.isNotEmpty) {
        locationName = cityName;
      } else {
        // If reverse geocoding returns empty, use coordinates temporarily
        locationName = '${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}';
      }
    } catch (e) {
      // If reverse geocoding fails completely, use coordinates
      locationName = '${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}';
    }
    
    await setLocation(SelectedLocation(name: locationName, latitude: pos.latitude, longitude: pos.longitude));
  }

  Future<void> toggleFavorite() async {
    if (state == null) return;
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getString(_favoritesKey) ?? '[]';
    final List<dynamic> favorites = json.decode(favoritesJson);
    
    // Check if current location is already favorited
    final currentLocation = {
      'name': state!.name,
      'latitude': state!.latitude,
      'longitude': state!.longitude,
    };
    
    final isFavorite = favorites.any((fav) =>
      fav['name'] == state!.name &&
      (fav['latitude'] as double).toStringAsFixed(6) == state!.latitude.toStringAsFixed(6) &&
      (fav['longitude'] as double).toStringAsFixed(6) == state!.longitude.toStringAsFixed(6)
    );
    
    if (isFavorite) {
      // Remove from favorites
      favorites.removeWhere((fav) =>
        fav['name'] == state!.name &&
        (fav['latitude'] as double).toStringAsFixed(6) == state!.latitude.toStringAsFixed(6) &&
        (fav['longitude'] as double).toStringAsFixed(6) == state!.longitude.toStringAsFixed(6)
      );
    } else {
      // Add to favorites
      favorites.add(currentLocation);
    }
    
    await prefs.setString(_favoritesKey, json.encode(favorites));
  }
}

final locationProvider = NotifierProvider<LocationNotifier, SelectedLocation?>(
  LocationNotifier.new,
);

final isFavoriteProvider = FutureProvider<bool>((ref) async {
  final loc = ref.watch(locationProvider);
  if (loc == null) return false;
  final prefs = await SharedPreferences.getInstance();
  final favoritesJson = prefs.getString(LocationNotifier._favoritesKey) ?? '[]';
  final List<dynamic> favorites = json.decode(favoritesJson);
  
  return favorites.any((fav) =>
    fav['name'] == loc.name &&
    (fav['latitude'] as double).toStringAsFixed(6) == loc.latitude.toStringAsFixed(6) &&
    (fav['longitude'] as double).toStringAsFixed(6) == loc.longitude.toStringAsFixed(6)
  );
});

final favoriteLocationsProvider = FutureProvider<List<SelectedLocation>>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final favoritesJson = prefs.getString(LocationNotifier._favoritesKey) ?? '[]';
  final List<dynamic> favorites = json.decode(favoritesJson);
  
  return favorites.map((fav) => SelectedLocation(
    name: fav['name'],
    latitude: fav['latitude'],
    longitude: fav['longitude'],
  )).toList();
});
