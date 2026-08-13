class BaseResponse {
  final bool success;
  final String message;

  BaseResponse({required this.success, required this.message});

  factory BaseResponse.fromJson(Map<String, dynamic> json) {
    return BaseResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
    );
  }
}

class ComplaintModel {
  final String id;
  final String uid;
  final String title;
  final String description;
  final String category;
  final List<String> imageUrls;
  final double longitude;
  final double latitude;
  final bool isPublic;
  final String status;
  final String? adminRemarks;
  final String? verifiedAt;
  final String? rejectedAt;
  final String? resolvedAt;
  final String createdAt;

  ComplaintModel({
    required this.id,
    required this.uid,
    required this.title,
    required this.description,
    required this.category,
    required this.imageUrls,
    required this.longitude,
    required this.latitude,
    required this.isPublic,
    required this.status,
    this.adminRemarks,
    this.verifiedAt,
    this.rejectedAt,
    this.resolvedAt,
    required this.createdAt,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    return ComplaintModel(
      id: json['id'] ?? '',
      uid: json['uid'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      imageUrls: List<String>.from(json['image_urls'] ?? []),
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      isPublic: json['is_public'] ?? true,
      status: json['status'] ?? 'open',
      adminRemarks: json['admin_remarks'],
      verifiedAt: json['verified_at'],
      rejectedAt: json['rejected_at'],
      resolvedAt: json['resolved_at'],
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'title': title,
      'description': description,
      'category': category,
      'image_urls': imageUrls,
      'longitude': longitude,
      'latitude': latitude,
      'is_public': isPublic,
      'status': status,
      'admin_remarks': adminRemarks,
      'verified_at': verifiedAt,
      'rejected_at': rejectedAt,
      'resolved_at': resolvedAt,
      'created_at': createdAt,
    };
  }
}

class FeedComplaintModel {
  final String id;
  final String uid;
  final String title;
  final String description;
  final String category;
  final List<String> imageUrls;
  final double longitude;
  final double latitude;
  final bool isPublic;
  final String status;
  final String fullname;
  final String email;
  final String? verifiedAt;
  final String? rejectedAt;
  final String? resolvedAt;
  final String createdAt;

  FeedComplaintModel({
    required this.id,
    required this.uid,
    required this.title,
    required this.description,
    required this.category,
    required this.imageUrls,
    required this.longitude,
    required this.latitude,
    required this.isPublic,
    required this.status,
    required this.fullname,
    required this.email,
    this.verifiedAt,
    this.rejectedAt,
    this.resolvedAt,
    required this.createdAt,
  });

  factory FeedComplaintModel.fromJson(Map<String, dynamic> json) {
    return FeedComplaintModel(
      id: json['id'] ?? '',
      uid: json['uid'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      imageUrls: List<String>.from(json['image_urls'] ?? []),
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      isPublic: json['is_public'] ?? true,
      status: json['status'] ?? 'open',
      fullname: json['fullname'],
      email: json['email'],
      verifiedAt: json['verified_at'],
      rejectedAt: json['rejected_at'],
      resolvedAt: json['resolved_at'],
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'title': title,
      'description': description,
      'category': category,
      'image_urls': imageUrls,
      'longitude': longitude,
      'latitude': latitude,
      'is_public': isPublic,
      'status': status,
      'fullname': fullname,
      'email': email,
      'verified_at': verifiedAt,
      'rejected_at': rejectedAt,
      'resolved_at': resolvedAt,
      'created_at': createdAt,
    };
  }
}

class ComplaintResponse {
  final bool success;
  final String message;
  final ComplaintModel data;

  ComplaintResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ComplaintResponse.fromJson(Map<String, dynamic> json) {
    return ComplaintResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: ComplaintModel.fromJson(json['data'] ?? {}),
    );
  }
}

class ComplaintListResponse {
  final bool success;
  final String message;
  final List<ComplaintModel> data;

  ComplaintListResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ComplaintListResponse.fromJson(Map<String, dynamic> json) {
    return ComplaintListResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => ComplaintModel.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class FeedComplaintListResponse {
  final bool success;
  final String message;
  final List<FeedComplaintModel> data;

  FeedComplaintListResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory FeedComplaintListResponse.fromJson(Map<String, dynamic> json) {
    return FeedComplaintListResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => FeedComplaintModel.fromJson(item))
              .toList() ??
          [],
    );
  }
}
