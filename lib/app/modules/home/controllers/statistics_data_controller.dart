import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/services/storage/database_helpher.dart';
import '../../../data/model/statistics_data_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../data/providers/ApiService.dart';


  class StatisticsDataController extends GetxController {
    var totalRecordingHours = ''.obs;
    var totalQualityAudioHours = ''.obs;
    var numberOfDisconnects = 0.obs;
    var numberOfSyncs = 0.obs;
    var lastSync = ''.obs;
    var conversationCount = 0.obs;


    final ApiService _apiService = ApiService();

    /// Regex-based helper to turn “0 hrs 22min” → “0h 22m”
    String _formatDuration(String? raw) {
      // 1. Handle null or empty
      if (raw == null || raw.trim().isEmpty) {
        return '0h 0m';
      }

      // 2. Try to extract hours and minutes (both optional)
      final pattern = RegExp(
        r'(?:(\d+)\s*hrs?)?\s*(?:(\d+)\s*min)?',
        caseSensitive: false,
      );
      final match = pattern.firstMatch(raw);

      if (match != null) {
        // If either group is missing, default to "0"
        final hours = match.group(1)?.trim().isNotEmpty == true ? match.group(1) : '0';
        final mins  = match.group(2)?.trim().isNotEmpty == true ? match.group(2) : '0';
        return '${hours}h ${mins}m';
      }

      // 3. Fallback: swap unit names, then as a last resort return raw
      final swapped = raw
          .replaceAll(RegExp(r'hrs?', caseSensitive: false), 'h')
          .replaceAll(RegExp(r'min', caseSensitive: false), 'm')
          .trim();
      return swapped.isNotEmpty ? swapped : '0h 0m';
    }



    Future<void> fetchUserAudioStats({
      required int userId,
      required DateTime selectedDate,
    }) async {
      final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);


      try {
       // First, check if the data is available in the local DB
       //  final localStats = await DatabaseHelper.getStats(userId, formattedDate);
       //  if (localStats != null) {
       //    _setStats(localStats);
       //  }


        // Now, fetch data from the API
        // Check internet connectivity
        final connectivityResult = await Connectivity().checkConnectivity();
        final isConnected = connectivityResult != ConnectivityResult.none;

        if (isConnected) {
          // Fetch from API if online
          final stats = await _apiService.fetchUserAudioStats(
            userId: userId,
            selectedDate: selectedDate,
          );


          // print('Fetched from API: $stats');

          if (stats != null) {
            _setStats(stats!);
             DatabaseHelper.insertOrUpdateStats(stats);
          }
        } else {
          final localStats = await DatabaseHelper.getStats(userId, formattedDate);
          if (localStats != null) {
            _setStats(localStats);
          }

        }
      } catch (e) {
        print("Error: $e");
      }
    }

    void _setStats(StatisticsDataModel stats) {
      totalRecordingHours.value = _formatDuration(stats.totalRecordingHours);
      totalQualityAudioHours.value = _formatDuration(stats.totalQualityAudioHours);
       numberOfDisconnects.value = stats.numberOfDisconnects;
      numberOfSyncs.value = stats.numberOfSyncs;
      lastSync.value = stats.last_sync;
      conversationCount.value = stats.conversationCount;
      update();
    }
  }

