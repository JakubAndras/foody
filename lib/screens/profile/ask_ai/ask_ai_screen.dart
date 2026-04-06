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
import 'package:diplomka/model/ask_ai_query_response.dart';
import 'package:diplomka/screens/dashboard_screen.dart';
import 'package:diplomka/screens/profile/ask_ai/ask_ai_widgets.dart';
import 'package:diplomka/screens/profile/profile_widgets.dart';
import 'package:diplomka/services/share/app_share_service.dart';
import 'package:diplomka/widgets/variable_blur_scroll_view.dart';
import 'package:diplomka/widgets/mesh_gradient_background.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

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
    if (result == null && _controller.errorMessage.value != null) {
      showSnackBar(
        context: context,
        message: tr(LocaleKeys.ask_ai_title),
        subtitle: _controller.errorMessage.value!,
        type: SnackBarType.error,
      );
    }
  }

  void _clearResponse() {
    _controller.clearResponse();
    _textController.clear();
  }

  Future<void> _handleShare() async {
    final response = _controller.response.value;
    final query = _controller.lastQuery.value;
    if (response == null) return;

    final text = [
      tr(LocaleKeys.ask_ai_title),
      '',
      '${tr(LocaleKeys.ask_ai_question_label)}: $query',
      '',
      '${tr(LocaleKeys.ask_ai_summary_label)}: ${response.summaryValue} ${response.summaryLabel}',
      '${tr(LocaleKeys.ask_ai_period_label)}: ${response.periodLabel}',
      if (response.primaryMonthDays.isNotEmpty) '${tr(LocaleKeys.ask_ai_affected_days_label)}: ${response.primaryMonthDays.join(', ')}',
      '',
      response.responseText,
    ].join('\n');

    try {
      await AppShareService.shareText(
        text: text,
        title: tr(LocaleKeys.ask_ai_title),
        subject: tr(LocaleKeys.ask_ai_share_subject),
        context: context,
      );
    } catch (_) {
      showSnackBar(
        context: context,
        message: tr(LocaleKeys.ask_ai_share_unavailable),
        subtitle: tr(LocaleKeys.ask_ai_share_error),
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
      barrierColor: AppColors.overlayDark40,
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
    return LiquidGlassScope(
      child: Scaffold(
        backgroundColor: AppColors.meshBase,
        body: Stack(
          children: [
            VariableBlurScrollView(
              topBlurSigma: 52,
              topFadeHeight: 40,
              bottomFadeHeight: 0,
              backgroundColor: Colors.transparent,
              fadeColor: AppColors.meshBase,
              backgroundWidget: const MeshGradientBackground(),
              padding: EdgeInsets.fromLTRB(AppSpacing.m, AppSpacing.mega + AppSpacing.s, AppSpacing.m, AppSpacing.xl),
              child: Obx(() {
                final response = _controller.response.value;
                final loading = _controller.isLoading.value;

                if (response != null) {
                  return _buildResponseContent(response);
                }

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
                    if (loading) ...[
                      const SizedBox(height: AppSpacing.m),
                      const AskAiLoadingSkeleton(),
                    ],
                  ],
                );
              }),
            ),
            Positioned(
              top: 0,
              left: AppSpacing.m,
              right: AppSpacing.m,
              child: Obx(() {
                final hasResponse = _controller.response.value != null;
                return ProfileTopBar(
                  title: tr(LocaleKeys.ask_ai_title),
                  onBack: () => Get.back(),
                  actions: [
                    if (hasResponse)
                      CustomGlassIconButtonGroup(
                        items: [
                          (icon: CupertinoIcons.arrow_counterclockwise, onPressed: _clearResponse),
                          (icon: CupertinoIcons.info_circle, onPressed: _showExampleQuestionsSheet),
                        ],
                      )
                    else
                      CustomGlassIconButton(
                        icon: CupertinoIcons.info_circle,
                        onPressed: _showExampleQuestionsSheet,
                      ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponseContent(AskAiQueryResponse response) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.m),
        AskAiResponseCard(text: response.responseText),
        const SizedBox(height: AppSpacing.m),
        AskAiSummaryCard(
          value: response.summaryValue,
          label: response.summaryLabel,
          icon: response.summaryIcon,
          iconGradient: response.summaryGradient,
          panelGradient: response.summarySurfaceGradient,
          valueGradient: response.summaryGradient,
        ),
        if (response.affectedDays.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.m),
          AskAiCalendarCard(
            allAffectedDays: response.affectedDays,
            affectedGradient: response.summaryGradient,
            initialYear: response.primaryYear,
            initialMonth: response.primaryMonth,
            onDayTap: (date) => Get.to(() => DashboardPreviewScreen(date: date)),
          ),
        ],
        const SizedBox(height: AppSpacing.m),
        SizedBox(
          width: double.infinity,
          child: AskAiPrimaryButton(
            label: tr(LocaleKeys.common_share),
            leading: Icon(CupertinoIcons.share, size: AppSizes.iconMd, color: AppColors.onPrimary),
            gradient: AppGradients.primary,
            onPressed: _handleShare,
          ),
        ),
      ],
    );
  }
}
