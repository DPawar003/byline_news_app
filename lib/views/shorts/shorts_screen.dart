import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodels/feed_view_model.dart';
import '../../models/article.dart';
import '../shared/empty_state_widget.dart';
import '../shared/loading_widget.dart';

class ShortsScreen extends StatefulWidget {
  const ShortsScreen({super.key});

  @override
  State<ShortsScreen> createState() => _ShortsScreenState();
}

class _ShortsScreenState extends State<ShortsScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedVM = context.watch<FeedViewModel>();
    final articles = feedVM.articles;

    if (feedVM.isLoading && articles.isEmpty) {
      return const Scaffold(
        body: EditorialShimmerLoading(),
      );
    }

    if (articles.isEmpty) {
      return const Scaffold(
        body: EmptyStateWidget(
          title: "No News Shorts",
          message: "Check back later for quick bite-sized updates.",
          icon: Icons.subtitles_outlined,
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final article = articles[index];
          return _ShortCard(article: article);
        },
      ),
    );
  }
}

class _ShortCard extends StatelessWidget {
  final Article article;

  const _ShortCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background image
        Positioned.fill(
          child: Image.network(
            article.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFF1C1917),
              child: const Center(
                child: Icon(Icons.newspaper, size: 64, color: Colors.white24),
              ),
            ),
          ),
        ),

        // Gradient overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.5),
                  Colors.black.withOpacity(0.95),
                ],
                stops: const [0.0, 0.4, 0.9],
              ),
            ),
          ),
        ),

        // Content
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top badge row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF8C00),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'WIRE SHORTS',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Text(
                        article.category.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),

                // Title
                Text(
                  article.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    height: 1.3,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'serif',
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Description
                Text(
                  article.description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    height: 1.4,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 20),

                // Footer row
                Row(
                  children: [
                    Text(
                      '${article.sourceName} • ${article.formattedDate}',
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.push('/article/${article.id}', extra: article);
                      },
                      icon: const Icon(Icons.arrow_forward, size: 16),
                      label: const Text('Read Full'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8C00),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
