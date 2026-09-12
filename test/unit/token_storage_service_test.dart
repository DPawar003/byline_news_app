import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:byline/services/token_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TokenStorageService tests', () {
    late TokenStorageService tokenStorage;

    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      tokenStorage = TokenStorageService();
    });

    test('Saves, retrieves, and clears access and refresh tokens', () async {
      expect(await tokenStorage.getAccessToken(), isNull);
      expect(await tokenStorage.getRefreshToken(), isNull);

      await tokenStorage.saveTokens(
        accessToken: 'mock_access_token_123',
        refreshToken: 'mock_refresh_token_456',
      );

      expect(await tokenStorage.getAccessToken(), equals('mock_access_token_123'));
      expect(await tokenStorage.getRefreshToken(), equals('mock_refresh_token_456'));

      await tokenStorage.clearTokens();

      expect(await tokenStorage.getAccessToken(), isNull);
      expect(await tokenStorage.getRefreshToken(), isNull);
    });

    test('isTokenExpired returns true for null, empty, or whitespace tokens', () {
      expect(tokenStorage.isTokenExpired(null), isTrue);
      expect(tokenStorage.isTokenExpired(''), isTrue);
      expect(tokenStorage.isTokenExpired('   '), isTrue);
    });

    test('isTokenExpired correctly parses JWT with past expiration', () {
      final pastExp = DateTime.now().subtract(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000;
      final header = base64Url.encode(utf8.encode(jsonEncode({'alg': 'HS256', 'typ': 'JWT'}))).replaceAll('=', '');
      final payload = base64Url.encode(utf8.encode(jsonEncode({'exp': pastExp, 'sub': 'user123'}))).replaceAll('=', '');
      final expiredJwt = '$header.$payload.signature';

      expect(tokenStorage.isTokenExpired(expiredJwt), isTrue);
    });

    test('isTokenExpired correctly parses JWT with future expiration', () {
      final futureExp = DateTime.now().add(const Duration(hours: 2)).millisecondsSinceEpoch ~/ 1000;
      final header = base64Url.encode(utf8.encode(jsonEncode({'alg': 'HS256', 'typ': 'JWT'}))).replaceAll('=', '');
      final payload = base64Url.encode(utf8.encode(jsonEncode({'exp': futureExp, 'sub': 'user123'}))).replaceAll('=', '');
      final validJwt = '$header.$payload.signature';

      expect(tokenStorage.isTokenExpired(validJwt), isFalse);
    });

    test('isTokenExpired safely treats non-JWT opaque tokens as non-expired', () {
      expect(tokenStorage.isTokenExpired('opaque_secure_session_key'), isFalse);
    });
  });
}
