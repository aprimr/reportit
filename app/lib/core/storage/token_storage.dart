import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _secureStorage = FlutterSecureStorage();

  // Save tokens to secure storage
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _secureStorage.write(key: 'access_token', value: accessToken);
    await _secureStorage.write(key: 'refresh_token', value: refreshToken);
  }

  static void saveAccessToken(String newToken) async {
    await _secureStorage.write(key: 'access_token', value: newToken);
  }

  // Get access token from secure storage
  static Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: 'access_token');
  }

  // Get refresh token from secure storage
  static Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: 'refresh_token');
  }

  // Clear all tokens on logout
  static Future<void> clearTokens() async {
    await _secureStorage.delete(key: 'access_token');
    await _secureStorage.delete(key: 'refresh_token');
  }
}
