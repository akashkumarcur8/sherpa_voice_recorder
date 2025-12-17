
import 'package:get/get.dart';
import '../controllers/agent_detail_controller.dart';

class AgentDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AgentDetailController>(
          () => AgentDetailController(),
    );
  }
}