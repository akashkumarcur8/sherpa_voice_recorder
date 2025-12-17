// lib/app/modules/login/bindings/login_binding.dart

import 'package:get/get.dart';
import '../controllers/login_controller.dart';
import '../services/auth_service.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize AuthService first (if not already initialized)
    if (!Get.isRegistered<AuthService>()) {
      Get.put<AuthService>(AuthService(), permanent: true);
    }

    // Initialize LoginController
    Get.lazyPut<LoginController>(() => LoginController(), fenix: true);
  }
}