import 'package:get/get.dart';

import '../modules/details/country_details_controller.dart';
import '../modules/details/country_details_view.dart';
import '../modules/home/home_controller.dart';
import '../modules/home/home_view.dart';
import '../modules/login/login_controller.dart';
import '../modules/login/login_view.dart';
import 'app_routes.dart';

/// Each page registers its own controller, so controllers are created when
/// the page opens and disposed when it closes.
class AppPages {
  AppPages._();

  static final pages = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => LoginController())),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => HomeController())),
    ),
    GetPage(
      name: AppRoutes.details,
      page: () => const CountryDetailsView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => CountryDetailsController())),
    ),
  ];
}
