import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as https;
import 'package:intl/intl.dart';
import 'package:mice_activeg/app/modules/realtime_conversation/realtime_conversation_model.dart';

import '../../core/services/storage/sharedPrefHelper.dart';

class RealtimeConvesationController extends GetxController {
  var sessions = <Session>[].obs;
  var isLoading = true.obs;
  var isOffline = false.obs;
  var isUpdating = false.obs;
  final _connectivity = Connectivity();
  var appliedFilterCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _listenConnectivity();
    fetchSessions();
  }

  void _listenConnectivity() {
    _connectivity.onConnectivityChanged.listen((status) {
      isOffline.value = status == ConnectivityResult.none;
      if (!isOffline.value) {
        fetchSessions();
      }
    });
  }

  Future<void> fetchSessions() async {
    try {
      isLoading.value = true;
      var userEmail = await SharedPrefHelper.getpref("email");
      var companyId = await SharedPrefHelper.getpref("company_id");

      final uri = Uri.parse("https://devreal.darwix.ai/api/sessions/");
      final body = jsonEncode({
        "user_id": userEmail,
        "company_id": companyId,
        "start_time": DateFormat('yyyy-MM-dd').format(DateTime.now()),
        "end_time": DateFormat('yyyy-MM-dd').format(DateTime.now())
      });
      final resp = await https.post(uri,
          headers: {"Content-Type": "application/json"}, body: body);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        List jsonList = data is List ? data : [data];
        sessions.value = jsonList.map((j) => Session.fromJson(j)).toList();
      } else {
        throw Exception("Failed with code ${resp.statusCode}");
      }
    } catch (e) {
      Get.snackbar("You are offline", "Please check Your internet connection",
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> applyFilter({
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      isLoading.value = true;
      var userEmail = await SharedPrefHelper.getpref("email");
      var companyId = await SharedPrefHelper.getpref("company_id");

      // update filter badge
      appliedFilterCount.value = 1;
      // call your same endpoint but with filter params:
      final uri = Uri.parse("https://devreal.darwix.ai/api/sessions/");
      final body = {
        "user_id": userEmail,
        "start_time": DateFormat('yyyy-MM-dd').format(start),
        "end_time": DateFormat('yyyy-MM-dd').format(end),
        "company_id": companyId
      };
      final resp = await https.post(uri,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(body));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        List jsonList = data is List ? data : [data];
        sessions.value = jsonList.map((j) => Session.fromJson(j)).toList();
      } else {
        throw Exception("Error ${resp.statusCode}");
      }
    } catch (e) {
      Get.snackbar("You are offline", "Please check Your internet connection",
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  /// Call the PUT API and then update the matching Session in [sessions].
  Future<void> updateProductsIdentified({
    required String callId,
    required List<String> productNames,
  }) async {
    isUpdating.value = true;
    try {
      final companyId = await SharedPrefHelper.getpref("company_id");
      final dio = Dio(BaseOptions(
        baseUrl: 'https://devreal.darwix.ai',
        headers: {'Content-Type': 'application/json'},
      ));

      final resp = await dio.put(
        '/api/sessions/update-products-identified',
        data: {
          'call_id': callId,
          'company_id': companyId,
          'productname': productNames,
        },
      );

      // server returns {"status":"success","new_value":"mattress, sofa, chair, table"}
      if (resp.statusCode == 200 && resp.data['status'] == 'success') {
        final String newValue = resp.data['new_value'] as String;

        // find the session in our list
        final idx = sessions.indexWhere((s) => s.report.callId == callId);
        if (idx != -1) {
          final old = sessions[idx];
          final updatedReport = old.report.copyWith(productName: newValue);
          sessions[idx] = old.copyWith(report: updatedReport);
        }

        Get.snackbar('Success', 'Products updated to: $newValue',
            snackPosition: SnackPosition.BOTTOM);
      } else {
        throw Exception('Server error: ${resp.data}');
      }
    } on DioError catch (dioErr) {
      final msg = dioErr.response != null
          ? 'HTTP ${dioErr.response?.statusCode}: ${dioErr.response?.statusMessage}'
          : 'Network error: ${dioErr.message}';
      Get.snackbar('Update failed', msg, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isUpdating.value = false;
    }
  }

  // Future<void> syncAllConversations() async {
  //   const int numericUserId = 134;
  //   const String email = 'karthikeyan.ramaswamy@darwix.ai';
  //   const String today = '2025-06-11';
  //   const String yesterday = '2025-06-10';
  //
  //   // 1) Initialize DB
  //   DatabaseHelper databaseHelper= DatabaseHelper();
  //
  //   // 2) Create a single Dio instance (optionally configure interceptors, timeouts, etc.)
  //   final dio = Dio();
  //   // e.g. dio.options.connectTimeout = 5000;
  //
  //   final api = ApiService();
  //
  //   // 3) Fetch both
  //   final unmarked = await api.fetchUnmarkedSessions(
  //     userId: numericUserId,
  //     date: today,
  //   );
  //   final detailed = await api.fetchDetailedSessions(
  //     userId: numericUserId,
  //     agentEmail: email,
  //     startTime: yesterday,
  //     endTime: today,
  //   );
  //
  //   // 4) Save them all
  //   await DatabaseHelper.insertConversations([
  //     ...unmarked,
  //     ...detailed,
  //   ]);
  //
  //   print('Synced ${unmarked.length + detailed.length} rows.');
  // }
}
