import 'package:flutter/foundation.dart';
import '../models/article.dart';
import '../models/user_interest_profile.dart';
import '../models/daily_briefing.dart';
import '../services/hive_service.dart';
import '../services/recommendation_engine.dart';

class OnboardingViewModel extends ChangeNotifier {
  final HiveService _hiveService;
  final RecommendationEngine _recommendationEngine = RecommendationEngine();

  int _currentStep = 0;

  // Screen 1: Topics
  final Set<String> _selectedTopics = {'technology', 'business', 'climate'};

  // Screen 2: Sub-topics / Entities
  final Set<String> _selectedEntities = {
    'Artificial Intelligence',
    'Semiconductor Hardware',
    'Macro Policy & Fed',
    'Nuclear & SMRs'
  };

  // Screen 3: Preferences
  String _selectedDepth = 'standard'; // 'brief', 'standard', 'deepDive'
  String _selectedTone = 'analytical'; // 'neutral', 'analytical', 'conversational'
  int _selectedTimeBudget = 10; // 5, 10, 20

  // Screen 4: Live Sample Briefing
  DailyBriefing? _sampleBriefing;
  bool _isGeneratingBriefing = false;

  OnboardingViewModel({required HiveService hiveService})
      : _hiveService = hiveService;

  int get currentStep => _currentStep;
  Set<String> get selectedTopics => Set.unmodifiable(_selectedTopics);
  Set<String> get selectedEntities => Set.unmodifiable(_selectedEntities);
  String get selectedDepth => _selectedDepth;
  String get selectedTone => _selectedTone;
  int get selectedTimeBudget => _selectedTimeBudget;
  DailyBriefing? get sampleBriefing => _sampleBriefing;
  bool get isGeneratingBriefing => _isGeneratingBriefing;

  bool get canProceedFromStep1 => _selectedTopics.length >= 3;
  bool get canProceedFromStep2 => _selectedEntities.isNotEmpty;

  void setStep(int step) {
    _currentStep = step;
    if (_currentStep == 3 && _sampleBriefing == null) {
      generateSampleBriefing();
    }
    notifyListeners();
  }

  void nextStep() {
    if (_currentStep < 3) {
      setStep(_currentStep + 1);
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      setStep(_currentStep - 1);
    }
  }

  // --- Step 1 Topic Actions ---
  void toggleTopic(String topic) {
    final lower = topic.toLowerCase();
    if (_selectedTopics.contains(lower)) {
      _selectedTopics.remove(lower);
      // Clean up subtopics if parent unselected
      final allowedSubtopics = getSubtopicsForTopic(lower);
      _selectedEntities.removeWhere((e) => allowedSubtopics.contains(e));
    } else {
      _selectedTopics.add(lower);
      // Auto-suggest first 2 subtopics
      final subtopics = getSubtopicsForTopic(lower);
      if (subtopics.isNotEmpty) {
        _selectedEntities.addAll(subtopics.take(2));
      }
    }
    _sampleBriefing = null; // Invalidate previous sample
    notifyListeners();
  }

  // --- Step 2 Sub-topic Actions ---
  void toggleEntity(String entity) {
    if (_selectedEntities.contains(entity)) {
      _selectedEntities.remove(entity);
    } else {
      _selectedEntities.add(entity);
    }
    _sampleBriefing = null;
    notifyListeners();
  }

  // --- Step 3 Preference Actions ---
  void setDepth(String depth) {
    _selectedDepth = depth;
    _sampleBriefing = null;
    notifyListeners();
  }

  void setTone(String tone) {
    _selectedTone = tone;
    _sampleBriefing = null;
    notifyListeners();
  }

  void setTimeBudget(int minutes) {
    _selectedTimeBudget = minutes;
    notifyListeners();
  }

  // --- Step 4 Sample Briefing Feedback Tuning ---
  void setSampleStoryFeedback(int itemIndex, int feedback) {
    if (_sampleBriefing != null &&
        itemIndex >= 0 &&
        itemIndex < _sampleBriefing!.items.length) {
      final item = _sampleBriefing!.items[itemIndex];
      item.userFeedback = (item.userFeedback == feedback) ? null : feedback;
      notifyListeners();
    }
  }

  /// Synthesizes a live, tailored sample briefing from user's active selections
  void generateSampleBriefing() {
    _isGeneratingBriefing = true;
    notifyListeners();

    final candidateArticles = _generateCandidateArticles();
    final tempProfile = buildDraftProfile();

    _sampleBriefing = _recommendationEngine.generateDailyBriefing(
      candidateArticles: candidateArticles,
      profile: tempProfile,
    );

    _isGeneratingBriefing = false;
    notifyListeners();
  }

  /// Builds a draft UserInterestProfile from the current wizard state
  UserInterestProfile buildDraftProfile({String userId = 'local_user'}) {
    final Map<String, double> topicWeights = {};
    for (final topic in _selectedTopics) {
      topicWeights[topic] = 0.85;
    }

    // Apply feedback from sample briefing if thumbs up/down was given
    if (_sampleBriefing != null) {
      for (final item in _sampleBriefing!.items) {
        final cat = item.article.category.toLowerCase();
        if (item.userFeedback == 1) {
          topicWeights[cat] = (topicWeights[cat] ?? 0.85) + 0.15;
        } else if (item.userFeedback == -1) {
          topicWeights[cat] = ((topicWeights[cat] ?? 0.85) - 0.25).clamp(0.1, 1.0);
        }
      }
    }

    return UserInterestProfile(
      userId: userId,
      topicWeights: topicWeights,
      followedEntities: _selectedEntities.toList(),
      depthPreference: _selectedDepth,
      tonePreference: _selectedTone,
      dailyTimeBudgetMinutes: _selectedTimeBudget,
      updatedAt: DateTime.now(),
    );
  }

  /// Persists the finalized interest profile to local storage
  Future<UserInterestProfile> completeOnboarding({String userId = 'local_user'}) async {
    final profile = buildDraftProfile(userId: userId);
    await _hiveService.saveInterestProfile(profile.toJson());
    return profile;
  }

  // --- Sub-topics Mapping ---
  static const Map<String, List<String>> topicSubtopicsMap = {
    'technology': [
      'Artificial Intelligence',
      'Semiconductor Hardware',
      'Big Tech Antitrust',
      'Cybersecurity & Defense',
      'Quantum Computing',
    ],
    'business': [
      'Macro Policy & Fed',
      'Venture Capital & Startups',
      'Global Supply Chains',
      'Commercial Real Estate',
      'Mergers & Acquisitions',
    ],
    'politics': [
      'Elections 2026',
      'Bipartisan Legislation',
      'Supreme Court Rulings',
      'Defense & Foreign Policy',
      'Trade Sanctions',
    ],
    'climate': [
      'Nuclear & SMRs',
      'Grid Storage & Batteries',
      'Carbon Markets & Capture',
      'Electric Vehicles',
      'Renewable Subsidies',
    ],
    'sports': [
      'Global Football / Soccer',
      'Formula 1 Dynamics',
      'Basketball & NBA',
      'Sports Analytics & Tech',
    ],
    'culture': [
      'Architecture & Urbanism',
      'Cinema & Film Festivals',
      'Literary Fiction & Non-Fiction',
      'Contemporary Art Markets',
    ],
    'health': [
      'Longevity & Bio-tech',
      'Neuroscience Research',
      'Global Public Health',
      'Pharmaceutical Approvals',
    ],
    'local': [
      'Metropolitan Transit & Infra',
      'Regional Housing Zoning',
      'Municipal Bond Finance',
      'Local Economic Hubs',
    ],
  };

  List<String> getSubtopicsForTopic(String topic) {
    return topicSubtopicsMap[topic.toLowerCase()] ?? [];
  }

  List<Article> _generateCandidateArticles() {
    return [
      Article(
        id: 'sample-ai-1',
        title: 'Frontier AI Testing Standards Ratified by Multilateral Council',
        description: 'Bipartisan commission establishes 10^25 FLOP compute reporting mandates with standardized red-teaming benchmarks.',
        content: 'Comprehensive full analysis across independent laboratories.',
        url: 'https://example.com/ai-standards',
        imageUrl: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=800&q=80',
        publishedAt: DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
        sourceName: 'Reuters Tech Bureau',
        sourceUrl: '',
        category: 'technology',
      ),
      Article(
        id: 'sample-biz-1',
        title: 'Central Banks Affirm Data-Dependent Rate Flexibility',
        description: 'Quarterly communiqués highlight persistent core services moderation balancing steady employment figures.',
        content: 'Detailed monetary policy assessment and market expectations.',
        url: 'https://example.com/rates',
        imageUrl: 'https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?auto=format&fit=crop&w=800&q=80',
        publishedAt: DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
        sourceName: 'Financial Times Markets',
        sourceUrl: '',
        category: 'business',
      ),
      Article(
        id: 'sample-climate-1',
        title: 'Next-Generation Small Modular Reactors Secure Fast-Track Licenses',
        description: 'Standardized 300MW nuclear facilities enter commercial site preparation with 18-month regulatory review windows.',
        content: 'Clean baseload power projections and utility procurement plans.',
        url: 'https://example.com/smr',
        imageUrl: 'https://images.unsplash.com/photo-1473341304170-971dccb5ac1e?auto=format&fit=crop&w=800&q=80',
        publishedAt: DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
        sourceName: 'The Wall Street Journal',
        sourceUrl: '',
        category: 'climate',
      ),
      Article(
        id: 'sample-politics-1',
        title: 'Bilateral Critical Mineral Trade Compact Finalized',
        description: 'Key trading partners coordinate tariff exemptions on processed lithium and rare-earth components.',
        content: 'Trade pact terms and diplomatic statements.',
        url: 'https://example.com/trade-compact',
        imageUrl: 'https://images.unsplash.com/photo-1541872703-74c5e44368f9?auto=format&fit=crop&w=800&q=80',
        publishedAt: DateTime.now().subtract(const Duration(hours: 7)).toIso8601String(),
        sourceName: 'Bloomberg Washington',
        sourceUrl: '',
        category: 'politics',
      ),
      Article(
        id: 'sample-health-1',
        title: 'Novel Gene-Editing Therapy Demonstrates Durable Remission in Trials',
        description: 'Clinical Phase 3 results highlight 94% efficacy with targeted delivery vectors.',
        content: 'Medical journal summary and specialist reviews.',
        url: 'https://example.com/gene-therapy',
        imageUrl: 'https://images.unsplash.com/photo-1532938911079-1b06ac7ceec7?auto=format&fit=crop&w=800&q=80',
        publishedAt: DateTime.now().subtract(const Duration(hours: 8)).toIso8601String(),
        sourceName: 'Associated Press Science',
        sourceUrl: '',
        category: 'health',
      ),
    ];
  }
}
