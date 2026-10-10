import 'package:country_wearther_task/core/network/app_exception.dart';
import 'package:country_wearther_task/core/utils/formatters.dart';
import 'package:country_wearther_task/core/utils/validators.dart';
import 'package:country_wearther_task/data/models/country_model.dart';
import 'package:country_wearther_task/data/models/weather_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Country.fromJson', () {
    test('parses a REST Countries v5 record', () {
      final country = Country.fromJson({
        'names': {'common': 'Canada', 'official': 'Canada'},
        'codes': {'alpha_3': 'CAN'},
        'capitals': [
          {'name': 'Ottawa', 'coordinates': {'lat': 45.42, 'lng': -75.7}},
        ],
        'flag': {'emoji': '🇨🇦', 'url_png': 'https://flags.restcountries.com/v5/w640/ca.png'},
        'region': 'Americas',
        'subregion': 'North America',
        'population': 41798407,
        'currencies': [
          {'code': 'CAD', 'name': 'Canadian dollar', 'symbol': r'$'},
        ],
        'coordinates': {'lat': 60, 'lng': -95},
      });

      expect(country.code, 'CAN');
      expect(country.name, 'Canada');
      expect(country.capital, 'Ottawa');
      expect(country.region, 'Americas');
      expect(country.population, 41798407);
      expect(country.currencyLabel, r'Canadian dollar ($)');
      expect(country.latitude, 60);
      expect(country.longitude, -95);
      expect(country.hasLocation, isTrue);
    });

    test('handles missing fields without crashing', () {
      final country = Country.fromJson({});

      expect(country.name, 'Unknown');
      expect(country.capital, 'N/A');
      expect(country.region, 'N/A');
      expect(country.population, isNull);
      expect(country.currencyLabel, 'N/A');
      expect(country.hasLocation, isFalse);
    });

    test('falls back to capital coordinates', () {
      final country = Country.fromJson({
        'names': {'common': 'Test'},
        'capitals': [
          {'name': 'Cap', 'coordinates': {'lat': 1.5, 'lng': 2.5}},
        ],
      });

      expect(country.latitude, 1.5);
      expect(country.longitude, 2.5);
    });
  });

  group('Weather.fromJson', () {
    test('parses Open-Meteo current block', () {
      final weather = Weather.fromJson({
        'current': {
          'temperature_2m': 26.7,
          'apparent_temperature': 27.4,
          'relative_humidity_2m': 47,
          'wind_speed_10m': 5.2,
          'weather_code': 0,
          'is_day': 1,
        },
      });

      expect(weather.temperature, 26.7);
      expect(weather.humidity, 47);
      expect(weather.windSpeed, 5.2);
      expect(weather.condition, 'Clear sky');
      expect(weather.isDay, isTrue);
    });

    test('throws AppException on invalid response', () {
      expect(() => Weather.fromJson({'foo': 'bar'}), throwsA(isA<AppException>()));
    });
  });

  group('Validators', () {
    test('email', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('wrong'), isNotNull);
      expect(Validators.email('user@example.com'), isNull);
    });

    test('password', () {
      expect(Validators.password(''), isNotNull);
      expect(Validators.password('123'), isNotNull);
      expect(Validators.password('123456'), isNull);
    });
  });

  group('Formatters', () {
    test('groupedNumber', () {
      expect(Formatters.groupedNumber(41798407), '41,798,407');
      expect(Formatters.groupedNumber(null), 'N/A');
    });

    test('coordinates', () {
      expect(Formatters.latitude(-12.5), '12.5000° S');
      expect(Formatters.longitude(77), '77.0000° E');
    });
  });
}
