import 'package:get/get.dart';
import '../controllers/user_tickets_controller.dart';
import 'dart:developer' as developer;

class UserTicketsBinding extends Bindings {
  @override
  void dependencies() {
    developer.log(
      '🔗 UserTicketsBinding: Registering UserTicketsController',
      name: 'UserTicketsBinding',
    );
    Get.put<UserTicketsController>(
      UserTicketsController(),
      permanent: false,
    );
  }
}

