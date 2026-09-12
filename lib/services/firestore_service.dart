import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';
import '../models/article.dart';

class FirestoreService {
  final FirebaseFirestore _db;

  FirestoreService({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  // --- USER PROFILE DOC ---
  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String displayName,
  }) async {
    final docRef = _db.collection('users').doc(uid);
    final doc = await docRef.get();
    if (!doc.exists) {
      final user = AppUser(
        uid: uid,
        email: email,
        displayName: displayName.isNotEmpty ? displayName : email.split('@').first,
        themePref: 'system',
        createdAt: DateTime.now().toIso8601String(),
      );
      await docRef.set(user.toJson());
    }
  }

  Future<AppUser?> getUserProfile(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return AppUser.fromJson(doc.data()!);
      }
    } catch (_) {}
    return null;
  }

  // --- BOOKMARK CLOUD SYNC ---
  Future<void> syncBookmarkToCloud(String uid, Article article) async {
    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('bookmarks')
          .doc(article.id)
          .set(article.toHiveMap());

      // Trigger aggregate counter (demonstrating server-side Firestore aggregation trigger)
      await _db.collection('article_stats').doc(article.id).set({
        'bookmarkCount': FieldValue.increment(1),
        'lastBookmarkedAt': FieldValue.serverTimestamp(),
        'title': article.title,
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  Future<void> removeBookmarkFromCloud(String uid, String articleId) async {
    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('bookmarks')
          .doc(articleId)
          .delete();
    } catch (_) {}
  }

  Future<List<Article>> getCloudBookmarks(String uid) async {
    try {
      final querySnapshot = await _db
          .collection('users')
          .doc(uid)
          .collection('bookmarks')
          .get();

      return querySnapshot.docs
          .map((doc) => Article.fromHiveMap(doc.data()))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
