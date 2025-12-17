import 'dart:math' as math;
import 'dart:typed_data';

class AudioQualityReport {
  final double averageVolume, peakVolume, totalSeconds;
  final bool passed;
  final String reason;

  const AudioQualityReport({
    required this.averageVolume,
    required this.peakVolume,
    required this.totalSeconds,
    required this.passed,
    required this.reason,
  });

  factory AudioQualityReport.empty() => const AudioQualityReport(
    averageVolume: 0, peakVolume: 0, totalSeconds: 0, passed: false, reason: 'No audio data',
  );

  // For backward compatibility with existing UI
  double get snrDb => averageVolume * 20; // Mock SNR value
  double get peakDbfs => peakVolume > 0 ? 20 * math.log(peakVolume) / math.ln10 : -120.0;
  double get clipRatio => 0.0; // Always 0 for this simple test
}

class QualityAnalyzer {
  final int sampleRate;
  QualityAnalyzer({this.sampleRate = 16000});

  int _totalSamples = 0;
  double _totalEnergy = 0.0;
  double _peakValue = 0.0;
  int _nonZeroSamples = 0;
  int _significantSamples = 0;
  List<double> _volumeLevels = [];

  /// Feed **PCM16 LE mono** bytes (no WAV header).
  void feedPcm16(Uint8List bytes) {
    if (bytes.isEmpty) return;

    final bd = ByteData.sublistView(bytes);
    final n = bytes.length >> 1; // Number of 16-bit samples

    for (int i = 0; i < n; i++) {
      final sample = bd.getInt16(i * 2, Endian.little);
      final normalized = sample.abs() / 32768.0; // Normalize to 0-1 range

      _totalSamples++;
      _totalEnergy += normalized;

      // Track peak value
      if (normalized > _peakValue) {
        _peakValue = normalized;
      }

      // Count samples with any audio activity (very low threshold)
      if (sample.abs() > 50) { // Lower threshold to catch quiet audio
        _nonZeroSamples++;
      }

      // Count samples with significant audio activity
      if (sample.abs() > 500) { // Threshold for actual speech
        _significantSamples++;
      }

      // Store volume levels for analysis (every 1000 samples to avoid memory issues)
      if (i % 1000 == 0) {
        _volumeLevels.add(normalized);
      }
    }
  }

  AudioQualityReport finalizeReport() {
    if (_totalSamples == 0) {
      return AudioQualityReport.empty();
    }

    final totalSeconds = _totalSamples / sampleRate;
    final averageVolume = _totalEnergy / _totalSamples;
    final activityRatio = _nonZeroSamples / _totalSamples;
    final significantRatio = _significantSamples / _totalSamples;

    // Calculate RMS (Root Mean Square) for better volume assessment
    double rms = 0.0;
    if (_volumeLevels.isNotEmpty) {
      final sumSquares = _volumeLevels.fold<double>(0.0, (sum, v) => sum + v * v);
      rms = math.sqrt(sumSquares / _volumeLevels.length);
    }

    // More sensitive criteria for mute detection:
    String reason = '';
    bool passed = true;

    print('Audio Quality Analysis:');
    print('- Total Samples: $_totalSamples');
    print('- Sample Rate: $sampleRate Hz');
    print('- Duration: ${totalSeconds.toStringAsFixed(1)}s');
    print('- Average Volume: ${averageVolume.toStringAsFixed(6)} (${(averageVolume * 100).toStringAsFixed(3)}%)');
    print('- Peak Volume: ${_peakValue.toStringAsFixed(6)} (${(_peakValue * 100).toStringAsFixed(3)}%)');
    print('- RMS Volume: ${rms.toStringAsFixed(6)} (${(rms * 100).toStringAsFixed(3)}%)');
    print('- Activity Ratio: ${(activityRatio * 100).toStringAsFixed(1)}%');
    print('- Significant Activity: ${(significantRatio * 100).toStringAsFixed(1)}%');
    print('- Non-zero samples: $_nonZeroSamples / $_totalSamples');
    print('- Significant samples: $_significantSamples / $_totalSamples');

    // Very sensitive mute detection
    if (averageVolume < 0.0001) { // Extremely low average volume
      passed = false;
      reason = 'Microphone appears to be muted - no audio detected';
    } else if (_peakValue < 0.001) { // Very low peak volume
      passed = false;
      reason = 'Microphone appears to be muted - peak volume too low';
    } else if (activityRatio < 0.01) { // Less than 1% audio activity
      passed = false;
      reason = 'Microphone appears to be muted - no significant audio activity';
    } else if (significantRatio < 0.005 && totalSeconds > 5) { // Less than 0.5% significant activity for longer recordings
      passed = false;
      reason = 'Very weak audio signal detected - microphone may be muted or too far';
    } else if (rms < 0.0005) { // Very low RMS value
      passed = false;
      reason = 'Audio signal too weak - microphone may be muted';
    } else {
      reason = 'Microphone test passed - clear audio detected';
    }

    print('- Result: ${passed ? 'PASSED' : 'FAILED'} - $reason');
    print('');

    return AudioQualityReport(
      averageVolume: averageVolume,
      peakVolume: _peakValue,
      totalSeconds: totalSeconds,
      passed: passed,
      reason: reason,
    );
  }

  // Helper method to get real-time volume level (if needed)
  double getCurrentVolumeLevel() {
    if (_totalSamples == 0) return 0.0;
    return _totalEnergy / _totalSamples;
  }

  // Helper method to reset analyzer (if needed for multiple recordings)
  void reset() {
    _totalSamples = 0;
    _totalEnergy = 0.0;
    _peakValue = 0.0;
    _nonZeroSamples = 0;
    _significantSamples = 0;
    _volumeLevels.clear();
  }
}