import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/screens/profile/profile_widgets.dart';

class ConfirmUsernameScreen extends StatelessWidget {
  const ConfirmUsernameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileGradientScaffold(
      scroll: true,
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileBackButton(onPressed: () => Get.back()),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Confirm your username',
            style: AppTextStyles.h1.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'This is the name others will see in groups.',
            style: AppTextStyles.body16.copyWith(color: AppColors.textTertiary, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            height: AppSizes.inputHeightMd,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: AppColors.borderStrong),
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            alignment: Alignment.centerLeft,
            child: Text(
              'Your username',
              style: AppTextStyles.body16.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          const Spacer(),
          const ProfilePrimaryButton(
            label: 'Continue',
            height: AppSizes.buttonHeightCompact,
          ),
        ],
      ),
    );
  }
}
