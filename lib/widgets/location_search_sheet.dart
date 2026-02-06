import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/open_meteo_service.dart';
import '../providers/location_provider.dart';
import '../providers/location_provider.dart' as lp;

class LocationSearchSheet extends ConsumerStatefulWidget {
  const LocationSearchSheet({super.key});

  @override
  ConsumerState<LocationSearchSheet> createState() => _LocationSearchSheetState();
}

class _LocationSearchSheetState extends ConsumerState<LocationSearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<CityResult> _results = [];
  bool _loading = false;
  Future<List<CityResult>>? _pending;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search city...',
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: const Icon(Icons.search_rounded, color: Colors.white54),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (q) {
                    _runSearch(q);
                  },
                ),
                const SizedBox(height: 30),
                if (_loading)
                  const Center(child: CircularProgressIndicator())
                else if (_results.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final r = _results[index];
                        return GestureDetector(
                          onTap: () async {
                            await ref.read(locationProvider.notifier).setLocation(
                                  SelectedLocation(name: r.name, latitude: r.latitude, longitude: r.longitude),
                                );
                            if (mounted) Navigator.of(context).pop();
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.location_on_outlined, color: Colors.white70),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    r.name,
                                    style: const TextStyle(color: Colors.white, fontSize: 16),
                                  ),
                                ),
                                Text(
                                  r.countryCode,
                                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                else ...[
                const Text(
                  'FAVORITES',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 15),
                _buildFavoritesGrid(),
                const SizedBox(height: 30),
                const Text(
                  'POPULAR CITIES',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 15),
                _buildPopularCitiesGrid(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _runSearch(String q) {
    if (q.trim().isEmpty) {
      setState(() {
        _results = [];
        _loading = false;
      });
      return;
    }
    setState(() {
      _loading = true;
    });
    final svc = OpenMeteoService();
    final fut = svc.searchCities(q);
    _pending = fut;
    fut.then((res) {
      if (!mounted) return;
      if (_pending != fut) return;
      setState(() {
        _results = res;
        _loading = false;
      });
    });
  }

  Widget _buildFavoritesGrid() {
    final favAsync = ref.watch(lp.favoriteLocationsProvider);
    final favorites = favAsync.value ?? [];
    if (favorites.isEmpty) {
      return const SizedBox.shrink();
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.5,
      ),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final fav = favorites[index];
        return GestureDetector(
          onTap: () async {
            await ref.read(locationProvider.notifier).setLocation(
                  SelectedLocation(name: fav.name, latitude: fav.latitude, longitude: fav.longitude),
                );
            if (mounted) Navigator.of(context).pop();
          },
          child: _CityChip(name: fav.name, isFavorite: true),
        );
      },
    );
  }

  Widget _buildPopularCitiesGrid() {
    // Popular cities with actual coordinates
    final popular = [
      _PopularCity('New York', 40.7128, -74.0060),
      _PopularCity('Paris', 48.8566, 2.3522),
      _PopularCity('Berlin', 52.5200, 13.4050),
      _PopularCity('Dubai', 25.276987, 55.296249),
      _PopularCity('Sydney', -33.8688, 151.2093),
      _PopularCity('Seoul', 37.5665, 126.9780),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.5,
      ),
      itemCount: popular.length,
      itemBuilder: (context, index) {
        final city = popular[index];
        return GestureDetector(
          onTap: () async {
            await ref.read(locationProvider.notifier).setLocation(
                  SelectedLocation(name: city.name, latitude: city.lat, longitude: city.lon),
                );
            if (mounted) Navigator.of(context).pop();
          },
          child: _CityChip(name: city.name, isFavorite: false),
        );
      },
    );
  }
}

class _PopularCity {
  final String name;
  final double lat;
  final double lon;

  _PopularCity(this.name, this.lat, this.lon);
}

class _CityChip extends StatelessWidget {
  final String name;
  final bool isFavorite;

  const _CityChip({required this.name, required this.isFavorite});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              name,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
            if (isFavorite) ...[
              const SizedBox(width: 4),
              const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
            ],
          ],
        ),
      ),
    );
  }
}
