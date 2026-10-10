import 'package:get/get.dart';

import '../data/repositories/country_repository.dart';
import '../data/repositories/weather_repository.dart';
import '../data/services/auth_service.dart';
import '../data/services/storage_service.dart';
import 'network/api_client.dart';

/// Registers app-wide services and repositories once at startup.
/// Screen controllers are registered per page in `AppPages`.
Future<void> initDependencies() async {
  await Get.putAsync(() => StorageService().init(), permanent: true);
  Get.put(AuthService(), permanent: true);

  final apiClient = Get.put(ApiClient(), permanent: true);
  Get.put(CountryRepository(apiClient), permanent: true);
  Get.put(WeatherRepository(apiClient), permanent: true);
}
