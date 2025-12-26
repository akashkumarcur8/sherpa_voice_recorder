import 'package:get/get.dart';
import '../../../data/providers/ApiService.dart';
import '../controller/conversation_controller.dart';

class ConversationViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SessionController>(
      () => SessionController(ApiService()),
    );
  }
}
