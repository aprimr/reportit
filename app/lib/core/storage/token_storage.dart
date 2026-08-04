import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _secureStorage = FlutterSecureStorage();

  static String? accessToken;

  // Save refresh token to secure storage and access token to memory
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    TokenStorage.accessToken = accessToken;
    await _secureStorage.write(key: 'refresh_token', value: refreshToken);
  }

  static void saveAccessToken(String newToken) {
    accessToken = newToken;
  }

  // Get refresh token from secure storage
  static Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: 'refresh_token');
  }

  // Clear all tokens on logout
  static Future<void> clearTokens() async {
    accessToken = null;
    await _secureStorage.delete(key: 'refresh_token');
  }
}
