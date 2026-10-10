import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/network/app_exception.dart';
import '../../data/services/auth_service.dart';
import '../../routes/app_routes.dart';

class LoginController extends GetxController {
  final AuthService _auth = Get.find();

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final isSignUpMode = false.obs;
  final errorMessage = ''.obs;

  void togglePasswordVisibility() => obscurePassword.toggle();

  void toggleMode() {
    isSignUpMode.toggle();
    errorMessage.value = '';
  }

  Future<void> submit() async {
    // The keyboard "done" action can call this while a request is running.
    if (isLoading.value) return;
    errorMessage.value = '';
    if (!(formKey.currentState?.validate() ?? false)) return;

    FocusManager.instance.primaryFocus?.unfocus();
    isLoading.value = true;

    final email = emailController.text.trim();
    final password = passwordController.text;

    try {
      if (isSignUpMode.value) {
        await _auth.signUp(email, password);
      } else {
        await _auth.signIn(email, password);
      }
      Get.offAllNamed(AppRoutes.home);
    } on AppException catch (e) {
      errorMessage.value = e.message;
      isLoading.value = false;
    } catch (_) {
      errorMessage.value = 'Something went wrong. Please try again.';
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
