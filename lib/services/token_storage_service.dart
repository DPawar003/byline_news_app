import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for persisting and managing auth tokens securely using [FlutterSecureStorage].
class TokenStorageService {
  static const String _accessTokenKey = 'byline_access_token';
  static const String _refreshTokenKey = 'byline_refresh_token';

  final FlutterSecureStorage _storage;

  TokenStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(resetOnError: true),
              iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
            );

  /// Retrieves the stored access token, if any.
  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _accessTokenKey);
    } catch (_) {
      return null;
    }
  }

  /// Retrieves the stored refresh token, if any.
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (_) {
      return null;
    }
  }

  /// Saves both access and refresh tokens.
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  /// Deletes all stored tokens.
  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  /// Checks if a JWT token is expired.
  /// Returns `true` if null, empty, malformed, or past its expiration timestamp.
  bool isTokenExpired(String? token) {
    if (token == null || token.trim().isEmpty) return true;

    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        // Not a standard JWT; if it is an opaque token, treat non-empty as valid
        return false;
      }

      // Normalize base64 string padding
      var payload = parts[1];
      while (payload.length % 4 != 0) {
        payload += '=';
      }

      final decodedBytes = base64Url.decode(payload);
      final jsonMap = jsonDecode(utf8.decode(decodedBytes));

      if (jsonMap is Map<String, dynamic> && jsonMap.containsKey('exp')) {
        final expSeconds = jsonMap['exp'] as num;
        final expiryDate = DateTime.fromMillisecondsSinceEpoch(
          (expSeconds * 1000).toInt(),
          isUtc: true,
        );
        // Include a 10-second safety grace window
        return DateTime.now().toUtc().isAfter(
          expiryDate.subtract(const Duration(seconds: 10)),
        );
      }

      return false;
    } catch (_) {
      return true;
    }
  }
}
