import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/screens/profile/subscreens/export_pdf_email_screen.dart';
import 'package:diplomka/screens/profile/profile_widgets.dart';

class ExportPdfDateRangeScreen extends StatelessWidget {
  const ExportPdfDateRangeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileGradientScaffold(
      scroll: true,
      padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.l, AppSpacing.screen, AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileBackButton(onPressed: () => Get.back()),
          const SizedBox(height: AppSpacing.l),
          Text('Select date range', style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.xs),
          Text('Choose the time range for your report.', style: AppTextStyles.body16.copyWith(color: AppColors.textTertiary)),
          const SizedBox(height: AppSpacing.l),
          const _DateRangeButton(label: 'Last 7 Days', isSelected: true),
          const SizedBox(height: AppSpacing.m),
          const _DateRangeButton(label: 'Last 30 Days'),
          const SizedBox(height: AppSpacing.m),
          const _DateRangeButton(label: 'All Time'),
          const SizedBox(height: AppSpacing.m),
          const _DateRangeButton(label: 'Custom Date Range'),
          const Spacer(),
          ProfilePrimaryButton(
            label: 'Next',
            height: AppSizes.buttonHeightCompact,
            onPressed: () => Get.to(() => const ExportPdfEmailScreen()),
          ),
        ],
      ),
    );
  }
}

class _DateRangeButton extends StatelessWidget {
  const _DateRangeButton({required this.label, this.isSelected = false});

  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.inputHeightLg,
      decoration: BoxDecoration(
        color: isSelected ? null : AppColors.surfaceSubtle,
        gradient: isSelected ? AppGradients.primary : null,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: AppTextStyles.body16.copyWith(
          fontWeight: FontWeight.w600,
          color: isSelected ? AppColors.onPrimary : AppColors.textPrimary,
        ),
      ),
    );
  }
}
