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

class ComplaintStats {
  final int open;
  final int verified;
  final int resolved;
  final int rejected;
  final int total;

  ComplaintStats({
    required this.open,
    required this.verified,
    required this.resolved,
    required this.rejected,
    required this.total,
  });

  factory ComplaintStats.fromJson(Map<String, dynamic> json) {
    return ComplaintStats(
      open: json['open'] as int,
      verified: json['verified'] as int,
      resolved: json['resolved'] as int,
      rejected: json['rejected'] as int,
      total: json['total'] as int,
    );
  }
}

class UserProfile {
  final String uid;
  final String fullname;
  final String email;
  final String phone;
  final String role;
  final bool isVerified;
  final String createdAt;
  final String updatedAt;

  UserProfile({
    required this.uid,
    required this.fullname,
    required this.email,
    required this.phone,
    required this.role,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
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

class UserProfileData {
  final UserProfile user;
  final ComplaintStats complaintStats;

  UserProfileData({required this.user, required this.complaintStats});

  factory UserProfileData.fromJson(Map<String, dynamic> json) {
    return UserProfileData(
      user: UserProfile.fromJson(json['user'] as Map<String, dynamic>),
      complaintStats: ComplaintStats.fromJson(
        json['complaint_stats'] as Map<String, dynamic>,
      ),
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
