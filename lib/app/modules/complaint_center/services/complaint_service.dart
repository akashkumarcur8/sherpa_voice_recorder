import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/complaint_model.dart';
import '../models/complaint_response.dart';

class ComplaintService {
  final String baseUrl = 'http://35.154.144.116:8000/api';

  // If your API requires GET with query parameters, use this:
  Future fetchComplaints({
    required int managerId,
    required int companyId,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/complaints').replace(
        queryParameters: {
          'managerId': managerId.toString(),
          'companyId': companyId.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return ComplaintResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load complaints: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching complaints: $e');
    }
  }
}