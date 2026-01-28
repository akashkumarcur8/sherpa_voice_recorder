import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

/// Isolate for processing audio stream chunks
/// This prevents audio processing from blocking the main UI thread
class AudioStreamIsolate {
  static Isolate? _isolate;
  static SendPort? _sendPort;
  static StreamController<Uint8List>? _outputController;
  
  /// Start the audio stream processing isolate
  /// Returns a stream of processed audio chunks
  static Future<Stream<Uint8List>> spawn() async {
    _outputController = StreamController<Uint8List>.broadcast();
    final receivePort = ReceivePort();
    
    _isolate = await Isolate.spawn(_isolateEntry, receivePort.sendPort);
    
    receivePort.listen((message) {
      if (message is SendPort) {
        _sendPort = message;
      } else if (message is Uint8List) {
        // Processed audio chunk from isolate
        _outputController?.add(message);
      }
    });
    
    return _outputController!.stream;
  }
  
  static void _isolateEntry(SendPort mainSendPort) {
    final receivePort = ReceivePort();
    mainSendPort.send(receivePort.sendPort);
    
    receivePort.listen((message) {
      if (message is Uint8List) {
        // Process audio chunk in isolate
        final processed = _processAudioChunk(message);
        mainSendPort.send(processed);
      }
    });
  }
  
  static Uint8List _processAudioChunk(Uint8List chunk) {
    // Audio processing logic in isolate
    // Currently pass-through, but can be extended for:
    // - Buffering
    // - Compression
    // - Format conversion
    // - Noise reduction
    return chunk;
  }
  
  /// Send audio chunk to isolate for processing
  static void processChunk(Uint8List chunk) {
    _sendPort?.send(chunk);
  }
  
  /// Dispose the isolate and clean up resources
  static void dispose() {
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _sendPort = null;
    _outputController?.close();
    _outputController = null;
  }
}
