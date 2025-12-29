import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import 'main_bottom_nav_controller.dart';

class CustomBottomNavigation extends StatelessWidget {
  final bool isRecording;
  final VoidCallback onMicPressed;
  final bool isMicEnabled;

  const CustomBottomNavigation({
    super.key,
    required this.isRecording,
    required this.onMicPressed,
    this.isMicEnabled = true,
  });

  String get _currentRoute => Get.currentRoute;

  @override
  Widget build(BuildContext context) {
    // Try to get the MainBottomNavController if we're in the main bottom nav screen
    final MainBottomNavController? navController =
        Get.isRegistered<MainBottomNavController>()
            ? Get.find<MainBottomNavController>()
            : null;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEBEBEB), width: 1)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Obx(() {
            // Use controller's current index if available, otherwise fall back to route checking
            final int currentIndex = navController?.currentIndex.value ??
                _getIndexFromRoute(_currentRoute);

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home, 'Home', currentIndex == 0,
                    Routes.home, 0, navController),
                _buildNavItem(Icons.bar_chart, 'Analytics', currentIndex == 1,
                    Routes.analyticsDashboard, 1, navController),
                _buildMicButton(),
                _buildNavItem(Icons.history, 'History', currentIndex == 2,
                    Routes.conversationView, 2, navController),
                _buildNavItem(Icons.person, 'Profile', currentIndex == 3,
                    Routes.profile, 3, navController),
              ],
            );
          }),
        ),
      ),
    );
  }

  // Helper method to get index from route when controller is not available
  int _getIndexFromRoute(String route) {
    if (route == Routes.home) return 0;
    if (route == Routes.analyticsDashboard) return 1;
    if (route == Routes.conversationView) return 2;
    if (route == Routes.profile) return 3;
    return 0; // Default to home
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, String route,
      int index, MainBottomNavController? navController) {
    return InkWell(
      onTap: () {
        // If we have the nav controller, use it to switch indices (persistent navigation)
        // Otherwise, use regular Get.toNamed (fallback for direct navigation)
        if (navController != null) {
          navController.changeIndex(index);
        } else {
          Get.toNamed(route);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color:
                  isActive ? const Color(0xFF565ADD) : const Color(0xFF9D9D9D),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive
                    ? const Color(0xFF565ADD)
                    : const Color(0xFF9D9D9D),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMicButton() {
    return GestureDetector(
      onTap: () {
        developer.log(
            '🎯 Mic button tapped - isRecording: $isRecording, isMicEnabled: $isMicEnabled',
            name: 'CustomBottomNavigation');
        developer.log('🎯 onMicPressed callback: exists',
            name: 'CustomBottomNavigation');
        try {
          // Always call onMicPressed - it handles both enabled and disabled cases
          onMicPressed();
          developer.log('🎯 onMicPressed callback executed successfully',
              name: 'CustomBottomNavigation');
        } catch (e, stackTrace) {
          developer.log('❌ Error calling onMicPressed: $e',
              name: 'CustomBottomNavigation', level: 1000);
          developer.log('❌ Stack trace: $stackTrace',
              name: 'CustomBottomNavigation', level: 1000);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 70,
        height: 70,
        decoration: const BoxDecoration(
          color: Color(0xFF565ADD),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isRecording ? Icons.stop : Icons.mic,
          size: 30,
          color: Colors.white,
        ),
      ),
    );
  }
}
