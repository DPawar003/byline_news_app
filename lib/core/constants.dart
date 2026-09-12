import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // GNews API Configuration
  static const String gnewsBaseUrl = 'https://gnews.io/api/v4';
  
  // Default GNews API key fallback.
  static const String defaultGNewsApiKey = String.fromEnvironment(
    'GNEWS_API_KEY',
    defaultValue: '',
  );

  static String get gnewsApiKey {
    try {
      if (dotenv.isInitialized) {
        final envKey = dotenv.env['GNEWS_API_KEY'];
        if (envKey != null && envKey.isNotEmpty) {
          return envKey;
        }
      }
    } catch (_) {}
    return defaultGNewsApiKey;
  }

  // Pagination & Debounce
  static const int pageSize = 10;
  static const int searchDebounceMs = 400;
  static const int networkTimeoutSeconds = 10;
  static const int maxOfflineArticles = 20;

  // Hive Box Names
  static const String bookmarksBoxName = 'bookmarks_box';
  static const String readingQueueBoxName = 'reading_queue_box';
  static const String settingsBoxName = 'settings_box';
  static const String themePrefKey = 'theme_pref_key';
  static const String interestProfileKey = 'interest_profile_key';
  static const String dailyBriefingKey = 'daily_briefing_key';

  // Categories for GNews API
  static const List<String> newsCategories = [
    'general',
    'critical',
    'world',
    'business',
    'technology',
    'entertainment',
    'sports',
    'science',
  ];
}
