import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';

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
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEBEBEB), width: 1)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Home', _currentRoute == Routes.home,
                  Routes.home),
              _buildNavItem(
                  Icons.bar_chart,
                  'Analytics',
                  _currentRoute == Routes.analyticsDashboard,
                  Routes.analyticsDashboard),
              _buildMicButton(),
              _buildNavItem(
                  Icons.history,
                  'History',
                  _currentRoute == Routes.conversationView,
                  Routes.conversationView),
              _buildNavItem(Icons.person, 'Profile',
                  _currentRoute == Routes.profile, Routes.profile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      IconData icon, String label, bool isActive, String route) {
    return InkWell(
      onTap: () => Get.toNamed(route),
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
