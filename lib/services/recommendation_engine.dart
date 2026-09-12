import 'dart:math' as math;
import '../models/article.dart';
import '../models/user_interest_profile.dart';
import '../models/daily_briefing.dart';

class ScoredArticle {
  final Article article;
  final double finalScore;
  final String attributionTag; // "Why you're seeing this"
  final Map<String, double> scoreComponents;

  const ScoredArticle({
    required this.article,
    required this.finalScore,
    required this.attributionTag,
    required this.scoreComponents,
  });
}

class RecommendationEngine {
  /// Scores a single article against the user interest profile.
  ScoredArticle scoreArticle({
    required Article article,
    required UserInterestProfile profile,
  }) {
    // 1. Topic Affinity (Blended 60/40 explicit + implicit)
    final topicWeight = profile.getBlendedWeight(article.category);

    // 2. Granular Entity & Keyword Matching
    final matchedEntities = <String>[];
    final textToScan = '${article.title} ${article.description} ${article.content}'.toLowerCase();

    for (final entity in profile.followedEntities) {
      if (textToScan.contains(entity.toLowerCase())) {
        matchedEntities.add(entity);
      }
    }
    // Up to 0.5 bonus for matching multiple followed entities
    final entityScore = math.min(matchedEntities.length * 0.25, 0.50);

    // 3. Coverage Breadth (More outlets = higher consensus bonus)
    final outletCount = article.coverageSpread?.outletCount ?? 5;
    final breadthScore = (outletCount >= 12)
        ? 0.20
        : (outletCount >= 6 ? 0.10 : 0.0);

    // 4. Depth Match
    double depthScore = 0.05;
    if (profile.depthPreference == 'brief' && article.readTimeMinutes <= 2) {
      depthScore = 0.15;
    } else if (profile.depthPreference == 'deepDive' && article.readTimeMinutes >= 4) {
      depthScore = 0.15;
    } else if (profile.depthPreference == 'standard') {
      depthScore = 0.10;
    }

    // 5. Recency Exponential Decay (24-hour half-life)
    double recencyMultiplier = 1.0;
    try {
      final pubDate = DateTime.parse(article.publishedAt);
      final hoursOld = DateTime.now().difference(pubDate).inHours.clamp(0, 168);
      // Half life = 24 hours: decay = 0.5^(hours / 24)
      recencyMultiplier = math.pow(0.5, hoursOld / 24.0).toDouble();
    } catch (_) {
      recencyMultiplier = 0.8;
    }

    // 6. Fatigue Attenuation
    final fatigueFactor = profile.getFatigueAttenuation(article.category);

    // Composite Base Score
    final baseScore = (topicWeight * 0.40) +
        (entityScore * 0.30) +
        (breadthScore * 0.15) +
        (depthScore * 0.15);

    final finalScore = baseScore * recencyMultiplier * fatigueFactor;

    // 7. Generate Attribution Tag ("Why you're seeing this")
    final attributionTag = _generateAttributionTag(
      article: article,
      matchedEntities: matchedEntities,
      outletCount: outletCount,
      topicWeight: topicWeight,
      fatigueFactor: fatigueFactor,
    );

    return ScoredArticle(
      article: article,
      finalScore: finalScore,
      attributionTag: attributionTag,
      scoreComponents: {
        'topic': topicWeight,
        'entity': entityScore,
        'breadth': breadthScore,
        'depth': depthScore,
        'recency': recencyMultiplier,
        'fatigue': fatigueFactor,
      },
    );
  }

  /// Ranks an entire catalogue of articles and returns them sorted by recommendation score.
  List<ScoredArticle> rankArticles({
    required List<Article> articles,
    required UserInterestProfile profile,
  }) {
    final scored = articles
        .map((a) => scoreArticle(article: a, profile: profile))
        .toList();

    scored.sort((a, b) => b.finalScore.compareTo(a.finalScore));
    return scored;
  }

  /// Generates a synthesized Daily AI Briefing from the top ranked articles.
  DailyBriefing generateDailyBriefing({
    required List<Article> candidateArticles,
    required UserInterestProfile profile,
  }) {
    final ranked = rankArticles(articles: candidateArticles, profile: profile);
    final topItems = ranked.take(4).map((sa) {
      return BriefingItem(
        article: sa.article,
        attributionTag: sa.attributionTag,
        matchScore: sa.finalScore,
      );
    }).toList();

    // Synthesize cohesive narrative
    final narrative = _synthesizeNarrative(
      topItems: topItems,
      tone: profile.tonePreference,
      followedEntities: profile.followedEntities,
    );

    return DailyBriefing(
      id: 'briefing-${DateTime.now().toIso8601String().substring(0, 10)}',
      date: DateTime.now(),
      title: 'Your ${DateTime.now().hour < 12 ? "Morning" : "Evening"} Briefing',
      executiveNarrative: narrative,
      audioDurationSeconds: 150 + (topItems.length * 20),
      items: topItems,
    );
  }

  String _generateAttributionTag({
    required Article article,
    required List<String> matchedEntities,
    required int outletCount,
    required double topicWeight,
    required double fatigueFactor,
  }) {
    if (matchedEntities.isNotEmpty) {
      return "Matches your '${matchedEntities.first}' follow";
    }
    if (outletCount >= 14) {
      return "High consensus across $outletCount wire bureaus";
    }
    if (fatigueFactor < 0.8) {
      return "Paced story in ${article.category.toUpperCase()} (fatigue protected)";
    }
    if (topicWeight >= 0.8) {
      return "Top priority for your ${article.category} focus";
    }
    return "Trending in Byline today";
  }

  String _synthesizeNarrative({
    required List<BriefingItem> topItems,
    required String tone,
    required List<String> followedEntities,
  }) {
    if (topItems.isEmpty) {
      return "Your personalized dispatch is standing by as wire reports develop.";
    }

    final lead = topItems.first.article;
    final secondary = topItems.length > 1 ? topItems[1].article : null;

    if (tone == 'conversational') {
      return "Good morning. To start your day, ${lead.title} is leading coverage across major bureaus today. Meanwhile, in ${secondary?.category ?? 'global news'}, ${secondary?.title ?? 'new developments are emerging'}. Here is your tailored snapshot before you dive in.";
    } else if (tone == 'neutral') {
      return "Morning Wire Dispatch: Key reports focus on ${lead.title}, corroborated by primary newsrooms. Secondary developments in ${secondary?.category ?? 'markets'} center on ${secondary?.title ?? 'ongoing policy discussions'}. Full reporting summarized below.";
    } else {
      // Default: analytical (Economist/Byline style)
      return "Strategic Overview: Converging dynamics across ${lead.category} dominate today's briefing, marked by ${lead.title}. Intersecting with your focus areas${followedEntities.isNotEmpty ? ' (${followedEntities.take(2).join(', ')})' : ''}, institutional participants are balancing regulatory and macro variables in ${secondary?.category ?? 'near-term frameworks'}.";
    }
  }
}
