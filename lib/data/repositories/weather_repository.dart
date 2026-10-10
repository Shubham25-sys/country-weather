import '../../core/config/app_config.dart';
import '../../core/network/api_client.dart';
import '../../core/network/app_exception.dart';
import '../models/weather_model.dart';

class WeatherRepository {
  final ApiClient _client;

  WeatherRepository(this._client);

  Future<Weather> getCurrentWeather(double latitude, double longitude) async {
    final json = await _client.get(
      AppConfig.weatherBaseUrl,
      query: {
        'latitude': latitude,
        'longitude': longitude,
        'current': 'temperature_2m,apparent_temperature,relative_humidity_2m,'
            'wind_speed_10m,weather_code,is_day',
      },
    );
    if (json is! Map) throw const AppException.invalidResponse();
    return Weather.fromJson(Map<String, dynamic>.from(json));
  }
}
