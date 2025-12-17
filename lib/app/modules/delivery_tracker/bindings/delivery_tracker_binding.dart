
import 'package:get/get.dart';
import '../controllers/delivery_tracker_controller.dart';

class DeliveryTrackerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeliveryTrackerController>(
          () => DeliveryTrackerController(),
    );
  }
}