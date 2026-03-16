import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
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
      padding: const EdgeInsets.fromLTRB(AppSpacing.l, 0, AppSpacing.l, AppSpacing.xl),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width - (AppSpacing.l * 2),
        child: ProfilePrimaryButton(
          label: tr(LocaleKeys.common_continue_btn),
          height: AppSizes.buttonHeightCompact,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileTopBar(title: tr(LocaleKeys.onboarding_confirm_username_title), onBack: () => Get.back()),
          const SizedBox(height: AppSpacing.m),
          const SizedBox(height: AppSpacing.xs),
          Text(
            tr(LocaleKeys.onboarding_confirm_username_subtitle),
            style: AppTextStyles.body16.copyWith(color: AppColors.textTertiary, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: AppSpacing.l),
          Container(
            height: AppSizes.inputHeightMd,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: AppColors.borderStrong),
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
            alignment: Alignment.centerLeft,
            child: Text(
              tr(LocaleKeys.onboarding_your_username),
              style: AppTextStyles.body16.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: AppSpacing.mega + AppSizes.buttonHeightCompact),
        ],
      ),
    );
  }
}
