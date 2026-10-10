import '../../core/network/app_exception.dart';

/// Current weather from the Open-Meteo `current` block.
class Weather {
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int weatherCode;
  final bool isDay;

  const Weather({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.weatherCode,
    required this.isDay,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    final current = json['current'];
    if (current is! Map || current['temperature_2m'] == null) {
      throw const AppException.invalidResponse();
    }
    final temperature = (current['temperature_2m'] as num).toDouble();

    return Weather(
      temperature: temperature,
      feelsLike: (current['apparent_temperature'] as num?)?.toDouble() ?? temperature,
      humidity: (current['relative_humidity_2m'] as num?)?.toInt() ?? 0,
      windSpeed: (current['wind_speed_10m'] as num?)?.toDouble() ?? 0,
      weatherCode: (current['weather_code'] as num?)?.toInt() ?? -1,
      isDay: current['is_day'] != 0,
    );
  }

  /// Human readable condition for a WMO weather code.
  String get condition {
    switch (weatherCode) {
      case 0:
        return 'Clear sky';
      case 1:
        return 'Mainly clear';
      case 2:
        return 'Partly cloudy';
      case 3:
        return 'Overcast';
      case 45:
      case 48:
        return 'Foggy';
      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
        return 'Drizzle';
      case 61:
      case 63:
      case 65:
      case 66:
      case 67:
      case 80:
      case 81:
      case 82:
        return 'Rain';
      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        return 'Snow';
      case 95:
      case 96:
      case 99:
        return 'Thunderstorm';
      default:
        return 'Unknown';
    }
  }
}
