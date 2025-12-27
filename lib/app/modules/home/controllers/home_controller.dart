import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mice_activeg/app/core/utils/extensions/snackbar_extensions.dart';
import 'package:mice_activeg/app/modules/home/controllers/statistics_data_controller.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/storage/sharedPrefHelper.dart';
import '../../../core/services/websocket_service.dart';
import '../../../core/services/storage/upload_service.dart';
import '../notification_helper.dart';
import 'mice_blinking_controller.dart';

class HomeController extends GetxController {
  // Services
  final AudioService _audioService = AudioService();
  final WebSocketService _webSocketService = WebSocketService();
  final UploadService _uploadService = UploadService();

  // Controllers
  late final StatisticsDataController statsController;
  final MiceBlinkingController miceBlinkingController =
      Get.put(MiceBlinkingController());

  // Platform channels
  static const platform2 = MethodChannel('audio_device_channel');
  static const platform3 = MethodChannel('com.sherpa/usb');

  // Observable variables
  final RxBool isRecording = false.obs;
  final RxInt recordingSeconds = 0.obs;
  final RxString uploadStatus = "Waiting to upload...".obs;
  final ctx = Get.context;
  final empName = ''.obs;
  final email = ''.obs;

  // 🎯 RECORDING MODE TRACKING
  final RxString recordingMode = "".obs;

  // User data
  String username = "";
  String storeName = "";
  String teamId = "NA";
  String managerId = "NA";
  String companyId = "NA";
  String empType = "";

  // Timers
  Timer? _recordingTimer;
  Timer? _deviceMonitorTimer;

  @override
  void onInit() {
    super.onInit();
    statsController = Get.put(StatisticsDataController());
    _initialize();
  }

  @override
  void onClose() {
    _disposeResources();
    super.onClose();
  }

  /// Initialize controller
  Future<void> _initialize() async {
    await _loadUserData();
    await _audioService.initialize();
    await _fetchStatistics();
    _startDeviceMonitoring();
  }

  /// Load user data from SharedPreferences
  Future<void> _loadUserData() async {
    username = await SharedPrefHelper.getpref("username") ?? "";
    empName.value = await SharedPrefHelper.getpref("email") ?? "";
    email.value = await SharedPrefHelper.getpref("emp_name") ?? "";
    storeName = await SharedPrefHelper.getpref("store_name") ?? "";
    empType = await SharedPrefHelper.getpref("emp_type") ?? "";
    companyId = await SharedPrefHelper.getpref("company_id") ?? "NA";
    managerId = await SharedPrefHelper.getpref("manager_id") ?? "NA";
    teamId = await SharedPrefHelper.getpref("team_id") ?? "NA";
  }

  /// Fetch statistics data
  Future<void> _fetchStatistics() async {
    final DateTime selectedDate = DateTime.now();
    var userId = await SharedPrefHelper.getpref("user_id");

    if (userId != null) {
      await statsController.fetchUserAudioStats(
        userId: int.parse(userId),
        selectedDate: selectedDate,
      );
    }
  }

  /// Start recording - MANUAL MODE (Mic button press)
  Future<void> startRecordingManually() async {
    try {
      developer.log('MANUAL START: User pressed mic button',
          name: 'HomeController');

      await _startRecordingInternal();

      // Set mode to MANUAL
      recordingMode.value = "manual";

      developer.log('Manual recording started - Mode: ${recordingMode.value}',
          name: 'HomeController');
      ctx!.showSuccessSnackBar("Your call is now live.");
    } catch (e) {
      developer.log('Error in manual start: $e',
          name: 'HomeController', level: 1000);
      Get.snackbar(
        "Error",
        "Failed to start recording",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Start recording - DEVICE MODE (Auto-start on device connect)
  Future<void> _startRecordingByDevice() async {
    try {
      developer.log('DEVICE START: Audio device connected',
          name: 'HomeController');

      await _startRecordingInternal();

      // Set mode to DEVICE
      recordingMode.value = "device";

      developer.log('Device recording started - Mode: ${recordingMode.value}',
          name: 'HomeController');

      ctx!.showSuccessSnackBar("Your call is now live.");
    } catch (e) {
      developer.log('Error in device start: $e',
          name: 'HomeController', level: 1000);
    }
  }

  /// Internal method - Common recording start logic
  Future<void> _startRecordingInternal() async {
    developer.log('Starting recording and streaming...',
        name: 'HomeController');

    // Start background service
    BackgroundService().startService();

    // Safely start animation - catch disposal errors
    try {
      miceBlinkingController.startAnimation();
    } catch (e) {
      developer.log(
          'Animation controller error (controller may be disposed): $e',
          name: 'HomeController',
          level: 900);
      // Wait a bit for controller to be ready, then retry
      try {
        await Future.delayed(const Duration(milliseconds: 200));
        miceBlinkingController.startAnimation();
      } catch (e2) {
        developer.log('Animation retry failed: $e2',
            name: 'HomeController', level: 900);
        // Continue without animation - recording should still work
      }
    }

    // 1. Connect to WebSocket
    final wsConnected = await _webSocketService.connect(
      email: email.value.toString(),
      managerId: managerId,
      companyId: companyId,
      teamId: teamId,
      fullName: empName.value.toString(),
    );

    if (!wsConnected) {
      throw Exception("WebSocket connection failed");
    }

    // 2. Start FILE recording (AAC for uploads)
    final filePath = await _audioService.startFileRecording();

    if (filePath == null) {
      throw Exception("File recording failed");
    }

    // 3. Start STREAM recording (PCM16 for WebSocket)
    if (_webSocketService.audioSink != null) {
      final streamStarted = await _audioService.startStreamRecording(
        _webSocketService.audioSink!,
      );

      if (!streamStarted) {
        await _audioService.stopFileRecording();
        throw Exception("Stream recording failed");
      }
    }

    // Update state
    isRecording.value = true;
    recordingSeconds.value = 0;

    // Start recording timer
    _startRecordingTimer();

    // Start upload timer
    final isRealtime = empType.contains("realtime");
    _uploadService.startPeriodicUpload(isRealtime: isRealtime);

    // Try to upload any pending local data
    await _uploadService.uploadLocalData();
  }

  /// Stop recording - MANUAL STOP (User pressed stop button)
  /// This is idempotent - safe to call multiple times
  Future<void> stopRecordingManually() async {
    try {
      developer.log('MANUAL STOP: User pressed stop button',
          name: 'HomeController');
      developer.log('Current isRecording state: ${isRecording.value}',
          name: 'HomeController');
      developer.log('Current recordingMode: ${recordingMode.value}',
          name: 'HomeController');

      // If already stopped, just ensure state is clean and return
      if (!isRecording.value && recordingMode.value.isEmpty) {
        developer.log('Already stopped, ensuring clean state...',
            name: 'HomeController');
        // Still run cleanup to ensure everything is properly stopped
        await _stopRecordingInternal();
        return;
      }

      // Immediately set recording to false to prevent further operations
      isRecording.value = false;

      await _stopRecordingInternal();

      // Clear mode
      recordingMode.value = "";

      developer.log('Manual recording stopped', name: 'HomeController');
      if (ctx != null) {
        ctx!.showSuccessSnackBar("The call has been disconnected.");
      }
    } catch (e, stackTrace) {
      developer.log('Error in manual stop: $e',
          name: 'HomeController', level: 1000);
      developer.log('Stack trace: $stackTrace',
          name: 'HomeController', level: 1000);
      // Ensure state is updated even if there's an error
      isRecording.value = false;
      recordingMode.value = "";
    }
  }

  /// Stop recording - DEVICE STOP (Device disconnected)
  Future<void> _stopRecordingByDevice() async {
    try {
      developer.log('DEVICE STOP: Audio device disconnected',
          name: 'HomeController');

      await _stopRecordingInternal();

      // Clear mode
      recordingMode.value = "";

      developer.log('Device recording stopped.', name: 'HomeController');
      ctx!.showSuccessSnackBar("The call has been disconnected.");
      // Show notification
      NotificationHelper.showNotification(
        title: "Recording Stopped!! ⚠️",
        body:
            "The receiver has been disconnected. Plug it back in to resume recording seamlessly. 🚀",
        sound: "plugout",
        channelId: "3",
      );
    } catch (e) {
      developer.log('Error in device stop: $e',
          name: 'HomeController', level: 1000);
    }
  }

  /// Internal method - Common recording stop logic
  Future<void> _stopRecordingInternal() async {
    developer.log('Stopping recording and streaming...',
        name: 'HomeController');

    try {
      // Stop background service
      BackgroundService().stopService();
    } catch (e) {
      developer.log('Error stopping background service: $e',
          name: 'HomeController', level: 900);
    }

    try {
      miceBlinkingController.stopAnimation();
    } catch (e) {
      developer.log('Error stopping animation: $e',
          name: 'HomeController', level: 900);
    }

    // IMPORTANT: Stop audio recordings FIRST to stop sending data to stream
    // This must happen before disconnecting WebSocket
    try {
      developer.log('Stopping audio recordings...', name: 'HomeController');
      await _audioService.stopRecording();
      developer.log('Audio recordings stopped', name: 'HomeController');
    } catch (e) {
      developer.log('Error stopping audio recording: $e',
          name: 'HomeController', level: 900);
    }

    // Wait a moment for any pending stream operations to complete
    await Future.delayed(const Duration(milliseconds: 100));

    // Now stop WebSocket streaming (stream controller will be closed safely)
    try {
      developer.log('Disconnecting WebSocket...', name: 'HomeController');
      await _webSocketService.disconnect(
        email: email.toString(),
        managerId: managerId,
        companyId: companyId,
        teamId: teamId,
        fullName: empName.toString(),
      );
      developer.log('WebSocket disconnected', name: 'HomeController');
    } catch (e) {
      developer.log('Error disconnecting WebSocket: $e',
          name: 'HomeController', level: 900);
    }

    // Stop timers
    try {
      _recordingTimer?.cancel();
      _uploadService.stopPeriodicUpload();
    } catch (e) {
      developer.log('Error stopping timers: $e',
          name: 'HomeController', level: 900);
    }

    // Final upload (don't block on this)
    try {
      final userId = await SharedPrefHelper.getpref("user_id");
      _uploadService
          .uploadAudioData(
        DateTime.now().millisecondsSinceEpoch - 30 * 60 * 1000,
        userId: userId,
        companyId: companyId,
        isDisconnection: true,
      )
          .catchError((e) {
        developer.log('Error in final upload: $e',
            name: 'HomeController', level: 900);
      });
    } catch (e) {
      developer.log('Error initiating final upload: $e',
          name: 'HomeController', level: 900);
    }

    // Update state (already set in stopRecordingManually, but ensure it's false)
    isRecording.value = false;

    // Refresh statistics (don't block on this)
    try {
      _fetchStatistics().catchError((e) {
        developer.log('Error fetching statistics: $e',
            name: 'HomeController', level: 900);
      });
    } catch (e) {
      developer.log('Error initiating statistics fetch: $e',
          name: 'HomeController', level: 900);
    }
  }

  /// Start recording timer
  void _startRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      recordingSeconds.value++;
    });
  }

  /// Check if wired audio device is connected
  Future<bool> _isWiredAudioDeviceConnected() async {
    try {
      return await platform2.invokeMethod('isWiredHeadsetConnected');
    } catch (e) {
      return false;
    }
  }

  /// Check if OTG device is connected
  Future<bool> _isOtgDeviceConnected() async {
    try {
      return await platform3.invokeMethod('checkOtgStatus');
    } catch (e) {
      return false;
    }
  }

  /// Monitor connected audio devices
  void _startDeviceMonitoring() {
    _deviceMonitorTimer?.cancel();

    _deviceMonitorTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) async {
      final isWiredConnected = await _isWiredAudioDeviceConnected();
      final isOtgConnected = await _isOtgDeviceConnected();
      final isDeviceConnected = isWiredConnected || isOtgConnected;

      if (isDeviceConnected) {
        if (!isRecording.value) {
          await _startRecordingByDevice();
        } else {
          // Recording already chal rahi hai

          if (recordingMode.value == "manual") {
            developer.log('Manual mode active - Device connection ignored',
                name: 'HomeController');
          }
          // Device mode mein already hai - Continue recording
        }
      } else {
        if (isRecording.value) {
          if (recordingMode.value == "device") {
            // DEVICE mode mein hai - Device disconnect pe STOP KARO
            await _stopRecordingByDevice();
          } else if (recordingMode.value == "manual") {
            // MANUAL mode mein hai - Device disconnect pe STOP NAHI KARO
            developer.log('Manual mode active - Device disconnection ignored',
                name: 'HomeController');
          }
        }
      }
    });
  }

  /// Format time for display
  String formatTime(int seconds) {
    final int hours = seconds ~/ 3600;
    final int minutes = (seconds % 3600) ~/ 60;
    final int secs = seconds % 60;

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${secs.toString().padLeft(2, '0')}';
  }

  /// Dispose all resources
  void _disposeResources() {
    _recordingTimer?.cancel();
    _deviceMonitorTimer?.cancel();
    _uploadService.dispose();
  }
}
