import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:byline/views/search/search_screen.dart';
import 'package:byline/viewmodels/search_view_model.dart';
import 'package:byline/viewmodels/bookmark_view_model.dart';
import 'package:byline/viewmodels/auth_view_model.dart';
import 'package:byline/services/network_service.dart';
import 'package:byline/services/hive_service.dart';
import 'package:byline/services/firestore_service.dart';
import 'package:byline/services/firebase_auth_service.dart';
import 'package:byline/models/app_user.dart';
import 'package:byline/models/article.dart';

class MockSearchNetworkService extends NetworkService {
  final List<Article> mockArticles;

  MockSearchNetworkService({required this.mockArticles});

  @override
  Future<List<Article>> searchArticles({required String query, int page = 1}) async {
    final q = query.toLowerCase();
    return mockArticles.where((a) =>
      a.title.toLowerCase().contains(q) ||
      a.description.toLowerCase().contains(q)
    ).toList();
  }
}

class FakeHiveService extends HiveService {
  @override
  Future<void> init() async {}
  @override
  List<Article> getBookmarks() => [];
  @override
  bool isBookmarked(String id) => false;
}

class FakeFirestoreService implements FirestoreService {
  @override
  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String displayName,
  }) async {}

  @override
  Future<AppUser?> getUserProfile(String uid) async => null;

  @override
  Future<void> syncBookmarkToCloud(String uid, Article article) async {}

  @override
  Future<void> removeBookmarkFromCloud(String uid, String articleId) async {}

  @override
  Future<List<Article>> getCloudBookmarks(String uid) async => [];
}

class FakeFirebaseAuthService extends FirebaseAuthService {
  @override
  Stream<User?> get authStateChanges => Stream.value(null);

  @override
  User? get currentUser => null;
}

void main() {
  final testArticle = Article(
    id: '101',
    title: 'Quantum Computing Breakthrough',
    description: 'Scientists achieve quantum supremacy in new experiment.',
    content: 'Full article text.',
    url: 'https://example.com/quantum',
    imageUrl: 'https://example.com/image.jpg',
    publishedAt: '2026-09-12T10:00:00Z',
    sourceName: 'Science Daily',
    sourceUrl: 'https://example.com',
    category: 'technology',
  );

  Widget buildTestableSearchScreen({SearchViewModel? vm}) {
    final searchVM = vm ?? SearchViewModel(
      networkService: MockSearchNetworkService(mockArticles: [testArticle]),
    );
    final bookmarkVM = BookmarkViewModel(
      hiveService: FakeHiveService(),
      firestoreService: FakeFirestoreService(),
    );
    final authVM = AuthViewModel(
      authService: FakeFirebaseAuthService(),
      firestoreService: FakeFirestoreService(),
    );

    return MaterialApp(
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<SearchViewModel>.value(value: searchVM),
          ChangeNotifierProvider<BookmarkViewModel>.value(value: bookmarkVM),
          ChangeNotifierProvider<AuthViewModel>.value(value: authVM),
        ],
        child: const SearchScreen(),
      ),
    );
  }

  group('SearchScreen Widget Tests', () {
    testWidgets('Renders search field, filter chips, and recent searches when query is empty', (tester) async {
      await tester.pumpWidget(buildTestableSearchScreen());

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Filter By: '), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Title Only'), findsOneWidget);
      expect(find.text('Keywords Only'), findsOneWidget);
      expect(find.text('Recent & Popular Searches'), findsOneWidget);
    });

    testWidgets('Types query, searches dynamically, and updates results', (tester) async {
      await tester.pumpWidget(buildTestableSearchScreen());

      // Enter search term 'Quantum'
      await tester.enterText(find.byType(TextField), 'Quantum');
      await tester.pump(const Duration(milliseconds: 500)); // debounce
      await tester.pumpAndSettle();

      expect(find.text('Quantum Computing Breakthrough'), findsOneWidget);
      expect(find.textContaining('1 article found for "Quantum"'), findsOneWidget);
    });

    testWidgets('Clears search via clear button icon and returns to empty state', (tester) async {
      await tester.pumpWidget(buildTestableSearchScreen());

      await tester.enterText(find.byType(TextField), 'Quantum');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.text('Quantum Computing Breakthrough'), findsOneWidget);

      // Tap clear icon (X)
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      expect(find.text('Quantum Computing Breakthrough'), findsNothing);
      expect(find.text('Recent & Popular Searches'), findsOneWidget);
    });

    testWidgets('Toggles search filter mode chips (Title Only vs Keywords Only)', (tester) async {
      await tester.pumpWidget(buildTestableSearchScreen());

      await tester.enterText(find.byType(TextField), 'Quantum');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Tap Title Only choice chip
      await tester.tap(find.text('Title Only'));
      await tester.pumpAndSettle();

      expect(find.text('Quantum Computing Breakthrough'), findsOneWidget);
    });
  });
}
