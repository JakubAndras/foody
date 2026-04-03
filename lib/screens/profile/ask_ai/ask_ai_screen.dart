import 'package:diplomka/widgets/custom_glass_app_bar.dart';
import 'package:diplomka/widgets/logged_snackbar.dart';
import 'package:diplomka/widgets/sheet_drag_handle.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
      showSnackBar(
        context: context,
        message: tr(LocaleKeys.ask_ai_title),
        subtitle: _controller.errorMessage.value!,
        type: SnackBarType.error,
      );
    }
  }

  void _handleExampleTap(String question) {
    Navigator.of(context).pop();
    _textController.text = question;
    _handleAsk();
  }

  void _showExampleQuestionsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: AppColors.overlayDark,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppRadii.xxl),
              topRight: Radius.circular(AppRadii.xxl),
              bottomLeft: Radius.circular(AppRadii.xxl + 10),
              bottomRight: Radius.circular(AppRadii.xxl + 10),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.xxs, AppSpacing.l, AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SheetDragHandle(color: AppColors.textTertiary.withValues(alpha: 0.3)),
              const SizedBox(height: AppSpacing.l),
              AskAiSectionHeader(
                title: tr(LocaleKeys.ask_ai_example_questions),
                icon: CupertinoIcons.question,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProfileGradientScaffold(
      scroll: false,
      padding: const EdgeInsets.only(left: AppSpacing.m, right: AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileTopBar(
            title: tr(LocaleKeys.ask_ai_title),
            onBack: () => Get.back(),
            actions: [
              CustomGlassIconButton(
                icon: CupertinoIcons.info_circle,
                onPressed: _showExampleQuestionsSheet,
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Obx(() {
                final loading = _controller.isLoading.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.s),
                    AskAiPromptCard(
                      controller: _textController,
                      isLoading: loading,
                      onAsk: _handleAsk,
                      onClear: () => _textController.clear(),
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
