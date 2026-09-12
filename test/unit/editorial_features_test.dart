import 'package:flutter_test/flutter_test.dart';
import 'package:byline/models/article.dart';
import 'package:byline/viewmodels/story_threads_view_model.dart';
import 'package:byline/viewmodels/reading_budget_view_model.dart';
import 'package:byline/core/severity_classifier.dart';

void main() {
  group('Feature 1: Story Threads tests', () {
    test('StoryThreadsViewModel loads default evolving threads with events', () {
      final vm = StoryThreadsViewModel();
      expect(vm.threads.isNotEmpty, isTrue);

      final aiThread = vm.threads.firstWhere((t) => t.id == 'thread-ai-regulation');
      expect(aiThread.events.length, greaterThanOrEqualTo(4));
      expect(aiThread.unreadCount, equals(2));
    });

    test('Follow toggle and checkpoint update work correctly', () {
      final vm = StoryThreadsViewModel();
      final threadId = 'thread-clean-energy';

      final initialFollow = vm.threads.firstWhere((t) => t.id == threadId).isFollowing;
      vm.toggleFollow(threadId);
      expect(vm.threads.firstWhere((t) => t.id == threadId).isFollowing, !initialFollow);

      // Update checkpoint to mark milestones read
      vm.updateCheckpoint(threadId, 2);
      final updated = vm.threads.firstWhere((t) => t.id == threadId);
      expect(updated.checkpointIndex, equals(2));
      expect(updated.unreadCount, equals(0));
    });
  });

  group('Article.cleanArticleText tests', () {
    test('Strips character counters like [+1420 chars] from article text', () {
      const rawText = 'San Francisco (AP) -- The Senate today passed a landmark bill... [+1420 chars]';
      final cleaned = Article.cleanArticleText(rawText);
      expect(cleaned, equals('San Francisco (AP) -- The Senate today passed a landmark bill...'));
    });

    test('Strips variations like [250 chars] and [+100 characters]', () {
      expect(Article.cleanArticleText('Headline news... [250 chars]'), equals('Headline news...'));
      expect(Article.cleanArticleText('Breaking story... [+100 characters]'), equals('Breaking story...'));
    });
  });

  group('Feature 2: Reading Time Budget tests', () {
    final sampleArticles = [
      Article(
        id: '1',
        title: 'Article 1',
        description: 'Short desc',
        content: List.generate(200, (i) => 'word').join(' '), // ~2 min
        url: 'http://example.com/1',
        imageUrl: 'http://example.com/1.jpg',
        publishedAt: DateTime.now().toIso8601String(),
        sourceName: 'Byline',
        sourceUrl: '',
      ),
      Article(
        id: '2',
        title: 'Article 2',
        description: 'Medium desc',
        content: List.generate(400, (i) => 'word').join(' '), // ~3 min
        url: 'http://example.com/2',
        imageUrl: 'http://example.com/2.jpg',
        publishedAt: DateTime.now().toIso8601String(),
        sourceName: 'Byline',
        sourceUrl: '',
      ),
      Article(
        id: '3',
        title: 'Article 3',
        description: 'Long desc',
        content: List.generate(800, (i) => 'word').join(' '), // ~5 min
        url: 'http://example.com/3',
        imageUrl: 'http://example.com/3.jpg',
        publishedAt: DateTime.now().toIso8601String(),
        sourceName: 'Byline',
        sourceUrl: '',
      ),
      Article(
        id: '4',
        title: 'Article 4',
        description: 'Extra desc',
        content: List.generate(1000, (i) => 'word').join(' '), // ~6 min
        url: 'http://example.com/4',
        imageUrl: 'http://example.com/4.jpg',
        publishedAt: DateTime.now().toIso8601String(),
        sourceName: 'Byline',
        sourceUrl: '',
      ),
    ];

    test('Curates articles within 5 min budget without overflow', () {
      final vm = ReadingBudgetViewModel();
      vm.setTargetMinutes(5);

      final curated = vm.curateArticlesForBudget(sampleArticles);
      int totalMinutes = 0;
      for (final a in curated) {
        totalMinutes += a.readTimeMinutes;
      }

      expect(curated.length, greaterThanOrEqualTo(1));
      expect(totalMinutes, lessThanOrEqualTo(6));
    });

    test('Tracks read articles and completion state', () {
      final vm = ReadingBudgetViewModel();
      vm.setTargetMinutes(10);
      final curated = vm.curateArticlesForBudget(sampleArticles);

      expect(vm.isBudgetCompleted(curated), isFalse);

      for (final a in curated) {
        vm.markArticleRead(a.id);
      }

      expect(vm.isBudgetCompleted(curated), isTrue);
      expect(vm.calculateMinutesRead(curated), greaterThan(0));
    });
  });

  group('Feature 3: Coverage Spread tests', () {
    test('Computes multi-perspective breakdown and consensus level', () {
      final spread = CoverageSpread.computeFor(
        title: 'Global Tech Regulatory Accord Finalized',
        category: 'technology',
        sourceName: 'Reuters',
        severity: SeverityLevel.high,
      );

      expect(spread.outletCount, greaterThanOrEqualTo(14));
      expect(spread.notableOutlets.contains('Reuters'), isTrue);
      expect(spread.perspectives.containsKey('Product & Innovation'), isTrue);
      expect(spread.consensusLabel.isNotEmpty, isTrue);
    });

    test('Single source indicator for low-severity niche reporting', () {
      final spread = CoverageSpread.computeFor(
        title: 'Boutique Coffee Roaster Experiments with Solar Roasting',
        category: 'general',
        sourceName: 'Local Herald',
        severity: SeverityLevel.low,
      );

      expect(spread.outletCount, lessThanOrEqualTo(7));
    });
  });

  group('Feature 4: Depth Toggle Per Story tests', () {
    test('Article contains 3-part brief takeaways and deep-dive analysis', () {
      final article = Article.fromJson({
        'id': 'test-1',
        'title': 'Frontier AI Testing Accord Signed Across 14 Nations',
        'description': 'Governments coordinate standard benchmarks for safety evaluations.',
        'content': 'Comprehensive full text...',
        'category': 'technology',
      });

      expect(article.briefTakeaways?.length, equals(3));
      expect(article.briefTakeaways?[2].contains('Why It Matters'), isTrue);
      expect(article.deepDiveAnalysis?.contains('Historical & Strategic Context'), isTrue);
      expect(article.threadId, equals('thread-ai-regulation'));
    });
  });
}
