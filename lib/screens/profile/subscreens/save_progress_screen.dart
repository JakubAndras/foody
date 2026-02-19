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
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: ProfileBackButton(onPressed: () => Get.back()),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Save your progress',
            textAlign: TextAlign.center,
            style: AppTextStyles.h1.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            'Sign in with Apple or Google to save your data to the cloud and access it from any device.\n\nOr skip this step to save your data locally on your phone only.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body15.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.xl),
          ProfilePrimaryButton(
            label: 'Sign in with Apple',
            leading: const Icon(Icons.apple, color: AppColors.onPrimary, size: AppSizes.iconMd),
            height: AppSizes.buttonHeight,
          ),
          const SizedBox(height: AppSpacing.m),
          ProfileOutlineButton(
            label: 'Sign in with Google',
            leading: SizedBox(
              width: AppSizes.iconLg,
              height: AppSizes.iconLg,
              child: Image.asset('assets/images/google_icon.png'),
            ),
            height: AppSizes.buttonHeight,
          ),
          const Spacer(),
          const ProfilePrimaryButton(
            label: 'Skip',
            height: AppSizes.buttonHeight,
          ),
        ],
      ),
    );
  }
}
