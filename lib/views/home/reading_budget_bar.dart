import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/reading_budget_view_model.dart';
import '../../viewmodels/feed_view_model.dart';

class ReadingBudgetBar extends StatelessWidget {
  const ReadingBudgetBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final budgetVM = context.watch<ReadingBudgetViewModel>();
    final feedVM = context.watch<FeedViewModel>();

    final curatedArticles = budgetVM.curateArticlesForBudget(feedVM.articles);
    final readMins = budgetVM.calculateMinutesRead(curatedArticles);
    final isBudgetActive = budgetVM.isBudgetModeActive;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF191B1F) : const Color(0xFFF2F0EB),
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
          Row(
            children: [
              Icon(
                Icons.hourglass_top_rounded,
                size: 16,
                color: isBudgetActive ? const Color(0xFFFF8C00) : theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: 6),
              Text(
                'Reading Budget',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                  color: isBudgetActive ? const Color(0xFFFF8C00) : theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const Spacer(),
              if (isBudgetActive) ...[
                Flexible(
                  child: Text(
                    '$readMins of ${budgetVM.targetMinutes} min read',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: readMins >= budgetVM.targetMinutes
                          ? const Color(0xFF2E7D32)
                          : (isDark ? Colors.white70 : Colors.black87),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => budgetVM.toggleBudgetMode(false),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Show All',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildBudgetChip(
                  context,
                  label: 'All Feed',
                  icon: Icons.view_headline_rounded,
                  isSelected: !isBudgetActive,
                  onTap: () => budgetVM.toggleBudgetMode(false),
                ),
                const SizedBox(width: 8),
                _buildBudgetChip(
                  context,
                  label: '5m Sprint',
                  icon: Icons.flash_on_rounded,
                  isSelected: isBudgetActive && budgetVM.targetMinutes == 5,
                  onTap: () {
                    budgetVM.setTargetMinutes(5);
                    budgetVM.toggleBudgetMode(true);
                  },
                ),
                const SizedBox(width: 8),
                _buildBudgetChip(
                  context,
                  label: '10m Brief',
                  icon: Icons.timer_outlined,
                  isSelected: isBudgetActive && budgetVM.targetMinutes == 10,
                  onTap: () {
                    budgetVM.setTargetMinutes(10);
                    budgetVM.toggleBudgetMode(true);
                  },
                ),
                const SizedBox(width: 8),
                _buildBudgetChip(
                  context,
                  label: '15m Deep Scan',
                  icon: Icons.auto_stories_outlined,
                  isSelected: isBudgetActive && budgetVM.targetMinutes == 15,
                  onTap: () {
                    budgetVM.setTargetMinutes(15);
                    budgetVM.toggleBudgetMode(true);
                  },
                ),
              ],
            ),
          ),
          if (isBudgetActive) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: budgetVM.targetMinutes > 0
                    ? (readMins / budgetVM.targetMinutes).clamp(0.0, 1.0)
                    : 0.0,
                minHeight: 4,
                backgroundColor: isDark ? Colors.white12 : Colors.black12,
                valueColor: AlwaysStoppedAnimation<Color>(
                  readMins >= budgetVM.targetMinutes ? const Color(0xFF2E7D32) : const Color(0xFFFF8C00),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBudgetChip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFF8C00)
              : (isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFF8C00)
                : (isDark ? Colors.white12 : Colors.black12),
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : (isDark ? Colors.white.withOpacity(0.87) : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
