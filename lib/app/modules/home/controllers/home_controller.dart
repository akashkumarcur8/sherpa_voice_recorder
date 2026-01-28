import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mice_activeg/app/core/utils/extensions/snackbar_extensions.dart';
import 'package:mice_activeg/app/modules/home/controllers/statistics_data_controller.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/storage/shared_pref_cache.dart';
import '../../../core/services/websocket_service.dart';
import '../../../core/services/storage/upload_service.dart';
import '../notification_helper.dart';
import 'mice_blinking_controller.dart';
import '../../live_nudges/live_nudegs_controller.dart';

class HomeController extends GetxController {
  // Services
  final AudioService _audioService = AudioService();
  final WebSocketService _webSocketService = WebSocketService();
  final UploadService _uploadService = UploadService();

  // Controllers
  late final StatisticsDataController statsController;
  final MiceBlinkingController miceBlinkingController =
      Get.put(MiceBlinkingController());
  final NudgeController nudgeController = Get.put(NudgeController());

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

  /// Load user data from SharedPreferences cache
  Future<void> _loadUserData() async {
    username = SharedPrefCache().get("username");
    empName.value = SharedPrefCache().get("emp_name");
    email.value = SharedPrefCache().get("email");
    storeName = SharedPrefCache().get("store_name");
    empType = SharedPrefCache().get("emp_type");
    companyId = SharedPrefCache().get("company_id").isEmpty 
        ? "NA" 
        : SharedPrefCache().get("company_id");
    managerId = SharedPrefCache().get("manager_id").isEmpty 
        ? "NA" 
        : SharedPrefCache().get("manager_id");
    teamId = SharedPrefCache().get("team_id").isEmpty 
        ? "NA" 
        : SharedPrefCache().get("team_id");
        print("User Data: $username, $empName, $email, $storeName, $empType, $companyId, $managerId, $teamId");
  }

  /// Fetch statistics data
  Future<void> _fetchStatistics() async {
    final DateTime selectedDate = DateTime.now();
    var userId = SharedPrefCache().get("user_id");

    await statsController.fetchUserAudioStats(
      userId: int.parse(userId),
      selectedDate: selectedDate,
    );
    }

  /// Start recording - MANUAL MODE (Mic button press)
  Future<void> startRecordingManually() async {
    try {

      await _startRecordingInternal();

      // Set mode to MANUAL
      recordingMode.value = "manual";

      ctx!.showSuccessSnackBar("Your call is now live.");
    } catch (e) {
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

      await _startRecordingInternal();

      // Set mode to DEVICE
      recordingMode.value = "device";


      ctx!.showSuccessSnackBar("Your call is now live.");
    } catch (e) {
    }
  }

  /// Internal method - Common recording start logic
  Future<void> _startRecordingInternal() async {

    // Start background service
    BackgroundService().startService();
    miceBlinkingController.startAnimation();

    // 1. Connect to WebSocket
    final wsConnected = await _webSocketService.connect(
      email: email.value.toString(),
      managerId: managerId,
      companyId: companyId,
      teamId: teamId,
      fullName: empName.value.toString(),
    );
    print("wsConnected $wsConnected");

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

    // Connect to live nudges WebSocket
    nudgeController.connect();
  }

  /// Stop recording - MANUAL STOP (User pressed stop button)
  void stopRecordingManually() {
    // COMPLETELY SYNCHRONOUS - NO ASYNC AT ALL
    try {
      // 1. Update state IMMEDIATELY (synchronous)
      isRecording.value = false;
      recordingMode.value = "";
      
      // 2. Show feedback (synchronous)
      ctx!.showSuccessSnackBar("The call has been disconnected.");
      
      // 3. Schedule cleanup for NEXT frame (doesn't block this frame)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performCleanupAfterStop();
      });
    } catch (e) {
      print('Error in stopRecordingManually: $e');
    }
  }

  /// Stop recording - DEVICE STOP (Device disconnected)
  void _stopRecordingByDevice() {
    try {
      // COMPLETELY SYNCHRONOUS - NO ASYNC AT ALL
      isRecording.value = false;
      recordingMode.value = "";
      
      ctx!.showSuccessSnackBar("The call has been disconnected.");
      
      // Show notification
      NotificationHelper.showNotification(
        title: "Recording Stopped!! ⚠️",
        body: "The receiver has been disconnected. Plug it back in to resume recording seamlessly. 🚀",
        sound: "plugout",
        channelId: "3",
      );
      
      // Schedule cleanup for NEXT frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performCleanupAfterStop();
      });
    } catch (e) {
      print('Error in _stopRecordingByDevice: $e');
    }
  }

  /// Perform cleanup after stop - runs AFTER frame is rendered
  void _performCleanupAfterStop() async {
    try {
      // Cancel timers
      _recordingTimer?.cancel();
      _uploadService.stopPeriodicUpload();
      
      // Stop services in background
      Future.wait([
        Future(() => BackgroundService().stopService()),
        Future(() => miceBlinkingController.stopAnimation()),
        Future(() => nudgeController.disconnect()),
        _webSocketService.disconnect(
          email: email.toString(),
          managerId: managerId,
          companyId: companyId,
          teamId: teamId,
          fullName: empName.toString(),
        ),
        _audioService.stopRecording(),
      ]);
      
      // Final upload (fire and forget)
      _performFinalUploadInBackground();
      
      // Fetch statistics later
      Future.delayed(Duration(seconds: 1), () {
        _fetchStatistics();
      });
    } catch (e) {
      print('Error in cleanup: $e');
    }
  }

  /// Perform final upload in background without blocking UI
  void _performFinalUploadInBackground() async {
    try {
      final userId = SharedPrefCache().get("user_id");
      
      // This runs in background, won't block the stop button
      await _uploadService.uploadAudioData(
        DateTime.now().millisecondsSinceEpoch - 30 * 60 * 1000,
        userId: userId,
        companyId: companyId,
        isDisconnection: true,
      );
    } catch (e) {
      print('Background final upload failed: $e');
      // Failure is OK - periodic upload will retry
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
          }
          // Device mode mein already hai - Continue recording
        }
      } else {
        if (isRecording.value) {
          if (recordingMode.value == "device") {
            // DEVICE mode mein hai - Device disconnect pe STOP KARO
            _stopRecordingByDevice();
          } else if (recordingMode.value == "manual") {
            // MANUAL mode mein hai - Device disconnect pe STOP NAHI KARO
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
