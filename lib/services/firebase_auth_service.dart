import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth? _auth;

  FirebaseAuthService({FirebaseAuth? auth}) : _auth = auth;

  FirebaseAuth get _client => _auth ?? FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _client.authStateChanges();

  User? get currentUser => _client.currentUser;

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    return await _client.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  Future<void> signOut() async {
    await _client.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _client.sendPasswordResetEmail(email: email.trim());
  }

  /// Attempts a silent token refresh using the active auth session.
  /// Employs a strict timeout to prevent indefinite hangs on launch.
  Future<String?> attemptSilentRefresh({
    String? refreshToken,
    Duration timeout = const Duration(seconds: 4),
  }) async {
    try {
      final user = _client.currentUser;
      if (user != null) {
        final token = await user.getIdToken(true).timeout(timeout);
        return token;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
