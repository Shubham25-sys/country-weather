import '../../core/config/app_config.dart';
import '../../core/network/api_client.dart';
import '../../core/network/app_exception.dart';
import '../models/country_model.dart';

class CountryRepository {
  final ApiClient _client;

  CountryRepository(this._client);

  /// Fetches every country, following REST Countries' page-based pagination.
  Future<List<Country>> getCountries() async {
    if (AppConfig.countriesApiKey.isEmpty) {
      throw const AppException(
        'Countries API key is missing. Add COUNTRIES_API_KEY (see README).',
        type: AppErrorType.server,
      );
    }

    final countries = <Country>[];
    var offset = 0;
    var hasMore = true;
    const maxPages = 10; // Safety net against an endless loop.

    for (var page = 0; hasMore && page < maxPages; page++) {
      final json = await _client.get(
        AppConfig.countriesBaseUrl,
        query: {
          'response_fields': AppConfig.countriesFields,
          'limit': AppConfig.countriesPageSize,
          'offset': offset,
        },
        headers: {'Authorization': 'Bearer ${AppConfig.countriesApiKey}'},
      );

      final data = json is Map ? json['data'] : null;
      final objects = data is Map ? data['objects'] : null;
      if (objects is! List) throw const AppException.invalidResponse();

      countries.addAll(
        objects.whereType<Map>().map((e) => Country.fromJson(Map<String, dynamic>.from(e))),
      );

      final meta = data['meta'];
      hasMore = meta is Map && meta['more'] == true && objects.isNotEmpty;
      offset += objects.length;
    }

    countries.sort((a, b) => a.name.compareTo(b.name));
    return countries;
  }
}
