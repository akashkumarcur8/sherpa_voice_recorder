import 'dart:async';
import 'package:dio/dio.dart' as dio;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../../../modules/home/notification_helper.dart';
import '../audio_service.dart';
import '../../isolates/upload_isolate.dart';

class UploadService {
  static final UploadService _instance = UploadService._internal();
  factory UploadService() => _instance;
  UploadService._internal();

  final dio.Dio _dio = dio.Dio(
    dio.BaseOptions(
      connectTimeout: const Duration(seconds: 300),
      receiveTimeout: const Duration(seconds: 300),
      sendTimeout: const Duration(seconds: 300),
    ),
  );

  final AudioService _audioService = AudioService();
  final StorageService _storageService = StorageService();

  Timer? _uploadTimer;
  int _lastUploadedPosition = 0;
  bool _isUploading = false;

  bool get isUploading => _isUploading;

  /// Start periodic upload timer
  void startPeriodicUpload({bool isRealtime = false}) {
    _uploadTimer?.cancel();

    final duration =
        isRealtime ? const Duration(minutes: 31) : const Duration(minutes: 31);

    _uploadTimer = Timer.periodic(duration, (timer) async {
      final startTimeStamp = DateTime.now().millisecondsSinceEpoch -
          (isRealtime ? 30 * 60 * 60 * 1000 : 30 * 60 * 1000);

      await uploadAudioData(startTimeStamp);

      // Check if file recording is still active
      if (!_audioService.isRecording) {
        _uploadTimer?.cancel();
      }
    });
  }

  /// Stop upload timer
  void stopPeriodicUpload() {
    _uploadTimer?.cancel();
  }

  /// Upload audio data to server
  Future<void> uploadAudioData(
    int startTimeStamp, {
    String? userId,
    String? companyId,
    bool isDisconnection = false,
  }) async {
    if (_audioService.currentFilePath == null) {
      return;
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    // Prepare upload data in isolate (HEAVY OPERATION - offloaded from main thread)
    final preparedData = await UploadIsolate.prepareUploadData(
      UploadParams(
        filePath: _audioService.currentFilePath!,
        lastPosition: _lastUploadedPosition,
      ),
    );

    if (preparedData.isEmpty) {
      return;
    }

    // Prepare form data (lightweight operation on main thread)
    final formDataMap = {
      'user_id': userId,
      'recording_name': '$timestamp/_$userId',
      'employee_id': userId,
      'company_id': companyId,
      'start_time': startTimeStamp,
      'end_time': timestamp,
      'disconnection': isDisconnection ? 1 : 0,
      'file': dio.MultipartFile.fromBytes(
        preparedData.bytes,
        filename: '${timestamp}_$userId.mp3',
      ),
    };

    // Check internet connection
    if (await InternetConnectionChecker().hasConnection) {
      try {
        _isUploading = true;

        final formData = dio.FormData.fromMap(formDataMap);
        final response = await _dio.post(
          ApiConstants.uploadUrl,
          data: formData,
        );

        if (response.statusCode == 201) {
          _lastUploadedPosition = preparedData.totalFileSize;
        }

        _isUploading = false;
      } on dio.DioException catch (e) {
        _isUploading = false;
        // Save locally if upload fails
        await _saveDataLocally(
          preparedData.bytes,
          startTimeStamp,
          timestamp,
          userId,
          companyId,
        );
      }
    } else {
      await _saveDataLocally(
        preparedData.bytes,
        startTimeStamp,
        timestamp,
        userId,
        companyId,
      );
    }
  }

  /// Save data locally when internet is unavailable
  Future<void> _saveDataLocally(
    List<int> newBytes,
    int startTime,
    int endTime,
    String? userId,
    String? companyId,
  ) async {
    await _storageService.saveUploadData(
      timestamp: endTime.toString(),
      data: {
        'user_id': userId,
        'recording_name': '$endTime/_$userId',
        'employee_id': userId,
        'start_time': startTime,
        'company_id': companyId,
        'file_bytes': newBytes,
        'end_time': endTime,
      },
    );

    _lastUploadedPosition += newBytes.length;
  }

  /// Attempt to upload locally saved data
  Future<void> uploadLocalData() async {
    if (!await InternetConnectionChecker().hasConnection) {
      return;
    }

    _isUploading = true;
    final localData = await _storageService.getAllUploadData();

    for (var entry in localData.entries) {
      final key = entry.key;
      final data = entry.value;

      if (data == null) continue;

      try {
        // Prepare bytes in isolate (HEAVY OPERATION - offloaded from main thread)
        final bytes = await UploadIsolate.prepareLocalDataBytes(
          List<int>.from(data['file_bytes']),
        );
        
        final formData = dio.FormData.fromMap({
          'user_id': data['user_id'],
          'recording_name': data['recording_name'],
          'employee_id': data['employee_id'],
          'company_id': data['company_id'],
          'file': dio.MultipartFile.fromBytes(
            bytes,
            filename: '${data['recording_name']}.mp3',
          ),
        });

        final response = await _dio.post(
          ApiConstants.uploadUrl,
          data: formData,
        );

        if (response.statusCode == 201) {
          await _storageService.deleteUploadData(key);
        }
      } catch (e) {
      }
    }

    _isUploading = false;
  }

  /// Reset upload position
  void resetUploadPosition() {
    _lastUploadedPosition = 0;
  }

  /// Dispose resources
  void dispose() {
    _uploadTimer?.cancel();
  }
}
