import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/onboarding_view_model.dart';

class EditorialPreferencesStep extends StatelessWidget {
  const EditorialPreferencesStep({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onboardingVM = context.watch<OnboardingViewModel>();

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
                  'STEP 3 OF 4 • EDITORIAL PREFERENCES',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    color: Color(0xFFFF8C00),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'How do you like to read?',
            style: theme.textTheme.displayLarge?.copyWith(
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tune the length, narrative voice, and daily time budget. You can adjust this anytime in your settings.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),

          // 1. Reading Depth
          _buildSectionHeader(context, title: 'DEFAULT READING DEPTH', icon: Icons.straighten_outlined),
          const SizedBox(height: 10),
          _buildOptionCard(
            context,
            title: '⚡ Brief (30 Seconds)',
            subtitle: 'Executive bullets + "Why It Matters" callouts for rapid scanning.',
            isSelected: onboardingVM.selectedDepth == 'brief',
            onTap: () => onboardingVM.setDepth('brief'),
          ),
          const SizedBox(height: 8),
          _buildOptionCard(
            context,
            title: '📖 Standard (2–3 Minutes)',
            subtitle: 'Balanced narrative journalism with key quotes and corroborated facts.',
            isSelected: onboardingVM.selectedDepth == 'standard',
            onTap: () => onboardingVM.setDepth('standard'),
          ),
          const SizedBox(height: 8),
          _buildOptionCard(
            context,
            title: '🔍 Deep-Dive (5–8 Minutes)',
            subtitle: 'Exhaustive background context, stakeholder matrices, and forward outlook.',
            isSelected: onboardingVM.selectedDepth == 'deepDive',
            onTap: () => onboardingVM.setDepth('deepDive'),
          ),

          const SizedBox(height: 28),

          // 2. Editorial Tone Preference
          _buildSectionHeader(context, title: 'EDITORIAL TONE', icon: Icons.record_voice_over_outlined),
          const SizedBox(height: 10),
          _buildOptionCard(
            context,
            title: 'Neutral Wire',
            subtitle: 'Straightforward, dispassionate facts without opinion or conjecture.',
            isSelected: onboardingVM.selectedTone == 'neutral',
            onTap: () => onboardingVM.setTone('neutral'),
          ),
          const SizedBox(height: 8),
          _buildOptionCard(
            context,
            title: 'Analytical (Recommended)',
            subtitle: 'Economist-style insight examining structural causes, incentives, and second-order effects.',
            isSelected: onboardingVM.selectedTone == 'analytical',
            onTap: () => onboardingVM.setTone('analytical'),
          ),
          const SizedBox(height: 8),
          _buildOptionCard(
            context,
            title: 'Conversational',
            subtitle: 'Engaging, narrative-driven storytelling accessible to all audiences.',
            isSelected: onboardingVM.selectedTone == 'conversational',
            onTap: () => onboardingVM.setTone('conversational'),
          ),

          const SizedBox(height: 28),

          // 3. Daily Reading Time Budget
          _buildSectionHeader(context, title: 'DAILY READING BUDGET', icon: Icons.timer_outlined),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildTimeChip(
                context,
                title: '5 min/day',
                subtitle: 'Sprint',
                isSelected: onboardingVM.selectedTimeBudget == 5,
                onTap: () => onboardingVM.setTimeBudget(5),
              ),
              const SizedBox(width: 8),
              _buildTimeChip(
                context,
                title: '10 min/day',
                subtitle: 'Standard',
                isSelected: onboardingVM.selectedTimeBudget == 10,
                onTap: () => onboardingVM.setTimeBudget(10),
              ),
              const SizedBox(width: 8),
              _buildTimeChip(
                context,
                title: '20+ min/day',
                subtitle: 'Deep Scan',
                isSelected: onboardingVM.selectedTimeBudget == 20,
                onTap: () => onboardingVM.setTimeBudget(20),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, {required String title, required IconData icon}) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFFFF8C00)),
        const SizedBox(width: 6),
        Text(
          title,
          style: theme.textTheme.labelSmall?.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
            color: const Color(0xFFFF8C00),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
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
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? const Color(0xFFFF8C00) : (isDark ? Colors.white38 : Colors.black38),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeChip(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFFF8C00)
                : (isDark ? const Color(0xFF1E2024) : Colors.white),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFFF8C00)
                  : (isDark ? Colors.white12 : Colors.black12),
              width: isSelected ? 1.5 : 0.8,
            ),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black87),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? Colors.white.withOpacity(0.85) : (isDark ? Colors.white54 : Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
