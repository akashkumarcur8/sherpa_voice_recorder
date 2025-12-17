import 'package:get/get.dart';

import '../controllers/complaint_controller.dart';
class ComplaintCenterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ComplaintController>(
          () => ComplaintController(),
    );
  }
}