import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/weather_provider.dart';
import '../widgets/weather_background.dart';
import '../widgets/weather_icon.dart';
import '../widgets/top_action_bar.dart';
import '../widgets/current_weather_display.dart';
import '../widgets/hourly_forecast.dart';
import '../widgets/daily_forecast.dart';
import '../widgets/weather_details.dart';
import '../widgets/settings_drawer.dart';
import '../models/weather_models.dart';

class WeatherScreen extends ConsumerWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherProvider);
    final weather = weatherAsync.value;

    return Scaffold(
      endDrawer: const SettingsDrawer(),
      body: WeatherBackground(
        condition: weather?.condition ?? WeatherCondition.partlyCloudy,
        child: SafeArea(
          child: Column(
            children: [
              const TopActionBar(),
              Expanded(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          if (weather != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                weather.cityName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                          const SizedBox(height: 40),
                          if (weather != null)
                            CurrentWeatherDisplay(weather: weather)
                          else
                            const Center(child: CircularProgressIndicator()),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                    const SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverToBoxAdapter(
                        child: HourlyForecastWidget(),
                      ),
                    ),
                    const SliverPadding(
                      padding: EdgeInsets.all(20),
                      sliver: SliverToBoxAdapter(
                        child: DailyForecastWidget(),
                      ),
                    ),
                    const SliverPadding(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 40),
                      sliver: SliverToBoxAdapter(
                        child: WeatherDetailsGrid(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
