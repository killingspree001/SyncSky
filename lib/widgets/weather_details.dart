import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/weather_provider.dart';

class WeatherDetailsGrid extends ConsumerWidget {
  const WeatherDetailsGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherProvider);
    final w = weatherAsync.value;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      childAspectRatio: 1.5,
      children: [
        _DetailItem(
          label: 'VISIBILITY',
          value: w != null ? '${w.visibility.round()} km' : '-',
          icon: Icons.visibility_outlined,
        ),
        _DetailItem(
          label: 'UV INDEX',
          value: w != null ? '${w.uvIndex}' : '-',
          icon: Icons.wb_sunny_outlined,
        ),
        _DetailItem(
          label: 'HUMIDITY',
          value: w != null ? '${w.humidity}%' : '-',
          icon: Icons.water_drop_outlined,
        ),
        _DetailItem(
          label: 'WIND',
          value: w != null ? '${w.windSpeed.round()} km/h ${w.windDirection}' : '-',
          icon: Icons.air_rounded,
        ),
        _DetailItem(
          label: 'PRESSURE',
          value: w != null ? '${w.pressure} hPa' : '-',
          icon: Icons.speed_rounded,
        ),
        _DetailItem(
          label: 'FEELS LIKE',
          value: w != null ? '${w.feelsLike.round()}°' : '-',
          icon: Icons.thermostat_rounded,
        ),
      ],
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DetailItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, color: Colors.white60, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
