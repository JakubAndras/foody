import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/screens/profile/subscreens/confirm_username_screen.dart';
import 'package:diplomka/screens/profile/subscreens/save_progress_screen.dart';
import 'package:diplomka/screens/profile/subscreens/personal_details_screen.dart';
import 'package:diplomka/screens/profile/subscreens/preferences_screen.dart';
import 'package:diplomka/screens/profile/subscreens/edit_nutrition_goals_screen.dart';
import 'package:diplomka/screens/profile/subscreens/tracking_reminders_screen.dart';
import 'package:diplomka/screens/profile/subscreens/weight_history_screen.dart';
import 'package:diplomka/screens/profile/subscreens/ring_colors_explained_screen.dart';
import 'package:diplomka/screens/profile/subscreens/export_pdf_intro_screen.dart';
import 'package:diplomka/screens/profile/ask_ai/ask_ai_screen.dart';
import 'package:diplomka/screens/profile/profile_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileGradientScaffold(
      scroll: true,
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.huge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Profile', style: AppTextStyles.h1.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.lg),
          const _ProfileHeaderCard(),
          const SizedBox(height: AppSpacing.lg),
          const ProfileSectionHeader(title: 'AI Tools'),
          const SizedBox(height: AppSpacing.sm),
          ProfileCard(
            radius: AppRadii.lg,
            shadow: AppShadows.cardSubtle,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ProfileSettingsRow(
                  title: 'Ask AI',
                  leading: const Icon(Icons.auto_awesome_outlined, size: AppSizes.iconMd, color: AppColors.textPrimary),
                  showDivider: false,
                  onTap: () => Get.to(() => const AskAiScreen()),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const ProfileSectionHeader(title: 'Account'),
          const SizedBox(height: AppSpacing.sm),
          ProfileCard(
            radius: AppRadii.lg,
            shadow: AppShadows.cardSubtle,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ProfileSettingsRow(
                  title: 'Confirm username',
                  leading: const Icon(Icons.badge_outlined, size: AppSizes.iconMd, color: AppColors.textPrimary),
                  onTap: () => Get.to(() => const ConfirmUsernameScreen()),
                ),
                ProfileSettingsRow(
                  title: 'Save your progress',
                  leading: const Icon(Icons.cloud_outlined, size: AppSizes.iconMd, color: AppColors.textPrimary),
                  onTap: () => Get.to(() => const SaveProgressScreen()),
                ),
                ProfileSettingsRow(
                  title: 'Personal Details',
                  leading: const Icon(Icons.person_outline, size: AppSizes.iconMd, color: AppColors.textPrimary),
                  onTap: () => Get.to(() => const PersonalDetailsScreen()),
                ),
                ProfileSettingsRow(
                  title: 'Preferences',
                  leading: const Icon(Icons.tune, size: AppSizes.iconMd, color: AppColors.textPrimary),
                  showDivider: false,
                  onTap: () => Get.to(() => const PreferencesScreen()),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const ProfileSectionHeader(title: 'Goals & Tracking'),
          const SizedBox(height: AppSpacing.sm),
          ProfileCard(
            radius: AppRadii.lg,
            shadow: AppShadows.cardSubtle,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ProfileSettingsRow(
                  title: 'Edit Nutrition Goals',
                  leading: const Icon(Icons.flag_outlined, size: AppSizes.iconMd, color: AppColors.textPrimary),
                  onTap: () => Get.to(() => const EditNutritionGoalsScreen()),
                ),
                ProfileSettingsRow(
                  title: 'Tracking Reminders',
                  leading: const Icon(Icons.notifications_outlined, size: AppSizes.iconMd, color: AppColors.textPrimary),
                  onTap: () => Get.to(() => const TrackingRemindersScreen()),
                ),
                ProfileSettingsRow(
                  title: 'Weight History',
                  leading: const Icon(Icons.monitor_weight_outlined, size: AppSizes.iconMd, color: AppColors.textPrimary),
                  onTap: () => Get.to(() => const WeightHistoryScreen()),
                ),
                ProfileSettingsRow(
                  title: 'Ring Colors Explained',
                  leading: const Icon(Icons.palette_outlined, size: AppSizes.iconMd, color: AppColors.textPrimary),
                  showDivider: false,
                  onTap: () => Get.to(() => const RingColorsExplainedScreen()),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const ProfileSectionHeader(title: 'Progress Data'),
          const SizedBox(height: AppSpacing.sm),
          ProfileCard(
            radius: AppRadii.lg,
            shadow: AppShadows.cardSubtle,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ProfileSettingsRow(
                  title: 'Export PDF summary report',
                  leading: const Icon(Icons.picture_as_pdf_outlined, size: AppSizes.iconMd, color: AppColors.textPrimary),
                  showDivider: false,
                  onTap: () => Get.to(() => const ExportPdfIntroScreen()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.profileHeaderHeight,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: AppShadows.cardSubtle,
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
      child: Row(
        children: [
          Container(
            width: AppSizes.avatarSize,
            height: AppSizes.avatarSize,
            decoration: const BoxDecoration(
              color: AppColors.avatarPurple,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('E', style: AppTextStyles.h3.copyWith(color: AppColors.onPrimary)),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Username', style: AppTextStyles.title17.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: AppSpacing.xxs),
                Text('example@gmail.com', style: AppTextStyles.body14.copyWith(color: AppColors.textTertiary)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textTertiary, size: AppSizes.iconSm),
        ],
      ),
    );
  }
}
