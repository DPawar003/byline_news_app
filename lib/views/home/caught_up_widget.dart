import 'package:flutter/material.dart';

class CaughtUpWidget extends StatelessWidget {
  final int articlesRead;
  final int totalMinutes;
  final VoidCallback? onBrowseArchives;

  const CaughtUpWidget({
    super.key,
    required this.articlesRead,
    required this.totalMinutes,
    this.onBrowseArchives,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B1D22) : const Color(0xFFF9F8F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black12,
          width: 0.8,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF2E7D32).withOpacity(0.12),
              border: Border.all(color: const Color(0xFF2E7D32), width: 1.5),
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: Color(0xFF2E7D32),
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            "You're All Caught Up",
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "No infinite doomscrolling. You've reviewed today's essential reporting across primary wire bureaus.",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.white60 : Colors.black54,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          // Stats row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  title: 'Stories Read',
                  value: '$articlesRead',
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: isDark ? Colors.white12 : Colors.black12,
                ),
                _buildStatItem(
                  context,
                  title: 'Est. Focus Time',
                  value: '${totalMinutes > 0 ? totalMinutes : 8} mins',
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: isDark ? Colors.white12 : Colors.black12,
                ),
                _buildStatItem(
                  context,
                  title: 'Edition Status',
                  value: 'Complete',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Today's 3-Bullet Recap
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "TODAY'S RECAP IN BRIEF",
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
                color: const Color(0xFFFF8C00),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildRecapBullet(
            context,
            'Global regulatory frameworks advance for frontier compute and foundation models.',
          ),
          _buildRecapBullet(
            context,
            'Clean energy infrastructure deployments expand into next-generation battery manufacturing.',
          ),
          _buildRecapBullet(
            context,
            'Central bank communiqués indicate ongoing data-dependent policy neutrality.',
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wb_twilight, size: 16, color: Color(0xFFFF8C00)),
              const SizedBox(width: 6),
              Text(
                'Next curated dispatch at 6:00 PM',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ],
          ),
          if (onBrowseArchives != null) ...[
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: onBrowseArchives,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isDark ? Colors.white24 : Colors.black26,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text('Browse Archive Stories'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String title,
    required String value,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: TextStyle(
            fontSize: 10.5,
            color: isDark ? Colors.white54 : Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildRecapBullet(BuildContext context, String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF8C00))),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: isDark ? Colors.white.withOpacity(0.87) : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
