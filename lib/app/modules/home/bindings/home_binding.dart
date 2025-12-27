import 'package:get/get.dart';
import 'package:mice_activeg/app/modules/home/controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Use permanent: true to ensure controller persists across navigation
    // This prevents recording from stopping when switching screens
    Get.put<HomeController>(
      HomeController(),
      permanent: true,
    );
  }
}