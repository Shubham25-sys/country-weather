import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/config/app_config.dart';
import 'core/dependencies.dart';
import 'core/theme/app_theme.dart';
import 'data/services/auth_service.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'widgets/status_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    // Show a friendly screen instead of crashing if Firebase isn't set up.
    runApp(_StartupErrorApp(message: e.toString()));
    return;
  }

  await initDependencies();
  runApp(const CountryWeatherApp());
}

class CountryWeatherApp extends StatelessWidget {
  const CountryWeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Firebase restores the previous session, so logged-in users skip the login screen.
    final isLoggedIn = Get.find<AuthService>().isLoggedIn;

    return GetMaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: isLoggedIn ? AppRoutes.home : AppRoutes.login,
      getPages: AppPages.pages,
      defaultTransition: Transition.cupertino,
    );
  }
}

class _StartupErrorApp extends StatelessWidget {
  final String message;

  const _StartupErrorApp({required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: Scaffold(
        body: StatusView(
          icon: Icons.settings_suggest_rounded,
          title: 'Setup required',
          message: message,
        ),
      ),
    );
  }
}
