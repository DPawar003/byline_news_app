import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/article.dart';
import '../../core/severity_classifier.dart';
import '../../viewmodels/bookmark_view_model.dart';
import '../../viewmodels/auth_view_model.dart';
import '../../viewmodels/story_threads_view_model.dart';
import '../shared/coverage_spread_widget.dart';
import '../threads/thread_detail_sheet.dart';

class LeadHeroArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;

  const LeadHeroArticleCard({
    super.key,
    required this.article,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bookmarkVM = context.watch<BookmarkViewModel>();
    final authVM = context.watch<AuthViewModel>();
    final threadsVM = context.watch<StoryThreadsViewModel>();
    final isBookmarked = bookmarkVM.isBookmarked(article.id);

    final isHighSeverity = article.severityLevel == SeverityLevel.high;

    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Hero(
                tag: 'article-img-${article.id}',
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    article.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: theme.dividerColor,
                      child: const Center(
                        child: Icon(Icons.newspaper, size: 48),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.85),
                        Colors.black.withOpacity(0.0),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 32, 16, 12),
                  child: Text(
                    article.title,
                    style: theme.textTheme.displayLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 22,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              if (isHighSeverity)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD32F2F),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: const Text(
                      'BREAKING',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.black.withOpacity(0.5),
                  shape: const CircleBorder(),
                  child: IconButton(
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: isBookmarked ? theme.colorScheme.secondary : Colors.white,
                    ),
                    onPressed: () {
                      bookmarkVM.toggleBookmark(article, authVM.user?.uid);
                    },
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (article.threadId != null && article.threadTitle != null) ...[
                  InkWell(
                    onTap: () {
                      final thread = threadsVM.getThreadForArticle(article.threadId);
                      if (thread != null) {
                        ThreadDetailSheet.show(context, thread);
                      }
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF8C00).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: const Color(0xFFFF8C00).withOpacity(0.4),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.linear_scale, size: 14, color: Color(0xFFFF8C00)),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              'Story Thread: ${article.threadTitle}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF8C00),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.chevron_right, size: 14, color: Color(0xFFFF8C00)),
                        ],
                      ),
                    ),
                  ),
                ],
                Text(
                  article.description,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${article.sourceName} • ${article.formattedDate} • ${article.readTimeMinutes} min read',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.secondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (article.coverageSpread != null) ...[
                      const SizedBox(width: 8),
                      CoverageSpreadBadge(
                        coverage: article.coverageSpread!,
                        compact: true,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StandardArticleRow extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;

  const StandardArticleRow({
    super.key,
    required this.article,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bookmarkVM = context.watch<BookmarkViewModel>();
    final authVM = context.watch<AuthViewModel>();
    final isBookmarked = bookmarkVM.isBookmarked(article.id);

    Color indicatorColor;
    switch (article.severityLevel) {
      case SeverityLevel.high:
        indicatorColor = const Color(0xFFD32F2F); // Red
        break;
      case SeverityLevel.medium:
        indicatorColor = const Color(0xFFF57C00); // Amber
        break;
      case SeverityLevel.low:
        indicatorColor = Colors.transparent;
        break;
    }

    return InkWell(
      onTap: onTap,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (indicatorColor != Colors.transparent)
              Container(
                width: 4,
                color: indicatorColor,
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: 'article-img-${article.id}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: SizedBox(
                          width: 72,
                          height: 72,
                          child: Image.network(
                            article.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: theme.dividerColor,
                              child: const Icon(Icons.newspaper, size: 24),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            article.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontSize: 16,
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  article.sourceName,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.secondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Text(' • '),
                              Text(
                                article.formattedDate,
                                style: theme.textTheme.labelSmall,
                              ),
                            ],
                          ),
                          if (article.coverageSpread != null || article.threadId != null) ...[
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                if (article.coverageSpread != null)
                                  CoverageSpreadBadge(
                                    coverage: article.coverageSpread!,
                                    compact: true,
                                  ),
                                if (article.threadId != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF8C00).withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: const Text(
                                      '🧵 Thread',
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFFF8C00),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      icon: AnimatedScale(
                        scale: isBookmarked ? 1.15 : 1.0,
                        duration: const Duration(milliseconds: 150),
                        child: Icon(
                          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                          color: isBookmarked ? theme.colorScheme.secondary : theme.colorScheme.onSurface.withOpacity(0.5),
                          size: 20,
                        ),
                      ),
                      onPressed: () {
                        bookmarkVM.toggleBookmark(article, authVM.user?.uid);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
