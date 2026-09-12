import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodels/bookmark_view_model.dart';
import '../../viewmodels/auth_view_model.dart';
import '../shared/empty_state_widget.dart';
import '../home/article_card.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVM = context.read<AuthViewModel>();
      context.read<BookmarkViewModel>().loadBookmarks(authVM.user?.uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookmarkVM = context.watch<BookmarkViewModel>();
    final authVM = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Articles'),
      ),
      body: bookmarkVM.bookmarks.isEmpty
          ? const EmptyStateWidget(
              title: "No Saved Reading",
              message: "Articles you bookmark will be available offline here anytime.",
              icon: Icons.bookmark_outline,
            )
          : RefreshIndicator(
              onRefresh: () async {
                bookmarkVM.loadBookmarks(authVM.user?.uid);
              },
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: bookmarkVM.bookmarks.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final article = bookmarkVM.bookmarks[index];
                  return StandardArticleRow(
                    article: article,
                    onTap: () => context.push('/article/${article.id}', extra: article),
                  );
                },
              ),
            ),
    );
  }
}
