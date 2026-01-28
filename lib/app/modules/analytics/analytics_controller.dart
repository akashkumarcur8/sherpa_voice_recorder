import 'package:get/get.dart';
import 'package:http/http.dart' as https;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/services/storage/sharedPrefHelper.dart';
import 'analytics_model.dart';
class AnalyticsController extends GetxController {
  /// loading flag
  final isLoading = false.obs;

  /// today's numbers
  final todayCallCount = 0.obs;
  final todayAvgScore  = 0.obs;

  /// aggregate agent numbers
  final agentCallCount = 0.obs;
  final agentAvgScore  = 0.obs;

  /// the 7+ day history for charting
  final chartSpots  = <FlSpot>[].obs;
  final chartLabels = <String>[].obs;

  /// overall scores
  final agentScore       = 0.obs;
  final avgProductScore  = 0.obs;
  final avgBehaviorScore = 0.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    fetchAnalytics();

  }

  Future<void> fetchAnalytics( {
    DateTime? start,
    DateTime? end,
  }) async {
    isLoading.value = true;
    var userEmail=await SharedPrefHelper.getpref("email");

    try {
      final now     = DateTime.now();
      final dtEnd   = end   ?? now;
      final dtStart = start ?? now.subtract(const Duration(days: 6));

      final startStr = DateFormat('yyyy-MM-dd').format(dtStart);
      final endStr   = DateFormat('yyyy-MM-dd').format(dtEnd);

      final uri = Uri.https('transform.cur8.in', '/webservice/rest/server.php',
        {
          // Moodle WS fields
          'wstoken':            '55d122d76ce0b08e792ce0d4f680b1d2',
          'wsfunction':         'local_get_sherpa_analytics_data',
          'moodlewsrestformat': 'json',

          // Your function's params
          'useremail': userEmail,
          'startdate': startStr,
          'enddate':   endStr,
        },
      );

      final resp = await https.get(uri);

      // 1️⃣ HTTP‐status check
      if (resp.statusCode != 200) {
        throw Exception('HTTP error: ${resp.statusCode}');
      }

      // 2️⃣ Parse JSON
      final jsonBody = jsonDecode(resp.body) as Map<String, dynamic>;

      // 3️⃣ Moodle “exception” guard
      if (jsonBody['exception'] != null) {
        throw Exception(
            'Moodle error: ${jsonBody['exception']} – ${jsonBody['message']}'
        );
      }

      // 4️⃣ Map into your model
      final data = AnalyticsData.fromJson(jsonBody);

      // 5️⃣ Populate your observables
      todayCallCount.value = data.today.callCount;
      todayAvgScore.value  = data.today.avgScore;

      agentCallCount.value = data.agent.callCount;
      agentAvgScore.value  = data.agent.avgScore;

      chartSpots.value = data.agent.scoreHistory
          .asMap()
          .entries
          .map((e) => FlSpot(
        e.key.toDouble(),
        e.value.score.toDouble(),
      ))
          .toList();
      chartLabels.value = data.agent.scoreHistory
          .map((e) => e.day)
          .toList();

      agentScore.value       = data.overall.agentScore;
      avgProductScore.value  = data.overall.avgProductScore;
      avgBehaviorScore.value = data.overall.avgBehaviorScore;
    } catch (e) {
    } finally {
      isLoading.value = false;
    }
  }




  Future<void> fetchFilterAnalytics({
    required int days,
  }) async {
    isLoading.value = true;
    var userEmail= await SharedPrefHelper.getpref("email");

    try {
      final Uri uri;
      final now     = DateTime.now();
      final dtEnd   = now;
      final dtStart =  now.subtract(const Duration(days: 6));

      final startStr = DateFormat('yyyy-MM-dd').format(dtStart);
      final endStr   = DateFormat('yyyy-MM-dd').format(dtEnd);
      if(days==7)
        {
           uri = Uri.https('transform.cur8.in', '/webservice/rest/server.php',
            {
              // Moodle WS fields
              'wstoken':            '55d122d76ce0b08e792ce0d4f680b1d2',
              'wsfunction':         'local_get_sherpa_analytics_data',
              'moodlewsrestformat': 'json',

              // Your function's params
              'useremail': userEmail,
              'startdate': startStr,
              'enddate':   endStr,
            },
          );
        }
      else
        {
           uri = Uri.https(
            'transform.cur8.in',
            '/webservice/rest/server.php',
            {
              // Moodle WS fields
              'wstoken':            '55d122d76ce0b08e792ce0d4f680b1d2',
              'wsfunction':         'local_learningnudges_get_analytics_sherpa',
              'moodlewsrestformat': 'json',

              // Your function's params
              'userEmail': userEmail,
              'days': days.toString(),

            },
          );
        }

      final resp = await https.get(uri);

      // 1️⃣ HTTP‐status check
      if (resp.statusCode != 200) {
        throw Exception('HTTP error: ${resp.statusCode}');
      }

      // 2️⃣ Parse JSON
      final jsonBody = jsonDecode(resp.body) as Map<String, dynamic>;

      // 3️⃣ Moodle “exception” guard
      if (jsonBody['exception'] != null) {
        throw Exception(
            'Moodle error: ${jsonBody['exception']} – ${jsonBody['message']}'
        );
      }

      // 4️⃣ Map into your model
      final data = AnalyticsData.fromJson(jsonBody);

      // 5️⃣ Populate your observables
      todayCallCount.value = data.today.callCount;
      todayAvgScore.value  = data.today.avgScore;

      agentCallCount.value = data.agent.callCount;
      agentAvgScore.value  = data.agent.avgScore;

      chartSpots.value = data.agent.scoreHistory
          .asMap()
          .entries
          .map((e) => FlSpot(
        e.key.toDouble(),
        e.value.score.toDouble(),
      ))
          .toList();
      chartLabels.value = data.agent.scoreHistory
          .map((e) => e.day)
          .toList();

      agentScore.value       = data.overall.agentScore;
      avgProductScore.value  = data.overall.avgProductScore;
      avgBehaviorScore.value = data.overall.avgBehaviorScore;
    } catch (e) {
    } finally {
      isLoading.value = false;
    }
  }








}
