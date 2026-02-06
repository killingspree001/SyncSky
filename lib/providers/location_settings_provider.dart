import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'location_provider.dart';

class UseGpsNotifier extends Notifier<bool> {
  static const _useGpsKey = 'use_device_location';

  @override
  bool build() {
    _load();
    return false;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final val = prefs.getBool(_useGpsKey) ?? false;
    state = val;
    if (val) {
      await ref.read(locationProvider.notifier).detectCurrentLocation();
    }
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_useGpsKey, enabled);
    if (enabled) {
      await ref.read(locationProvider.notifier).detectCurrentLocation();
    }
  }
}

final useGpsProvider = NotifierProvider<UseGpsNotifier, bool>(
  UseGpsNotifier.new,
);
