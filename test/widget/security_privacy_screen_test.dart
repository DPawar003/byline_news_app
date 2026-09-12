import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:byline/views/profile/security_privacy_screen.dart';
import 'package:byline/views/profile/profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:byline/viewmodels/auth_view_model.dart';
import 'package:byline/viewmodels/theme_view_model.dart';
import 'package:byline/viewmodels/feed_view_model.dart';
import 'package:byline/models/app_user.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Security & Privacy Screen Tests', () {
    testWidgets('Renders header and all 5 required privacy & security statements',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: SecurityPrivacyScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Screen Title
      expect(find.text('Security & Privacy'), findsOneWidget);

      // Verify Item 1: Data Protection
      expect(find.text('Data Protection'), findsOneWidget);
      expect(
        find.text(
          'Data Protection – Your personal information is securely stored and protected from unauthorized access.',
        ),
        findsOneWidget,
      );

      // Verify Item 2: Secure Authentication
      expect(find.text('Secure Authentication'), findsOneWidget);
      expect(
        find.text(
          'Secure Authentication – User accounts are protected with secure login and authentication methods.',
        ),
        findsOneWidget,
      );

      // Verify Item 3: Privacy of User Data
      expect(find.text('Privacy of User Data'), findsOneWidget);
      expect(
        find.text(
          'Privacy of User Data – Personal information and reading activity are kept private and are not shared without consent.',
        ),
        findsOneWidget,
      );

      // Verify Item 4: Location Privacy
      expect(find.text('Location Privacy'), findsOneWidget);
      expect(
        find.text(
          'Location Privacy – Location data is collected only when required for location-based news and can be disabled by the user.',
        ),
        findsOneWidget,
      );

      // Verify Item 5: Data Deletion
      expect(find.text('Data Deletion'), findsOneWidget);
      expect(
        find.text(
          'Data Deletion – Users can request deletion of their account and associated personal data.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('Data Deletion action opens dialog with explanation and confirmation',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: SecurityPrivacyScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Find and tap Request Account & Data Deletion
      final actionButton = find.text('Request Account & Data Deletion');
      expect(actionButton, findsOneWidget);
      await tester.ensureVisible(actionButton);
      await tester.tap(actionButton);
      await tester.pumpAndSettle();

      // Check dialog
      expect(find.text('Request Data Deletion'), findsOneWidget);
      expect(find.text('Confirm Request'), findsOneWidget);

      // Tap confirm
      await tester.tap(find.text('Confirm Request'));
      await tester.pumpAndSettle();

      // Check feedback SnackBar
      expect(
        find.text('Your data deletion request has been registered.'),
        findsOneWidget,
      );
    });
  });

  group('Notifications UI Removal Verification', () {
    testWidgets('ProfileScreen contains Security & Privacy and NO Notifications option',
        (tester) async {
      final fakeAuthVM = _MockAuthViewModel();
      final fakeThemeVM = _MockThemeViewModel();
      final fakeFeedVM = _MockFeedViewModel();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthViewModel>.value(value: fakeAuthVM),
            ChangeNotifierProvider<ThemeViewModel>.value(value: fakeThemeVM),
            ChangeNotifierProvider<FeedViewModel>.value(value: fakeFeedVM),
          ],
          child: const MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Security & Privacy MUST be present
      expect(find.text('Security & Privacy'), findsOneWidget);

      // Notification settings MUST NOT be present anywhere in the screen
      expect(find.text('Breaking News Notifications'), findsNothing);
      expect(find.byIcon(Icons.notifications_none_outlined), findsNothing);
      expect(find.byIcon(Icons.notifications), findsNothing);
    });
  });
}

class _MockAuthViewModel extends ChangeNotifier implements AuthViewModel {
  @override
  bool get isAuthenticated => true;

  @override
  bool get isLoading => false;

  @override
  String? get errorMessage => null;

  @override
  fb.User? get user => null;

  @override
  AppUser? get userProfile => const AppUser(
        uid: 'u1',
        email: 'reader@byline.news',
        displayName: 'Byline Reader',
        createdAt: '2026-01-01',
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockThemeViewModel extends ChangeNotifier implements ThemeViewModel {
  @override
  bool get isDarkMode => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockFeedViewModel extends ChangeNotifier implements FeedViewModel {
  @override
  bool get isOfflineMode => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
