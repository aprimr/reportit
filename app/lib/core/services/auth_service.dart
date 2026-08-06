import 'package:app/core/model/auth_model.dart';
import 'package:app/core/network/api_endpoints.dart';
import 'package:app/core/network/dio_client.dart';
import 'package:dio/dio.dart';

class AuthService {
  final DioClient _client = DioClient.instance;

  Future<RegisterResponse> register({
    required String fullname,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _client.post(
        ApiEndpoints.register,
        data: {
          'fullname': fullname,
          'email': email,
          'phone': phone,
          'password': password,
        },
      );
      return RegisterResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw e.error is ApiError
          ? e.error as ApiError
          : ApiError(message: e.message ?? 'Registration failed');
    }
  }

  Future<LoginResponse> login({
    required String emailOrPhone,
    required String password,
  }) async {
    try {
      final response = await _client.post(
        ApiEndpoints.login,
        data: {'email_or_phone': emailOrPhone, 'password': password},
      );
      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw e.error is ApiError
          ? e.error as ApiError
          : ApiError(message: e.message ?? 'Login failed');
    }
  }

  Future<LoginResponse> refresh({required String refreshToken}) async {
    try {
      final response = await _client.post(
        ApiEndpoints.refresh,
        data: {'refresh_token': refreshToken},
      );
      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw e.error is ApiError
          ? e.error as ApiError
          : ApiError(message: e.message ?? 'Refresh failed');
    }
  }
}
