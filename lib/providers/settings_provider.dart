import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings_models.dart';

class SettingsNotifier extends Notifier<SettingsState> {
  static const _tempUnitKey = 'temp_unit';
  static const _windUnitKey = 'wind_unit';
  static const _refreshKey = 'refresh_interval';
  static const _useGpsKey = 'use_device_location';

  @override
  SettingsState build() {
    _loadFromStorage();
    return SettingsState(
      tempUnit: TemperatureUnit.celsius,
      windUnit: WindSpeedUnit.kmh,
      refreshInterval: AutoRefreshInterval.min30,
      useDeviceLocation: false,
    );
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    
    final tempIndex = prefs.getInt(_tempUnitKey);
    final windIndex = prefs.getInt(_windUnitKey);
    final refreshIndex = prefs.getInt(_refreshKey);
    final useGps = prefs.getBool(_useGpsKey);

    state = state.copyWith(
      tempUnit: tempIndex != null ? TemperatureUnit.values[tempIndex] : null,
      windUnit: windIndex != null ? WindSpeedUnit.values[windIndex] : null,
      refreshInterval: refreshIndex != null ? AutoRefreshInterval.values[refreshIndex] : null,
      useDeviceLocation: useGps,
    );
  }

  Future<void> updateTempUnit(TemperatureUnit unit) async {
    state = state.copyWith(tempUnit: unit);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_tempUnitKey, unit.index);
  }

  Future<void> updateWindUnit(WindSpeedUnit unit) async {
    state = state.copyWith(windUnit: unit);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_windUnitKey, unit.index);
  }

  Future<void> updateRefreshInterval(AutoRefreshInterval interval) async {
    state = state.copyWith(refreshInterval: interval);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_refreshKey, interval.index);
  }

  Future<void> updateUseDeviceLocation(bool enabled) async {
    state = state.copyWith(useDeviceLocation: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_useGpsKey, enabled);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);
