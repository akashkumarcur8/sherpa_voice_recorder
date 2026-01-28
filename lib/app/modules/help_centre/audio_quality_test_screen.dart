import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound/flutter_sound.dart' as fs;
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'audio_quality.dart';

class AudioQualityTestScreen extends StatefulWidget {
  const AudioQualityTestScreen({super.key});
  @override
  State<AudioQualityTestScreen> createState() => _AudioQualityTestScreenState();
}

class _AudioQualityTestScreenState extends State<AudioQualityTestScreen> {
  final _slides = const [
    'asset/images/sherpa_device7.png',
    'asset/images/sherpa_device6.png',
    'asset/images/sherpa_device5.png',

  ];

  final FlutterSoundRecorder _testRecorder = FlutterSoundRecorder();
  bool _recReady = false, _isRecording = false;
  int _seconds = 0;
  Timer? _timer;
  String? _wavPath;
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  // Real-time audio monitoring
  double _currentVolume = 0.0;
  StreamSubscription<RecordingDisposition>? _recorderSubscription;

  @override
  void initState() {
    super.initState();
    _initRec();
  }

  Future<void> _initRec() async {
    try {
      // Ask for the mic first
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        _recReady = false;
        setState(() {});
        _showErrorDialog('Microphone permission denied.');
        return;
      }

      await _testRecorder.openRecorder();
      await _testRecorder.setSubscriptionDuration(const Duration(milliseconds: 100));

      // Ready if not recording
      _recReady = _testRecorder.isStopped;
      setState(() {});
    } catch (e) {
      _recReady = false;
      setState(() {});
    }
  }



  @override
  void dispose() {
    _timer?.cancel();
    _recorderSubscription?.cancel();

    if (_testRecorder.isRecording) {
      _testRecorder.stopRecorder();
    }
    _testRecorder.closeRecorder();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _startTest() async {
    if (!_recReady || _isRecording) return;

    try {
      final dir = await getTemporaryDirectory();
      _wavPath = '${dir.path}/aac_test_${DateTime.now().millisecondsSinceEpoch}.aac';

      setState(() {
        _isRecording = true;
        _seconds = 0;
        _currentVolume = -60.0;
      });

      await _testRecorder.startRecorder(
        toFile: _wavPath,
        codec: fs.Codec.aacADTS,
        audioSource: fs.AudioSource.microphone, // <- important on some devices
      );

      // Wait until it really started (defensive)
      await Future.doWhile(() async {
        await Future.delayed(const Duration(milliseconds: 50));
        return !_testRecorder.isRecording;
      });

      _recorderSubscription = _testRecorder.onProgress?.listen((e) {
        if (!mounted) return;
        setState(() {
          _currentVolume = e.decibels ?? -60.0;
        });
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (t) async {
        setState(() => _seconds++);
        if (_seconds >= 15) {
          t.cancel();
          await _stopAndProcess();
        }
      });
    } catch (e) {
      setState(() => _isRecording = false);
      _showErrorDialog('Failed to start recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;

    _timer?.cancel();
    await _stopAndProcess();
  }

  Future<void> _stopAndProcess() async {
    if (!_isRecording) return;

    try {
      // Cancel subscriptions first
      _recorderSubscription?.cancel();
      _recorderSubscription = null;

      // Stop recording
      await _testRecorder.stopRecorder();
      setState(() => _isRecording = false);

      // Show processing dialog
      final closeProcessing = _showProcessing();

      // Verify file exists and has content
      final file = File(_wavPath!);
      if (!await file.exists()) {
        await closeProcessing();
        throw Exception('Recording file not found at: $_wavPath');
      }

      final fileSize = await file.length();

      if (fileSize < 1000) {
        await closeProcessing();
        throw Exception('Recording file too small ($fileSize bytes) - microphone may be muted');
      }

      final bytes = await file.readAsBytes();

      // Parse WAV header to skip to PCM data
      int pcmStart = _findPcmDataStart(bytes);
      if (pcmStart == -1) {
        await closeProcessing();
        throw Exception('Invalid WAV file format');
      }

      final pcmData = Uint8List.sublistView(bytes, pcmStart);

      if (pcmData.length < 100) {
        await closeProcessing();
        throw Exception('Insufficient audio data - microphone may be muted');
      }

      // Analyze audio quality
      final qa = QualityAnalyzer(sampleRate: 16000);
      qa.feedPcm16(pcmData);
      final report = qa.finalizeReport();

      await closeProcessing();
      await _showResult(report);

      // Return result
      Get.back(result: {
        'status': report.passed ? 'passed' : 'failed',
        'path': report.passed ? _wavPath : null,
        'averageVolume': report.averageVolume,
        'peakVolume': report.peakVolume,
        'reason': report.reason,
      });

    } catch (e) {
      setState(() => _isRecording = false);

      // Close processing dialog if open
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      _showErrorDialog('Recording processing failed: $e');
    }
  }

  // Helper method to find where PCM data starts in WAV file
  int _findPcmDataStart(Uint8List bytes) {
    try {
      // Look for "data" chunk marker
      for (int i = 0; i < bytes.length - 8; i++) {
        if (bytes[i] == 0x64 && bytes[i + 1] == 0x61 &&
            bytes[i + 2] == 0x74 && bytes[i + 3] == 0x61) {
          // Found "data", return position after chunk size (4 bytes later)
          return i + 8;
        }
      }

      // Fallback: assume standard 44-byte header if "data" not found
      return bytes.length > 44 ? 44 : -1;
    } catch (e) {
      return -1;
    }
  }

  Future<void> _showErrorDialog(String message) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Test Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> Function() _showProcessing() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 220,
          height: 120,
          padding: const EdgeInsets.all(20),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Analyzing audio...', style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );

    return () async {
      if (mounted && Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    };
  }

  Future<void> _showResult(AudioQualityReport r) async {
    final extra = 'Avg Volume: ${(r.averageVolume * 100).toStringAsFixed(2)}% • '
        'Peak: ${(r.peakVolume * 100).toStringAsFixed(2)}%';

    final color = r.passed ? const Color(0xFF00C853) : const Color(0xFFFF1744);
    final icon = r.passed ? Icons.check_circle : Icons.cancel;
    final title = r.passed ? 'Microphone Test Passed' : 'Microphone Test Failed';

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 48),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                r.reason,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                extra,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF565ADD),
                  foregroundColor: Colors.white,
                ),
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Audio Testing',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: const Color(0xFF565ADD),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),

          // Image carousel
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 200,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  return Image.asset(
                    _slides[index],
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Test phrase container
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFBABCF0), Color(0xFF565ADD)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Repeat exact test phrase to verify mic:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '"Hello I\'m calling from Darwix AI by Sherpa, this is a quality check"',
                  style: TextStyle(
                    color: Colors.yellow,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Real-time volume indicator (only show when recording)
          if (_isRecording) ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Text('Audio Level:', style: TextStyle(fontSize: 12)),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: (_currentVolume + 60) / 60, // Convert dB to 0-1 range
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _currentVolume > -40 ? Colors.green :
                      _currentVolume > -60 ? Colors.orange : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('${_currentVolume.toStringAsFixed(1)} dB',
                      style: const TextStyle(fontSize: 10)),
                ],
              ),
            ),
          ],

          const Spacer(),

          // Timer display
          Text(
            _formatTime(_seconds),
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 120), // Space for floating button
        ],
      ),

      // Bottom navigation with microphone button
      bottomNavigationBar: SizedBox(
        height: 140,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Bottom bar background
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFF565ADD),
                ),
              ),
            ),

            // Floating microphone button
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    if (!_recReady) {
                      _showErrorDialog('Microphone not ready. Please check permissions.');
                      return;
                    }

                    if (_isRecording) {
                      _stopRecording();
                    } else {
                      _startTest();
                    }
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _recReady ? Colors.white : Colors.grey.shade300,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isRecording ? Icons.stop : Icons.mic,
                      color: _recReady ? const Color(0xFF565ADD) : Colors.grey.shade600,
                      size: 35,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}