import 'dart:isolate';

/// Isolate for processing device state changes
/// Offloads device state logic from main thread
class DeviceMonitorIsolate {
  static Isolate? _isolate;
  static SendPort? _sendPort;
  
  /// Spawn the device monitor isolate
  /// Callback receives processed device state changes
  static Future<void> spawn(Function(Map<String, dynamic>) onDeviceChange) async {
    final receivePort = ReceivePort();
    
    _isolate = await Isolate.spawn(_isolateEntry, receivePort.sendPort);
    
    receivePort.listen((message) {
      if (message is SendPort) {
        _sendPort = message;
      } else if (message is Map<String, dynamic>) {
        onDeviceChange(message);
      }
    });
  }
  
  static void _isolateEntry(SendPort mainSendPort) {
    final receivePort = ReceivePort();
    mainSendPort.send(receivePort.sendPort);
    
    receivePort.listen((message) {
      if (message is Map<String, dynamic>) {
        // Process device state in isolate
        final processed = _processDeviceState(message);
        mainSendPort.send(processed);
      }
    });
  }
  
  static Map<String, dynamic> _processDeviceState(Map<String, dynamic> state) {
    // Device state processing logic in isolate
    final deviceConnected = state['deviceConnected'] as bool;
    final isRecording = state['isRecording'] as bool;
    final mode = state['mode'] as String;
    
    return {
      'shouldStartRecording': deviceConnected && !isRecording,
      'shouldStopRecording': !deviceConnected && isRecording && mode == 'device',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }
  
  /// Send device state to isolate for processing
  static void sendDeviceState(Map<String, dynamic> state) {
    _sendPort?.send(state);
  }
  
  /// Dispose the isolate
  static void dispose() {
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _sendPort = null;
  }
}
