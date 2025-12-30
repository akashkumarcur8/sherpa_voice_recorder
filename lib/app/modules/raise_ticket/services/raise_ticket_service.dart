import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../models/ticket_model.dart';
import '../models/user_ticket_model.dart';

class RaiseTicketService {
  static const String baseUrl = 'http://35.154.144.116:8000/api';
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.none,
    ),
  );

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
        throw Exception(
            'Failed to load delivery stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch delivery stats: $e');
    }
  }

  // Fetch user tickets with optional filters
  Future<List<UserTicketModel>> fetchUserTickets({
    required String userId,
    String? status,
    String? dateRange,
  }) async {
    try {
      final queryParams = <String, String>{
        'user_id': userId,
      };

      if (status != null && status.isNotEmpty && status != 'all') {
        queryParams['status'] = status;
      }

      if (dateRange != null && dateRange.isNotEmpty) {
        queryParams['date_range'] = dateRange;
      }

      final uri = Uri.parse('$baseUrl/tickets').replace(
        queryParameters: queryParams,
      );

      _logger.d('🌐 RaiseTicketService: GET $baseUrl/tickets');
      _logger.d('📤 RaiseTicketService: Query parameters: $queryParams');
      _logger.d('🔗 RaiseTicketService: Full URL: $uri');
      _logger.d(
          '👤 RaiseTicketService: user_id being sent: "${queryParams['user_id']}"');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      _logger
          .d('📥 RaiseTicketService: Response status: ${response.statusCode}');

      // Handle 404 with NO_TICKETS_FOUND - this is not an error, just empty result
      if (response.statusCode == 404) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['error'] != null &&
            jsonData['error']['code'] == 'NO_TICKETS_FOUND') {
          _logger.i('ℹ️ RaiseTicketService: No tickets found (not an error)');
          return []; // Return empty list instead of throwing error
        }
      }

      if (response.statusCode != 200) {
        _logger
            .e('❌ RaiseTicketService: Error response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        _logger.d(
            '📦 RaiseTicketService: Response JSON keys: ${jsonData.keys.toList()}');

        // Handle different response structures
        List? tickets;

        // Check for success field (API uses "success" not "status")
        if ((jsonData['success'] == true || jsonData['status'] == true) &&
            jsonData['data'] != null) {
          _logger.d('✅ RaiseTicketService: Found data object');
          // Try nested structure first: data.tickets
          tickets = jsonData['data']['tickets'] as List?;
          _logger.d(
              '📋 RaiseTicketService: Found ${tickets?.length ?? 0} tickets in data.tickets');

          // If not found, try direct array in data
          if (tickets == null) {
            tickets = jsonData['data'] as List?;
            _logger.d(
                '📋 RaiseTicketService: Found ${tickets?.length ?? 0} tickets in data array');
          }
        }
        // If still not found, try direct array
        if (tickets == null && jsonData is List) {
          tickets = jsonData;
          _logger.d(
              '📋 RaiseTicketService: Found ${tickets.length} tickets in root array');
        }

        if (tickets != null && tickets.isNotEmpty) {
          _logger
              .d('🔄 RaiseTicketService: Parsing ${tickets.length} tickets...');
          final parsedTickets = tickets
              .map((e) {
                try {
                  return UserTicketModel.fromJson(e);
                } catch (error) {
                  _logger.e(
                      '❌ RaiseTicketService: Error parsing ticket: $error',
                      error: error);
                  return null;
                }
              })
              .whereType<UserTicketModel>()
              .toList();
          _logger.d(
              '✅ RaiseTicketService: Successfully parsed ${parsedTickets.length} tickets');
          return parsedTickets;
        }
        _logger.w('⚠️ RaiseTicketService: No tickets found in response');
        return [];
      } else {
        throw Exception('Failed to load tickets: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network errors more gracefully
      if (e.toString().contains('Connection closed') ||
          e.toString().contains('ClientException')) {
        throw Exception(
            'Network error: Please check your internet connection and try again');
      }
      throw Exception('Error fetching tickets: $e');
    }
  }

  // Search user tickets
  Future<List<UserTicketModel>> searchUserTickets({
    required String userId,
    required String query,
  }) async {
    try {
      final queryParams = {
        'user_id': userId,
        'q': query,
      };

      final uri = Uri.parse('$baseUrl/tickets/search').replace(
        queryParameters: queryParams,
      );

      _logger.d('🔍 RaiseTicketService: GET $baseUrl/tickets/search');
      _logger.d('📤 RaiseTicketService: Query parameters: $queryParams');
      _logger.d('🔗 RaiseTicketService: Full URL: $uri');
      _logger.d('👤 RaiseTicketService: user_id being sent: "$userId"');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      _logger.d(
          '📥 RaiseTicketService: Search response status: ${response.statusCode}');

      // Handle 404 with TICKET_NOT_FOUND or NO_TICKETS_FOUND - this is not an error, just empty result
      if (response.statusCode == 404) {
        final jsonData = jsonDecode(response.body);
        final errorCode = jsonData['error']?['code'];
        if (errorCode == 'TICKET_NOT_FOUND' ||
            errorCode == 'NO_TICKETS_FOUND') {
          _logger.i(
              'ℹ️ RaiseTicketService: No tickets found in search (not an error)');
          return []; // Return empty list instead of throwing error
        }
      }

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        _logger.d(
            '🔍 RaiseTicketService: Search response JSON keys: ${jsonData.keys.toList()}');

        // Handle different response structures
        List? tickets;

        // Check for success field (API uses "success" not "status")
        if ((jsonData['success'] == true || jsonData['status'] == true) &&
            jsonData['data'] != null) {
          _logger
              .d('✅ RaiseTicketService: Found data object in search response');
          // Try nested structure first: data.tickets
          tickets = jsonData['data']['tickets'] as List?;
          _logger.d(
              '📋 RaiseTicketService: Found ${tickets?.length ?? 0} tickets in search data.tickets');

          // If not found, try direct array in data
          if (tickets == null) {
            tickets = jsonData['data'] as List?;
            _logger.d(
                '📋 RaiseTicketService: Found ${tickets?.length ?? 0} tickets in search data array');
          }
        }
        // If still not found, try direct array
        if (tickets == null && jsonData is List) {
          tickets = jsonData;
          _logger.d(
              '📋 RaiseTicketService: Found ${tickets.length} tickets in search root array');
        }

        if (tickets != null && tickets.isNotEmpty) {
          _logger.d(
              '🔄 RaiseTicketService: Parsing ${tickets.length} search tickets...');
          final parsedTickets = tickets
              .map((e) {
                try {
                  return UserTicketModel.fromJson(e);
                } catch (error) {
                  _logger.e(
                      '❌ RaiseTicketService: Error parsing search ticket: $error',
                      error: error);
                  return null;
                }
              })
              .whereType<UserTicketModel>()
              .toList();
          _logger.d(
              '✅ RaiseTicketService: Successfully parsed ${parsedTickets.length} search tickets');
          return parsedTickets;
        }
        _logger.w('⚠️ RaiseTicketService: No tickets found in search response');
        return [];
      } else {
        throw Exception('Failed to search tickets: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network errors more gracefully
      if (e.toString().contains('Connection closed') ||
          e.toString().contains('ClientException')) {
        throw Exception(
            'Network error: Please check your internet connection and try again');
      }
      throw Exception('Error searching tickets: $e');
    }
  }

  // Fetch ticket details by ticket ID
  Future<UserTicketModel> fetchTicketDetails({
    required String ticketId,
    required String userId,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/tickets/$ticketId').replace(
        queryParameters: {
          'user_id': userId,
        },
      );

      _logger.d('🔍 RaiseTicketService: GET $baseUrl/tickets/$ticketId');
      _logger.d('📤 RaiseTicketService: Query parameters: {user_id: $userId}');
      _logger.d('🔗 RaiseTicketService: Full URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      _logger.d(
          '📥 RaiseTicketService: Ticket details response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        _logger.d(
            '📦 RaiseTicketService: Ticket details response JSON keys: ${jsonData.keys.toList()}');

        // Handle response structure
        Map<String, dynamic>? ticketData;
        if (jsonData['success'] == true && jsonData['data'] != null) {
          ticketData = jsonData['data'] as Map<String, dynamic>?;
        } else if (jsonData is Map<String, dynamic>) {
          ticketData = jsonData;
        }

        if (ticketData != null) {
          _logger.d('✅ RaiseTicketService: Successfully parsed ticket details');
          return UserTicketModel.fromJson(ticketData);
        } else {
          throw Exception('Invalid response structure');
        }
      } else {
        throw Exception(
            'Failed to fetch ticket details: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network errors more gracefully
      if (e.toString().contains('Connection closed') ||
          e.toString().contains('ClientException')) {
        throw Exception(
            'Network error: Please check your internet connection and try again');
      }
      throw Exception('Error fetching ticket details: $e');
    }
  }
}
