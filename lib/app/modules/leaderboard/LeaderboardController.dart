import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as https;
import 'package:intl/intl.dart';
import 'dart:convert';

import '../../core/services/storage/sharedPrefHelper.dart';
class LeaderboardController extends GetxController {
  String startDate;
  String endDate;

  LeaderboardController({
    required this.startDate,
    required this.endDate,
  });

  // Observable variables
  final RxList<dynamic> leaderboardData = <dynamic>[].obs;
  final RxBool isLoading = true.obs;
  final RxnString error = RxnString();
  final RxnInt currentUserRank = RxnInt();
  final RxString currentUserName = "You".obs;

  // Filter variables
  final TextEditingController startDateCtrl = TextEditingController();
  final TextEditingController endDateCtrl = TextEditingController();
  final RxString selectedSort = 'Newest to Oldest (Newest First)'.obs;
  final RxList<bool> shortcutSel = [false, false, false].obs;
  final RxInt appliedFiltersCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLeaderboardData();
  }

  void updateFiltersCount() {
    int count = 0;
    if (startDateCtrl.text.isNotEmpty && endDateCtrl.text.isNotEmpty) count++;
    if (selectedSort.value != 'Newest to Oldest (Newest First)') count++;
    appliedFiltersCount.value = count;
  }

  void applyFilter({required DateTime start, required DateTime end}) {
    startDate = DateFormat('yyyy-MM-dd').format(start);
    endDate = DateFormat('yyyy-MM-dd').format(end);
    fetchLeaderboardData();
  }

  void resetAllFilters() {
    startDateCtrl.clear();
    endDateCtrl.clear();
    selectedSort.value = 'Newest to Oldest (Newest First)';
    shortcutSel.value = [false, false, false];
    updateFiltersCount();
  }

  Future<void> fetchLeaderboardData() async {
    try {

      isLoading.value = true;
      error.value = null;
      final companyId = await SharedPrefHelper.getpref("company_id");

      final response = await https.post(
        Uri.parse('https://leaderboard.darwix.ai/leaderboard'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer sherpaleaderboard123',
        },
        body: json.encode({
          'companyId': companyId,
          'startDate': startDate,
          'endDate': endDate,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        leaderboardData.value = responseData['data'] ?? [];
        currentUserRank.value = _findCurrentUserRank();
        isLoading.value = false;
      } else {
        throw Exception('Failed to load leaderboard data');
      }
    } catch (e) {
      error.value = e.toString();
      isLoading.value = false;
    }
  }

  int? _findCurrentUserRank() {
    // Logic to find current user's rank
    // You can modify this based on how you identify the current user
    return leaderboardData.length > 3 ? 4 : null;
  }

  Color getAvatarColor(int index) {
    final colors = [
      const Color(0xFF565ADD), // Purple
      const Color(0xFF4CAF50), // Green
      const Color(0xFFFF9800), // Orange
      const Color(0xFF2196F3), // Blue
      const Color(0xFFE91E63), // Pink
      const Color(0xFF9C27B0), // Deep Purple
      const Color(0xFF00BCD4), // Cyan
      const Color(0xFFFF5722), // Deep Orange
    ];
    return colors[index % colors.length];
  }

  String getInitials(String name) {
    List<String> nameParts = name.trim().split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else if (nameParts.isNotEmpty) {
      return nameParts[0][0].toUpperCase();
    }
    return '?';
  }

  List<dynamic> get topThree {
    return leaderboardData.take(3).toList();
  }

  List<dynamic> get otherRanks {
    return leaderboardData.skip(3).toList();
  }
}