import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodels/search_view_model.dart';
import '../../core/widgets/widgets.dart';
import '../shared/error_state_widget.dart';
import '../shared/empty_state_widget.dart';
import '../shared/loading_widget.dart';
import '../home/article_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final searchVM = context.read<SearchViewModel>();
      if (searchVM.query.isNotEmpty) {
        _searchController.text = searchVM.query;
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<SearchViewModel>().fetchNextPage();
    }
  }

  void _triggerSearch(String term) {
    _searchController.text = term;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: term.length),
    );
    final searchVM = context.read<SearchViewModel>();
    searchVM.onQueryChanged(term);
    setState(() {});
  }

  void _clearSearch() {
    _searchController.clear();
    final searchVM = context.read<SearchViewModel>();
    searchVM.clearQuery();
    setState(() {});
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final searchVM = context.watch<SearchViewModel>();
    final results = searchVM.searchResults;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: AppTypography.bodyLarge.copyWith(color: theme.colorScheme.onSurface),
          textInputAction: TextInputAction.search,
          onSubmitted: (term) => searchVM.executeSearch(term, refresh: true),
          decoration: InputDecoration(
            hintText: 'Search by title or keywords...',
            hintStyle: AppTypography.bodyMedium.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            fillColor: Colors.transparent,
            prefixIcon: const Icon(Icons.search, size: 22),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: _clearSearch,
                    tooltip: 'Clear search',
                  )
                : null,
          ),
          onChanged: (val) {
            searchVM.onQueryChanged(val);
            setState(() {});
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: theme.dividerColor, width: 0.5),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text(
                    'Filter By: ',
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  AppSpacing.hXs,
                  ChoiceChip(
                    label: const Text('All'),
                    selected: searchVM.filterMode == SearchFilterMode.all,
                    onSelected: (selected) {
                      if (selected) searchVM.setFilterMode(SearchFilterMode.all);
                    },
                  ),
                  AppSpacing.hXs,
                  ChoiceChip(
                    label: const Text('Title Only'),
                    selected: searchVM.filterMode == SearchFilterMode.titleOnly,
                    onSelected: (selected) {
                      if (selected) searchVM.setFilterMode(SearchFilterMode.titleOnly);
                    },
                  ),
                  AppSpacing.hXs,
                  ChoiceChip(
                    label: const Text('Keywords Only'),
                    selected: searchVM.filterMode == SearchFilterMode.keywordsOnly,
                    onSelected: (selected) {
                      if (selected) searchVM.setFilterMode(SearchFilterMode.keywordsOnly);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _buildBody(context, searchVM, results),
    );
  }

  Widget _buildBody(BuildContext context, SearchViewModel searchVM, List dynamicResults) {
    final theme = Theme.of(context);

    // Initial state when no search query has been typed
    if (searchVM.query.isEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (searchVM.recentSearches.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Recent & Popular Searches',
                      style: AppTypography.titleMedium.copyWith(fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: () => searchVM.clearRecentSearches(),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: Text(
                      'Clear Recent',
                      style: AppTypography.caption.copyWith(color: theme.colorScheme.secondary),
                    ),
                  ),
                ],
              ),
              AppSpacing.vXs,
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: searchVM.recentSearches.map((term) {
                  return InputChip(
                    label: Text(term, style: AppTypography.caption),
                    avatar: const Icon(Icons.history, size: 16),
                    onPressed: () => _triggerSearch(term),
                    onDeleted: () => searchVM.removeRecentSearch(term),
                    deleteIcon: const Icon(Icons.close, size: 14),
                  );
                }).toList(),
              ),
              AppSpacing.vXl,
            ],
            const EmptyStateWidget(
              title: "Search Byline",
              message: "Search by article title or global keywords dynamically across thousands of editorial reports.",
              icon: Icons.search_rounded,
            ),
          ],
        ),
      );
    }

    // Loading state while searching
    if (searchVM.isLoading && dynamicResults.isEmpty) {
      return const EditorialShimmerLoading();
    }

    // Error state
    if (searchVM.failure != null && dynamicResults.isEmpty) {
      return ErrorStateWidget(
        failure: searchVM.failure,
        onRetry: () => searchVM.executeSearch(searchVM.query, refresh: true),
      );
    }

    // No matches found state
    if (dynamicResults.isEmpty) {
      final scopeLabel = searchVM.filterMode == SearchFilterMode.titleOnly
          ? 'title'
          : searchVM.filterMode == SearchFilterMode.keywordsOnly
              ? 'keywords'
              : 'title or keywords';

      return EmptyStateWidget(
        title: "No Matches Found",
        message: "No articles matching '$scopeLabel' found for '${searchVM.query}'. Try searching other terms or switching filter scope.",
        icon: Icons.manage_search_rounded,
      );
    }

    // Results List
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: theme.colorScheme.onSurface.withOpacity(0.04),
          child: Text(
            '${dynamicResults.length} ${dynamicResults.length == 1 ? "article" : "articles"} found for "${searchVM.query}"',
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: dynamicResults.length + (searchVM.isFetchingNextPage ? 1 : 0),
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              if (index < dynamicResults.length) {
                final article = dynamicResults[index];
                return StandardArticleRow(
                  article: article,
                  onTap: () => context.push('/article/${article.id}', extra: article),
                );
              }

              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
