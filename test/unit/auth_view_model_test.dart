import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:byline/viewmodels/auth_view_model.dart';
import 'package:byline/services/firebase_auth_service.dart';
import 'package:byline/services/firestore_service.dart';
import 'package:byline/models/app_user.dart';
import 'package:byline/models/article.dart';

class FakeFirebaseAuthService extends FirebaseAuthService {
  bool shouldFail;
  String? failErrorCode;
  bool passwordResetSent = false;
  String? lastResetEmail;

  FakeFirebaseAuthService({this.shouldFail = false, this.failErrorCode});

  @override
  Stream<User?> get authStateChanges => Stream.value(null);

  @override
  Future<UserCredential> signIn({required String email, required String password}) async {
    if (shouldFail) {
      throw FirebaseAuthException(code: failErrorCode ?? 'user-not-found');
    }
    return MockUserCredential();
  }

  @override
  Future<UserCredential> signUp({required String email, required String password}) async {
    if (shouldFail) {
      throw FirebaseAuthException(code: failErrorCode ?? 'email-already-in-use');
    }
    return MockUserCredential();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    if (shouldFail) {
      throw FirebaseAuthException(code: failErrorCode ?? 'user-not-found');
    }
    passwordResetSent = true;
    lastResetEmail = email;
  }
}

class MockUserCredential implements UserCredential {
  @override
  User? get user => null;

  @override
  AuthCredential? get credential => null;

  @override
  AdditionalUserInfo? get additionalUserInfo => null;
}

class FakeFirestoreService implements FirestoreService {
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
  group('AuthViewModel unit tests', () {
    test('signIn success clears error message and sets loading to false', () async {
      final fakeAuth = FakeFirebaseAuthService(shouldFail: false);
      final vm = AuthViewModel(authService: fakeAuth, firestoreService: FakeFirestoreService());

      final result = await vm.signIn('test@example.com', 'password123');
      expect(result, isTrue);
      expect(vm.errorMessage, isNull);
      expect(vm.isLoading, isFalse);
    });

    test('signIn failure parses FirebaseAuthException error code correctly', () async {
      final fakeAuth = FakeFirebaseAuthService(shouldFail: true, failErrorCode: 'invalid-credential');
      final vm = AuthViewModel(authService: fakeAuth, firestoreService: FakeFirestoreService());

      final result = await vm.signIn('wrong@example.com', 'wrongpass');
      expect(result, isFalse);
      expect(vm.errorMessage, contains('Incorrect email or password'));
      expect(vm.isLoading, isFalse);
    });

    test('signUp failure parses weak-password code', () async {
      final fakeAuth = FakeFirebaseAuthService(shouldFail: true, failErrorCode: 'weak-password');
      final vm = AuthViewModel(authService: fakeAuth, firestoreService: FakeFirestoreService());

      final result = await vm.signUp('test@example.com', '123', 'User');
      expect(result, isFalse);
      expect(vm.errorMessage, contains('at least 6 characters'));
    });

    test('sendPasswordResetEmail success updates state and delegates to authService', () async {
      final fakeAuth = FakeFirebaseAuthService();
      final vm = AuthViewModel(authService: fakeAuth, firestoreService: FakeFirestoreService());

      final result = await vm.sendPasswordResetEmail('user@domain.com');
      expect(result, isTrue);
      expect(fakeAuth.passwordResetSent, isTrue);
      expect(fakeAuth.lastResetEmail, equals('user@domain.com'));
      expect(vm.errorMessage, isNull);
    });

    test('sendPasswordResetEmail failure sets user-friendly error message', () async {
      final fakeAuth = FakeFirebaseAuthService(shouldFail: true, failErrorCode: 'user-not-found');
      final vm = AuthViewModel(authService: fakeAuth, firestoreService: FakeFirestoreService());

      final result = await vm.sendPasswordResetEmail('nonexistent@domain.com');
      expect(result, isFalse);
      expect(vm.errorMessage, contains('No account found with this email address'));
    });

    test('clearErrorMessage resets errorMessage to null', () async {
      final fakeAuth = FakeFirebaseAuthService(shouldFail: true, failErrorCode: 'too-many-requests');
      final vm = AuthViewModel(authService: fakeAuth, firestoreService: FakeFirestoreService());

      await vm.signIn('test@example.com', 'pass');
      expect(vm.errorMessage, isNotNull);

      vm.clearErrorMessage();
      expect(vm.errorMessage, isNull);
    });
  });
}
