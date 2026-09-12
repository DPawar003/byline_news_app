import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodels/onboarding_view_model.dart';
import 'steps/topic_grid_step.dart';
import 'steps/subtopic_entity_step.dart';
import 'steps/editorial_preferences_step.dart';
import 'steps/sample_briefing_preview_step.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onStepChanged(int step) {
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onboardingVM = context.watch<OnboardingViewModel>();
    final currentStep = onboardingVM.currentStep;

    return Scaffold(
      appBar: AppBar(
        leading: currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  onboardingVM.previousStep();
                  _onStepChanged(onboardingVM.currentStep);
                },
              )
            : null,
        title: Row(
          children: [
            Text(
              'Byline',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: isDark ? const Color(0xFFFF8C00) : const Color(0xFFE65100),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFF8C00).withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'SETUP',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF8C00),
                ),
              ),
            ),
          ],
        ),
        actions: [
          if (currentStep < 3)
            TextButton(
              onPressed: () {
                onboardingVM.setStep(3);
                _onStepChanged(3);
              },
              child: const Text(
                'Skip to Preview',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(
            value: (currentStep + 1) / 4.0,
            backgroundColor: isDark ? Colors.white12 : Colors.black12,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF8C00)),
            minHeight: 3,
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Controls driven by buttons
        children: [
          const TopicGridStep(),
          const SubtopicEntityStep(),
          const EditorialPreferencesStep(),
          SampleBriefingPreviewStep(
            onComplete: () => context.go('/home'),
          ),
        ],
      ),
      bottomNavigationBar: currentStep < 3
          ? Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF16171A) : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark ? Colors.white12 : Colors.black12,
                    width: 0.8,
                  ),
                ),
              ),
              child: Row(
                children: [
                  if (currentStep > 0) ...[
                    OutlinedButton(
                      onPressed: () {
                        onboardingVM.previousStep();
                        _onStepChanged(onboardingVM.currentStep);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                      child: const Text('Back'),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _canProceed(onboardingVM)
                          ? () {
                              onboardingVM.nextStep();
                              _onStepChanged(onboardingVM.currentStep);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8C00),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: isDark ? Colors.white12 : Colors.black12,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        currentStep == 2 ? 'Generate My Preview →' : 'Continue →',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  bool _canProceed(OnboardingViewModel vm) {
    if (vm.currentStep == 0) return vm.canProceedFromStep1;
    if (vm.currentStep == 1) return vm.canProceedFromStep2;
    return true;
  }
}
