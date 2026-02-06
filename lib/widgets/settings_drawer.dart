import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../models/settings_models.dart';
import '../providers/location_settings_provider.dart';

class SettingsDrawer extends ConsumerWidget {
  const SettingsDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final useGps = ref.watch(useGpsProvider);

    return Drawer(
      backgroundColor: Colors.black.withOpacity(0.8),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Settings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildSectionTitle('TEMPERATURE UNIT'),
              _buildUnitToggle<TemperatureUnit>(
                ref: ref,
                current: settings.tempUnit,
                options: TemperatureUnit.values,
                onChanged: (val) => ref.read(settingsProvider.notifier).updateTempUnit(val),
                labelBuilder: (u) => u == TemperatureUnit.celsius ? 'Celsius (°C)' : 'Fahrenheit (°F)',
              ),
              _buildSectionTitle('WIND SPEED UNIT'),
              _buildUnitToggle<WindSpeedUnit>(
                ref: ref,
                current: settings.windUnit,
                options: WindSpeedUnit.values,
                onChanged: (val) => ref.read(settingsProvider.notifier).updateWindUnit(val),
                labelBuilder: (u) => u.name.toUpperCase(),
              ),
              _buildSectionTitle('AUTO REFRESH'),
              _buildUnitToggle<AutoRefreshInterval>(
                ref: ref,
                current: settings.refreshInterval,
                options: AutoRefreshInterval.values,
                onChanged: (val) => ref.read(settingsProvider.notifier).updateRefreshInterval(val),
                labelBuilder: (i) => '${i.minutes} min',
              ),
              _buildSectionTitle('LOCATION'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: SwitchListTile(
                    title: const Text('Use Device Location', style: TextStyle(color: Colors.white)),
                    subtitle: const Text('Automatically detect your location', style: TextStyle(color: Colors.white60)),
                    value: useGps,
                    onChanged: (v) => ref.read(useGpsProvider.notifier).setEnabled(v),
                    activeColor: Colors.blueAccent,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'SyncSky v1.0.0',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildUnitToggle<T>({
    required WidgetRef ref,
    required T current,
    required List<T> options,
    required Function(T) onChanged,
    required String Function(T) labelBuilder,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: options.map((option) {
            final isSelected = current == option;
            return ListTile(
              title: Text(
                labelBuilder(option),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white60,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              trailing: isSelected 
                  ? const Icon(Icons.check_circle_rounded, color: Colors.blueAccent) 
                  : null,
              onTap: () => onChanged(option),
            );
          }).toList(),
        ),
      ),
    );
  }
}
