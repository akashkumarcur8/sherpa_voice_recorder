import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import 'package:mice_activeg/app/modules/conversation/model/conversation_model.dart';
import '../model/statistics_data_model.dart';

class ApiService {
  final Dio _dio = Dio();
  static const _baseUrl = 'https://dashboard.cur8.in';

  Future<StatisticsDataModel?> fetchUserAudioStats({
    required int userId,
    required DateTime selectedDate,
  }) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    try {
      final response = await _dio.post(
        'https://dashboard.cur8.in/api/getUserAudioStats/',
        data: {
          'userId': userId,
          'date': formattedDate,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        print('userer data $data');

        return StatisticsDataModel(
          userId: userId,
          date: formattedDate,
          totalRecordingHours: data['totalRecordingHours'] ?? '',
          totalQualityAudioHours: data['totalQualityAudioHours'] ?? '',
          numberOfDisconnects: data['numberOfDisconnects'] ?? 0,
          numberOfSyncs: data['numberOfSyncs'] ?? 0,
          last_sync: data['last_sync'] ?? '',
          conversationCount: data['conversationCount'] ?? 0,
        );
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<Response?> postConversationSession(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
          "https://dashboard.cur8.in/api/save_conversation_session/",
          data: data);
      return response;
    } catch (e) {
      return null;
    }
  }

  Future<List<ConversationSession>> getConversationSessions({
    required int userId,
    required DateTime date,
    required bool marked,
  }) async {
    final endpoint = marked
        ? '$_baseUrl/api/get_conversation_sessions/'
        : '$_baseUrl/api/get_unmarked_conversation_sessions/';
    final payload = marked
        ? {'userId': userId, 'date': DateFormat('yyyy-MM-dd').format(date)}
        : {'user_id': userId, 'date': DateFormat('yyyy-MM-dd').format(date)};

    final resp = await _dio.post(endpoint, data: payload);
    if (resp.statusCode != 200) {
      throw Exception('Failed to load sessions (${resp.statusCode})');
    }

    final List<dynamic> listData = resp.data is String
        ? jsonDecode(resp.data as String) as List<dynamic>
        : resp.data as List<dynamic>;

    return listData
        .map((e) => ConversationSession.fromJson(
              e as Map<String, dynamic>,
              isMarked: marked,
            ))
        .toList();
  }

  Future<List<ConversationSession>> filterConversationSessions({
    required int userId,
    required DateTime start,
    required DateTime end,
    required bool marked,
  }) async {
    const url = '$_baseUrl/api/filter_conversation_sessions/';
    final resp = await _dio.post(url, data: {
      'user_id': userId,
      'start_date': DateFormat('yyyy-MM-dd').format(start),
      'end_date': DateFormat('yyyy-MM-dd').format(end),
      'type': marked ? 'marked' : 'unmarked',
    });
    if (resp.statusCode != 200) {
      throw Exception('Failed to filter sessions (${resp.statusCode})');
    }

    final List<dynamic> listData = resp.data is String
        ? jsonDecode(resp.data as String) as List<dynamic>
        : resp.data as List<dynamic>;

    return listData
        .map((e) => ConversationSession.fromJson(
              e as Map<String, dynamic>,
              isMarked: marked,
            ))
        .toList();
  }
}
