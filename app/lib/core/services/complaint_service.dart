import 'package:app/core/model/complaint_model.dart';
import 'package:app/core/network/api_endpoints.dart';
import 'package:app/core/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class ComplaintService {
  final DioClient _client = DioClient.instance;

  Future<ComplaintResponse> createComplaint({
    required String title,
    required String description,
    required String category,
    required double latitude,
    required double longitude,
    required bool isPublic,
    required List<XFile?> images,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'title': title,
        'description': description,
        'category': category,
        'latitude': latitude,
        'longitude': longitude,
        'is_public': isPublic,
        'images': images.isNotEmpty
            ? await Future.wait(
                images.map(
                  (image) async => await MultipartFile.fromFile(
                    image!.path,
                    filename: image.path.split('/').last,
                  ),
                ),
              )
            : [],
      });

      final response = await _client.post(
        ApiEndpoints.createComplaint,
        data: formData,
      );
      return ComplaintResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw e.error is ApiError
          ? e.error as ApiError
          : ApiError(message: e.message ?? 'Failed to create complaint');
    }
  }

  Future<BaseResponse> deleteComplaint({required String id}) async {
    try {
      final response = await _client.delete(
        '${ApiEndpoints.complaintDetail}/$id',
      );
      return BaseResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw e.error is ApiError
          ? e.error as ApiError
          : ApiError(message: e.message ?? 'Failed to delete complaint');
    }
  }

  Future<ComplaintResponse> getComplaintById({required String id}) async {
    try {
      final response = await _client.get('${ApiEndpoints.complaintDetail}/$id');
      return ComplaintResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw e.error is ApiError
          ? e.error as ApiError
          : ApiError(message: e.message ?? 'Failed to fetch complaint details');
    }
  }

  Future<ComplaintListResponse> getMyComplaints({
    String? search,
    String? status,
    String? sort,
    int? limit,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};
      if (search != null) queryParameters['search'] = search;
      if (status != null) queryParameters['status'] = status;
      if (sort != null) queryParameters['sort'] = sort;
      if (limit != null) queryParameters['limit'] = limit;

      final response = await _client.get(
        ApiEndpoints.getMyComplaints,
        queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
      );
      return ComplaintListResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw e.error is ApiError
          ? e.error as ApiError
          : ApiError(message: e.message ?? 'Failed to fetch your complaints');
    }
  }

  Future<FeedComplaintListResponse> getAllComplaints({
    String? search,
    String? status,
    String? sort,
    int? limit,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};
      if (search != null) queryParameters['search'] = search;
      if (status != null) queryParameters['status'] = status;
      if (sort != null) queryParameters['sort'] = sort;
      if (limit != null) queryParameters['limit'] = limit;

      final response = await _client.get(
        ApiEndpoints.getAllComplaints,
        queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
      );
      return FeedComplaintListResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw e.error is ApiError
          ? e.error as ApiError
          : ApiError(message: e.message ?? 'Failed to fetch all complaints');
    }
  }
}
