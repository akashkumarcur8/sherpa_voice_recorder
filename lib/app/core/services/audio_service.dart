import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../modules/home/notification_helper.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  // Separate recorders for different purposes
  FlutterSoundRecorder? _fileRecorder;      // For file saving only
  FlutterSoundRecorder? _streamRecorder;    // For streaming only

  String? _filePath;
  StreamSubscription? _amplitudeSubscription;

  // Silence detection variables
  bool _firstNotificationTriggered = false;
  int _silentIntervals = 0;
  bool _initialBuffer = true;

  // Getters
  bool get isRecording => _fileRecorder?.isRecording ?? false;
  String? get currentFilePath => _filePath;

  /// Initialize both recorders
  Future<void> initialize() async {
    // Initialize file recorder
    _fileRecorder = FlutterSoundRecorder();
    await _fileRecorder!.openRecorder();

    // Initialize stream recorder
    _streamRecorder = FlutterSoundRecorder();
    await _streamRecorder!.openRecorder();

    PermissionStatus status = await Permission.microphone.request();
    if (status.isGranted) {
      await WakelockPlus.enable();
    }

    print('✅ Both recorders initialized');
  }

  /// Start file recording for uploads
  Future<String?> startFileRecording() async {
    try {
      if (_fileRecorder == null) {
        await initialize();
      }

      if (_fileRecorder!.isRecording) {
        await _fileRecorder!.stopRecorder();
      }

      await _fileRecorder!.openRecorder();

      // Generate file path
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'recording_${DateTime.now().millisecondsSinceEpoch}.aac';
      _filePath = '${directory.path}/$fileName';

      // Reset silence detection
      _resetSilenceDetection();

      print('🎙️ Starting FILE recording (AAC)');
      await _fileRecorder!.startRecorder(
        toFile: _filePath,
        codec: Codec.aacADTS,
      );

      // Start amplitude monitoring on file recorder
      _startAmplitudeMonitoring();

      await WakelockPlus.enable();

      print('✅ File recording started: $_filePath');
      return _filePath;
    } catch (e) {
      print('❌ Error starting file recording: $e');
      return null;
    }
  }

  /// Start stream recording for WebSocket
  Future<bool> startStreamRecording(StreamSink<Uint8List> streamSink) async {
    try {
      if (_streamRecorder == null) {
        await initialize();
      }

      if (_streamRecorder!.isRecording) {
        await _streamRecorder!.stopRecorder();
      }

      await _streamRecorder!.openRecorder();

      print('🌐 Starting STREAM recording (PCM16)');
      await _streamRecorder!.startRecorder(
        codec: Codec.pcm16,
        numChannels: 1,
        sampleRate: 16000,
        toStream: streamSink,
      );

      print('✅ Stream recording started');
      return true;
    } catch (e) {
      print('❌ Error starting stream recording: $e');
      return false;
    }
  }

  /// Stop file recording
  Future<void> stopFileRecording() async {
    try {
      _amplitudeSubscription?.cancel();
      await _fileRecorder?.stopRecorder();
      print('🛑 File recording stopped');
    } catch (e) {
      print('❌ Error stopping file recording: $e');
    }
  }

  /// Stop stream recording
  Future<void> stopStreamRecording() async {
    try {
      await _streamRecorder?.stopRecorder();
      print('🛑 Stream recording stopped');
    } catch (e) {
      print('❌ Error stopping stream recording: $e');
    }
  }

  /// Stop both recordings
  Future<void> stopRecording() async {
    await stopFileRecording();
    await stopStreamRecording();
    await WakelockPlus.disable();
    print('✅ All recordings stopped');
  }

  /// Start monitoring audio amplitude for silence detection
  void _startAmplitudeMonitoring() {
    _fileRecorder?.setSubscriptionDuration(const Duration(seconds: 1));
    _amplitudeSubscription?.cancel();

    _amplitudeSubscription = _fileRecorder?.onProgress?.listen((e) {
      double amplitudeDb = e.decibels ?? 0;

      if (_initialBuffer) {
        _initialBuffer = false;
        return;
      }

      if (amplitudeDb < 30) {
        _silentIntervals++;
      } else {
        _silentIntervals = 0;
        _firstNotificationTriggered = false;
      }

      // First warning at 1 minute (60 seconds)
      if (_silentIntervals == 60 && !_firstNotificationTriggered) {
        _firstNotificationTriggered = true;
        NotificationHelper.showNotification(
          title: "Silence Detected!! ⚠️",
          body: "No voice input detected. Please check if your microphone is muted, turned off, or out of charge, and try reconnecting. 🚀",
          sound: "muted",
          channelId: "2",
        );
      }

      // Stop recording after 2 minutes (120 seconds)
      if (_silentIntervals >= 120) {
        NotificationHelper.showNotification(
          title: "Silence detected for 2 minutes!! ⚠️",
          body: "Your recording has stopped after being muted for 2 minutes. Please unmute your mic or start your receiver mic to start recording again. 🚀",
          sound: "fiveminutemute",
          channelId: "1",
        );
      }
    });
  }

  /// Reset silence detection variables
  void _resetSilenceDetection() {
    _firstNotificationTriggered = false;
    _silentIntervals = 0;
    _initialBuffer = true;
  }

  /// Convert raw amplitude to decibels (dB)
  double amplitudeToDb(double amplitude) {
    return 20 * log(amplitude) / ln10;
  }

  /// Read file bytes for upload
  Future<List<int>> readFileBytes(int lastPosition) async {
    if (_filePath == null) return [];

    File file = File(_filePath!);
    int totalFileSize = await file.length();

    if (totalFileSize > lastPosition) {
      List<int> fileBytes = await file.readAsBytes();
      return fileBytes.sublist(lastPosition);
    }

    return [];
  }

  /// Get current file size
  Future<int> getCurrentFileSize() async {
    if (_filePath == null) return 0;
    File file = File(_filePath!);
    return await file.length();
  }

  /// Dispose resources
  Future<void> dispose() async {
    _amplitudeSubscription?.cancel();
    await _fileRecorder?.closeRecorder();
    await _streamRecorder?.closeRecorder();
    _fileRecorder = null;
    _streamRecorder = null;
    print('🧹 All recorders disposed');
  }
}