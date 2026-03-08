import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/screens/profile/profile_widgets.dart';

class SaveProgressScreen extends StatelessWidget {
  const SaveProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileGradientScaffold(
      scroll: true,
      padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.l, AppSpacing.screen, AppSpacing.xl),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width - (AppSpacing.screen * 2),
        child: ProfilePrimaryButton(
          label: tr(LocaleKeys.common_skip),
          height: AppSizes.buttonHeight,
        ),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: ProfileBackButton(onPressed: () => Get.back()),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            tr(LocaleKeys.onboarding_save_progress_title),
            textAlign: TextAlign.center,
            style: AppTextStyles.h1.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            '${tr(LocaleKeys.onboarding_save_progress_subtitle)}\n\n${tr(LocaleKeys.onboarding_save_progress_local)}',
            textAlign: TextAlign.center,
            style: AppTextStyles.body15.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.xl),
          ProfilePrimaryButton(
            label: tr(LocaleKeys.onboarding_sign_in_apple),
            leading: const Icon(Icons.apple, color: AppColors.onPrimary, size: AppSizes.iconMd),
            height: AppSizes.buttonHeight,
          ),
          const SizedBox(height: AppSpacing.m),
          ProfileOutlineButton(
            label: tr(LocaleKeys.onboarding_sign_in_google),
            leading: SizedBox(
              width: AppSizes.iconLg,
              height: AppSizes.iconLg,
              child: Image.asset('assets/images/google_icon.png'),
            ),
            height: AppSizes.buttonHeight,
          ),
          const SizedBox(height: AppSpacing.mega + AppSizes.buttonHeight),
        ],
      ),
    );
  }
}
