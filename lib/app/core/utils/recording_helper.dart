import 'dart:developer' as developer;
import 'package:get/get.dart';
import '../../modules/home/controllers/home_controller.dart';

/// Global helper to toggle recording after navigation to home
/// This survives widget disposal because it's not tied to any widget instance
/// [shouldStart] - true to start recording, false to stop recording
void scheduleRecordingToggleAfterNavigation(String source, bool shouldStart) {
  developer.log(
      '🚀 scheduleRecordingToggleAfterNavigation called from $source - shouldStart: $shouldStart',
      name: 'RecordingHelper');

  // Schedule the polling to start after navigation completes
  Future.delayed(const Duration(milliseconds: 800), () {
    if (shouldStart) {
      _waitAndStartRecording(source);
    } else {
      _waitAndStopRecording(source);
    }
  });
}

void _waitAndStartRecording(String source) {
  developer.log('🔄 _waitAndStartRecording started from $source',
      name: 'RecordingHelper');
  int attempts = 0;
  const maxAttempts = 15;
  const delayMs = 200;

  Future<void> checkAndStart() async {
    attempts++;
    developer.log(
        '🔄 Attempt $attempts/$maxAttempts: Checking for HomeController...',
        name: 'RecordingHelper');

    if (Get.isRegistered<HomeController>()) {
      try {
        final homeController = Get.find<HomeController>();
        if (!homeController.isRecording.value) {
          developer.log('🎤 Starting recording after redirect from $source',
              name: 'RecordingHelper');
          await homeController.startRecordingManually();
          return; // Success, exit
        } else {
          developer.log('ℹ️ Already recording, skipping start',
              name: 'RecordingHelper');
          return; // Already recording, exit
        }
      } catch (e) {
        developer.log('⚠️ Error accessing HomeController: $e',
            name: 'RecordingHelper', level: 900);
        if (attempts < maxAttempts) {
          Future.delayed(const Duration(milliseconds: delayMs), checkAndStart);
        }
      }
    } else {
      developer.log('⏳ HomeController not registered yet, waiting...',
          name: 'RecordingHelper');
      if (attempts < maxAttempts) {
        Future.delayed(const Duration(milliseconds: delayMs), checkAndStart);
      } else {
        developer.log(
            '❌ Failed to start recording: Controller not found after $maxAttempts attempts',
            name: 'RecordingHelper',
            level: 1000);
      }
    }
  }

  // Start checking immediately
  checkAndStart();
}

void _waitAndStopRecording(String source) {
  developer.log('🔄 _waitAndStopRecording started from $source',
      name: 'RecordingHelper');
  int attempts = 0;
  const maxAttempts = 15;
  const delayMs = 200;

  Future<void> checkAndStop() async {
    attempts++;
    developer.log(
        '🔄 Attempt $attempts/$maxAttempts: Checking for HomeController...',
        name: 'RecordingHelper');

    if (Get.isRegistered<HomeController>()) {
      try {
        final homeController = Get.find<HomeController>();
        // Force stop regardless of state - user explicitly requested stop
        // The state might be false if controller was recreated after navigation
        developer.log(
            '🛑 Stopping recording after redirect from $source (current state: ${homeController.isRecording.value})',
            name: 'RecordingHelper');
        await homeController.stopRecordingManually();
        developer.log('✅ Stop command executed successfully',
            name: 'RecordingHelper');
        return; // Success, exit
      } catch (e) {
        developer.log('⚠️ Error accessing HomeController: $e',
            name: 'RecordingHelper', level: 900);
        if (attempts < maxAttempts) {
          Future.delayed(const Duration(milliseconds: delayMs), checkAndStop);
        } else {
          developer.log(
              '❌ Failed to stop recording after $maxAttempts attempts',
              name: 'RecordingHelper',
              level: 1000);
        }
      }
    } else {
      developer.log('⏳ HomeController not registered yet, waiting...',
          name: 'RecordingHelper');
      if (attempts < maxAttempts) {
        Future.delayed(const Duration(milliseconds: delayMs), checkAndStop);
      } else {
        developer.log(
            '❌ Failed to stop recording: Controller not found after $maxAttempts attempts',
            name: 'RecordingHelper',
            level: 1000);
      }
    }
  }

  // Start checking immediately
  checkAndStop();
}
