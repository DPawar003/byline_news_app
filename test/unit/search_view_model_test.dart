import 'package:flutter_test/flutter_test.dart';
import 'package:byline/viewmodels/search_view_model.dart';
import 'package:byline/services/network_service.dart';
import 'package:byline/models/article.dart';

class FakeNetworkService extends NetworkService {
  final List<Article> mockArticles;
  bool shouldThrow;

  FakeNetworkService({required this.mockArticles, this.shouldThrow = false});

  @override
  Future<List<Article>> searchArticles({required String query, int page = 1}) async {
    if (shouldThrow) throw Exception('Search failed');
    final q = query.toLowerCase();
    return mockArticles.where((a) =>
      a.title.toLowerCase().contains(q) ||
      a.description.toLowerCase().contains(q) ||
      a.category.toLowerCase().contains(q)
    ).toList();
  }
}

void main() {
  final sampleArticle1 = Article(
    id: '1',
    title: 'Global Semiconductor Market Outlook',
    description: 'A deep dive into chip manufacturing and tech supply chains.',
    content: 'Full content about semiconductors.',
    url: 'https://example.com/1',
    imageUrl: 'https://example.com/1.jpg',
    publishedAt: '2026-09-12T10:00:00Z',
    sourceName: 'Tech Dispatch',
    sourceUrl: 'https://example.com',
    category: 'technology',
  );

  final sampleArticle2 = Article(
    id: '2',
    title: 'Climate Summit Reach Agreement',
    description: 'World leaders sign landmark environmental treaty.',
    content: 'Full content about climate policy.',
    url: 'https://example.com/2',
    imageUrl: 'https://example.com/2.jpg',
    publishedAt: '2026-09-12T11:00:00Z',
    sourceName: 'Global News',
    sourceUrl: 'https://example.com',
    category: 'environment',
  );

  group('SearchViewModel unit tests', () {
    test('executeSearch populates raw search results and filters dynamically', () async {
      final fakeNetwork = FakeNetworkService(mockArticles: [sampleArticle1, sampleArticle2]);
      final vm = SearchViewModel(networkService: fakeNetwork);

      await vm.executeSearch('Semiconductor');
      expect(vm.searchResults.length, equals(1));
      expect(vm.searchResults.first.title, contains('Semiconductor'));
    });

    test('Filter mode titleOnly filters by title only', () async {
      final fakeNetwork = FakeNetworkService(mockArticles: [sampleArticle1, sampleArticle2]);
      final vm = SearchViewModel(networkService: fakeNetwork);

      await vm.executeSearch('Climate');
      expect(vm.searchResults.length, equals(1));

      vm.setFilterMode(SearchFilterMode.titleOnly);
      expect(vm.searchResults.length, equals(1));

      // Search for keyword in description 'environmental'
      await vm.executeSearch('environmental');
      expect(vm.searchResults.length, equals(0)); // Description has it, but filterMode is titleOnly

      vm.setFilterMode(SearchFilterMode.keywordsOnly);
      expect(vm.searchResults.length, equals(1)); // Found in description under keywordsOnly
    });

    test('clearQuery resets query and results dynamically', () async {
      final fakeNetwork = FakeNetworkService(mockArticles: [sampleArticle1]);
      final vm = SearchViewModel(networkService: fakeNetwork);

      await vm.executeSearch('Semiconductor');
      expect(vm.searchResults.length, equals(1));
      expect(vm.query, equals('Semiconductor'));

      vm.clearQuery();
      expect(vm.query, isEmpty);
      expect(vm.searchResults, isEmpty);
      expect(vm.isLoading, isFalse);
    });

    test('Recent searches history updates dynamically', () {
      final fakeNetwork = FakeNetworkService(mockArticles: []);
      final vm = SearchViewModel(networkService: fakeNetwork);

      vm.executeSearch('Artificial Intelligence');
      expect(vm.recentSearches.first, equals('Artificial Intelligence'));

      vm.removeRecentSearch('Artificial Intelligence');
      expect(vm.recentSearches.contains('Artificial Intelligence'), isFalse);

      vm.clearRecentSearches();
      expect(vm.recentSearches, isEmpty);
    });
  });
}
