import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/weather_provider.dart';
import 'location_search_sheet.dart';
import '../providers/location_provider.dart';
import '../providers/weather_provider.dart' as wp;

class TopActionBar extends ConsumerWidget {
  const TopActionBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavoriteAsync = ref.watch(isFavoriteProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const LocationSearchSheet(),
              );
            },
            icon: const Icon(Icons.search_rounded, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () async {
              await ref.read(locationProvider.notifier).toggleFavorite();
              ref.invalidate(isFavoriteProvider);
              ref.invalidate(favoriteLocationsProvider);
            },
            icon: Icon(
              isFavoriteAsync.value == true ? Icons.star_rounded : Icons.star_border_rounded,
              color: Colors.white,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () async {
              await ref.read(locationProvider.notifier).detectCurrentLocation();
              ref.refresh(wp.weatherProvider);
              ref.refresh(wp.hourlyForecastProvider);
              ref.refresh(wp.dailyForecastProvider);
            },
            icon: const Icon(Icons.my_location_rounded, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
            ),
            tooltip: 'Use my location',
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              ref.refresh(wp.weatherProvider);
              ref.refresh(wp.hourlyForecastProvider);
              ref.refresh(wp.dailyForecastProvider);
            },
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
            icon: const Icon(Icons.settings_rounded, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }
}
