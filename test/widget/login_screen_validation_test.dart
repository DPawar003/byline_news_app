import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:byline/views/auth/login_screen.dart';
import 'package:byline/viewmodels/auth_view_model.dart';
import 'package:byline/services/firebase_auth_service.dart';
import 'package:byline/services/firestore_service.dart';
import 'package:byline/models/app_user.dart';
import 'package:byline/models/article.dart';

class MockFirebaseAuthService extends FirebaseAuthService {
  bool shouldResetSucceed = true;

  @override
  Stream<User?> get authStateChanges => Stream.value(null);

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    if (!shouldResetSucceed) {
      throw Exception('Reset error');
    }
  }
}

class MockFirestoreService implements FirestoreService {
  @override
  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String displayName,
  }) async {}

  @override
  Future<AppUser?> getUserProfile(String uid) async => null;

  @override
  Future<void> syncBookmarkToCloud(String uid, Article article) async {}

  @override
  Future<void> removeBookmarkFromCloud(String uid, String articleId) async {}

  @override
  Future<List<Article>> getCloudBookmarks(String uid) async => [];
}

void main() {
  Widget buildTestableLoginScreen({AuthViewModel? vm}) {
    final authVM = vm ?? AuthViewModel(
      authService: MockFirebaseAuthService(),
      firestoreService: MockFirestoreService(),
    );

    return MaterialApp(
      home: ChangeNotifierProvider<AuthViewModel>.value(
        value: authVM,
        child: const LoginScreen(),
      ),
    );
  }

  group('LoginScreen Validation & Authentication Widget Tests', () {
    testWidgets('Shows validation errors on empty Sign In submission', (tester) async {
      await tester.pumpWidget(buildTestableLoginScreen());

      // Tap SIGN IN button without filling fields
      await tester.tap(find.text('SIGN IN'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email address'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('Validates invalid email format', (tester) async {
      await tester.pumpWidget(buildTestableLoginScreen());

      await tester.enterText(find.byType(TextFormField).at(0), 'invalidemailformat');
      await tester.tap(find.text('SIGN IN'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });

    testWidgets('Switches between Sign In and Create Account tabs with field updates', (tester) async {
      await tester.pumpWidget(buildTestableLoginScreen());

      expect(find.text('CREATE ACCOUNT'), findsNothing);
      expect(find.text('Full Name / Display Name'), findsNothing);

      // Switch to Create Account tab
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      expect(find.text('CREATE ACCOUNT'), findsOneWidget);
      expect(find.text('Full Name / Display Name'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.text('I agree to the Terms of Service and Privacy Policy.'), findsOneWidget);
    });

    testWidgets('Validates Sign Up form: name, email, password strength, confirm password, terms checkbox', (tester) async {
      await tester.pumpWidget(buildTestableLoginScreen());

      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      // Ensure button is visible before tapping in test runner environment
      final submitButtonFinder = find.text('CREATE ACCOUNT');
      await tester.ensureVisible(submitButtonFinder);
      await tester.tap(submitButtonFinder);
      await tester.pumpAndSettle();

      expect(find.text('Please enter your full name'), findsOneWidget);
      expect(find.text('Please enter your email address'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
      expect(find.text('You must accept the terms to create an account'), findsOneWidget);

      // Enter weak password without uppercase/digit
      await tester.enterText(find.byType(TextFormField).at(0), 'Jane Doe');
      await tester.enterText(find.byType(TextFormField).at(1), 'jane@example.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'short');

      await tester.ensureVisible(submitButtonFinder);
      await tester.tap(submitButtonFinder);
      await tester.pumpAndSettle();

      expect(find.text('Password must be at least 8 characters long'), findsOneWidget);

      // Enter valid password but mismatching confirm password
      await tester.enterText(find.byType(TextFormField).at(2), 'SecurePass1');
      await tester.enterText(find.byType(TextFormField).at(3), 'DifferentPass1');

      await tester.ensureVisible(submitButtonFinder);
      await tester.tap(submitButtonFinder);
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('Opens Forgot Password dialog and handles email password reset', (tester) async {
      await tester.pumpWidget(buildTestableLoginScreen());

      // Tap Forgot Password
      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();

      expect(find.text('Reset Password'), findsOneWidget);
      expect(find.text('SEND LINK'), findsOneWidget);

      // Submit empty reset email
      await tester.tap(find.text('SEND LINK'));
      await tester.pumpAndSettle();

      expect(find.text('Enter your email address'), findsOneWidget);

      // Enter valid email and send
      await tester.enterText(find.byType(TextFormField).last, 'resetuser@example.com');
      await tester.tap(find.text('SEND LINK'));
      await tester.pumpAndSettle();

      // Verify dialog dismissed and success SnackBar shown
      expect(find.text('Reset Password'), findsNothing);
      expect(find.text('Password reset email sent to resetuser@example.com. Please check your inbox.'), findsOneWidget);
    });
  });
}
