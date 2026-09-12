import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/story_thread.dart';
import '../../viewmodels/story_threads_view_model.dart';

class ThreadDetailSheet extends StatelessWidget {
  final StoryThread thread;

  const ThreadDetailSheet({
    super.key,
    required this.thread,
  });

  static void show(BuildContext context, StoryThread thread) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ThreadDetailSheet(thread: thread),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final threadsVM = context.watch<StoryThreadsViewModel>();
    final currentThread = threadsVM.threads.firstWhere(
      (t) => t.id == thread.id,
      orElse: () => thread,
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF16171A) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 16,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Sheet drag handle
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black26,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Thread Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF8C00).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'STORY THREAD • ${currentThread.topic.toUpperCase()}',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFFF8C00),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(
                            currentThread.isFollowing
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: currentThread.isFollowing ? const Color(0xFFFF8C00) : null,
                          ),
                          onPressed: () {
                            threadsVM.toggleFollow(currentThread.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  currentThread.isFollowing
                                      ? 'Unfollowed thread'
                                      : 'Following thread! Saved to your followed stories.',
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          tooltip: currentThread.isFollowing ? 'Following Thread' : 'Follow Thread',
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentThread.title,
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentThread.summary,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.white70 : Colors.black87,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.update,
                          size: 14,
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${currentThread.events.length} timeline milestones • ${currentThread.unreadCount} unread',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                        const Spacer(),
                        if (currentThread.unreadCount > 0)
                          TextButton(
                            onPressed: () {
                              threadsVM.updateCheckpoint(
                                currentThread.id,
                                currentThread.events.length - 1,
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Mark All Read',
                              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Vertical Timeline
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  itemCount: currentThread.events.length,
                  itemBuilder: (context, index) {
                    final event = currentThread.events[index];
                    final isCheckpoint = index == currentThread.checkpointIndex;
                    final isNew = index > currentThread.checkpointIndex;
                    final isLast = index == currentThread.events.length - 1;

                    return _buildTimelineNode(
                      context,
                      event: event,
                      nodeIndex: index,
                      isCheckpoint: isCheckpoint,
                      isNew: isNew,
                      isLast: isLast,
                      onMarkCheckpoint: () {
                        threadsVM.updateCheckpoint(currentThread.id, index);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimelineNode(
    BuildContext context, {
    required ThreadEvent event,
    required int nodeIndex,
    required bool isCheckpoint,
    required bool isNew,
    required bool isLast,
    required VoidCallback onMarkCheckpoint,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final dotColor = isNew
        ? const Color(0xFFFF8C00)
        : (isDark ? Colors.white38 : Colors.black38);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator line + circle
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dotColor,
                    border: Border.all(
                      color: isDark ? const Color(0xFF16171A) : Colors.white,
                      width: 2,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isDark ? Colors.white12 : Colors.black12,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isNew
                              ? const Color(0xFFFF8C00).withOpacity(0.15)
                              : (isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          event.impact.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: isNew
                                ? const Color(0xFFFF8C00)
                                : (isDark ? Colors.white60 : Colors.black54),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        event.formattedTimeAgo,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                      ),
                      const Spacer(),
                      if (isCheckpoint)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: const Text(
                            'YOU READ UP TO HERE',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    event.headline,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.summary,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.white70 : Colors.black87,
                      height: 1.4,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        'Source: ${event.source}',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontStyle: FontStyle.italic,
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                      ),
                      const Spacer(),
                      if (isNew)
                        InkWell(
                          onTap: onMarkCheckpoint,
                          child: const Text(
                            'Mark as Read',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF8C00),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
