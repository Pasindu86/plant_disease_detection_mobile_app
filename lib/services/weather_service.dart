import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';

class WeatherService {
  // Static lat/lon for Galle, Sri Lanka
  final String _url =
      'https://api.open-meteo.com/v1/forecast?latitude=6.0535&longitude=80.2210&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m,is_day&hourly=temperature_2m,relative_humidity_2m,precipitation_probability,precipitation,weather_code&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum,wind_speed_10m_max,sunrise,sunset,daylight_duration,et0_fao_evapotranspiration&timezone=auto&forecast_days=7';

  Future<WeatherData> fetchWeather() async {
    try {
      final response = await http.get(Uri.parse(_url));

      if (response.statusCode == 200) {
        return WeatherData.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      throw Exception('Failed to load weather data: $e');
    }
  }
}
