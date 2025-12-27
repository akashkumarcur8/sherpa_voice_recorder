import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../modules/home/home_screen.dart';
import '../../modules/analytics/analytics_widget.dart';
import '../../modules/conversation/conversation_view.dart';
import '../../modules/profile/profile_page.dart';
import '../custom_bottom_navigation.dart';
import '../../modules/home/controllers/home_controller.dart';
import '../../core/utils/recording_helper.dart';
import 'main_bottom_nav_controller.dart';
import 'dart:developer' as developer;

class MainBottomNavScreen extends StatelessWidget {
  const MainBottomNavScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navController = Get.find<MainBottomNavController>();

    // Initialize all bottom nav screens (they'll be kept in memory via IndexedStack)
    // These screens will maintain their state when switching tabs
    final List<Widget> screens = [
      HomeScreen(),
      const AnalyticsDashboard(),
      const ConversationView(),
      const ProfileScreen(),
    ];

    return Obx(() => Scaffold(
          body: IndexedStack(
            index: navController.currentIndex.value,
            children: screens,
          ),
          bottomNavigationBar: Obx(() => CustomBottomNavigation(
                isRecording: Get.isRegistered<HomeController>()
                    ? Get.find<HomeController>().isRecording.value
                    : false,
                onMicPressed: () {
                  // Check current recording state before navigation
                  final isCurrentlyRecording =
                      Get.isRegistered<HomeController>()
                          ? Get.find<HomeController>().isRecording.value
                          : false;

                  developer.log(
                      '📱 MainBottomNav: Mic button pressed - isRecording: $isCurrentlyRecording',
                      name: 'MainBottomNavScreen');

                  // Schedule recording toggle (start or stop) based on current state
                  scheduleRecordingToggleAfterNavigation(
                      'MainBottomNav', !isCurrentlyRecording);

                  // Navigate to home screen (index 0)
                  navController.changeIndex(0);
                },
                isMicEnabled: true,
              )),
        ));
  }
}
