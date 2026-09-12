import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants.dart';
import '../models/article.dart';

class HiveService {
  late Box _bookmarksBox;
  late Box _readingQueueBox;
  late Box _settingsBox;

  Future<void> init() async {
    await Hive.initFlutter();
    _bookmarksBox = await Hive.openBox(AppConstants.bookmarksBoxName);
    _readingQueueBox = await Hive.openBox(AppConstants.readingQueueBoxName);
    _settingsBox = await Hive.openBox(AppConstants.settingsBoxName);
  }

  // --- BOOKMARKS ---
  Future<void> saveBookmark(Article article) async {
    await _bookmarksBox.put(article.id, article.toHiveMap());
  }

  Future<void> removeBookmark(String articleId) async {
    await _bookmarksBox.delete(articleId);
  }

  bool isBookmarked(String articleId) {
    return _bookmarksBox.containsKey(articleId);
  }

  List<Article> getBookmarks() {
    final List<Article> list = [];
    for (var key in _bookmarksBox.keys) {
      final value = _bookmarksBox.get(key);
      if (value != null && value is Map) {
        list.add(Article.fromHiveMap(value));
      }
    }
    return list;
  }

  // --- OFFLINE READING QUEUE ---
  Future<void> cacheArticles(List<Article> articles) async {
    for (var article in articles) {
      await _readingQueueBox.put(article.id, article.toHiveMap());
    }

    // Enforce max offline cache size limit
    if (_readingQueueBox.length > AppConstants.maxOfflineArticles) {
      final keysToRemove = _readingQueueBox.keys
          .take(_readingQueueBox.length - AppConstants.maxOfflineArticles)
          .toList();
      await _readingQueueBox.deleteAll(keysToRemove);
    }
  }

  List<Article> getCachedArticles() {
    final List<Article> list = [];
    for (var key in _readingQueueBox.keys) {
      final value = _readingQueueBox.get(key);
      if (value != null && value is Map) {
        list.add(Article.fromHiveMap(value));
      }
    }
    return list.reversed.toList(); // return most recent first
  }

  // --- SETTINGS / THEME ---
  Future<void> saveThemePref(String themeStr) async {
    await _settingsBox.put(AppConstants.themePrefKey, themeStr);
  }

  String getThemePref() {
    return _settingsBox.get(AppConstants.themePrefKey, defaultValue: 'system') as String;
  }

  static Map<String, dynamic> _deepCastMap(Map map) {
    return map.map((key, value) {
      final stringKey = key.toString();
      if (value is Map) {
        return MapEntry(stringKey, _deepCastMap(value));
      } else if (value is List) {
        return MapEntry(stringKey, _deepCastList(value));
      }
      return MapEntry(stringKey, value);
    });
  }

  static List _deepCastList(List list) {
    return list.map((item) {
      if (item is Map) {
        return _deepCastMap(item);
      } else if (item is List) {
        return _deepCastList(item);
      }
      return item;
    }).toList();
  }

  // --- USER INTEREST PROFILE ---
  Future<void> saveInterestProfile(Map<String, dynamic> json) async {
    await _settingsBox.put(AppConstants.interestProfileKey, json);
  }

  Map<String, dynamic>? getInterestProfile() {
    final raw = _settingsBox.get(AppConstants.interestProfileKey);
    if (raw is Map) {
      return _deepCastMap(raw);
    }
    return null;
  }

  // --- DAILY BRIEFING ---
  Future<void> saveDailyBriefing(Map<String, dynamic> json) async {
    await _settingsBox.put(AppConstants.dailyBriefingKey, json);
  }

  Map<String, dynamic>? getDailyBriefing() {
    final raw = _settingsBox.get(AppConstants.dailyBriefingKey);
    if (raw is Map) {
      return _deepCastMap(raw);
    }
    return null;
  }
}
