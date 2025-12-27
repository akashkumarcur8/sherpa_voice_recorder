import 'package:get/get.dart';
import '../main_bottom_nav_controller.dart';

class MainBottomNavBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainBottomNavController>(() => MainBottomNavController());
  }
}

