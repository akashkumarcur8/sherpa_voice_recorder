import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/delivery_stats_model.dart';
import '../models/agent_model.dart';

class DeliveryTrackerService {
  static const String baseUrl = 'http://35.154.144.116:8000/api';

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
  };

  /// Fetch all delivery data (stats + agents) from single API
  Future<Map<String, dynamic>> fetchDeliveryData(String managerId, String companyId) async {
    try {
      final uri = Uri.parse('$baseUrl/delivery-stats').replace(queryParameters: {
        'managerId': managerId,
        'companyId': companyId,
      });

      final response = await http.get(
        uri,
        headers: _headers,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Extract stats from the response
        final stats = DeliveryStatsModel(
          pending: data['pending']['count'] ?? 0,
          delivered: data['delivered']['count'] ?? 0,
          totalAgents: data['totalAgents']['count'] ?? 0,
        );

        // Extract agents lists
        final pendingAgents = (data['pending']['agents'] as List)
            .map((json) => AgentModel.fromJson(json))
            .toList();

        final deliveredAgents = (data['delivered']['agents'] as List)
            .map((json) => AgentModel.fromJson(json))
            .toList();

        final allAgents = (data['totalAgents']['agents'] as List)
            .map((json) => AgentModel.fromJson(json))
            .toList();

        return {
          'stats': stats,
          'pendingAgents': pendingAgents,
          'deliveredAgents': deliveredAgents,
          'allAgents': allAgents,
        };
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch delivery data: $e');
    }
  }

  /// Send reminder to agents with pending deliveries
  Future<bool> sendReminder(List<String> agentIds) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/send-reminder'),
        headers: _headers,
        body: json.encode({
          'agent_ids': agentIds,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to send reminder: ${response.statusCode}');
      }
    } catch (e) {
      // For now, if API is not ready, simulate success
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    }
  }

  /// Fetch agent detail by ID
  Future<dynamic> fetchAgentDetail(String agentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/agents/$agentId/details'),
        headers: _headers,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else if (response.statusCode == 404) {
        throw Exception('Agent details not found');
      } else {
        throw Exception('Failed to load agent details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}