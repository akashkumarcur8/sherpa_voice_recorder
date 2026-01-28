import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/io.dart';
import '../../core/services/storage/sharedPrefHelper.dart';
import '../../core/services/storage/shared_pref_cache.dart';
import '../../core/isolates/json_parser_isolate.dart';
// Top-level function for isolate execution
List<Nudge> _parseNudgesInIsolate(Map<String, dynamic> response) {
  final List<Nudge> parsed = [];
  response.forEach((_, cat) {
    (cat['content'] as Map).forEach((_, sub) {
      final text = (sub['nudges'] ?? '').toString().trim();
      if (text.isNotEmpty) {
        final positive = (sub['value'] ?? '').toString().toLowerCase().contains('yes');
        parsed.add(Nudge(text: text, positive: positive));
      }
    });
  });
  return parsed;
}

class Nudge {
  final String text;
  final bool positive;
  Nudge({required this.text, required this.positive});
}
class NudgeController extends GetxController {
  final nudges = <Nudge>[].obs;
  final currentPage = 0.obs;
  // new: recording state
  final isRecording = false.obs;

  late final PageController pageCtrl;
  Timer? _autoScrollTimer;

  IOWebSocketChannel? _channel;

  // ← ADDED: flag to stop auto-reconnect when disconnect() is called
  bool _manuallyClosed = false;

  // ← ADDED: how many seconds between retries
  final int _retrySeconds = 5;

  /// Call this when recording starts
  void connect() {
    if (_channel != null) return; // already connected
    _manuallyClosed = false;      // ← ADDED: allow reconnects
    _connectWebSocket();
    // give the PageView time to attach
    // Future.delayed(const Duration(milliseconds: 100), _startAutoScroll);
  }

  /// Call this when recording stops
  void disconnect() {
    _manuallyClosed = true;       // ← ADDED: prevent further reconnects
    _autoScrollTimer?.cancel();
    try { _channel?.sink.close(); } catch (_) {}
    _channel = null;
  }

  @override
  void onInit() {
    super.onInit();
    pageCtrl = PageController(viewportFraction: 0.95)
      ..addListener(() {
        final page = pageCtrl.page?.round() ?? 0;
        if (page != currentPage.value) {
          currentPage.value = page;
        }
      });
  }

  @override
  void onClose() {
    _autoScrollTimer?.cancel();
    pageCtrl.dispose();
    super.onClose();
  }

  // ← CHANGED: added retry loop + onDone/onError hooks
  void _connectWebSocket() async {
    final teamId    = await SharedPrefHelper.getpref("team_id");
    final managerId = await SharedPrefHelper.getpref("manager_id");
    final emailId   = await SharedPrefHelper.getpref("email");
    final companyId = await SharedPrefHelper.getpref("company_id");

    final url = Uri(
      scheme: 'wss',
      host: 'devreal.darwix.ai',
      path: '/ws/live-results',
      queryParameters: {
        'user_id':     SharedPrefCache().get("email"),
        'manager_id':  SharedPrefCache().get("manager_id"),
        'company_id':  SharedPrefCache().get("company_id"),
        'team_id':     SharedPrefCache().get("team_id"),
      },
    ).toString();

    while (!_manuallyClosed) {
      try {
        _channel = IOWebSocketChannel.connect(url);

        _channel!.stream.listen(
          (raw) async {
            try {
              // Parse JSON in isolate (HEAVY OPERATION - offloaded from main thread)
              final msg = await JsonParserIsolate.parse(raw);
              print('Received WebSocket message type: ${msg['type']}, action: ${msg['action']}');
              
              // Handle nudge messages (type: nudge)
              if (msg['type'] == 'nudge') {
                final suggestion = (msg['suggestion'] ?? '').toString().trim();
                final value = (msg['value'] ?? '').toString().toLowerCase();
                
                if (suggestion.isNotEmpty) {
                  final isPositive = value.contains('yes');
                  final nudge = Nudge(text: suggestion, positive: isPositive);
                  // Add to nudges list
                  nudges.add(nudge);
                  print('✅ Nudges list updated. Total nudges: ${nudges.length}');
                  
                  // Reset controller to show the new nudge
                  resetController();
                }
              }
              // Handle analysis messages (action: analysis) - legacy support
              else if (msg['action'] == 'analysis') {
                // Parse nudges in isolate
                final parsedNudges = await compute<Map<String, dynamic>, List<Nudge>>(
                  _parseNudgesInIsolate,
                  msg['analysis_result']['response'] as Map<String, dynamic>,
                );
                
                if (parsedNudges.isNotEmpty) {
                  print('📢 Parsed ${parsedNudges.length} nudges from analysis');
                  nudges.assignAll(parsedNudges);
                  resetController();
                }
              }
            } catch (e) {
            }
          },
          onError: _handleSocketError,
          onDone:  _handleSocketDone,
        );

        break;  // exit retry loop on success

      } catch (err) {
        await Future.delayed(Duration(seconds: _retrySeconds));
      }
    }
  }

  // ← ADDED: handler for clean reconnect after server closes
  void _handleSocketDone() {
    _channel = null;
    if (!_manuallyClosed) {
     Future.delayed(Duration(seconds: _retrySeconds), _connectWebSocket);
    }
  }

  // ← ADDED: handler for reconnect on error
  void _handleSocketError(dynamic error) {
    _channel = null;
    if (!_manuallyClosed) {
      Future.delayed(Duration(seconds: _retrySeconds), _connectWebSocket);
    }
  }

  void _parseNudges(Map<String, dynamic> response) {
    final List<Nudge> parsed = [];
    response.forEach((_, cat) {
      (cat['content'] as Map).forEach((_, sub) {
        final text = (sub['nudges'] ?? '').toString().trim();
        if (text.isNotEmpty) {
          final positive = (sub['value'] ?? '').toString().toLowerCase().contains('yes');
          parsed.add(Nudge(text: text, positive: positive));
        }
      });
    });
    if (parsed.isNotEmpty) {
      nudges.assignAll(parsed);
      resetController();
    }
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(
      const Duration(seconds: 10),
          (_) {
        if (nudges.isEmpty) return;
        if (pageCtrl.hasClients && nudges.isNotEmpty) {
          final next = (currentPage.value + 1) % nudges.length;
          pageCtrl.animateToPage(
            next,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeIn,
          );
        }
      },
    );
  }

  void resetController() {
    _autoScrollTimer?.cancel();
    currentPage.value = 0;
    if (pageCtrl.hasClients) {
      pageCtrl.jumpToPage(0);
    }
    //Future.delayed(const Duration(milliseconds: 100), _startAutoScroll);
  }
}
