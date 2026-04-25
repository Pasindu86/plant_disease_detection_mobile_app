import 'package:flutter/material.dart';
import '../../services/weather_service.dart';
import '../../models/weather_data.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final WeatherService _weatherService = WeatherService();
  late Future<WeatherData> _weatherFuture;

  @override
  void initState() {
    super.initState();
    _weatherFuture = _weatherService.fetchWeather();
  }

  String _formatTime(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      int hour = date.hour;
      final ampm = hour >= 12 ? 'PM' : 'AM';
      hour = hour % 12;
      if (hour == 0) hour = 12;
      return '${hour}:00 $ampm';
    } catch (_) {
      return '';
    }
  }
  
  String _formatSunTime(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      int hour = date.hour;
      final min = date.minute.toString().padLeft(2, '0');
      final ampm = hour >= 12 ? 'PM' : 'AM';
      hour = hour % 12;
      if (hour == 0) hour = 12;
      return '${hour}:${min} $ampm';
    } catch (_) {
      return '';
    }
  }

  String _formatDay(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[date.weekday - 1];
    } catch (_) {
      return '';
    }
  }

  Widget _buildGridMetric(String label, String value, IconData icon, Color bgColor) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.black87, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Weather Forecast',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<WeatherData>(
          future: _weatherFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF1EAC50)),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading forecast:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              );
            }

            final data = snapshot.data!;
            final current = data.current;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Minimal Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.black87, size: 20),
                              const SizedBox(width: 4),
                              const Text(
                                'Galle, Sri Lanka',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            WeatherData.getWeatherDescription(current.weatherCode),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${current.temperature2m.toStringAsFixed(1)}',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: Colors.black87,
                              height: 1,
                            ),
                          ),
                          const Text(
                            '°C',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),

                  // Today's Hourly Forecast
                  const Text(
                    'Today',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 24, // Show next 24 hours
                      separatorBuilder: (context, index) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        return Container(
                          width: 70,
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatTime(data.hourly.time[index]),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                              Icon(
                                WeatherData.getWeatherIcon(data.hourly.weatherCode[index]),
                                color: Colors.black87,
                                size: 24,
                              ),
                              Text(
                                '${data.hourly.temperature2m[index].round()}°',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.water_drop, size: 10, color: Colors.blue),
                                  Text(
                                    '${data.hourly.precipitationProbability[index]}%',
                                    style: const TextStyle(fontSize: 10, color: Colors.blue),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Details Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 2.2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: [
                      _buildGridMetric('Humidity', '${current.relativeHumidity2m}%', Icons.water_drop_outlined, const Color(0xFFE5F9E9)),
                      _buildGridMetric('Wind', '${current.windSpeed10m} km/h', Icons.air, const Color(0xFFF0F5FF)),
                      _buildGridMetric('Sunrise', _formatSunTime(data.daily.sunrise[0]), Icons.wb_twilight, const Color(0xFFFFF5EE)),
                      _buildGridMetric('Sunset', _formatSunTime(data.daily.sunset[0]), Icons.nightlight_round, const Color(0xFFFDF5FF)),
                      _buildGridMetric('Daylight', '${(data.daily.daylightDuration[0] / 3600).toStringAsFixed(1)}h', Icons.light_mode_outlined, const Color(0xFFFFF5EE)),
                      _buildGridMetric('Evapotrans.', '${data.daily.et0FaoEvapotranspiration[0]} mm', Icons.grass, const Color(0xFFE5F9E9)),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // 7-Day Forecast
                  const Text(
                    '7-Day Forecast',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 7,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: 50,
                                child: Text(
                                  index == 0 ? 'Today' : _formatDay(data.daily.time[index]),
                                  style: TextStyle(
                                    fontWeight: index == 0 ? FontWeight.bold : FontWeight.normal,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.water_drop,
                                    size: 14,
                                    color: data.daily.precipitationSum[index] > 0 ? Colors.blue : Colors.transparent,
                                  ),
                                  const SizedBox(width: 4),
                                  SizedBox(
                                    width: 30,
                                    child: Text(
                                      data.daily.precipitationSum[index] > 0 
                                          ? '${data.daily.precipitationSum[index]}m' 
                                          : '',
                                      style: const TextStyle(fontSize: 10, color: Colors.blue),
                                    ),
                                  ),
                                ],
                              ),
                              Icon(
                                WeatherData.getWeatherIcon(data.daily.weatherCode[index]),
                                color: Colors.black87,
                                size: 20,
                              ),
                              SizedBox(
                                width: 80,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${data.daily.temperature2mMax[index].round()}°',
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${data.daily.temperature2mMin[index].round()}°',
                                      style: const TextStyle(color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}