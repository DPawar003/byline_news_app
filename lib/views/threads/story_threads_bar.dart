import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/story_threads_view_model.dart';
import 'thread_detail_sheet.dart';

class StoryThreadsBar extends StatelessWidget {
  const StoryThreadsBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final threadsVM = context.watch<StoryThreadsViewModel>();
    final threads = threadsVM.threads;

    if (threads.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131417) : const Color(0xFFFAF9F6),
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white10 : Colors.black12,
            width: 0.8,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(
                  Icons.linear_scale,
                  size: 16,
                  color: Color(0xFFFF8C00),
                ),
                const SizedBox(width: 6),
                Text(
                  'STORY THREADS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    color: const Color(0xFFFF8C00),
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    '• Evolving Sagas',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 64,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: threads.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final thread = threads[index];
                final hasUnread = thread.unreadCount > 0;

                return InkWell(
                  onTap: () => ThreadDetailSheet.show(context, thread),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 210,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E2024) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: hasUnread
                            ? const Color(0xFFFF8C00).withOpacity(0.5)
                            : (isDark ? Colors.white12 : Colors.black12),
                        width: 0.8,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                thread.topic.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.secondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (hasUnread)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF8C00),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '+${thread.unreadCount} new',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          thread.title,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : Colors.black87,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
