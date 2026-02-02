import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/screens/profile/profile_widgets.dart';

class ExportPdfEmailScreen extends StatelessWidget {
  const ExportPdfEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileGradientScaffold(
      scroll: true,
      padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.lg, AppSpacing.screen, AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileBackButton(onPressed: () => Get.back()),
          const SizedBox(height: AppSpacing.lg),
          Text('Enter an email', style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            "We'll send your summary report here. You can send it to yourself or someone else.",
            style: AppTextStyles.body16.copyWith(color: AppColors.textTertiary),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            height: AppSizes.inputHeightLg,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            alignment: Alignment.centerLeft,
            child: Text('Email', style: AppTextStyles.body16.copyWith(color: AppColors.textTertiary)),
          ),
          const Spacer(),
          const ProfilePrimaryButton(
            label: 'Send',
            height: AppSizes.buttonHeightCompact,
          ),
        ],
      ),
    );
  }
}
