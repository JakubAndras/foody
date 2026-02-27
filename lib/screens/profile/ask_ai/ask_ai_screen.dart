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
      scroll: false,
      padding: const EdgeInsets.only(left: AppSpacing.m, right: AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileTopBar(title: 'Ask AI', onBack: () => Get.back()),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AskAiPromptCard(
                    onAsk: () => Get.to(() => const AskAiViolationsScreen()),
                  ),
                  const SizedBox(height: AppSpacing.l),
                  ProfileCard(
                    radius: AppRadii.lg,
                    shadow: AppShadows.cardSubtle,
                    padding: const EdgeInsets.all(AppSpacing.m),
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
                        const SizedBox(height: AppSpacing.m),
                        AskAiExampleQuestionCard(
                          label: 'How many times did I violate my gluten-free restriction this month?',
                          height: 68,
                          onTap: () => Get.to(() => const AskAiViolationsScreen()),
                        ),
                        const SizedBox(height: AppSpacing.s),
                        AskAiExampleQuestionCard(
                          label: 'Show me the days I exceeded my daily calorie goal.',
                          height: 68,
                          onTap: () => Get.to(() => const AskAiViolationsScreen()),
                        ),
                        const SizedBox(height: AppSpacing.s),
                        AskAiExampleQuestionCard(
                          label: 'What was my average protein intake last week?',
                          onTap: () => Get.to(() => const AskAiAchievedScreen()),
                        ),
                        const SizedBox(height: AppSpacing.s),
                        AskAiExampleQuestionCard(
                          label: 'Did I meet my fiber goals in January?',
                          onTap: () => Get.to(() => const AskAiAchievedScreen()),
                        ),
                        const SizedBox(height: AppSpacing.s),
                        AskAiExampleQuestionCard(
                          label: 'Which days did I consume dairy products?',
                          onTap: () => Get.to(() => const AskAiTrackedScreen()),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
