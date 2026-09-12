import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodels/feed_view_model.dart';
import '../../viewmodels/theme_view_model.dart';
import '../../viewmodels/reading_budget_view_model.dart';
import '../../viewmodels/recommendation_view_model.dart';
import '../../core/constants.dart';
import '../shared/error_state_widget.dart';
import '../shared/empty_state_widget.dart';
import '../shared/loading_widget.dart';
import 'article_card.dart';
import 'reading_budget_bar.dart';
import 'caught_up_widget.dart';
import 'daily_briefing_card.dart';
import '../threads/story_threads_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: AppConstants.newsCategories.length,
      vsync: this,
    );
    _scrollController = ScrollController()..addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeedViewModel>().fetchHeadlines();
    });
  }

  void _onScroll() {
    final budgetVM = context.read<ReadingBudgetViewModel>();
    // Do not trigger infinite fetch in budget mode
    if (budgetVM.isBudgetModeActive) return;

    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<FeedViewModel>().fetchNextPage();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final feedVM = context.watch<FeedViewModel>();
    final themeVM = context.watch<ThemeViewModel>();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.tune),
          tooltip: 'Personalization Walkthrough',
          onPressed: () => context.push('/onboarding'),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Byline',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: theme.brightness == Brightness.dark ? const Color(0xFFFF8C00) : const Color(0xFFE65100),
                letterSpacing: -0.5,
              ),
            ),
            if (feedVM.isOfflineMode) ...[
              const SizedBox(width: 6),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: theme.colorScheme.secondary),
                    ),
                    child: Text(
                      'OFFLINE QUEUE',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
            tooltip: 'Search',
          ),
          IconButton(
            icon: Icon(
              themeVM.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
            onPressed: () => themeVM.toggleTheme(),
            tooltip: 'Toggle Theme',
          ),
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: theme.brightness == Brightness.dark ? const Color(0xFFFF8C00) : const Color(0xFFE65100),
                ),
                foregroundColor: theme.brightness == Brightness.dark ? const Color(0xFFFF8C00) : const Color(0xFFE65100),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Subscribe', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Column(
            children: [
              const Divider(height: 1),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicatorColor: const Color(0xFFFF8C00),
                labelColor: const Color(0xFFFF8C00),
                unselectedLabelColor: theme.brightness == Brightness.dark ? Colors.white.withOpacity(0.6) : Colors.black.withOpacity(0.6),
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                onTap: (index) {
                  final cat = AppConstants.newsCategories[index];
                  feedVM.selectCategory(cat);
                },
                tabs: AppConstants.newsCategories.map((cat) {
                  return Tab(
                    text: cat[0].toUpperCase() + cat.substring(1),
                  );
                }).toList(),
              ),
              const Divider(height: 1),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Feature 2: Reading Time Budget Bar
          const ReadingBudgetBar(),
          // Feature 1: Story Threads Bar
          const StoryThreadsBar(),
          // Main Editorial Feed
          Expanded(child: _buildBody(context, feedVM)),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, FeedViewModel feedVM) {
    final budgetVM = context.watch<ReadingBudgetViewModel>();

    if (feedVM.isLoading && feedVM.articles.isEmpty) {
      return const EditorialShimmerLoading();
    }

    if (feedVM.failure != null && feedVM.articles.isEmpty) {
      return ErrorStateWidget(
        failure: feedVM.failure,
        onRetry: () => feedVM.fetchHeadlines(refresh: true),
      );
    }

    if (feedVM.articles.isEmpty) {
      return const EmptyStateWidget(
        title: "No Wire Stories",
        message: "No articles available for this category right now.",
        icon: Icons.newspaper_outlined,
      );
    }

    final activeArticles = budgetVM.isBudgetModeActive
        ? budgetVM.curateArticlesForBudget(feedVM.articles)
        : feedVM.articles;

    if (activeArticles.isEmpty) {
      return const EmptyStateWidget(
        title: "No Matching Stories",
        message: "Try adjusting your reading time budget.",
        icon: Icons.hourglass_empty,
      );
    }

    final leadArticle = activeArticles.first;
    final remaining = activeArticles.length > 1 ? activeArticles.sublist(1) : <dynamic>[];

    // Check if feed should show the Defined End ("You're Caught Up" milestone)
    final showCaughtUp = budgetVM.isBudgetModeActive || feedVM.hasReachedMax;

    final recVM = context.watch<RecommendationViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: () => feedVM.fetchHeadlines(refresh: true),
      color: Theme.of(context).colorScheme.secondary,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 32),
        itemCount: 2 + remaining.length + (showCaughtUp ? 1 : (feedVM.isFetchingNextPage ? 1 : 0)),
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              children: [
                if (!recVM.hasCompletedOnboarding)
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFF8C00).withOpacity(0.18),
                          const Color(0xFFFF8C00).withOpacity(0.06),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFF8C00).withOpacity(0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: Color(0xFFFF8C00), size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Personalize Your Briefing',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Run the 4-step walkthrough to calibrate your AI morning dispatch.',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: isDark ? Colors.white70 : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => context.push('/onboarding'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF8C00),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          child: const Text('Start'),
                        ),
                      ],
                    ),
                  ),
                const DailyBriefingCard(),
              ],
            );
          }

          if (index == 1) {
            return LeadHeroArticleCard(
              article: leadArticle,
              onTap: () => context.push('/article/${leadArticle.id}', extra: leadArticle),
            );
          }

          final articleIndex = index - 2;

          if (articleIndex < remaining.length) {
            final article = remaining[articleIndex];
            return StandardArticleRow(
              article: article,
              onTap: () => context.push('/article/${article.id}', extra: article),
            );
          }

          // Feature 5: Defined End to Feed ("You're Caught Up" Screen)
          if (showCaughtUp) {
            return CaughtUpWidget(
              articlesRead: activeArticles.length,
              totalMinutes: budgetVM.isBudgetModeActive ? budgetVM.targetMinutes : 12,
              onBrowseArchives: budgetVM.isBudgetModeActive
                  ? () => budgetVM.toggleBudgetMode(false)
                  : () => feedVM.fetchNextPage(),
            );
          }

          // Bottom loading indicator during pagination
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
      ),
    );
  }
}
