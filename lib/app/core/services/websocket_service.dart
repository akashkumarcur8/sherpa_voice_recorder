// lib/core/services/websocket_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:web_socket_channel/io.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  IOWebSocketChannel? _channel;
  StreamController<Uint8List>? _audioController;

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
        print('❌ Failed to create WebSocket channel');
        return false;
      }

      print('🌐 WebSocket connected successfully');

      // Create stream controller for audio chunks
      _audioController = StreamController<Uint8List>();

      // Listen to audio chunks and send via WebSocket
      _audioController!.stream.listen(
            (data) {
          print('📤 Sending ${data.length} bytes to WebSocket');
          _channel!.sink.add(data);
        },
        onError: (e) {
          print('❌ Stream error: $e');
        },
      );

      return true;
    } catch (e) {
      print('❌ Error connecting to WebSocket: $e');
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
      // Send disconnect payload if channel is open
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
          print('📤 Sending disconnect payload...');
          _channel!.sink.add(disconnectPayload);
          print('✅ Disconnect payload sent');
        } catch (e) {
          print('❌ Failed to send disconnect payload: $e');
        }

        // Wait briefly to ensure server receives the message
        await Future.delayed(const Duration(milliseconds: 200));

        // Close WebSocket
        await _channel!.sink.close();
        _channel = null;
        print('🔒 WebSocket channel closed');
      }

      // Close stream controller
      await _audioController?.close();
      _audioController = null;
      print('🧹 StreamController closed');
    } catch (e) {
      print('❌ Error disconnecting from WebSocket: $e');
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