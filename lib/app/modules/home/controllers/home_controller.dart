
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mice_activeg/app/core/utils/extensions/snackbar_extensions.dart';
import 'package:mice_activeg/app/modules/home/controllers/statistics_data_controller.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/storage/sharedPrefHelper.dart';
import '../../../core/services/websocket_service.dart';
import '../../../core/services/upload_service.dart';
import '../notification_helper.dart';
import 'mice_blinking_controller.dart';

class HomeController extends GetxController {
  // Services
  final AudioService _audioService = AudioService();
  final WebSocketService _webSocketService = WebSocketService();
  final UploadService _uploadService = UploadService();

  // Controllers
  late final StatisticsDataController statsController;
  final MiceBlinkingController miceBlinkingController = Get.put(MiceBlinkingController());

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
    email.value  = await SharedPrefHelper.getpref("emp_name") ?? "";
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
      print('🎤 MANUAL START: User pressed mic button');

      await _startRecordingInternal();

      // Set mode to MANUAL
      recordingMode.value = "manual";

      print('✅ Manual recording started - Mode: ${recordingMode.value}');
      ctx!.showSuccessSnackBar("Your call is now live.");
    } catch (e) {
      print('❌ Error in manual start: $e');
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
      print('🔌 DEVICE START: Audio device connected');

      await _startRecordingInternal();

      // Set mode to DEVICE
      recordingMode.value = "device";

      print('✅ Device recording started - Mode: ${recordingMode.value}');

      ctx!.showSuccessSnackBar("Your call is now live.");

    } catch (e) {
      print('❌ Error in device start: $e');
    }
  }

  /// Internal method - Common recording start logic
  Future<void> _startRecordingInternal() async {
    print('🚀 Starting recording and streaming...');

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
  Future<void> stopRecordingManually() async {
    try {
      print('🛑 MANUAL STOP: User pressed stop button');

      await _stopRecordingInternal();

      // Clear mode
      recordingMode.value = "";

      print('✅ Manual recording stopped');
    ctx!.showSuccessSnackBar("The call has been disconnected.");
    } catch (e) {
      print('❌ Error in manual stop: $e');
    }
  }

  /// Stop recording - DEVICE STOP (Device disconnected)
  Future<void> _stopRecordingByDevice() async {
    try {
      print('🔌 DEVICE STOP: Audio device disconnected');

      await _stopRecordingInternal();

      // Clear mode
      recordingMode.value = "";

      print('✅ Device recording stopped.');
      ctx!.showSuccessSnackBar("The call has been disconnected.");
      // Show notification
      NotificationHelper.showNotification(
        title: "Recording Stopped!! ⚠️",
        body: "The receiver has been disconnected. Plug it back in to resume recording seamlessly. 🚀",
        sound: "plugout",
        channelId: "3",
      );
    } catch (e) {
      print('❌ Error in device stop: $e');
    }
  }

  /// Internal method - Common recording stop logic
  Future<void> _stopRecordingInternal() async {
    print('🛑 Stopping recording and streaming...');

    // Stop background service
    BackgroundService().stopService();
    miceBlinkingController.stopAnimation();
    // Stop WebSocket streaming
    await _webSocketService.disconnect(
      email: email.toString(),
      managerId: managerId,
      companyId: companyId,
      teamId: teamId,
      fullName: empName.toString(),
    );

    // Stop both audio recordings
    await _audioService.stopRecording();

    // Stop timers
    _recordingTimer?.cancel();
    _uploadService.stopPeriodicUpload();

    // Final upload
    final userId = await SharedPrefHelper.getpref("user_id");
    await _uploadService.uploadAudioData(
      DateTime.now().millisecondsSinceEpoch - 30 * 60 * 1000,
      userId: userId,
      companyId: companyId,
      isDisconnection: true,
    );

    // Update state
    isRecording.value = false;

    // Refresh statistics
    await _fetchStatistics();
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

    _deviceMonitorTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      final isWiredConnected = await _isWiredAudioDeviceConnected();
      final isOtgConnected = await _isOtgDeviceConnected();
      final isDeviceConnected = isWiredConnected || isOtgConnected;

      if (isDeviceConnected) {

        if (!isRecording.value) {
          await _startRecordingByDevice();
        } else {
          // Recording already chal rahi hai

          if (recordingMode.value == "manual") {
            print('ℹ️ Manual mode active - Device connection ignored');
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
            print('ℹ️ Manual mode active - Device disconnection ignored');
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