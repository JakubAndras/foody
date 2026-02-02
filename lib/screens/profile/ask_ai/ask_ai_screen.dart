import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/screens/profile/ask_ai/ask_ai_response_screen.dart';
import 'package:diplomka/screens/profile/ask_ai/ask_ai_widgets.dart';
import 'package:diplomka/screens/profile/profile_widgets.dart';

class AskAiScreen extends StatelessWidget {
  const AskAiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileGradientScaffold(
      scroll: true,
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.lg, AppSpacing.md, AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AskAiTopBar(),
          const SizedBox(height: AppSpacing.md),
          AskAiPromptCard(
            onAsk: () => Get.to(() => const AskAiViolationsScreen()),
          ),
          const SizedBox(height: AppSpacing.lg),
          ProfileCard(
            radius: AppRadii.lg,
            shadow: AppShadows.cardSubtle,
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AskAiSectionHeader(
                  title: 'Example Questions',
                  icon: Icons.question_mark,
                  iconGradient: AppGradients.askAiExample,
                  iconRadius: AppRadii.xs,
                  iconSize: 28,
                ),
                const SizedBox(height: AppSpacing.md),
                AskAiExampleQuestionCard(
                  label: 'How many times did I violate my gluten-free restriction this month?',
                  height: 68,
                  onTap: () => Get.to(() => const AskAiViolationsScreen()),
                ),
                const SizedBox(height: AppSpacing.sm),
                AskAiExampleQuestionCard(
                  label: 'Show me the days I exceeded my daily calorie goal.',
                  height: 68,
                  onTap: () => Get.to(() => const AskAiViolationsScreen()),
                ),
                const SizedBox(height: AppSpacing.sm),
                AskAiExampleQuestionCard(
                  label: 'What was my average protein intake last week?',
                  onTap: () => Get.to(() => const AskAiAchievedScreen()),
                ),
                const SizedBox(height: AppSpacing.sm),
                AskAiExampleQuestionCard(
                  label: 'Did I meet my fiber goals in January?',
                  onTap: () => Get.to(() => const AskAiAchievedScreen()),
                ),
                const SizedBox(height: AppSpacing.sm),
                AskAiExampleQuestionCard(
                  label: 'Which days did I consume dairy products?',
                  onTap: () => Get.to(() => const AskAiTrackedScreen()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
