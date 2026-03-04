import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/controller/dashboard_controller.dart';
import 'package:diplomka/model/day_record.dart';
import 'package:diplomka/screens/profile/subscreens/confirm_username_screen.dart';
import 'package:diplomka/screens/profile/subscreens/personal_details_screen.dart';
import 'package:diplomka/screens/profile/subscreens/preferences_screen.dart';
import 'package:diplomka/screens/profile/subscreens/language_screen.dart';
import 'package:diplomka/screens/profile/subscreens/edit_nutrition_goals_screen.dart';
import 'package:diplomka/screens/profile/subscreens/weight_history_screen.dart';
import 'package:diplomka/screens/profile/subscreens/ring_colors_explained_screen.dart';
import 'package:diplomka/screens/profile/subscreens/motivational_summary_screen.dart';
import 'package:diplomka/screens/profile/subscreens/tracking_reminders_screen.dart';
import 'package:diplomka/screens/profile/subscreens/export_pdf_intro_screen.dart';
import 'package:diplomka/screens/profile/ask_ai/ask_ai_screen.dart';
import 'package:diplomka/screens/scan/scan_camera_screen.dart';
import 'package:diplomka/screens/scan/scan_onboarding_screen.dart';
import 'package:diplomka/screens/profile/profile_widgets.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:diplomka/widgets/progress_ring.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileGradientScaffold(
      scroll: true,
      safeBottom: false,
      padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.s, AppSpacing.l, AppSpacing.mega + 42),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr(LocaleKeys.profile_title), style: AppTextStyles.h1.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.s),
          const _ProfileHeaderCard(),
          const SizedBox(height: AppSpacing.l),
          ProfileSectionHeader(title: tr(LocaleKeys.profile_account)),
          const SizedBox(height: AppSpacing.s),
          _ProfileGroupCard(
            children: [
              _ProfileActionRow(
                title: tr(LocaleKeys.profile_personal_details),
                icon: Icons.credit_card_outlined,
                onTap: () => Get.to(() => const PersonalDetailsScreen()),
              ),
              _ProfileActionRow(
                title: tr(LocaleKeys.profile_preferences),
                icon: Icons.settings_outlined,
                onTap: () => Get.to(() => const PreferencesScreen()),
              ),
              _ProfileActionRow(
                title: tr(LocaleKeys.profile_language),
                icon: Icons.translate_outlined,
                showDivider: false,
                onTap: () => Get.to(() => const LanguageScreen()),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          ProfileSectionHeader(title: tr(LocaleKeys.profile_goals_tracking)),
          const SizedBox(height: AppSpacing.s),
          _ProfileGroupCard(
            children: [
              _ProfileActionRow(
                title: tr(LocaleKeys.profile_edit_nutrition_goals),
                icon: Icons.gps_fixed,
                onTap: () => Get.to(() => const EditNutritionGoalsScreen()),
              ),
              _ProfileActionRow(
                title: tr(LocaleKeys.profile_weight_history),
                icon: Icons.history,
                onTap: () => Get.to(() => const WeightHistoryScreen()),
              ),
              _ProfileActionRow(
                title: tr(LocaleKeys.profile_tracking_reminders),
                icon: Icons.notifications_none_outlined,
                onTap: () => Get.to(() => const TrackingRemindersScreen()),
              ),
              _ProfileActionRow(
                title: tr(LocaleKeys.profile_motivational_summary),
                icon: Icons.emoji_events_outlined,
                onTap: () => Get.to(() => const MotivationalSummaryScreen()),
              ),
              _ProfileActionRow(
                title: tr(LocaleKeys.profile_ring_colors),
                icon: Icons.brightness_1_outlined,
                showDivider: false,
                onTap: () => Get.to(() => const RingColorsExplainedScreen()),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          ProfileSectionHeader(
            title: tr(LocaleKeys.profile_widgets),
            trailing: Text(
              tr(LocaleKeys.profile_how_to_add),
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          const _WidgetSection(),
          const SizedBox(height: AppSpacing.l),
          ProfileSectionHeader(title: tr(LocaleKeys.profile_progress_data)),
          const SizedBox(height: AppSpacing.s),
          _ProfileGroupCard(
            children: [
              _ProfileActionRow(
                title: tr(LocaleKeys.profile_export_summary),
                icon: Icons.ios_share_outlined,
                onTap: () => Get.to(() => const ExportPdfIntroScreen()),
              ),
              _ProfileActionRow(
                title: tr(LocaleKeys.profile_ask_ai),
                icon: Icons.auto_awesome_outlined,
                showDivider: false,
                onTap: () => Get.to(() => const AskAiScreen()),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          ProfileSectionHeader(title: tr(LocaleKeys.profile_account_actions)),
          const SizedBox(height: AppSpacing.s),
          _ProfileGroupCard(
            children: [
              _ProfileActionRow(
                title: tr(LocaleKeys.profile_logout),
                icon: Icons.logout,
                onTap: () => Get.snackbar(tr(LocaleKeys.profile_logout), tr(LocaleKeys.profile_logout_stub)),
              ),
              _ProfileActionRow(
                title: tr(LocaleKeys.profile_delete_account),
                icon: Icons.person_remove_outlined,
                showDivider: false,
                onTap: () => Get.snackbar(tr(LocaleKeys.profile_delete_account), tr(LocaleKeys.profile_delete_account_stub)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Center(
            child: Text(
              tr(LocaleKeys.profile_version),
              style: AppTextStyles.body13.copyWith(color: AppColors.textTertiary),
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
    return GestureDetector(
      onTap: () => Get.to(() => const ConfirmUsernameScreen()),
      child: Container(
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
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tr(LocaleKeys.profile_username), style: AppTextStyles.title17.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(tr(LocaleKeys.profile_email_placeholder), style: AppTextStyles.body14.copyWith(color: AppColors.textTertiary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textTertiary, size: AppSizes.iconSm),
          ],
        ),
      ),
    );
  }
}

class _ProfileGroupCard extends StatelessWidget {
  const _ProfileGroupCard({
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ProfileCard(
      radius: AppRadii.lg,
      shadow: AppShadows.cardSubtle,
      padding: EdgeInsets.zero,
      child: Column(children: children),
    );
  }
}

class _ProfileActionRow extends StatelessWidget {
  const _ProfileActionRow({
    required this.title,
    required this.icon,
    this.showDivider = true,
    this.onTap,
  });

  final String title;
  final IconData icon;
  final bool showDivider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ProfileSettingsRow(
      title: title,
      leading: Icon(icon, size: AppSizes.iconMd, color: AppColors.textPrimary),
      showDivider: showDivider,
      onTap: onTap,
    );
  }
}

class _WidgetSection extends StatelessWidget {
  const _WidgetSection();

  @override
  Widget build(BuildContext context) {
    final dashboardController = DashboardController.to;
    return Obx(() {
      final record = dashboardController.dayRecord.value ?? DayRecord.initial(dashboardController.selectedDate.value);

      final caloriesText = record.totalCalories.round().toString();
      final proteinText = '${_formatMacro(record.totalProteins)}g';
      final carbsText = '${_formatMacro(record.totalCarbs)}g';
      final fatText = '${_formatMacro(record.totalFats)}g';
      final progress = record.calorieGoal <= 0 ? 0.0 : (record.totalCalories / record.calorieGoal).clamp(0.0, 1.0);

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: ProfileCard(
              radius: AppRadii.lg,
              shadow: AppShadows.cardSubtle,
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Row(
                children: [
                  ProgressRing(
                    size: 96,
                    strokeWidth: 8,
                    value: progress,
                    backgroundColor: AppColors.outline.withValues(alpha: 0.7),
                    foregroundColor: AppColors.primarySoft,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          caloriesText,
                          style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          tr(LocaleKeys.common_calories),
                          style: AppTextStyles.caption12.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _MacroLeftRow(
                          icon: Icons.vpn_key_rounded,
                          color: AppColors.macroProtein,
                          value: proteinText,
                          label: tr(LocaleKeys.dashboard_protein_eaten),
                        ),
                        const SizedBox(height: AppSpacing.s),
                        _MacroLeftRow(
                          icon: Icons.grain,
                          color: AppColors.macroCarbs,
                          value: carbsText,
                          label: tr(LocaleKeys.dashboard_carbs_eaten),
                        ),
                        const SizedBox(height: AppSpacing.s),
                        _MacroLeftRow(
                          icon: Icons.water_drop,
                          color: AppColors.macroFats,
                          value: fatText,
                          label: tr(LocaleKeys.dashboard_fat_eaten),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _WidgetShortcutCard(
                  icon: Icons.center_focus_strong,
                  label: tr(LocaleKeys.profile_scan_food),
                  onTap: () {
                    if (SessionManager.to.scanOnboardingComplete.value) {
                      Get.to(() => const ScanCameraScreen());
                    } else {
                      Get.to(() => const ScanOnboardingScreen());
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.s),
                _WidgetShortcutCard(
                  icon: Icons.qr_code,
                  label: tr(LocaleKeys.profile_barcode),
                  onTap: () => Get.to(() => const ScanCameraScreen(initialMode: ScanMode.barcode)),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  String _formatMacro(double value) {
    return value.toStringAsFixed(0);
  }
}

class _MacroLeftRow extends StatelessWidget {
  const _MacroLeftRow({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: AppSizes.iconSm, color: color),
        const SizedBox(width: AppSpacing.xs),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: AppTextStyles.title17.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              label,
              style: AppTextStyles.caption12.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }
}

class _WidgetShortcutCard extends StatelessWidget {
  const _WidgetShortcutCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ProfileCard(
        radius: AppRadii.lg2,
        shadow: AppShadows.cardSubtle,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xs),
        child: SizedBox(
          height: 62,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: AppSizes.iconMd, color: AppColors.textPrimary),
              const SizedBox(height: AppSpacing.xs),
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption12.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
