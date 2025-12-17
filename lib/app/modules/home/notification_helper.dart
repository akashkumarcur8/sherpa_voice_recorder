import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@drawable/ic_bg_service_small');

    const InitializationSettings settings =
    InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(settings);
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    required String sound,
    required String channelId,
  }) async {
    final AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      channelId,
      'channelname',
      channelDescription: 'This is a description of the channel',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@drawable/ic_bg_service_small',
      playSound: true,
      sound: RawResourceAndroidNotificationSound(sound),
    );

    final NotificationDetails notificationDetails =
    NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      int.parse(channelId),
      title,
      body,
      notificationDetails,
    );
  }
}

// lib/core/constants/api_constants.dart

class ApiConstants {
  static const String baseUrl = 'https://dashboard.cur8.in';
  static const String uploadUrl = '$baseUrl/api/upload/';
  static const String pushNotificationUrl = 'https://13.233.246.42/api/push_notification/';

  static const String wsBaseUrl = 'wss://devreal.darwix.ai';
  static const String wsAudioStreamUrl = '$wsBaseUrl/ws/audio-stream';
}



class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  Box? _uploadBox;

  Future<void> initialize() async {
    final directory = await getApplicationDocumentsDirectory();
    Hive.init(directory.path);
    _uploadBox = await Hive.openBox('uploads');
  }

  Future<void> saveUploadData({
    required String timestamp,
    required Map<String, dynamic> data,
  }) async {
    if (_uploadBox == null || !Hive.isBoxOpen('uploads')) {
      await initialize();
    }
    await _uploadBox!.put(timestamp, data);
  }

  Future<Map<dynamic, dynamic>> getAllUploadData() async {
    if (_uploadBox == null || !Hive.isBoxOpen('uploads')) {
      await initialize();
    }
    return _uploadBox!.toMap();
  }

  Future<void> deleteUploadData(dynamic key) async {
    if (_uploadBox == null || !Hive.isBoxOpen('uploads')) {
      await initialize();
    }
    await _uploadBox!.delete(key);
  }

  bool get isEmpty => _uploadBox?.isEmpty ?? true;
}



class BackgroundService {
  static final BackgroundService _instance = BackgroundService._internal();
  factory BackgroundService() => _instance;
  BackgroundService._internal();

  final FlutterBackgroundService _service = FlutterBackgroundService();

  void startService() {
    _service.startService();
    _service.invoke('setAsForeground');
  }

  void stopService() {
    _service.invoke('stopService');
  }

  Future<bool> isRunning() async {
    return await _service.isRunning();
  }
}

// lib/core/utils/time_formatter.dart

class TimeFormatter {
  static String formatTime(int seconds) {
    final int hours = seconds ~/ 3600;
    final int minutes = (seconds % 3600) ~/ 60;
    final int secs = seconds % 60;

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${secs.toString().padLeft(2, '0')}';
  }

  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}



class PermissionHelper {
  static Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  static Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  static Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  static Future<Map<Permission, PermissionStatus>> requestMultiplePermissions() async {
    return await [
      Permission.microphone,
      Permission.location,
      Permission.notification,
    ].request();
  }
}