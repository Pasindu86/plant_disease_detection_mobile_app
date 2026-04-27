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
      return '$hour $ampm';
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
      return '$hour:$min $ampm';
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

  Widget _buildMetricTile(
    String label,
    String value,
    IconData icon,
    Color bgColor,
    Color iconColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAF8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 16),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Weather Forecast',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
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
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Hero Weather Card ─────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1EAC50), Color(0xFF0D7A38)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1EAC50).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left: location + description + temp
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: Colors.white70,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  const Flexible(
                                    child: Text(
                                      'Galle, Sri Lanka',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                WeatherData.getWeatherDescription(current.weatherCode),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${current.temperature2m.toStringAsFixed(1)}',
                                    style: const TextStyle(
                                      fontSize: 52,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      height: 1,
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(top: 6),
                                    child: Text(
                                      '°C',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Right: illustration image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            'assets/images/weather_illustration.png',
                            width: 110,
                            height: 110,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const SizedBox(
                              width: 110,
                              height: 110,
                              child: Icon(Icons.wb_sunny, color: Colors.white70, size: 60),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Today's Hourly Forecast ───────────────────────────
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
                    height: 110,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 24,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final isNow = index == 0;
                        return Container(
                          width: 68,
                          decoration: BoxDecoration(
                            color: isNow
                                ? const Color(0xFF1EAC50)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                isNow ? 'Now' : _formatTime(data.hourly.time[index]),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isNow ? Colors.white : Colors.black54,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Icon(
                                WeatherData.getWeatherIcon(data.hourly.weatherCode[index]),
                                color: isNow ? Colors.white : Colors.black87,
                                size: 22,
                              ),
                              Text(
                                '${data.hourly.temperature2m[index].round()}°',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isNow ? Colors.white : Colors.black87,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.water_drop,
                                    size: 9,
                                    color: isNow ? Colors.white70 : Colors.blue,
                                  ),
                                  const SizedBox(width: 1),
                                  Text(
                                    '${data.hourly.precipitationProbability[index]}%',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: isNow ? Colors.white70 : Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Details Grid ──────────────────────────────────────
                  const Text(
                    'Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 0.88,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: [
                      _buildMetricTile(
                        'Humidity',
                        '${current.relativeHumidity2m}%',
                        Icons.water_drop_outlined,
                        const Color(0xFFE5F9E9),
                        const Color(0xFF1EAC50),
                      ),
                      _buildMetricTile(
                        'Wind',
                        '${current.windSpeed10m}\nkm/h',
                        Icons.air,
                        const Color(0xFFE8F0FF),
                        Colors.blue,
                      ),
                      _buildMetricTile(
                        'Daylight',
                        '${(data.daily.daylightDuration[0] / 3600).toStringAsFixed(1)}h',
                        Icons.light_mode_outlined,
                        const Color(0xFFFFF8E1),
                        Colors.orange,
                      ),
                      _buildMetricTile(
                        'Sunrise',
                        _formatSunTime(data.daily.sunrise[0]),
                        Icons.wb_twilight,
                        const Color(0xFFFFF3E0),
                        Colors.deepOrange,
                      ),
                      _buildMetricTile(
                        'Sunset',
                        _formatSunTime(data.daily.sunset[0]),
                        Icons.nightlight_round,
                        const Color(0xFFF3E5F5),
                        Colors.purple,
                      ),
                      _buildMetricTile(
                        'Evapo.',
                        '${data.daily.et0FaoEvapotranspiration[0]}mm',
                        Icons.grass,
                        const Color(0xFFE5F9E9),
                        const Color(0xFF1EAC50),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ── 7-Day Forecast ────────────────────────────────────
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
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 7,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: Colors.grey.shade100,
                        indent: 16,
                        endIndent: 16,
                      ),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              // Day label
                              SizedBox(
                                width: 48,
                                child: Text(
                                  index == 0
                                      ? 'Today'
                                      : _formatDay(data.daily.time[index]),
                                  style: TextStyle(
                                    fontWeight: index == 0
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: Colors.black87,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              // Rain indicator
                              SizedBox(
                                width: 44,
                                child: data.daily.precipitationSum[index] > 0
                                    ? Row(
                                        children: [
                                          const Icon(
                                            Icons.water_drop,
                                            size: 12,
                                            color: Colors.blue,
                                          ),
                                          const SizedBox(width: 2),
                                          Text(
                                            '${data.daily.precipitationSum[index]}',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ],
                                      )
                                    : const SizedBox.shrink(),
                              ),
                              // Weather icon
                              Icon(
                                WeatherData.getWeatherIcon(
                                    data.daily.weatherCode[index]),
                                color: Colors.black87,
                                size: 22,
                              ),
                              const Spacer(),
                              // Max temp
                              Text(
                                '${data.daily.temperature2mMax[index].round()}°',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Min temp
                              SizedBox(
                                width: 32,
                                child: Text(
                                  '${data.daily.temperature2mMin[index].round()}°',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.right,
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