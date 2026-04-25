import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import '../models/weather_data.dart';
import '../pages/weather/weather_page.dart';

class WeatherQuickActionCard extends StatefulWidget {
  const WeatherQuickActionCard({super.key});

  @override
  State<WeatherQuickActionCard> createState() => _WeatherQuickActionCardState();
}

class _WeatherQuickActionCardState extends State<WeatherQuickActionCard> {
  final WeatherService _weatherService = WeatherService();
  Future<WeatherData>? _weatherDataFuture;

  @override
  void initState() {
    super.initState();
    _weatherDataFuture = _weatherService.fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFFDF5FF); // Light Purple

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WeatherPage()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<WeatherData>(
          future: _weatherDataFuture,
          builder: (context, snapshot) {
            Widget iconWidget = const Icon(Icons.wb_sunny_outlined, color: Colors.black87, size: 20);
            String title = 'Weather';
            String subtitle = 'Forecast';

            if (snapshot.connectionState == ConnectionState.waiting) {
              iconWidget = const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black87),
              );
              subtitle = 'Loading...';
            } else if (snapshot.hasData) {
              final weather = snapshot.data!;
              title = 'Weather';
              subtitle = '${weather.current.temperature2m.toStringAsFixed(1)}°C';
              iconWidget = Icon(WeatherData.getWeatherIcon(weather.current.weatherCode), color: Colors.black87, size: 20);
            } else if (snapshot.hasError) {
              subtitle = 'Error data';
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: iconWidget,
                ),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
