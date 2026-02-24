import 'package:flutter/material.dart';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/screens/profile/ask_ai/ask_ai_widgets.dart';
import 'package:diplomka/screens/profile/profile_widgets.dart';
import 'package:diplomka/services/share/app_share_service.dart';
import 'package:get/get.dart';

enum AskAiResponseVariant {
  violations,
  achieved,
  tracked,
}

class AskAiResponseScreen extends StatelessWidget {
  const AskAiResponseScreen({super.key, required this.variant});

  final AskAiResponseVariant variant;

  Future<void> _handleShare(BuildContext context, _AskAiVariantData data) async {
    final text = _buildShareText(data);
    try {
      await AppShareService.shareText(
        text: text,
        title: 'Ask AI insight',
        subject: 'Nutrition insight',
        context: context,
      );
    } catch (_) {
      Get.snackbar(
        'Share unavailable',
        'Unable to open the share sheet right now.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  String _buildShareText(_AskAiVariantData data) {
    return [
      'Ask AI nutrition insight',
      '',
      'Summary: ${data.summaryValue} ${data.summaryLabel}',
      'Period: ${data.monthLabel}',
      'Affected days: ${data.affectedDays.join(', ')}',
      '',
      data.responseText,
    ].join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final data = _AskAiVariantData.fromVariant(variant);

    return ProfileGradientScaffold(
      scroll: true,
      padding: const EdgeInsets.fromLTRB(AppSpacing.m, AppSpacing.l, AppSpacing.m, AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AskAiTopBar(),
          const SizedBox(height: AppSpacing.m),
          const AskAiPromptCard(),
          const SizedBox(height: AppSpacing.l),
          AskAiResponseCard(text: data.responseText),
          const SizedBox(height: AppSpacing.m),
          AskAiSummaryCard(
            value: data.summaryValue,
            label: data.summaryLabel,
            icon: data.summaryIcon,
            iconGradient: data.summaryGradient,
            panelGradient: data.summarySurfaceGradient,
            valueGradient: data.summaryGradient,
          ),
          const SizedBox(height: AppSpacing.m),
          AskAiCalendarCard(
            affectedDays: data.affectedDays,
            affectedGradient: data.summaryGradient,
            monthLabel: data.monthLabel,
            year: data.year,
            month: data.month,
          ),
          const SizedBox(height: AppSpacing.m),
          Row(
            children: [
              Expanded(
                child: _SecondaryActionButton(
                  label: 'Export CSV',
                  icon: Icons.file_download_outlined,
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: AskAiPrimaryButton(
                  label: 'Share',
                  leading: const Icon(Icons.share, size: AppSizes.iconMd, color: AppColors.onPrimary),
                  gradient: AppGradients.primary,
                  onPressed: () => _handleShare(context, data),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AskAiViolationsScreen extends StatelessWidget {
  const AskAiViolationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AskAiResponseScreen(variant: AskAiResponseVariant.violations);
  }
}

class AskAiAchievedScreen extends StatelessWidget {
  const AskAiAchievedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AskAiResponseScreen(variant: AskAiResponseVariant.achieved);
  }
}

class AskAiTrackedScreen extends StatelessWidget {
  const AskAiTrackedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AskAiResponseScreen(variant: AskAiResponseVariant.tracked);
  }
}

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.askAiActionHeight,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.md),
          onTap: () {},
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.md),
              boxShadow: AppShadows.cardSubtle,
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: AppSizes.iconMd, color: AppColors.textPrimary),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    label,
                    style: AppTextStyles.body15.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AskAiVariantData {
  const _AskAiVariantData({
    required this.responseText,
    required this.summaryLabel,
    required this.summaryValue,
    required this.summaryIcon,
    required this.summaryGradient,
    required this.summarySurfaceGradient,
    required this.affectedDays,
    required this.monthLabel,
    required this.year,
    required this.month,
  });

  final String responseText;
  final String summaryLabel;
  final int summaryValue;
  final IconData summaryIcon;
  final LinearGradient summaryGradient;
  final LinearGradient summarySurfaceGradient;
  final List<int> affectedDays;
  final String monthLabel;
  final int year;
  final int month;

  static _AskAiVariantData fromVariant(AskAiResponseVariant variant) {
    switch (variant) {
      case AskAiResponseVariant.violations:
        return _AskAiVariantData(
          responseText:
              'Based on your dietary history, you violated your gluten-free restriction on 3 occasions in the past 30 days. The violations occurred when you consumed bread at breakfast and pasta at dinner.',
          summaryLabel: 'Violations found',
          summaryValue: 3,
          summaryIcon: Icons.report_gmailerrorred_outlined,
          summaryGradient: AppGradients.askAiDanger,
          summarySurfaceGradient: AppGradients.askAiDangerSurface,
          affectedDays: const [5, 12, 18],
          monthLabel: 'January 2026',
          year: 2026,
          month: 1,
        );
      case AskAiResponseVariant.achieved:
        return _AskAiVariantData(
          responseText:
              'Your average protein intake last week was 142g per day, which is 95% of your daily goal of 150g. You met your protein target on 5 out of 7 days.',
          summaryLabel: 'Days achieved',
          summaryValue: 5,
          summaryIcon: Icons.check_circle_outline,
          summaryGradient: AppGradients.askAiSuccess,
          summarySurfaceGradient: AppGradients.askAiSuccessSurface,
          affectedDays: const [6, 7, 8, 10, 11],
          monthLabel: 'January 2026',
          year: 2026,
          month: 1,
        );
      case AskAiResponseVariant.tracked:
        return _AskAiVariantData(
          responseText:
              'You consumed dairy products on 8 days this month. The most common dairy items were milk in coffee, yogurt at breakfast, and cheese in dinner meals.',
          summaryLabel: 'Days tracked',
          summaryValue: 8,
          summaryIcon: Icons.info_outline,
          summaryGradient: AppGradients.askAiWarning,
          summarySurfaceGradient: AppGradients.askAiWarningSurface,
          affectedDays: const [2, 4, 7, 9, 11, 13, 15, 17],
          monthLabel: 'January 2026',
          year: 2026,
          month: 1,
        );
    }
  }
}
