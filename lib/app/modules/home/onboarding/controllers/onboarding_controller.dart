import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

import '../../../routes/app_routes.dart';
class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  var currentPage = 0.obs;

  void nextPage() {
    if (currentPage.value < 4) {
      pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
    } else {
      finishOnboarding();
    }
  }

  void finishOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingCompleted', true); // Mark onboarding as completed
    Get.toNamed(Routes.login); // Navigate to home screen
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
