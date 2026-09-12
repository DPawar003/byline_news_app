import 'package:flutter/foundation.dart';
import '../models/article.dart';

class ReadingBudgetViewModel extends ChangeNotifier {
  int _targetMinutes = 10; // Default 10 min daily briefing
  bool _isBudgetModeActive = false;
  final Set<String> _readArticleIds = {};

  int get targetMinutes => _targetMinutes;
  bool get isBudgetModeActive => _isBudgetModeActive;
  Set<String> get readArticleIds => Set.unmodifiable(_readArticleIds);

  void setTargetMinutes(int minutes) {
    if (_targetMinutes != minutes) {
      _targetMinutes = minutes;
      notifyListeners();
    }
  }

  void toggleBudgetMode([bool? active]) {
    _isBudgetModeActive = active ?? !_isBudgetModeActive;
    notifyListeners();
  }

  void markArticleRead(String articleId) {
    if (!_readArticleIds.contains(articleId)) {
      _readArticleIds.add(articleId);
      notifyListeners();
    }
  }

  /// Curates an exact mix of articles matching the selected budget
  List<Article> curateArticlesForBudget(List<Article> allArticles) {
    if (allArticles.isEmpty) return [];

    final result = <Article>[];
    int currentMinutes = 0;

    for (final article in allArticles) {
      final time = article.readTimeMinutes;
      // If adding this article fits or is within target margin:
      if (currentMinutes + time <= _targetMinutes || result.isEmpty) {
        result.add(article);
        currentMinutes += time;
      }
      if (currentMinutes >= _targetMinutes) break;
    }

    return result;
  }

  int calculateMinutesRead(List<Article> curatedList) {
    int readMins = 0;
    for (final article in curatedList) {
      if (_readArticleIds.contains(article.id)) {
        readMins += article.readTimeMinutes;
      }
    }
    return readMins;
  }

  bool isBudgetCompleted(List<Article> curatedList) {
    if (curatedList.isEmpty) return false;
    return curatedList.every((a) => _readArticleIds.contains(a.id));
  }

  void resetProgress() {
    _readArticleIds.clear();
    notifyListeners();
  }
}
