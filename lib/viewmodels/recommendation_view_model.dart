import 'package:flutter/foundation.dart';
import '../models/article.dart';
import '../models/user_interest_profile.dart';
import '../models/daily_briefing.dart';
import '../services/hive_service.dart';
import '../services/recommendation_engine.dart';

class RecommendationViewModel extends ChangeNotifier {
  final HiveService _hiveService;
  final RecommendationEngine _engine = RecommendationEngine();

  UserInterestProfile? _profile;
  DailyBriefing? _dailyBriefing;
  bool _isLoading = false;

  RecommendationViewModel({required HiveService hiveService})
      : _hiveService = hiveService {
    loadProfile();
  }

  UserInterestProfile? get profile => _profile;
  DailyBriefing? get dailyBriefing => _dailyBriefing;
  bool get isLoading => _isLoading;
  bool get hasCompletedOnboarding => _profile != null;

  void loadProfile() {
    try {
      final rawProfile = _hiveService.getInterestProfile();
      if (rawProfile != null) {
        _profile = UserInterestProfile.fromJson(rawProfile);
      }

      final rawBriefing = _hiveService.getDailyBriefing();
      if (rawBriefing != null) {
        _dailyBriefing = DailyBriefing.fromJson(rawBriefing);
      }
    } catch (e, stackTrace) {
      debugPrint('RecommendationViewModel.loadProfile error: $e\n$stackTrace');
    }
    notifyListeners();
  }

  Future<void> setProfile(UserInterestProfile newProfile) async {
    _profile = newProfile;
    await _hiveService.saveInterestProfile(newProfile.toJson());
    notifyListeners();
  }

  /// Scores and ranks a list of candidate articles according to the user's profile
  List<ScoredArticle> getPersonalizedFeed(List<Article> candidates) {
    if (_profile == null || candidates.isEmpty) {
      return candidates.map((a) {
        return ScoredArticle(
          article: a,
          finalScore: 0.5,
          attributionTag: 'Trending in Byline',
          scoreComponents: const {},
        );
      }).toList();
    }

    return _engine.rankArticles(articles: candidates, profile: _profile!);
  }

  /// Generates or refreshes the AI-synthesized morning briefing
  Future<void> generateDailyBriefing(List<Article> candidates) async {
    if (_profile == null || candidates.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    final briefing = _engine.generateDailyBriefing(
      candidateArticles: candidates,
      profile: _profile!,
    );

    _dailyBriefing = briefing;
    await _hiveService.saveDailyBriefing(briefing.toJson());

    _isLoading = false;
    notifyListeners();
  }

  /// Records implicit and explicit reading signals:
  /// - Opens & read duration (> 60s is high engagement)
  /// - Thumbs up / Thumbs down
  Future<void> recordArticleInteraction({
    required Article article,
    required int durationSeconds,
    bool? thumbsUp,
  }) async {
    if (_profile == null) return;

    _profile = _profile!.recordRead(
      topic: article.category,
      durationSeconds: durationSeconds,
      thumbsUp: thumbsUp,
    );

    await _hiveService.saveInterestProfile(_profile!.toJson());
    notifyListeners();
  }

  /// Toggles the fatigue exemption ("Keep showing me this" override)
  Future<void> toggleFatigueExemption(String topic) async {
    if (_profile == null) return;

    _profile = _profile!.toggleFatigueExemption(topic);
    await _hiveService.saveInterestProfile(_profile!.toJson());
    notifyListeners();
  }
}
