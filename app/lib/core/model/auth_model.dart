class LoginResponse {
  final bool success;
  final String message;
  final TokenData data;

  LoginResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: TokenData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class TokenData {
  final String accessToken;
  final String refreshToken;

  TokenData({required this.accessToken, required this.refreshToken});

  factory TokenData.fromJson(Map<String, dynamic> json) {
    return TokenData(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
    );
  }
}

class RegisterResponse {
  final bool success;
  final String message;
  final UserData data;

  RegisterResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: UserData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class UserData {
  final String uid;
  final String fullname;
  final String email;
  final String phone;
  final String role;
  final bool isVerified;

  UserData({
    required this.uid,
    required this.fullname,
    required this.email,
    required this.phone,
    required this.role,
    required this.isVerified,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      uid: json['uid'] as String,
      fullname: json['fullname'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      role: json['role'] as String,
      isVerified: json['is_verified'] as bool,
    );
  }
}
