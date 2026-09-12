import 'package:flutter/foundation.dart';
import '../models/article.dart';
import '../services/hive_service.dart';
import '../services/firestore_service.dart';

class BookmarkViewModel extends ChangeNotifier {
  final HiveService _hiveService;
  final FirestoreService _firestoreService;

  List<Article> _bookmarks = [];

  BookmarkViewModel({
    required HiveService hiveService,
    FirestoreService? firestoreService,
  })  : _hiveService = hiveService,
        _firestoreService = firestoreService ?? FirestoreService() {
    loadBookmarks();
  }

  List<Article> get bookmarks => _bookmarks;

  void loadBookmarks([String? userId]) {
    _bookmarks = _hiveService.getBookmarks();
    notifyListeners();

    // Async sync from cloud if user is logged in
    if (userId != null && userId.isNotEmpty) {
      _syncFromCloud(userId);
    }
  }

  Future<void> toggleBookmark(Article article, String? userId) async {
    final exists = _hiveService.isBookmarked(article.id);
    if (exists) {
      await _hiveService.removeBookmark(article.id);
      if (userId != null && userId.isNotEmpty) {
        _firestoreService.removeBookmarkFromCloud(userId, article.id);
      }
    } else {
      await _hiveService.saveBookmark(article);
      if (userId != null && userId.isNotEmpty) {
        _firestoreService.syncBookmarkToCloud(userId, article);
      }
    }
    _bookmarks = _hiveService.getBookmarks();
    notifyListeners();
  }

  bool isBookmarked(String articleId) {
    return _hiveService.isBookmarked(articleId);
  }

  Future<void> _syncFromCloud(String userId) async {
    try {
      final cloudItems = await _firestoreService.getCloudBookmarks(userId);
      for (var article in cloudItems) {
        await _hiveService.saveBookmark(article);
      }
      _bookmarks = _hiveService.getBookmarks();
      notifyListeners();
    } catch (_) {}
  }
}
