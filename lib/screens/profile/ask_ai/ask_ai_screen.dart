import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/controller/ask_ai_controller.dart';
import 'package:diplomka/screens/profile/ask_ai/ask_ai_response_screen.dart';
import 'package:diplomka/screens/profile/ask_ai/ask_ai_widgets.dart';
import 'package:diplomka/screens/profile/profile_widgets.dart';

class AskAiScreen extends StatefulWidget {
  const AskAiScreen({super.key});

  @override
  State<AskAiScreen> createState() => _AskAiScreenState();
}

class _AskAiScreenState extends State<AskAiScreen> {
  final _textController = TextEditingController();
  late final AskAiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AskAiController.to;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _handleAsk() async {
    final query = _textController.text.trim();
    if (query.isEmpty) return;

    final result = await _controller.submitQuery(query);
    if (result != null) {
      Get.to(() => AskAiResponseScreen(response: result, query: query));
    } else if (_controller.errorMessage.value != null) {
      Get.snackbar(
        'Ask AI',
        _controller.errorMessage.value!,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _handleExampleTap(String question) {
    _textController.text = question;
    _handleAsk();
  }

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
              child: Obx(() {
                final loading = _controller.isLoading.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AskAiPromptCard(
                      controller: _textController,
                      isLoading: loading,
                      onAsk: _handleAsk,
                      onClear: () => _textController.clear(),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    IgnorePointer(
                      ignoring: loading,
                      child: Opacity(
                        opacity: loading ? 0.5 : 1.0,
                        child: ProfileCard(
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
                                label: 'How many times did I violate my dietary restriction this month?',
                                height: 68,
                                onTap: () => _handleExampleTap('How many times did I violate my dietary restriction this month?'),
                              ),
                              const SizedBox(height: AppSpacing.s),
                              AskAiExampleQuestionCard(
                                label: 'Show me the days I exceeded my daily calorie goal.',
                                height: 68,
                                onTap: () => _handleExampleTap('Show me the days I exceeded my daily calorie goal.'),
                              ),
                              const SizedBox(height: AppSpacing.s),
                              AskAiExampleQuestionCard(
                                label: 'What was my average protein intake last week?',
                                onTap: () => _handleExampleTap('What was my average protein intake last week?'),
                              ),
                              const SizedBox(height: AppSpacing.s),
                              AskAiExampleQuestionCard(
                                label: 'Did I meet my fiber goals in January?',
                                onTap: () => _handleExampleTap('Did I meet my fiber goals in January?'),
                              ),
                              const SizedBox(height: AppSpacing.s),
                              AskAiExampleQuestionCard(
                                label: 'Which days did I consume dairy products?',
                                onTap: () => _handleExampleTap('Which days did I consume dairy products?'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
