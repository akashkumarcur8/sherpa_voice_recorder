// lib/core/services/websocket_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:typed_data';
import 'package:web_socket_channel/io.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  IOWebSocketChannel? _channel;
  StreamController<Uint8List>? _audioController;
  StreamSubscription<Uint8List>? _audioSubscription;

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
        developer.log('Failed to create WebSocket channel',
            name: 'WebSocketService');
        return false;
      }

      developer.log('WebSocket connected successfully',
          name: 'WebSocketService');

      // Create stream controller for audio chunks
      _audioController = StreamController<Uint8List>();

      // Listen to audio chunks and send via WebSocket
      _audioSubscription = _audioController!.stream.listen(
        (data) {
          // Check if channel is still open before sending
          if (_channel != null) {
            try {
              developer.log('Sending ${data.length} bytes to WebSocket',
                  name: 'WebSocketService');
              _channel!.sink.add(data);
            } catch (e) {
              developer.log('Error sending to WebSocket (may be closed): $e',
                  name: 'WebSocketService', level: 900);
              // Cancel subscription if channel is closed
              _audioSubscription?.cancel();
              _audioSubscription = null;
            }
          }
        },
        onError: (e) {
          developer.log('Stream error: $e',
              name: 'WebSocketService', level: 1000);
        },
      );

      return true;
    } catch (e) {
      developer.log('Error connecting to WebSocket: $e',
          name: 'WebSocketService', level: 1000);
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
      developer.log('Starting WebSocket disconnect...',
          name: 'WebSocketService');

      // Step 1: Cancel stream subscription FIRST to stop sending data
      if (_audioSubscription != null) {
        developer.log('Cancelling audio stream subscription...',
            name: 'WebSocketService');
        await _audioSubscription!.cancel();
        _audioSubscription = null;
        developer.log('Audio stream subscription cancelled',
            name: 'WebSocketService');
      }

      // Step 2: Close stream controller to prevent new data
      if (_audioController != null) {
        developer.log('Closing stream controller...', name: 'WebSocketService');
        await _audioController!.close();
        _audioController = null;
        developer.log('StreamController closed', name: 'WebSocketService');
      }

      // Step 3: Wait a bit for any pending operations to complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Step 4: Send disconnect payload if channel is still open
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
          developer.log('Sending disconnect payload...',
              name: 'WebSocketService');
          _channel!.sink.add(disconnectPayload);
          developer.log('Disconnect payload sent', name: 'WebSocketService');

          // Wait briefly to ensure server receives the message
          await Future.delayed(const Duration(milliseconds: 200));
        } catch (e) {
          developer.log(
              'Failed to send disconnect payload (channel may be closed): $e',
              name: 'WebSocketService',
              level: 900);
        }

        // Step 5: Close WebSocket channel
        try {
          await _channel!.sink.close();
          _channel = null;
          developer.log('WebSocket channel closed', name: 'WebSocketService');
        } catch (e) {
          developer.log('Error closing WebSocket channel: $e',
              name: 'WebSocketService', level: 900);
          _channel = null;
        }
      }

      developer.log('WebSocket disconnect completed', name: 'WebSocketService');
    } catch (e, stackTrace) {
      developer.log('Error disconnecting from WebSocket: $e',
          name: 'WebSocketService', level: 1000);
      developer.log('Stack trace: $stackTrace',
          name: 'WebSocketService', level: 1000);
      // Clean up even if there's an error
      _audioSubscription?.cancel();
      _audioSubscription = null;
      _audioController?.close();
      _audioController = null;
      _channel = null;
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
