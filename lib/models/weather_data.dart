import 'package:flutter/material.dart';

class CurrentWeather {
  final double temperature2m;
  final int relativeHumidity2m;
  final int weatherCode;
  final double windSpeed10m;
  final int isDay;

  CurrentWeather({
    required this.temperature2m,
    required this.relativeHumidity2m,
    required this.weatherCode,
    required this.windSpeed10m,
    required this.isDay,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperature2m: (json['temperature_2m'] as num).toDouble(),
      relativeHumidity2m: json['relative_humidity_2m'] as int,
      weatherCode: json['weather_code'] as int,
      windSpeed10m: (json['wind_speed_10m'] as num).toDouble(),
      isDay: json['is_day'] as int,
    );
  }
}

class HourlyWeather {
  final List<String> time;
  final List<double> temperature2m;
  final List<int> relativeHumidity2m;
  final List<int> precipitationProbability;
  final List<double> precipitation;
  final List<int> weatherCode;

  HourlyWeather({
    required this.time,
    required this.temperature2m,
    required this.relativeHumidity2m,
    required this.precipitationProbability,
    required this.precipitation,
    required this.weatherCode,
  });

  factory HourlyWeather.fromJson(Map<String, dynamic> json) {
    return HourlyWeather(
      time: List<String>.from(json['time']),
      temperature2m: List<double>.from(json['temperature_2m'].map((e) => (e as num).toDouble())),
      relativeHumidity2m: List<int>.from(json['relative_humidity_2m']),
      precipitationProbability: List<int>.from(json['precipitation_probability']),
      precipitation: List<double>.from(json['precipitation'].map((e) => (e as num).toDouble())),
      weatherCode: List<int>.from(json['weather_code']),
    );
  }
}

class DailyWeather {
  final List<String> time;
  final List<int> weatherCode;
  final List<double> temperature2mMax;
  final List<double> temperature2mMin;
  final List<double> precipitationSum;
  final List<double> windSpeed10mMax;
  final List<String> sunrise;
  final List<String> sunset;
  final List<double> daylightDuration;
  final List<double> et0FaoEvapotranspiration;

  DailyWeather({
    required this.time,
    required this.weatherCode,
    required this.temperature2mMax,
    required this.temperature2mMin,
    required this.precipitationSum,
    required this.windSpeed10mMax,
    required this.sunrise,
    required this.sunset,
    required this.daylightDuration,
    required this.et0FaoEvapotranspiration,
  });

  factory DailyWeather.fromJson(Map<String, dynamic> json) {
    return DailyWeather(
      time: List<String>.from(json['time']),
      weatherCode: List<int>.from(json['weather_code']),
      temperature2mMax: List<double>.from(json['temperature_2m_max'].map((e) => (e as num).toDouble())),
      temperature2mMin: List<double>.from(json['temperature_2m_min'].map((e) => (e as num).toDouble())),
      precipitationSum: List<double>.from(json['precipitation_sum'].map((e) => (e as num).toDouble())),
      windSpeed10mMax: List<double>.from(json['wind_speed_10m_max'].map((e) => (e as num).toDouble())),
      sunrise: List<String>.from(json['sunrise']),
      sunset: List<String>.from(json['sunset']),
      daylightDuration: List<double>.from(json['daylight_duration'].map((e) => (e as num).toDouble())),
      et0FaoEvapotranspiration: List<double>.from(json['et0_fao_evapotranspiration'].map((e) => (e as num).toDouble())),
    );
  }
}

class WeatherData {
  final CurrentWeather current;
  final HourlyWeather hourly;
  final DailyWeather daily;

  WeatherData({
    required this.current,
    required this.hourly,
    required this.daily,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      current: CurrentWeather.fromJson(json['current']),
      hourly: HourlyWeather.fromJson(json['hourly']),
      daily: DailyWeather.fromJson(json['daily']),
    );
  }

  static String getWeatherDescription(int weatherCode) {
    switch (weatherCode) {
      case 0:
        return 'Clear sky';
      case 1:
      case 2:
      case 3:
        return 'Mainly clear, partly cloudy, overcast';
      case 45:
      case 48:
        return 'Fog / rime fog';
      case 51:
      case 53:
      case 55:
        return 'Drizzle';
      case 56:
      case 57:
        return 'Freezing Drizzle';
      case 61:
      case 63:
      case 65:
        return 'Rain';
      case 66:
      case 67:
        return 'Freezing Rain';
      case 71:
      case 73:
      case 75:
        return 'Snow';
      case 77:
        return 'Snow grains';
      case 80:
      case 81:
      case 82:
        return 'Rain showers';
      case 85:
      case 86:
        return 'Snow showers';
      case 95:
        return 'Thunderstorm';
      case 96:
      case 99:
        return 'Thunderstorm / Hail';
      default:
        return 'Unknown';
    }
  }

  static IconData getWeatherIcon(int weatherCode) {
    switch (weatherCode) {
      case 0:
        return Icons.wb_sunny_outlined; // Clear sky
      case 1:
      case 2:
      case 3:
        return Icons.cloud_queue; // Partly cloudy
      case 45:
      case 48:
        return Icons.foggy; // Fog
      case 51:
      case 53:
      case 55:
      case 61:
      case 63:
      case 65:
      case 80:
      case 81:
      case 82:
        return Icons.water_drop_outlined; // Rain/Drizzle
      case 56:
      case 57:
      case 66:
      case 67:
      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        return Icons.ac_unit; // Snow
      case 95:
      case 96:
      case 99:
        return Icons.thunderstorm_outlined; // Thunderstorm
      default:
        return Icons.cloud_outlined;
    }
  }
}
