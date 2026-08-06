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

class UserProfileResponse {
  final bool success;
  final String message;
  final UserProfileData data;

  UserProfileResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) {
    return UserProfileResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: UserProfileData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class UserProfileData {
  final String uid;
  final String fullname;
  final String email;
  final String phone;
  final String role;
  final bool isVerified;
  final String createdAt;
  final String updatedAt;

  UserProfileData({
    required this.uid,
    required this.fullname,
    required this.email,
    required this.phone,
    required this.role,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfileData.fromJson(Map<String, dynamic> json) {
    return UserProfileData(
      uid: json['uid'] as String,
      fullname: json['fullname'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      role: json['role'] as String,
      isVerified: json['is_verified'] as bool,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }
}
