import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/controller/ask_ai_controller.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
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
        tr(LocaleKeys.ask_ai_title),
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
          ProfileTopBar(title: tr(LocaleKeys.ask_ai_title), onBack: () => Get.back()),
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
                              AskAiSectionHeader(
                                title: tr(LocaleKeys.ask_ai_example_questions),
                                icon: Icons.question_mark,
                                iconGradient: AppGradients.askAiExample,
                                iconRadius: AppRadii.xs,
                                iconSize: 28,
                              ),
                              const SizedBox(height: AppSpacing.m),
                              AskAiExampleQuestionCard(
                                label: tr(LocaleKeys.ask_ai_example_1),
                                height: 68,
                                onTap: () => _handleExampleTap(tr(LocaleKeys.ask_ai_example_1)),
                              ),
                              const SizedBox(height: AppSpacing.s),
                              AskAiExampleQuestionCard(
                                label: tr(LocaleKeys.ask_ai_example_2),
                                height: 68,
                                onTap: () => _handleExampleTap(tr(LocaleKeys.ask_ai_example_2)),
                              ),
                              const SizedBox(height: AppSpacing.s),
                              AskAiExampleQuestionCard(
                                label: tr(LocaleKeys.ask_ai_example_3),
                                onTap: () => _handleExampleTap(tr(LocaleKeys.ask_ai_example_3)),
                              ),
                              const SizedBox(height: AppSpacing.s),
                              AskAiExampleQuestionCard(
                                label: tr(LocaleKeys.ask_ai_example_4),
                                onTap: () => _handleExampleTap(tr(LocaleKeys.ask_ai_example_4)),
                              ),
                              const SizedBox(height: AppSpacing.s),
                              AskAiExampleQuestionCard(
                                label: tr(LocaleKeys.ask_ai_example_5),
                                onTap: () => _handleExampleTap(tr(LocaleKeys.ask_ai_example_5)),
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
