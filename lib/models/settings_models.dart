enum TemperatureUnit {
  celsius,
  fahrenheit,
}

enum WindSpeedUnit {
  kmh,
  mph,
  ms,
}

enum AutoRefreshInterval {
  min15(15),
  min30(30),
  min60(60);

  final int minutes;
  const AutoRefreshInterval(this.minutes);
}

class SettingsState {
  final TemperatureUnit tempUnit;
  final WindSpeedUnit windUnit;
  final AutoRefreshInterval refreshInterval;
  final bool useDeviceLocation;

  SettingsState({
    required this.tempUnit,
    required this.windUnit,
    required this.refreshInterval,
    required this.useDeviceLocation,
  });

  SettingsState copyWith({
    TemperatureUnit? tempUnit,
    WindSpeedUnit? windUnit,
    AutoRefreshInterval? refreshInterval,
    bool? useDeviceLocation,
  }) {
    return SettingsState(
      tempUnit: tempUnit ?? this.tempUnit,
      windUnit: windUnit ?? this.windUnit,
      refreshInterval: refreshInterval ?? this.refreshInterval,
      useDeviceLocation: useDeviceLocation ?? this.useDeviceLocation,
    );
  }
}
