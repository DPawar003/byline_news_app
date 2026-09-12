import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodels/recommendation_view_model.dart';
import '../../viewmodels/feed_view_model.dart';
import '../../services/audio_briefing_service.dart';

class DailyBriefingCard extends StatefulWidget {
  const DailyBriefingCard({super.key});

  @override
  State<DailyBriefingCard> createState() => _DailyBriefingCardState();
}

class _DailyBriefingCardState extends State<DailyBriefingCard> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final recommendationVM = context.watch<RecommendationViewModel>();
    final feedVM = context.watch<FeedViewModel>();
    final audioService = context.watch<AudioBriefingService>();
    final briefing = recommendationVM.dailyBriefing;

    // If no briefing yet but we have articles, generate one automatically
    if (briefing == null && feedVM.articles.isNotEmpty && !recommendationVM.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        recommendationVM.generateDailyBriefing(feedVM.articles);
      });
      return const SizedBox.shrink();
    }

    if (briefing == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B1D22) : const Color(0xFFF9F8F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFF8C00).withOpacity(0.35),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF8C00),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'DAILY BRIEFING',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    briefing.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),

          // Audio Player Bar with Real Speech Synthesis
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: InkWell(
              onTap: () {
                final fullNarrative = briefing.executiveNarrative.isNotEmpty
                    ? '${briefing.title}. ${briefing.executiveNarrative}'
                    : briefing.title;
                audioService.togglePlay(fullNarrative);
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8C00).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFFF8C00).withOpacity(audioService.isPlaying ? 0.45 : 0.2),
                    width: 0.8,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(
                          audioService.isPlaying
                              ? Icons.pause_circle_filled
                              : (audioService.isPaused
                                  ? Icons.play_circle_outline
                                  : Icons.play_circle_fill),
                          color: const Color(0xFFFF8C00),
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            audioService.isPlaying
                                ? 'Listening to Morning Dispatch'
                                : (audioService.isPaused
                                    ? 'Paused · Tap to Resume'
                                    : briefing.formattedAudioDuration),
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF8C00),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (audioService.isPlaying || audioService.isPaused)
                          IconButton(
                            icon: const Icon(
                              Icons.stop_circle_outlined,
                              size: 18,
                              color: Color(0xFFFF8C00),
                            ),
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            tooltip: 'Stop Audio',
                            onPressed: () => audioService.stop(),
                          ),
                        Icon(
                          Icons.graphic_eq,
                          size: 16,
                          color: audioService.isPlaying
                              ? const Color(0xFFFF8C00)
                              : theme.disabledColor,
                        ),
                      ],
                    ),
                    if (audioService.isPlaying || audioService.isPaused) ...[
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: audioService.progress > 0 ? audioService.progress : null,
                          backgroundColor: const Color(0xFFFF8C00).withOpacity(0.15),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF8C00)),
                          minHeight: 2.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          if (_isExpanded) ...[
            // Executive Synthesized Summary
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Text(
                briefing.executiveNarrative,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                  color: isDark ? Colors.white.withOpacity(0.85) : Colors.black87,
                ),
              ),
            ),
            const Divider(height: 1),

            // Top Tailored Stories with "Why you're seeing this" attribution tags
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: briefing.items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = briefing.items[index];
                final article = item.article;

                return InkWell(
                  onTap: () => context.push('/article/${article.id}', extra: article),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF8C00).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.bolt, size: 11, color: Color(0xFFFF8C00)),
                                  const SizedBox(width: 3),
                                  Text(
                                    item.attributionTag,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFF8C00),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${article.readTimeMinutes}m',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: isDark ? Colors.white54 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          article.title,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                            color: isDark ? Colors.white : Colors.black87,
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

            // Footer with recalibrate link
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Row(
                children: [
                  Text(
                    'Calibrated by Byline AI',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () => context.push('/onboarding'),
                    child: const Text(
                      'Recalibrate Interests',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF8C00),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
