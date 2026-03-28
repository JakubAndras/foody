import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/ask_ai_query_response.dart';
import 'package:diplomka/screens/dashboard_screen.dart';
import 'package:diplomka/screens/profile/ask_ai/ask_ai_widgets.dart' show AskAiResponseCard, AskAiSummaryCard, AskAiCalendarCard, AskAiPrimaryButton;
import 'package:diplomka/screens/profile/profile_widgets.dart';
import 'package:diplomka/services/share/app_share_service.dart';
import 'package:get/get.dart';

class AskAiResponseScreen extends StatelessWidget {
  const AskAiResponseScreen({
    super.key,
    required this.response,
    required this.query,
  });

  final AskAiQueryResponse response;
  final String query;

  Future<void> _handleShare(BuildContext context) async {
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
      Get.snackbar(
        tr(LocaleKeys.ask_ai_share_unavailable),
        tr(LocaleKeys.ask_ai_share_error),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProfileGradientScaffold(
      scroll: true,
      padding: const EdgeInsets.fromLTRB(AppSpacing.m, 0, AppSpacing.m, AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileTopBar(title: tr(LocaleKeys.ask_ai_title), onBack: () => Get.back()),
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
              leading: const Icon(CupertinoIcons.share, size: AppSizes.iconMd, color: AppColors.onPrimary),
              gradient: AppGradients.primary,
              onPressed: () => _handleShare(context),
            ),
          ),
        ],
      ),
    );
  }
}
