import 'package:flutter/foundation.dart';
import '../models/article.dart';
import '../services/network_service.dart';
import '../services/hive_service.dart';
import '../core/error/failure.dart';
import '../core/constants.dart';
import '../core/severity_classifier.dart';

class FeedViewModel extends ChangeNotifier {
  final NetworkService _networkService;
  final HiveService _hiveService;

  List<Article> _articles = [];
  String _selectedCategory = 'general';
  int _currentPage = 1;
  bool _isLoading = false;
  bool _isFetchingNextPage = false;
  bool _hasReachedMax = false;
  bool _isOfflineMode = false;
  Failure? _failure;

  FeedViewModel({
    NetworkService? networkService,
    required HiveService hiveService,
  })  : _networkService = networkService ?? NetworkService(),
        _hiveService = hiveService;

  List<Article> get articles {
    if (_selectedCategory == 'critical') {
      final high = _articles.where((a) => a.severityLevel == SeverityLevel.high).toList();
      if (high.isNotEmpty) return high;
      return _articles.where((a) => a.severityLevel == SeverityLevel.medium).toList();
    }
    return _articles;
  }

  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  bool get isFetchingNextPage => _isFetchingNextPage;
  bool get hasReachedMax => _hasReachedMax;
  bool get isOfflineMode => _isOfflineMode;
  Failure? get failure => _failure;

  Article? get leadHeroArticle {
    final list = articles;
    return list.isNotEmpty ? list.first : null;
  }

  List<Article> get remainingArticles {
    final list = articles;
    return list.length > 1 ? list.sublist(1) : [];
  }

  Future<void> fetchHeadlines({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasReachedMax = false;
      _failure = null;
    }

    if (_isLoading) return;
    _isLoading = true;
    _failure = null;
    notifyListeners();

    try {
      List<Article> fetched;
      if (_selectedCategory == 'critical') {
        fetched = await _networkService.searchArticles(
          query: 'crisis OR attack OR emergency OR war OR breaking OR risk',
          page: _currentPage,
        );
      } else {
        fetched = await _networkService.fetchTopHeadlines(
          category: _selectedCategory,
          page: _currentPage,
        );
      }

      _isOfflineMode = false;
      if (refresh || _currentPage == 1) {
        _articles = fetched;
      } else {
        _articles.addAll(fetched);
      }

      if (fetched.length < AppConstants.pageSize) {
        _hasReachedMax = true;
      }

      // Auto-cache to Hive offline reading queue
      await _hiveService.cacheArticles(_articles);
    } on Failure catch (f) {
      _failure = f;
      if (f is NoInternetFailure || f is TimeoutFailure) {
        // Fallback to offline reading queue
        final cached = _hiveService.getCachedArticles();
        if (cached.isNotEmpty) {
          _articles = cached;
          _isOfflineMode = true;
        }
      }
    } catch (e) {
      _failure = UnknownFailure(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchNextPage() async {
    if (_isFetchingNextPage || _hasReachedMax || _isLoading || _isOfflineMode) return;

    _isFetchingNextPage = true;
    notifyListeners();

    _currentPage++;
    try {
      List<Article> fetched;
      if (_selectedCategory == 'critical') {
        fetched = await _networkService.searchArticles(
          query: 'crisis OR attack OR emergency OR war OR breaking OR risk',
          page: _currentPage,
        );
      } else {
        fetched = await _networkService.fetchTopHeadlines(
          category: _selectedCategory,
          page: _currentPage,
        );
      }

      if (fetched.isEmpty || fetched.length < AppConstants.pageSize) {
        _hasReachedMax = true;
      }
      _articles.addAll(fetched);

      // Cache updated list
      await _hiveService.cacheArticles(_articles);
    } catch (_) {
      _hasReachedMax = true;
    } finally {
      _isFetchingNextPage = false;
      notifyListeners();
    }
  }

  void selectCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    fetchHeadlines(refresh: true);
  }
}
