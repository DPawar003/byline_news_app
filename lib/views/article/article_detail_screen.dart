import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/article.dart';
import '../../viewmodels/bookmark_view_model.dart';
import '../../viewmodels/auth_view_model.dart';
import '../../viewmodels/reading_budget_view_model.dart';
import '../../viewmodels/story_threads_view_model.dart';
import '../shared/coverage_spread_widget.dart';
import '../threads/thread_detail_sheet.dart';

enum ReadingDepth {
  brief,
  standard,
  deepDive,
}

class ArticleDetailScreen extends StatefulWidget {
  final Article article;

  const ArticleDetailScreen({
    super.key,
    required this.article,
  });

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  ReadingDepth _selectedDepth = ReadingDepth.standard;

  Future<void> _launchArticleUrl([String? urlOverride]) async {
    final target = (urlOverride != null && urlOverride.isNotEmpty)
        ? urlOverride
        : (widget.article.url.isNotEmpty ? widget.article.url : widget.article.sourceUrl);
    if (target.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No article web URL available.')),
        );
      }
      return;
    }
    final uri = Uri.tryParse(target);
    if (uri != null) {
      try {
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!launched) {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opening article at $target')),
          );
        }
      }
    }
  }

  Widget _buildInteractiveArticleText(BuildContext context, String rawText) {
    final theme = Theme.of(context);
    final text = rawText.trim();
    if (text.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText.rich(
          TextSpan(
            children: [
              TextSpan(
                text: text.endsWith('.') ? '$text ' : '$text... ',
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.7,
                  fontSize: 15,
                ),
              ),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: InkWell(
                  onTap: () => _launchArticleUrl(),
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    margin: const EdgeInsets.only(left: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: theme.colorScheme.secondary.withOpacity(0.3),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '... Read full article',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.open_in_new,
                          size: 13,
                          color: theme.colorScheme.secondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReadingBudgetViewModel>().markArticleRead(widget.article.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bookmarkVM = context.watch<BookmarkViewModel>();
    final authVM = context.watch<AuthViewModel>();
    final threadsVM = context.watch<StoryThreadsViewModel>();
    final isBookmarked = bookmarkVM.isBookmarked(widget.article.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.article.sourceName),
        actions: [
          IconButton(
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: isBookmarked ? theme.colorScheme.secondary : null,
            ),
            onPressed: () {
              bookmarkVM.toggleBookmark(widget.article, authVM.user?.uid);
            },
            tooltip: 'Bookmark Article',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'article-img-${widget.article.id}',
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  widget.article.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: theme.dividerColor,
                    child: const Center(
                      child: Icon(Icons.newspaper, size: 64),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Story Thread Header link if available
                  if (widget.article.threadId != null && widget.article.threadTitle != null) ...[
                    InkWell(
                      onTap: () {
                        final thread = threadsVM.getThreadForArticle(widget.article.threadId);
                        if (thread != null) {
                          ThreadDetailSheet.show(context, thread);
                        }
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF8C00).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFFFF8C00).withOpacity(0.4),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.linear_scale, size: 16, color: Color(0xFFFF8C00)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'PART OF EVOLVING STORY THREAD',
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                      color: Color(0xFFFF8C00),
                                    ),
                                  ),
                                  Text(
                                    widget.article.threadTitle!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFFFF8C00)),
                          ],
                        ),
                      ),
                    ),
                  ],

                  Text(
                    widget.article.title,
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontSize: 26,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.article.category.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.article.formattedDate,
                        style: theme.textTheme.labelSmall,
                      ),
                      const Text(' • '),
                      Text(
                        _getReadingTimeForDepth(),
                        style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Feature 4: Depth Toggle Per Story (Brief, Standard, Deep-Dive)
                  _buildDepthSelector(context),

                  const SizedBox(height: 18),
                  const Divider(),
                  const SizedBox(height: 18),

                  // Content view based on chosen Depth
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _buildDepthContent(context),
                  ),

                  const SizedBox(height: 28),

                  // Feature 3: Coverage Spread & Perspectives Indicator (Expanded)
                  if (widget.article.coverageSpread != null) ...[
                    CoverageSpreadBadge(
                      coverage: widget.article.coverageSpread!,
                      compact: false,
                    ),
                    const SizedBox(height: 28),
                  ],

                  const Divider(),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _launchArticleUrl(),
                          icon: const Icon(Icons.open_in_browser, size: 18),
                          label: const Text('Read Full Original Wire'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: theme.dividerColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getReadingTimeForDepth() {
    switch (_selectedDepth) {
      case ReadingDepth.brief:
        return '30s brief';
      case ReadingDepth.standard:
        return '${widget.article.readTimeMinutes} min read';
      case ReadingDepth.deepDive:
        return '${widget.article.readTimeMinutes + 4} min deep-dive';
    }
  }

  Widget _buildDepthSelector(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2024) : const Color(0xFFEEECE7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _buildDepthOption(
            title: '⚡ Brief',
            subtitle: '30s take',
            depth: ReadingDepth.brief,
            isDark: isDark,
          ),
          _buildDepthOption(
            title: '📖 Standard',
            subtitle: 'Core story',
            depth: ReadingDepth.standard,
            isDark: isDark,
          ),
          _buildDepthOption(
            title: '🔍 Deep-Dive',
            subtitle: 'Analysis',
            depth: ReadingDepth.deepDive,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildDepthOption({
    required String title,
    required String subtitle,
    required ReadingDepth depth,
    required bool isDark,
  }) {
    final isSelected = _selectedDepth == depth;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedDepth = depth;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF2C2F36) : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected
                      ? const Color(0xFFFF8C00)
                      : (isDark ? Colors.white60 : Colors.black54),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected
                      ? (isDark ? Colors.white70 : Colors.black87)
                      : (isDark ? Colors.white38 : Colors.black38),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDepthContent(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    switch (_selectedDepth) {
      case ReadingDepth.brief:
        final takeaways = widget.article.briefTakeaways ?? [
          'Key event: ${widget.article.title}',
          widget.article.description,
          'Why It Matters: Influences near-term stakeholder sentiment.',
        ];

        return Container(
          key: const ValueKey('depth-brief'),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFFF8C00).withOpacity(0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFFFF8C00).withOpacity(0.25),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.bolt, color: Color(0xFFFF8C00), size: 20),
                  const SizedBox(width: 6),
                  Text(
                    'EXECUTIVE BRIEFING (30 SECONDS)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFFFF8C00),
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ...takeaways.map((bullet) {
                final isWhyItMatters = bullet.toLowerCase().startsWith('why it matters');
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        isWhyItMatters ? Icons.priority_high : Icons.arrow_right,
                        size: 18,
                        color: isWhyItMatters ? const Color(0xFFFF8C00) : theme.colorScheme.secondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          bullet,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.45,
                            fontWeight: isWhyItMatters ? FontWeight.w700 : FontWeight.w500,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );

      case ReadingDepth.standard:
        final bodyText = widget.article.content.isNotEmpty
            ? widget.article.content
            : widget.article.description;

        return Column(
          key: const ValueKey('depth-standard'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.article.description,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.6,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            _buildInteractiveArticleText(context, bodyText),
          ],
        );

      case ReadingDepth.deepDive:
        return Column(
          key: const ValueKey('depth-deepdive'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'IN-DEPTH EDITORIAL ANALYSIS & STAKEHOLDER MATRIX',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: Color(0xFFFF8C00),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.article.description,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.6,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2024) : const Color(0xFFF9F8F5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? Colors.white12 : Colors.black12,
                ),
              ),
              child: Text(
                widget.article.deepDiveAnalysis ??
                    'Detailed analytical breakdown indicates coordinated cross-sector engagement.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: isDark ? Colors.white.withOpacity(0.87) : Colors.black87,
                ),
              ),
            ),
          ],
        );
    }
  }
}
