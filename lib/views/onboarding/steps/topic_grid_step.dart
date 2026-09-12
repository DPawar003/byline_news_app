import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/onboarding_view_model.dart';

class TopicGridStep extends StatelessWidget {
  const TopicGridStep({super.key});

  static const List<Map<String, dynamic>> _topics = [
    {
      'id': 'technology',
      'title': 'Technology',
      'icon': Icons.memory_outlined,
      'subtitle': 'AI, compute, cyber, startups',
    },
    {
      'id': 'business',
      'title': 'Business & Markets',
      'icon': Icons.trending_up_outlined,
      'subtitle': 'Central banks, equities, venture',
    },
    {
      'id': 'climate',
      'title': 'Climate & Energy',
      'icon': Icons.eco_outlined,
      'subtitle': 'Nuclear, grid storage, carbon',
    },
    {
      'id': 'politics',
      'title': 'Politics & Policy',
      'icon': Icons.account_balance_outlined,
      'subtitle': 'Elections, law, trade accords',
    },
    {
      'id': 'health',
      'title': 'Health & Biotech',
      'icon': Icons.biotech_outlined,
      'subtitle': 'Longevity, pharma, trials',
    },
    {
      'id': 'science',
      'title': 'Science & Space',
      'icon': Icons.rocket_launch_outlined,
      'subtitle': 'Astrophysics, research, quantum',
    },
    {
      'id': 'culture',
      'title': 'Culture & Arts',
      'icon': Icons.palette_outlined,
      'subtitle': 'Literature, architecture, ideas',
    },
    {
      'id': 'sports',
      'title': 'Sports & Analytics',
      'icon': Icons.sports_basketball_outlined,
      'subtitle': 'Global leagues, F1, dynamics',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onboardingVM = context.watch<OnboardingViewModel>();
    final selected = onboardingVM.selectedTopics;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                child: const Text(
                  'STEP 1 OF 4 • TOPICS',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    color: Color(0xFFFF8C00),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${selected.length} selected (min 3)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: selected.length >= 3
                      ? const Color(0xFF2E7D32)
                      : (isDark ? Colors.white60 : Colors.black54),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'What drives your curiosity?',
            style: theme.textTheme.displayLarge?.copyWith(
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select 3 to 8 broad topics. Byline uses these to calibrate your baseline editorial news mix.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.25,
            ),
            itemCount: _topics.length,
            itemBuilder: (context, index) {
              final topic = _topics[index];
              final isSelected = selected.contains(topic['id']);

              return InkWell(
                onTap: () => onboardingVM.toggleTopic(topic['id']),
                borderRadius: BorderRadius.circular(10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFFF8C00).withOpacity(isDark ? 0.18 : 0.08)
                        : (isDark ? const Color(0xFF1E2024) : Colors.white),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFFF8C00)
                          : (isDark ? Colors.white12 : Colors.black12),
                      width: isSelected ? 1.8 : 0.8,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFFFF8C00).withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            topic['icon'] as IconData,
                            size: 24,
                            color: isSelected
                                ? const Color(0xFFFF8C00)
                                : (isDark ? Colors.white70 : Colors.black87),
                          ),
                          AnimatedScale(
                            scale: isSelected ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 150),
                            child: const Icon(
                              Icons.check_circle,
                              size: 18,
                              color: Color(0xFFFF8C00),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            topic['title'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            topic['subtitle'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.white54 : Colors.black54,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
