import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/complaint_response.dart';
import '../models/complaint_model.dart';

class ComplaintService {
  final String baseUrl = 'http://35.154.144.116:8000/api';

  // Fetch complaints with optional filters
  Future<ComplaintResponse> fetchComplaints({
    required int managerId,
    required int companyId,
    String? status,
    String? dateRange,
  }) async {
    try {
      final queryParams = <String, String>{
        'managerId': managerId.toString(),
        'companyId': companyId.toString(),
      };

      if (status != null && status.isNotEmpty && status != 'all') {
        queryParams['status'] = status;
      }

      if (dateRange != null && dateRange.isNotEmpty) {
        queryParams['dateRange'] = dateRange;
      }

      final uri = Uri.parse('$baseUrl/complaints').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      // Handle 404 with "No complaints found" - this is not an error, just empty result
      if (response.statusCode == 404) {
        final jsonData = jsonDecode(response.body);
        // Check for different response structures
        final errorCode = jsonData['error']?['code'];
        final message = jsonData['message']?.toString().toLowerCase() ?? '';
        final status = jsonData['status'];

        // Handle both error code format and message format
        if (errorCode == 'NO_TICKETS_FOUND' ||
            errorCode == 'NO_COMPLAINTS_FOUND' ||
            message.contains('no complaints found') ||
            message.contains('no complaints') ||
            (status == false && message.isNotEmpty)) {
          // Return empty response
          return ComplaintResponse(
            status: true,
            message: 'No complaints found',
            pendingComplaints: [],
            resolvedComplaints: [],
            statistics: Statistics(
              total: 0,
              pending: 0,
              resolved: 0,
            ),
          );
        }
      }

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

  // Search complaints
  Future<List<ComplaintModel>> searchComplaints({
    required int managerId,
    required int companyId,
    required String query,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/complaints/search').replace(
        queryParameters: {
          'managerId': managerId.toString(),
          'companyId': companyId.toString(),
          'query': query,
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      // Handle 404 with "No complaints found" - this is not an error, just empty result
      if (response.statusCode == 404) {
        final jsonData = jsonDecode(response.body);
        // Check for different response structures
        final errorCode = jsonData['error']?['code'];
        final message = jsonData['message']?.toString().toLowerCase() ?? '';
        final status = jsonData['status'];

        if (errorCode == 'NO_TICKETS_FOUND' ||
            errorCode == 'NO_COMPLAINTS_FOUND' ||
            errorCode == 'TICKET_NOT_FOUND' ||
            message.contains('no complaints found') ||
            message.contains('no tickets found') ||
            (status == false &&
                (message.contains('no complaints') ||
                    message.contains('no tickets')))) {
          return []; // Return empty list instead of throwing error
        }
      }

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == true && jsonData['data'] != null) {
          final complaints = jsonData['data']['complaints'] as List?;
          if (complaints != null) {
            return complaints.map((e) => ComplaintModel.fromJson(e)).toList();
          }
        }
        return [];
      } else {
        throw Exception('Failed to search complaints: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching complaints: $e');
    }
  }

  // Fetch complaint details by ID
  Future<ComplaintModel> fetchComplaintDetails({
    required int managerId,
    required int companyId,
    required String complaintId,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/complaints/$complaintId').replace(
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
        if (jsonData['status'] == true && jsonData['data'] != null) {
          return ComplaintModel.fromJson(jsonData['data']);
        } else {
          throw Exception('Complaint not found');
        }
      } else {
        throw Exception(
            'Failed to load complaint details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching complaint details: $e');
    }
  }
}
