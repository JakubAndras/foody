import 'package:diplomka/app_theme.dart';
import 'package:diplomka/controller/motivational_summary_controller.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/motivational_summary_setting.dart';
import 'package:diplomka/screens/profile/profile_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MotivationalSummaryScreen extends StatelessWidget {
  const MotivationalSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MotivationalSummaryController.to;

    return ProfileGradientScaffold(
      scroll: true,
      padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.l, AppSpacing.screen, AppSpacing.xl),
      child: Obx(() {
        final settingsByType = {
          for (final s in controller.summaries) s.type: s,
        };

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileTopBar(title: tr(LocaleKeys.motivational_summary_title), onBack: () => Get.back()),
            const SizedBox(height: AppSpacing.l),
            ProfileCard(
              radius: AppRadii.lg,
              shadow: AppShadows.cardSubtle,
              padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.m, AppSpacing.screen, AppSpacing.m),
              child: Text(
                tr(LocaleKeys.motivational_summary_description),
                style: AppTextStyles.body13.copyWith(color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            ProfileCard(
              radius: AppRadii.lg,
              shadow: AppShadows.cardSubtle,
              padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.xs, AppSpacing.screen, AppSpacing.xs),
              child: Column(
                children: [
                  for (int i = 0; i < MotivationalSummaryType.values.length; i++) ...[
                    _buildSummaryRow(
                      context,
                      controller,
                      settingsByType[MotivationalSummaryType.values[i]] ?? MotivationalSummarySetting.defaults(MotivationalSummaryType.values[i]),
                      showDivider: i != MotivationalSummaryType.values.length - 1,
                    ),
                  ],
                ],
              ),
            ),
            if (controller.notificationPermissionDenied.value) ...[
              const SizedBox(height: AppSpacing.l),
              ProfileCard(
                radius: AppRadii.lg,
                shadow: AppShadows.cardSubtle,
                padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.m, AppSpacing.screen, AppSpacing.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr(LocaleKeys.motivational_summary_permission_hint),
                      style: AppTextStyles.body13.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    ProfileOutlineButton(
                      label: tr(LocaleKeys.motivational_summary_open_settings),
                      onPressed: controller.openSystemNotificationSettings,
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      }),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    MotivationalSummaryController controller,
    MotivationalSummarySetting setting, {
    bool showDivider = true,
  }) {
    final timeStr = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay(hour: setting.hour, minute: setting.minute),
      alwaysUse24HourFormat: MediaQuery.of(context).alwaysUse24HourFormat,
    );

    return Column(
      children: [
        SizedBox(
          height: AppSizes.listRowHeight,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  tr(setting.type.titleKey),
                  style: AppTextStyles.title17.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              GestureDetector(
                onTap: () => _pickTime(context, controller, setting),
                child: ProfileTimeChip(label: timeStr),
              ),
              const SizedBox(width: AppSpacing.s),
              ProfileToggle(
                isOn: setting.enabled,
                onTap: () => controller.toggleSummary(setting.type, !setting.enabled),
              ),
            ],
          ),
        ),
        if (showDivider) Divider(height: AppSizes.dividerThin, color: AppColors.surfaceMuted),
      ],
    );
  }

  Future<void> _pickTime(
    BuildContext context,
    MotivationalSummaryController controller,
    MotivationalSummarySetting setting,
  ) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: setting.hour, minute: setting.minute),
    );
    if (selected != null) {
      await controller.changeSummaryTime(setting.type, selected);
    }
  }
}
