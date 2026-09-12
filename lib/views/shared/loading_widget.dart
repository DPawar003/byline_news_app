import 'package:flutter/material.dart';

class EditorialShimmerLoading extends StatefulWidget {
  const EditorialShimmerLoading({super.key});

  @override
  State<EditorialShimmerLoading> createState() => _EditorialShimmerLoadingState();
}

class _EditorialShimmerLoadingState extends State<EditorialShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final opacity = 0.3 + (_controller.value * 0.5);
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: 5,
          separatorBuilder: (_, __) => const Divider(height: 32),
          itemBuilder: (context, index) {
            if (index == 0) {
              // Lead Hero Shimmer
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    color: baseColor.withOpacity(opacity),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 24,
                    width: double.infinity,
                    color: baseColor.withOpacity(opacity),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 14,
                    width: 160,
                    color: baseColor.withOpacity(opacity),
                  ),
                ],
              );
            }
            // Row Shimmer
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  color: baseColor.withOpacity(opacity),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: double.infinity,
                        color: baseColor.withOpacity(opacity),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 16,
                        width: 200,
                        color: baseColor.withOpacity(opacity),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: 100,
                        color: baseColor.withOpacity(opacity),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
