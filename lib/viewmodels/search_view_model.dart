import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/article.dart';
import '../services/network_service.dart';
import '../core/error/failure.dart';
import '../core/constants.dart';

enum SearchFilterMode { all, titleOnly, keywordsOnly }

class SearchViewModel extends ChangeNotifier {
  final NetworkService _networkService;

  List<Article> _rawResults = [];
  List<String> _recentSearches = ['Technology', 'Economy', 'Global Trade', 'Climate'];
  SearchFilterMode _filterMode = SearchFilterMode.all;
  String _query = '';
  int _currentPage = 1;
  bool _isLoading = false;
  bool _isFetchingNextPage = false;
  bool _hasReachedMax = false;
  Failure? _failure;
  Timer? _debounceTimer;

  SearchViewModel({NetworkService? networkService})
      : _networkService = networkService ?? NetworkService();

  String get query => _query;
  SearchFilterMode get filterMode => _filterMode;
  List<String> get recentSearches => List.unmodifiable(_recentSearches);
  bool get isLoading => _isLoading;
  bool get isFetchingNextPage => _isFetchingNextPage;
  bool get hasReachedMax => _hasReachedMax;
  Failure? get failure => _failure;

  /// Returns search results dynamically filtered by title or keywords depending on [filterMode]
  List<Article> get searchResults {
    if (_query.trim().isEmpty) return [];

    final q = _query.trim().toLowerCase();

    return _rawResults.where((article) {
      final matchesTitle = article.title.toLowerCase().contains(q);
      final matchesKeywords = article.description.toLowerCase().contains(q) ||
          article.content.toLowerCase().contains(q) ||
          article.category.toLowerCase().contains(q) ||
          article.sourceName.toLowerCase().contains(q) ||
          (article.briefTakeaways?.any((t) => t.toLowerCase().contains(q)) ?? false) ||
          (article.deepDiveAnalysis?.toLowerCase().contains(q) ?? false);

      switch (_filterMode) {
        case SearchFilterMode.titleOnly:
          return matchesTitle;
        case SearchFilterMode.keywordsOnly:
          return matchesKeywords;
        case SearchFilterMode.all:
          return matchesTitle || matchesKeywords;
      }
    }).toList();
  }

  void setFilterMode(SearchFilterMode mode) {
    if (_filterMode == mode) return;
    _filterMode = mode;
    notifyListeners();
  }

  void onQueryChanged(String newQuery) {
    _query = newQuery;
    _debounceTimer?.cancel();

    if (newQuery.trim().isEmpty) {
      _rawResults = [];
      _failure = null;
      _isLoading = false;
      notifyListeners();
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: AppConstants.searchDebounceMs), () {
      executeSearch(newQuery, refresh: true);
    });
  }

  Future<void> executeSearch(String searchQuery, {bool refresh = false}) async {
    final cleanQuery = searchQuery.trim();
    if (cleanQuery.isEmpty) return;

    _query = cleanQuery;
    _addRecentSearch(cleanQuery);

    if (refresh) {
      _currentPage = 1;
      _hasReachedMax = false;
      _failure = null;
    }

    _isLoading = true;
    _failure = null;
    notifyListeners();

    try {
      final results = await _networkService.searchArticles(
        query: cleanQuery,
        page: _currentPage,
      );

      if (refresh || _currentPage == 1) {
        _rawResults = results;
      } else {
        _rawResults.addAll(results);
      }

      if (results.length < AppConstants.pageSize) {
        _hasReachedMax = true;
      }
    } on Failure catch (f) {
      _failure = f;
    } catch (e) {
      _failure = UnknownFailure(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchNextPage() async {
    if (_isFetchingNextPage || _hasReachedMax || _isLoading || _query.trim().isEmpty) return;

    _isFetchingNextPage = true;
    notifyListeners();

    _currentPage++;
    try {
      final results = await _networkService.searchArticles(
        query: _query.trim(),
        page: _currentPage,
      );

      if (results.isEmpty || results.length < AppConstants.pageSize) {
        _hasReachedMax = true;
      }
      _rawResults.addAll(results);
    } catch (_) {
      _hasReachedMax = true;
    } finally {
      _isFetchingNextPage = false;
      notifyListeners();
    }
  }

  void clearQuery() {
    _query = '';
    _rawResults = [];
    _failure = null;
    _isLoading = false;
    _debounceTimer?.cancel();
    notifyListeners();
  }

  void _addRecentSearch(String search) {
    if (search.isEmpty) return;
    _recentSearches.removeWhere((item) => item.toLowerCase() == search.toLowerCase());
    _recentSearches.insert(0, search);
    if (_recentSearches.length > 8) {
      _recentSearches = _recentSearches.sublist(0, 8);
    }
  }

  void removeRecentSearch(String search) {
    _recentSearches.remove(search);
    notifyListeners();
  }

  void clearRecentSearches() {
    _recentSearches.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
