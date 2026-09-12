import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/onboarding_view_model.dart';

class SubtopicEntityStep extends StatelessWidget {
  const SubtopicEntityStep({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onboardingVM = context.watch<OnboardingViewModel>();
    final selectedTopics = onboardingVM.selectedTopics;
    final selectedEntities = onboardingVM.selectedEntities;

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
                  'STEP 2 OF 4 • GRANULAR FOCUS',
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
                '${selectedEntities.length} entities followed',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF8C00),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Refine with specific entities',
            style: theme.textTheme.displayLarge?.copyWith(
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Broad categories are good, but granularity matters. Pick sub-topics and ongoing sectors you want prioritized in your dispatch.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),
          if (selectedTopics.isEmpty) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2024) : const Color(0xFFF8F7F4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text('Please select topics in Step 1 first.'),
              ),
            ),
          ] else ...[
            ...selectedTopics.map((topic) {
              final subtopics = onboardingVM.getSubtopicsForTopic(topic);
              if (subtopics.isEmpty) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 16,
                          color: const Color(0xFFFF8C00),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          topic.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: subtopics.map((subtopic) {
                        final isSelected = selectedEntities.contains(subtopic);

                        return InkWell(
                          onTap: () => onboardingVM.toggleEntity(subtopic),
                          borderRadius: BorderRadius.circular(20),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFFF8C00)
                                  : (isDark ? const Color(0xFF1E2024) : Colors.white),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFFF8C00)
                                    : (isDark ? Colors.white12 : Colors.black12),
                                width: 1.0,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFFFF8C00).withOpacity(0.2),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      )
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isSelected ? Icons.check : Icons.add,
                                  size: 14,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark ? Colors.white70 : Colors.black87),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  subtopic,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected
                                        ? Colors.white
                                        : (isDark ? Colors.white : Colors.black87),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
