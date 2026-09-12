import 'package:flutter_test/flutter_test.dart';
import 'package:byline/models/article.dart';
import 'package:byline/models/user_interest_profile.dart';
import 'package:byline/services/recommendation_engine.dart';

void main() {
  group('UserInterestProfile tests', () {
    test('Calculates 60/40 blended weight initially and shifts as reads accumulate', () {
      final initialProfile = UserInterestProfile(
        userId: 'u1',
        topicWeights: {'technology': 1.0, 'business': 0.5},
        followedEntities: ['Artificial Intelligence'],
        implicitWeights: {'technology': 0.5}, // Disagreeing implicit
        totalArticlesRead: 0,
        updatedAt: DateTime.now(),
      );

      // With 0 reads: explicit weight is 0.60, implicit is 0.40
      // 1.0 * 0.60 + 0.5 * 0.40 = 0.80
      expect(initialProfile.getBlendedWeight('technology'), closeTo(0.80, 0.01));

      // After 30 reads: explicit weight is 0.30, implicit is 0.70
      // 1.0 * 0.30 + 0.5 * 0.70 = 0.65
      final matureProfile = initialProfile.copyWith(totalArticlesRead: 30);
      expect(matureProfile.getBlendedWeight('technology'), closeTo(0.65, 0.01));
    });

    test('Applies fatigue attenuation after 3 reads and honors exemption toggle', () {
      final profile = UserInterestProfile(
        userId: 'u1',
        topicWeights: {'technology': 1.0},
        followedEntities: [],
        recentTopicReads: {'technology': 2}, // Under 3 reads: no penalty
        updatedAt: DateTime.now(),
      );

      expect(profile.getFatigueAttenuation('technology'), equals(1.0));

      // After 5 reads: penalty should be applied
      final fatiguedProfile = profile.copyWith(
        recentTopicReads: {'technology': 5},
      );
      expect(fatiguedProfile.getFatigueAttenuation('technology'), lessThan(1.0));

      // Toggle exemption ("keep showing me this")
      final exemptProfile = fatiguedProfile.toggleFatigueExemption('technology');
      expect(exemptProfile.getFatigueAttenuation('technology'), equals(1.0));
    });

    test('Serialization and Deserialization round-trip', () {
      final original = UserInterestProfile(
        userId: 'u123',
        topicWeights: {'technology': 0.9, 'climate': 0.8},
        followedEntities: ['AI', 'Nuclear & SMRs'],
        depthPreference: 'brief',
        tonePreference: 'analytical',
        dailyTimeBudgetMinutes: 20,
        implicitWeights: {'technology': 0.95},
        totalArticlesRead: 12,
        recentTopicReads: {'technology': 3},
        fatigueExemptTopics: ['technology'],
        updatedAt: DateTime.now(),
      );

      final json = original.toJson();
      final reconstructed = UserInterestProfile.fromJson(json);

      expect(reconstructed.userId, equals(original.userId));
      expect(reconstructed.topicWeights['technology'], equals(0.9));
      expect(reconstructed.followedEntities, contains('AI'));
      expect(reconstructed.depthPreference, equals('brief'));
      expect(reconstructed.fatigueExemptTopics, contains('technology'));
    });

    test('Deserializes dynamic nested maps without TypeError (Hive storage format)', () {
      final hiveData = <dynamic, dynamic>{
        'userId': 'u123',
        'topicWeights': <dynamic, dynamic>{
          'technology': 0.85,
          'business': 0.6,
        },
        'followedEntities': <dynamic>['Artificial Intelligence'],
        'depthPreference': 'brief',
        'tonePreference': 'analytical',
        'dailyTimeBudgetMinutes': 15,
        'implicitWeights': <dynamic, dynamic>{
          'technology': 0.75,
        },
        'totalArticlesRead': 5,
        'recentTopicReads': <dynamic, dynamic>{
          'technology': 2,
        },
        'fatigueExemptTopics': <dynamic>['technology'],
        'updatedAt': DateTime.now().toIso8601String(),
      };

      final profile = UserInterestProfile.fromJson(hiveData);
      expect(profile.userId, equals('u123'));
      expect(profile.topicWeights['technology'], equals(0.85));
      expect(profile.implicitWeights['technology'], equals(0.75));
      expect(profile.recentTopicReads['technology'], equals(2));
    });
  });

  group('RecommendationEngine scoring tests', () {
    final engine = RecommendationEngine();

    final profile = UserInterestProfile(
      userId: 'u1',
      topicWeights: {'technology': 1.0, 'business': 0.4},
      followedEntities: ['Artificial Intelligence', 'Semiconductors'],
      depthPreference: 'standard',
      tonePreference: 'analytical',
      dailyTimeBudgetMinutes: 10,
      updatedAt: DateTime.now(),
    );

    final techArticle = Article(
      id: 'a1',
      title: 'Artificial Intelligence Breakthrough in Semiconductors',
      description: 'Major development in compute architectures.',
      content: 'Detailed text',
      url: 'http://example.com/ai',
      imageUrl: 'http://example.com/ai.jpg',
      publishedAt: DateTime.now().toIso8601String(),
      sourceName: 'Reuters',
      sourceUrl: '',
      category: 'technology',
      coverageSpread: const CoverageSpread(
        outletCount: 16,
        consensusLevel: ConsensusLevel.highConsensus,
        perspectives: {'Tech': 0.6, 'Market': 0.4},
        notableOutlets: ['Reuters', 'Bloomberg'],
      ),
    );

    final sportsArticle = Article(
      id: 'a2',
      title: 'Local Team Wins Championship Game',
      description: 'Exciting final round.',
      content: 'Detailed sports story.',
      url: 'http://example.com/sports',
      imageUrl: 'http://example.com/sports.jpg',
      publishedAt: DateTime.now().toIso8601String(),
      sourceName: 'Daily Sport',
      sourceUrl: '',
      category: 'sports',
    );

    test('Scores matched topic and entity significantly higher than unmatched', () {
      final scoredTech = engine.scoreArticle(article: techArticle, profile: profile);
      final scoredSports = engine.scoreArticle(article: sportsArticle, profile: profile);

      expect(scoredTech.finalScore, greaterThan(scoredSports.finalScore));
      expect(scoredTech.attributionTag, contains('Artificial Intelligence'));
    });

    test('Ranks articles and synthesizes DailyBriefing', () {
      final briefing = engine.generateDailyBriefing(
        candidateArticles: [sportsArticle, techArticle],
        profile: profile,
      );

      expect(briefing.items.isNotEmpty, isTrue);
      expect(briefing.items.first.article.id, equals(techArticle.id));
      expect(briefing.executiveNarrative.isNotEmpty, isTrue);
      expect(briefing.audioDurationSeconds, greaterThan(0));
    });
  });
}
