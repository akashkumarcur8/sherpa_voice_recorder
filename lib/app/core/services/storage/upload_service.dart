import 'dart:async';
import 'package:dio/dio.dart' as dio;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../../../modules/home/notification_helper.dart';
import '../audio_service.dart';

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
      print('⚠️ No file path available for upload');
      return;
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final totalFileSize = await _audioService.getCurrentFileSize();

    // Check if there's new data to upload
    if (totalFileSize <= _lastUploadedPosition) {
      print('📝 No new data to upload');
      return;
    }

    // Read new bytes
    final newBytes = await _audioService.readFileBytes(_lastUploadedPosition);

    if (newBytes.isEmpty) {
      print('⚠️ No bytes read from file');
      return;
    }

    // Prepare form data
    final formDataMap = {
      'user_id': userId,
      'recording_name': '$timestamp/_$userId',
      'employee_id': userId,
      'company_id': companyId,
      'start_time': startTimeStamp,
      'end_time': timestamp,
      'disconnection': isDisconnection ? 1 : 0,
      'file': dio.MultipartFile.fromBytes(
        newBytes,
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
          print('✅ Upload successful: ${response.data}');
          _lastUploadedPosition = totalFileSize;
        }

        _isUploading = false;
      } on dio.DioError catch (e) {
        print('❌ Upload failed: $e');
        _isUploading = false;
        // Save locally if upload fails
        await _saveDataLocally(
          newBytes,
          startTimeStamp,
          timestamp,
          userId,
          companyId,
        );
      }
    } else {
      print('📴 No internet, saving locally');
      await _saveDataLocally(
        newBytes,
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
        'recording_name': '${endTime}/_$userId',
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
      print('📴 No internet connection');
      return;
    }

    _isUploading = true;
    final localData = await _storageService.getAllUploadData();

    for (var entry in localData.entries) {
      final key = entry.key;
      final data = entry.value;

      if (data == null) continue;

      try {
        final formData = dio.FormData.fromMap({
          'user_id': data['user_id'],
          'recording_name': data['recording_name'],
          'employee_id': data['employee_id'],
          'company_id': data['company_id'],
          'file': dio.MultipartFile.fromBytes(
            List<int>.from(data['file_bytes']),
            filename: '${data['recording_name']}.mp3',
          ),
        });

        final response = await _dio.post(
          ApiConstants.uploadUrl,
          data: formData,
        );

        if (response.statusCode == 201) {
          print('✅ Local upload successful: ${data['recording_name']}');
          await _storageService.deleteUploadData(key);
        }
      } catch (e) {
        print('❌ Error uploading ${data['recording_name']}: $e');
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
