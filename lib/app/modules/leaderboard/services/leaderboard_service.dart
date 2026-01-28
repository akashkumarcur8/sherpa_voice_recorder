import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/services/storage/sharedPrefHelper.dart';

class LeaderboardService {
  static const String _baseUrl = 'https://leaderboard.darwix.ai';
  static const String _authToken = 'Bearer sherpaleaderboard123';

  /// Fetches leaderboard data for the given date range
  /// Returns a Map with 'data' key containing the leaderboard list
  /// Throws an Exception if the request fails
  Future<Map<String, dynamic>> fetchLeaderboardData({
    required String startDate,
    required String endDate,
  }) async {
    final companyId = await SharedPrefHelper.getpref("company_id");

    final response = await http.post(
      Uri.parse('$_baseUrl/leaderboard'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': _authToken,
      },
      body: json.encode({
        'companyId': companyId,
        'startDate': startDate,
        'endDate': endDate,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load leaderboard data: ${response.statusCode}');
    }
  }
}
