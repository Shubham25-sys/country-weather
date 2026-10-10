/// A country as returned by REST Countries v5.
///
/// Every field is parsed defensively so missing or null values never crash the app.
class Country {
  final String code;
  final String name;
  final String officialName;
  final String capital;
  final String region;
  final String subregion;
  final String flagUrl;
  final String flagEmoji;
  final int? population;
  final List<Currency> currencies;
  final double? latitude;
  final double? longitude;

  const Country({
    required this.code,
    required this.name,
    required this.officialName,
    required this.capital,
    required this.region,
    required this.subregion,
    required this.flagUrl,
    required this.flagEmoji,
    required this.population,
    required this.currencies,
    required this.latitude,
    required this.longitude,
  });

  /// Latitude and longitude are both available, so weather and map can use them.
  bool get hasLocation => latitude != null && longitude != null;

  String get currencyLabel => currencies.isEmpty
      ? 'N/A'
      : currencies.map((c) => c.label).join(', ');

  factory Country.fromJson(Map<String, dynamic> json) {
    final names = _map(json['names']);
    final codes = _map(json['codes']);
    final flag = _map(json['flag']);
    final capitals = _list(json['capitals']).map(_map).toList();
    final firstCapital = capitals.isNotEmpty ? capitals.first : <String, dynamic>{};

    // Prefer the country's centre point; fall back to the capital's coordinates.
    final coordinates = _map(json['coordinates']).isNotEmpty
        ? _map(json['coordinates'])
        : _map(firstCapital['coordinates']);

    final name = _string(names['common'], fallback: 'Unknown');

    return Country(
      code: _string(codes['alpha_3'], fallback: name),
      name: name,
      officialName: _string(names['official'], fallback: name),
      capital: capitals.isEmpty
          ? 'N/A'
          : capitals.map((c) => _string(c['name'])).where((n) => n.isNotEmpty).join(', '),
      region: _string(json['region'], fallback: 'N/A'),
      subregion: _string(json['subregion']),
      flagUrl: _string(flag['url_png']),
      flagEmoji: _string(flag['emoji'], fallback: '🏳️'),
      population: (json['population'] as num?)?.toInt(),
      currencies: _list(json['currencies']).map((c) => Currency.fromJson(_map(c))).toList(),
      latitude: (coordinates['lat'] as num?)?.toDouble(),
      longitude: (coordinates['lng'] as num?)?.toDouble(),
    );
  }

  static Map<String, dynamic> _map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

  static List<dynamic> _list(dynamic value) => value is List ? value : const [];

  static String _string(dynamic value, {String fallback = ''}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }
}

class Currency {
  final String code;
  final String name;
  final String symbol;

  const Currency({required this.code, required this.name, required this.symbol});

  /// e.g. "Indian rupee (₹)".
  String get label => symbol.isEmpty ? name : '$name ($symbol)';

  factory Currency.fromJson(Map<String, dynamic> json) => Currency(
        code: json['code']?.toString() ?? '',
        name: json['name']?.toString() ?? 'Unknown',
        symbol: json['symbol']?.toString() ?? '',
      );
}
