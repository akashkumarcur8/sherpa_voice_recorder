// lib/core/services/websocket_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:web_socket_channel/io.dart';
import '../isolates/audio_stream_isolate.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  IOWebSocketChannel? _channel;
  StreamController<Uint8List>? _audioController;
  StreamSubscription<Uint8List>? _isolateStreamSubscription;

  // Remove separate recorder - we'll use AudioService's recorder
  bool get isConnected => _channel != null;

  /// Connect to WebSocket and start streaming
  Future<bool> connect({
    required String email,
    required String managerId,
    required String companyId,
    required String teamId,
    required String fullName,
  }) async {
    try {
      // Build WebSocket URL
      final wsUrl = 'wss://devreal.darwix.ai/ws/audio-stream'
          '?user_id=$email'
          '&manager_id=$managerId'
          '&company_id=$companyId'
          '&team_id=$teamId'
          '&full_name=$fullName'
          '&region=east';
        
      _channel = IOWebSocketChannel.connect(wsUrl);

      if (_channel == null) {
        return false;
      }

      // Create stream controller for audio chunks
      _audioController = StreamController<Uint8List>();

      // Start audio stream processing isolate
      final processedStream = await AudioStreamIsolate.spawn();
      
      // Listen to processed audio chunks from isolate and send via WebSocket
      _isolateStreamSubscription = processedStream.listen(
        (processedData) {
          _channel!.sink.add(processedData);
          print("Sending processed audio chunk: ${processedData.lengthInBytes} bytes");
        },
        onError: (e) {
          print('Error in audio stream isolate: $e');
        },
      );
      
      // Listen to raw audio chunks and send to isolate for processing
      _audioController!.stream.listen(
        (rawData) {
          AudioStreamIsolate.processChunk(rawData);
        },
        onError: (e) {
          print('Error receiving audio chunk: $e');
        },
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get the stream sink to send audio data
  StreamSink<Uint8List>? get audioSink => _audioController?.sink;

  /// Disconnect from WebSocket and stop streaming
  Future<void> disconnect({
    required String email,
    required String managerId,
    required String companyId,
    required String teamId,
    required String fullName,
  }) async {
    try {
      // 1. FIRST: Cancel audio stream subscription to stop new chunks
      await _isolateStreamSubscription?.cancel();
      _isolateStreamSubscription = null;

      // 2. SECOND: Dispose audio stream isolate
      AudioStreamIsolate.dispose();

      // 3. THIRD: Close stream controller
      await _audioController?.close();
      _audioController = null;

      // 4. FINALLY: Send disconnect payload and close WebSocket
      if (_channel != null) {
        final disconnectPayload = jsonEncode({
          "user_id": email,
          "manager_id": managerId,
          "company_id": companyId,
          "team_id": teamId,
          "full_name": fullName,
          "status": "disconnect",
        });

        try {
          _channel!.sink.add(disconnectPayload);
        } catch (e) {
          // Ignore if already closed
        }

        // Wait briefly to ensure server receives the message
        await Future.delayed(const Duration(milliseconds: 200));

        // Close WebSocket
        await _channel!.sink.close();
        _channel = null;
      }
    } catch (e) {
      print('Error in disconnect: $e');
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    await disconnect(
      email: '',
      managerId: '',
      companyId: '',
      teamId: '',
      fullName: '',
    );
  }
}