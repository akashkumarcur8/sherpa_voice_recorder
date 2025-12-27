import 'package:get/get.dart';
import '../../routes/app_routes.dart';

class MainBottomNavController extends GetxController {
  final RxInt currentIndex = 0.obs;

  // Map routes to indices
  final Map<String, int> routeToIndex = {
    Routes.home: 0,
    Routes.analyticsDashboard: 1,
    Routes.conversationView: 2,
    Routes.profile: 3,
  };

  // Map indices to routes
  final Map<int, String> indexToRoute = {
    0: Routes.home,
    1: Routes.analyticsDashboard,
    2: Routes.conversationView,
    3: Routes.profile,
  };

  @override
  void onInit() {
    super.onInit();
    // Set initial index based on current route
    _updateIndexFromRoute();
  }

  void changeIndex(int index) {
    if (index >= 0 && index < 4) {
      // Just update the index - IndexedStack will handle the screen switching
      // No need to navigate since we're using IndexedStack
      currentIndex.value = index;
    }
  }

  void _updateIndexFromRoute() {
    final currentRoute = Get.currentRoute;
    final index = routeToIndex[currentRoute];
    if (index != null) {
      currentIndex.value = index;
    }
  }

  // Method to navigate to a specific route and update index
  void navigateToRoute(String route) {
    final index = routeToIndex[route];
    if (index != null) {
      changeIndex(index);
    }
  }
}
