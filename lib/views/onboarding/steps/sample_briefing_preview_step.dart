import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/onboarding_view_model.dart';
import '../../../viewmodels/recommendation_view_model.dart';

class SampleBriefingPreviewStep extends StatelessWidget {
  final VoidCallback onComplete;

  const SampleBriefingPreviewStep({
    super.key,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onboardingVM = context.watch<OnboardingViewModel>();
    final recommendationVM = context.read<RecommendationViewModel>();
    final briefing = onboardingVM.sampleBriefing;

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
                  color: const Color(0xFF2E7D32).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'STEP 4 OF 4 • LIVE PAYOFF',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8C00).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'AI SYNTHESIZED',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF8C00),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Your Sample Morning Dispatch',
            style: theme.textTheme.displayLarge?.copyWith(
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Here is how Byline synthesizes your interests into a calibrated morning briefing. Tap thumbs up or down on any story to tune the algorithm.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),

          // Executive Narrative Box
          if (briefing != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2024) : const Color(0xFFF9F8F5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFFF8C00).withOpacity(0.3),
                  width: 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, size: 16, color: Color(0xFFFF8C00)),
                      const SizedBox(width: 6),
                      Text(
                        'EXECUTIVE SYNTHESIS (${onboardingVM.selectedTone.toUpperCase()} TONE)',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: Color(0xFFFF8C00),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    briefing.executiveNarrative,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.55,
                      fontStyle: FontStyle.italic,
                      color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Top Sample Stories
            Text(
              'TOP TAILORED STORIES',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
            const SizedBox(height: 10),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: briefing.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = briefing.items[index];
                final article = item.article;
                final isThumbsUp = item.userFeedback == 1;
                final isThumbsDown = item.userFeedback == -1;

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF191B1F) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.black12,
                      width: 0.8,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // "Why this fits you" tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF8C00).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.bolt, size: 13, color: Color(0xFFFF8C00)),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'Why this fits you: ${item.attributionTag}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF8C00),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        article.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        article.description,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isDark ? Colors.white70 : Colors.black87,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            article.sourceName,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                          const Text(' • '),
                          Text(
                            '${article.readTimeMinutes} min read',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.white54 : Colors.black54,
                            ),
                          ),
                          const Spacer(),
                          // Thumbs Up / Down Tuning Buttons
                          IconButton(
                            icon: Icon(
                              isThumbsUp ? Icons.thumb_up : Icons.thumb_up_outlined,
                              size: 18,
                              color: isThumbsUp ? const Color(0xFF2E7D32) : null,
                            ),
                            onPressed: () => onboardingVM.setSampleStoryFeedback(index, 1),
                            tooltip: 'More like this',
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(6),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: Icon(
                              isThumbsDown ? Icons.thumb_down : Icons.thumb_down_outlined,
                              size: 18,
                              color: isThumbsDown ? const Color(0xFFD32F2F) : null,
                            ),
                            onPressed: () => onboardingVM.setSampleStoryFeedback(index, -1),
                            tooltip: 'Less like this',
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(6),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ] else ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            ),
          ],
          const SizedBox(height: 24),
          // Complete CTA Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final profile = await onboardingVM.completeOnboarding();
                await recommendationVM.setProfile(profile);
                onComplete();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8C00),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Complete Setup & Enter Byline',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
