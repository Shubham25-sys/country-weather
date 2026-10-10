import 'api_keys.dart';

/// Central place for API URLs, keys and app-wide constants.
///
/// The REST Countries key comes from the git-ignored `api_keys.dart`
/// (see `api_keys.example.dart`), or can be overridden at build time:
/// `flutter run --dart-define=COUNTRIES_API_KEY=your_key`
class AppConfig {
  AppConfig._();

  static const String appName = 'Country & Weather Explorer';

  // REST Countries (https://restcountries.com) - v5 requires an API key.
  static const String countriesBaseUrl = 'https://api.restcountries.com/countries/v5';
  static const String countriesApiKey = String.fromEnvironment(
    'COUNTRIES_API_KEY',
    defaultValue: ApiKeys.restCountries,
  );

  /// Only the fields the app actually uses, to keep responses small.
  static const String countriesFields =
      'names.common,names.official,codes.alpha_3,capitals,flag.url_png,'
      'flag.emoji,region,subregion,population,currencies,coordinates';

  /// Max page size allowed on the free plan.
  static const int countriesPageSize = 100;

  // Open-Meteo (https://open-meteo.com) - free, no API key required.
  static const String weatherBaseUrl = 'https://api.open-meteo.com/v1/forecast';

  // OpenStreetMap tiles used by flutter_map.
  static const String mapTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  // Must match the real applicationId - OSM's tile policy requires an identifying user agent.
  static const String mapUserAgent = 'country.weather';

  static const Duration requestTimeout = Duration(seconds: 15);
  static const int maxRecentSearches = 5;
}
