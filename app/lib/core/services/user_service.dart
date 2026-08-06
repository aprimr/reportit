import 'package:app/core/model/user_model.dart';
import 'package:app/core/network/api_endpoints.dart';
import 'package:app/core/network/dio_client.dart';
import 'package:dio/dio.dart';

class UserService {
  final DioClient _client = DioClient.instance;

  Future<UserProfileResponse> fetchProfile() async {
    try {
      final response = await _client.get(ApiEndpoints.fetchProfile);
      return UserProfileResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw e.error is ApiError
          ? e.error as ApiError
          : ApiError(message: e.message ?? 'Failed to fetch profile');
    }
  }

  Future<BaseResponse> updateFullname({required String fullname}) async {
    try {
      final response = await _client.patch(
        ApiEndpoints.updateFullname,
        data: {'fullname': fullname},
      );
      return BaseResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw e.error is ApiError
          ? e.error as ApiError
          : ApiError(message: e.message ?? 'Failed to update full name');
    }
  }

  Future<BaseResponse> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _client.patch(
        ApiEndpoints.changePassword,
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );
      return BaseResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw e.error is ApiError
          ? e.error as ApiError
          : ApiError(message: e.message ?? 'Failed to change password');
    }
  }
}
