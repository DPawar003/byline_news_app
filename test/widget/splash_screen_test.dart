import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:byline/views/splash/splash_screen.dart';
import 'package:byline/services/token_storage_service.dart';
import 'package:byline/services/firebase_auth_service.dart';

class FakeTokenStorageService extends TokenStorageService {
  String? accessToken;
  String? refreshToken;
  bool expired;
  bool cleared = false;

  FakeTokenStorageService({
    this.accessToken,
    this.refreshToken,
    this.expired = false,
  });

  @override
  Future<String?> getAccessToken() async => accessToken;

  @override
  Future<String?> getRefreshToken() async => refreshToken;

  @override
  bool isTokenExpired(String? token) => expired;

  @override
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
  }

  @override
  Future<void> clearTokens() async {
    cleared = true;
    accessToken = null;
    refreshToken = null;
  }
}

class FakeFirebaseAuthService extends FirebaseAuthService {
  final String? mockRefreshedToken;
  final bool shouldThrow;
  final Duration? delay;

  FakeFirebaseAuthService({
    this.mockRefreshedToken,
    this.shouldThrow = false,
    this.delay,
  });

  @override
  Future<String?> attemptSilentRefresh({
    String? refreshToken,
    Duration timeout = const Duration(seconds: 4),
  }) async {
    if (delay != null) {
      await Future.delayed(delay!);
    }
    if (shouldThrow) {
      throw Exception('Network error');
    }
    return mockRefreshedToken;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestApp({
    required TokenStorageService tokenStorage,
    required FirebaseAuthService authService,
    required String? Function() currentRouteGetter,
    Duration minDisplayDuration = const Duration(milliseconds: 10),
    Duration authTimeout = const Duration(milliseconds: 100),
  }) {
    final router = GoRouter(
      initialLocation: '/splash',
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => SplashScreen(
            tokenStorageService: tokenStorage,
            authService: authService,
            minDisplayDuration: minDisplayDuration,
            authTimeout: authTimeout,
          ),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const Scaffold(body: Text('HOME_SCREEN')),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const Scaffold(body: Text('LOGIN_SCREEN')),
        ),
      ],
    );

    return MaterialApp.router(
      routerConfig: router,
    );
  }

  group('SplashScreen Tests', () {
    testWidgets('Renders Byline brand elements and typography', (tester) async {
      final fakeStorage = FakeTokenStorageService();
      final fakeAuth = FakeFirebaseAuthService();
      String? currentPath;

      await tester.pumpWidget(
        buildTestApp(
          tokenStorage: fakeStorage,
          authService: fakeAuth,
          currentRouteGetter: () => currentPath,
          minDisplayDuration: const Duration(milliseconds: 50),
        ),
      );

      // Verify splash elements while visible
      await tester.pump(const Duration(milliseconds: 10));
      expect(find.text('BYLINE'), findsOneWidget);
      expect(find.text('INDEPENDENT JOURNALISM'), findsOneWidget);

      // Settle any remaining timers
      await tester.pumpAndSettle();
    });

    testWidgets('Navigates directly to /home when valid access token exists', (tester) async {
      final fakeStorage = FakeTokenStorageService(
        accessToken: 'valid_access_token_xyz',
        refreshToken: 'refresh_token_123',
        expired: false,
      );
      final fakeAuth = FakeFirebaseAuthService();
      String? currentPath;

      await tester.pumpWidget(
        buildTestApp(
          tokenStorage: fakeStorage,
          authService: fakeAuth,
          currentRouteGetter: () => currentPath,
          minDisplayDuration: const Duration(milliseconds: 5),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('HOME_SCREEN'), findsOneWidget);
    });

    testWidgets('Attempts silent refresh when access token is expired, navigates to /home on success', (tester) async {
      final fakeStorage = FakeTokenStorageService(
        accessToken: 'expired_access_token',
        refreshToken: 'valid_refresh_token',
        expired: true,
      );
      final fakeAuth = FakeFirebaseAuthService(mockRefreshedToken: 'new_fresh_token_789');
      String? currentPath;

      await tester.pumpWidget(
        buildTestApp(
          tokenStorage: fakeStorage,
          authService: fakeAuth,
          currentRouteGetter: () => currentPath,
          minDisplayDuration: const Duration(milliseconds: 5),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('HOME_SCREEN'), findsOneWidget);
      expect(fakeStorage.accessToken, equals('new_fresh_token_789'));
    });

    testWidgets('Clears tokens and navigates to /login when silent refresh fails', (tester) async {
      final fakeStorage = FakeTokenStorageService(
        accessToken: 'expired_access_token',
        refreshToken: 'invalid_refresh_token',
        expired: true,
      );
      final fakeAuth = FakeFirebaseAuthService(mockRefreshedToken: null);
      String? currentPath;

      await tester.pumpWidget(
        buildTestApp(
          tokenStorage: fakeStorage,
          authService: fakeAuth,
          currentRouteGetter: () => currentPath,
          minDisplayDuration: const Duration(milliseconds: 5),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('LOGIN_SCREEN'), findsOneWidget);
      expect(fakeStorage.cleared, isTrue);
    });

    testWidgets('Navigates directly to /login when neither token exists', (tester) async {
      final fakeStorage = FakeTokenStorageService(
        accessToken: null,
        refreshToken: null,
      );
      final fakeAuth = FakeFirebaseAuthService();
      String? currentPath;

      await tester.pumpWidget(
        buildTestApp(
          tokenStorage: fakeStorage,
          authService: fakeAuth,
          currentRouteGetter: () => currentPath,
          minDisplayDuration: const Duration(milliseconds: 5),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('LOGIN_SCREEN'), findsOneWidget);
    });

    testWidgets('Falls back to /login on network timeout or exception', (tester) async {
      final fakeStorage = FakeTokenStorageService(
        accessToken: 'expired',
        refreshToken: 'refresh',
        expired: true,
      );
      final fakeAuth = FakeFirebaseAuthService(
        shouldThrow: true,
      );
      String? currentPath;

      await tester.pumpWidget(
        buildTestApp(
          tokenStorage: fakeStorage,
          authService: fakeAuth,
          currentRouteGetter: () => currentPath,
          minDisplayDuration: const Duration(milliseconds: 5),
          authTimeout: const Duration(milliseconds: 50),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('LOGIN_SCREEN'), findsOneWidget);
    });
  });
}
