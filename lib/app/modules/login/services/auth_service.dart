
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../model/login_model.dart';

class AuthService extends GetxService {
  late final Dio _dio;
  static const String _baseUrl = 'https://dashboard.cur8.in/api';
  static const String _moodleBaseUrl = 'https://transform.cur8.in/webservice/rest/server.php';
  static const String _wsToken = '55d122d76ce0b08e792ce0d4f680b1d2';

  @override
  void onInit() {
    super.onInit();
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));
  }

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/login/',
        data: request.toJson(),
      );
    

      if (response.statusCode == 200) {
        final resData = response.data;
        final details = jsonDecode(resData['details']);

        return LoginResponse(
          status: resData['status'] ?? '',
          details: UserDetails.fromJson(details),
        );
      } else {
        throw Exception('Login failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Login failed: ${e.response?.statusMessage}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<ManagerInfoResponse> getManagerInfo(String email) async {
    try {
      final response = await _dio.get(
        _moodleBaseUrl,
        queryParameters: {
          'wstoken': _wsToken,
          'wsfunction': 'local_learningnudges_get_user_managerid_by_email',
          'moodlewsrestformat': 'json',
          'email': email,
        },
      );

      return ManagerInfoResponse.fromJson(response.data);
    } on DioException {
      // If manager info fails, return default values
      return ManagerInfoResponse();
    } catch (e) {
      return ManagerInfoResponse();
    }
  }




  Future<ManagerUserIdResponse> getMangerUserId(String email) async {
    try {
      final response = await _dio.get(
        _moodleBaseUrl,
        queryParameters: {
          'wstoken': _wsToken,
          'wsfunction': 'local_courses_get_user_detail',
          'moodlewsrestformat': 'json',
          'email_id': email,
        },
      );
      return ManagerUserIdResponse.fromJson(response.data);
    } on DioException {
      // If manager info fails, return default values
      return ManagerUserIdResponse();
    } catch (e) {
      return ManagerUserIdResponse();
    }
  }

}