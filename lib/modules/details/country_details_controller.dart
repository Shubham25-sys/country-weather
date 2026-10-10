import 'package:get/get.dart';

import '../../core/network/app_exception.dart';
import '../../core/utils/view_status.dart';
import '../../data/models/country_model.dart';
import '../../data/models/weather_model.dart';
import '../../data/repositories/weather_repository.dart';
import '../../data/services/storage_service.dart';

class CountryDetailsController extends GetxController {
  final WeatherRepository _weatherRepository = Get.find();
  final StorageService _storage = Get.find();

  /// The selected country passed via `Get.toNamed(..., arguments: country)`.
  final Country? country = Get.arguments is Country ? Get.arguments as Country : null;

  // Weather has its own state so the rest of the screen stays usable if it fails.
  final weatherStatus = ViewStatus.loading.obs;
  final weather = Rxn<Weather>();
  final weatherError = ''.obs;

  bool get isFavorite => country != null && _storage.favorites.contains(country!.code);

  @override
  void onInit() {
    super.onInit();
    if (country == null) return;
    _storage.saveLastSelected(country!.code);
    fetchWeather();
  }

  Future<void> fetchWeather() async {
    final selected = country;
    // No coordinates means we can't ask for weather - show the empty state instead.
    if (selected == null || !selected.hasLocation) {
      weatherStatus.value = ViewStatus.empty;
      return;
    }

    weatherStatus.value = ViewStatus.loading;
    try {
      weather.value = await _weatherRepository.getCurrentWeather(
        selected.latitude!,
        selected.longitude!,
      );
      weatherStatus.value = ViewStatus.success;
    } on AppException catch (e) {
      weatherError.value = e.message;
      weatherStatus.value = ViewStatus.error;
    } catch (_) {
      weatherError.value = 'Unable to load weather right now.';
      weatherStatus.value = ViewStatus.error;
    }
  }

  void toggleFavorite() {
    if (country != null) _storage.toggleFavorite(country!.code);
  }
}
