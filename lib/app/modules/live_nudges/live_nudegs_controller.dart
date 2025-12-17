import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/io.dart';

import '../../core/services/storage/sharedPrefHelper.dart';
class Nudge {
  final String text;
  final bool positive;
  Nudge({required this.text, required this.positive});
}

// class NudgeController extends GetxController {
//   final nudges = <Nudge>[].obs;
//   final currentPage = 0.obs;
//   // new: recording state
//   final isRecording = false.obs;
//
//   late final PageController pageCtrl;
//   Timer? _autoScrollTimer;
//   IOWebSocketChannel? _channel;
//
//
//
//   /// Call this when recording starts
//   void connect() {
//     if (_channel != null) return; // already connected
//     _connectWebSocket();
//     // give the PageView time to attach
//     Future.delayed(const Duration(milliseconds: 100), _startAutoScroll);
//   }
//
//   /// Call this when recording stops
//   void disconnect() {
//     _autoScrollTimer?.cancel();
//     try { _channel?.sink.close(); } catch (_) {}
//     _channel = null;
//   }
//
//   @override
//   void onInit() {
//     super.onInit();
//     pageCtrl = PageController(viewportFraction: 0.95)
//       ..addListener(() {
//         final page = pageCtrl.page?.round() ?? 0;
//         if (page != currentPage.value) {
//           currentPage.value = page;
//         }
//       });
//     // _connectWebSocket();
//     // Delay the start slightly to give the PageView time to attach
//     // Future.delayed(Duration(milliseconds: 100), _startAutoScroll);
//   }
//
//   @override
//   void onClose() {
//     _autoScrollTimer?.cancel();
//     pageCtrl.dispose();
//     super.onClose();
//   }
//
//   void _connectWebSocket() async {
//     var teamId = await SharedPrefHelper.getpref("team_id");
//     var managerId = await SharedPrefHelper.getpref("manager_id");
//     var emailId = await SharedPrefHelper.getpref("email");
//     var empName = await SharedPrefHelper.getpref("emp_name");
//     var companyId = await SharedPrefHelper.getpref("company_id");
//
//     // print('userdata $teamId,$managerId,$emailId,$empName,$companyId');
//
//
//
//     _channel = IOWebSocketChannel.connect(
//         'wss://omrealtime.cur8.in/ws/live-results?user_id=$emailId&manager_id=$managerId&company_id=$companyId&team_id=$teamId'
//     );
//     _channel!.stream.listen((raw) {
//       final msg = json.decode(raw);
//       print('sfksjabfsk $msg');
//       if (msg['action'] == 'analysis') {
//         _parseNudges(msg['analysis_result']['response']);
//       }
//     }, onError: (e) => print('WS error: $e'));
//   }
//
//   void _parseNudges(Map<String, dynamic> response) {
//     final List<Nudge> parsed = [];
//     response.forEach((_, cat) {
//       (cat['content'] as Map).forEach((_, sub) {
//         final text = (sub['nudges'] ?? '').toString().trim();
//         if (text.isNotEmpty) {
//           final positive = (sub['value'] ?? '').toString().toLowerCase().contains('yes');
//           parsed.add(Nudge(text: text, positive: positive));
//         }
//       });
//     });
//     if (parsed.isNotEmpty) {
//       nudges.assignAll(parsed);
//       resetController();
//       // currentPage.value = 0;
//       // pageCtrl.jumpToPage(0);
//
//     }
//   }
//
//   void _startAutoScroll() {
//     _autoScrollTimer = Timer.periodic(
//       const Duration(seconds: 10),
//           (_) {
//         if (nudges.isEmpty) return;
//         if(pageCtrl.hasClients && nudges.isNotEmpty){
//           final next = (currentPage.value + 1) % nudges.length;
//           pageCtrl.animateToPage(
//               next, duration: const Duration(milliseconds: 800), curve: Curves.easeIn
//           );
//         }
//       },
//     );
//   }
//
//
//   /// Resets page index, jumps back to 0, and restarts auto-scroll
//   void resetController() {
//     // 1) stop existing timer
//     _autoScrollTimer?.cancel();
//
//
//     // 2) reset the page index
//     currentPage.value = 0;
//
//     // 3) jump back to page 0 if attached
//     if (pageCtrl.hasClients) {
//       pageCtrl.jumpToPage(0);
//     }
//
//     // 4) restart auto-scroll after small delay
//     Future.delayed(const Duration(milliseconds: 100), _startAutoScroll);
//   }
//
//
//
//   /// Shut down socket + timer
//   // void disconnect() {
//   //   _autoScrollTimer?.cancel();
//   //   try { _channel?.sink.close(); } catch (_) {}
//   //   _channel = null;
//   // }
// }




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
    Future.delayed(const Duration(milliseconds: 100), _startAutoScroll);
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
        'user_id':     emailId,
        'manager_id':  managerId,
        'company_id':  companyId,
        'team_id':     teamId,
      },
    ).toString();

    while (!_manuallyClosed) {
      print(' urls $url');
      try {
        print('Attempting WS connect to $url …');
        _channel = IOWebSocketChannel.connect(url);

        _channel!.stream.listen(
              (raw) {
            final msg = json.decode(raw);
            print('sfksjabfsk $msg');
            if (msg['action'] == 'analysis') {
              _parseNudges(msg['analysis_result']['response']);
            }
          },
          onError: _handleSocketError,  // ← ADDED
          onDone:  _handleSocketDone,   // ← ADDED
        );

        print('WebSocket connected!');
        break;  // exit retry loop on success

      } catch (err) {
        print('WS connect failed: $err. Retrying in $_retrySeconds seconds…');
        //await Future.delayed(Duration(seconds: _retrySeconds));
      }
    }
  }

  // ← ADDED: handler for clean reconnect after server closes
  void _handleSocketDone() {
    print('WS connection closed by server');
    _channel = null;
    if (!_manuallyClosed) {
     // Future.delayed(Duration(seconds: _retrySeconds), _connectWebSocket);
    }
  }

  // ← ADDED: handler for reconnect on error
  void _handleSocketError(dynamic error) {
    print('WS error: $error');
    _channel = null;
    if (!_manuallyClosed) {
     // Future.delayed(Duration(seconds: _retrySeconds), _connectWebSocket);
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
    Future.delayed(const Duration(milliseconds: 100), _startAutoScroll);
  }
}




