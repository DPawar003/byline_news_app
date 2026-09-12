import 'package:flutter/material.dart';
import '../../models/article.dart';

class CoverageSpreadBadge extends StatelessWidget {
  final CoverageSpread coverage;
  final bool compact;

  const CoverageSpreadBadge({
    super.key,
    required this.coverage,
    this.compact = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color badgeColor;
    IconData icon;
    switch (coverage.consensusLevel) {
      case ConsensusLevel.highConsensus:
        badgeColor = const Color(0xFF2E7D32); // Deep Forest Green
        icon = Icons.verified_outlined;
        break;
      case ConsensusLevel.developingSplit:
        badgeColor = const Color(0xFFE65100); // Amber Orange
        icon = Icons.call_split_outlined;
        break;
      case ConsensusLevel.singleSource:
        badgeColor = const Color(0xFF616161); // Slate Gray
        icon = Icons.visibility_outlined;
        break;
    }

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: badgeColor.withOpacity(isDark ? 0.18 : 0.10),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: badgeColor.withOpacity(0.35), width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: badgeColor),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                coverage.consensusLevel == ConsensusLevel.singleSource
                    ? 'Single Source'
                    : '${coverage.outletCount} outlets',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: badgeColor,
                  letterSpacing: 0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2024) : const Color(0xFFF8F7F4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black12,
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: badgeColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Coverage Spread & Consensus',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  coverage.consensusLabel,
                  style: TextStyle(
                    color: badgeColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Multi-source reporting breakdown across independent newsrooms:',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          // Multi-perspective colored distribution bar
          _buildPerspectiveDistributionBar(context),
          const SizedBox(height: 12),
          // Perspective legend
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: coverage.perspectives.entries.map((entry) {
              final color = _getColorForAngle(entry.key);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${entry.key} (${(entry.value * 100).toInt()}%)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 10),
          // Notable Outlets
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reporting bureaus: ',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.secondary,
                ),
              ),
              Expanded(
                child: Text(
                  coverage.notableOutlets.join(' • '),
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerspectiveDistributionBar(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 10,
        child: Row(
          children: coverage.perspectives.entries.map((entry) {
            return Expanded(
              flex: (entry.value * 100).toInt(),
              child: Container(
                color: _getColorForAngle(entry.key),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _getColorForAngle(String angle) {
    final lower = angle.toLowerCase();
    if (lower.contains('market') || lower.contains('econom')) {
      return const Color(0xFF00897B); // Teal
    } else if (lower.contains('regulat') || lower.contains('policy') || lower.contains('law')) {
      return const Color(0xFF3949AB); // Indigo
    } else if (lower.contains('tech') || lower.contains('innovat') || lower.contains('product')) {
      return const Color(0xFFFF8C00); // Byline Orange
    } else if (lower.contains('geo') || lower.contains('diplomat')) {
      return const Color(0xFFC2185B); // Rose
    } else {
      return const Color(0xFF5E35B1); // Deep Purple
    }
  }
}
