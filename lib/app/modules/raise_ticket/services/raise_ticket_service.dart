

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/ticket_model.dart';

class RaiseTicketService {


  static const String baseUrl = 'http://35.154.144.116:8000/api';

  // Common headers for all requests
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    // Uncomment and add token if authentication is required
    // 'Authorization': 'Bearer $authToken',
  };


  Future<dynamic> createTicket(TicketModel ticket) async {
    try {


      final response = await http.post(
        Uri.parse('$baseUrl/tickets'),
        headers: _headers,
        body: json.encode(ticket.toJson()),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to load delivery stats: ${response.statusCode}');
      }


      // For now, return dummy data
      // await Future.delayed(const Duration(milliseconds: 500));
      // return DeliveryStatsModel(
      //   pending: 12,
      //   delivered: 32,
      //   totalAgents: 44,
      // );
    } catch (e) {
      throw Exception('Failed to fetch delivery stats: $e');
    }
  }


}


