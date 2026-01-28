import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/leaderboard_controller.dart';
import '../services/leaderboard_service.dart';

class LeaderboardBinding extends Bindings {
  @override
  void dependencies() {
    // Register service
    Get.lazyPut<LeaderboardService>(() => LeaderboardService());
    
    // Register controller with service dependency
    Get.lazyPut<LeaderboardController>(
      () => LeaderboardController(
        startDate: DateFormat('yyyy-MM-dd')
            .format(DateTime.now().subtract(const Duration(days: 7))),
        endDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        leaderboardService: Get.find<LeaderboardService>(),
      ),
    );
  }
}
