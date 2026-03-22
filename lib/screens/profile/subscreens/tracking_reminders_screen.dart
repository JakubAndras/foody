import 'package:diplomka/app_theme.dart';
import 'package:diplomka/controller/tracking_reminders_controller.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/tracking_reminder_setting.dart';
import 'package:diplomka/screens/profile/profile_widgets.dart';
import 'package:diplomka/widgets/glass_toggle_row.dart';
import 'package:diplomka/widgets/time_picker_sheet.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TrackingRemindersScreen extends StatelessWidget {
  const TrackingRemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TrackingRemindersController.to;
    final mealReminderTypes = [
      TrackingReminderType.breakfast,
      TrackingReminderType.lunch,
      TrackingReminderType.snack,
      TrackingReminderType.dinner,
    ];
    const endOfDayType = TrackingReminderType.endOfDay;

    return ProfileGradientScaffold(
      scroll: true,
      padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, AppSpacing.xl),
      child: Obx(() {
        if (!controller.isLoaded.value) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileTopBar(title: tr(LocaleKeys.tracking_reminders_title), onBack: () => Get.back()),
            ],
          );
        }

        final remindersByType = {
          for (final reminder in controller.reminders) reminder.type: reminder,
        };

        final mealReminders = mealReminderTypes.map((type) => remindersByType[type] ?? TrackingReminderSetting.defaults(type)).toList();
        final endOfDayReminder = remindersByType[endOfDayType] ?? TrackingReminderSetting.defaults(endOfDayType);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileTopBar(title: tr(LocaleKeys.tracking_reminders_title), onBack: () => Get.back()),
            const SizedBox(height: AppSpacing.l),
            ProfileCard(
              radius: AppRadii.l,
              shadow: AppShadows.cardSubtle,
              padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.xs, AppSpacing.screen, AppSpacing.xs),
              child: Column(
                children: [
                  for (int i = 0; i < mealReminders.length; i++)
                    GlassToggleRow(
                      title: tr(mealReminders[i].type.titleKey),
                      isOn: mealReminders[i].enabled,
                      showDivider: i != mealReminders.length - 1,
                      onChanged: (val) => controller.toggleReminder(mealReminders[i].type, val),
                      trailing: GestureDetector(
                        onTap: () => _pickTime(context, controller, mealReminders[i]),
                        child: ProfileTimeChip(label: _formatTime(context, mealReminders[i])),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            ProfileCard(
              radius: AppRadii.l,
              shadow: AppShadows.cardSubtle,
              padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.xs, AppSpacing.screen, AppSpacing.xs),
              child: Column(
                children: [
                  GlassToggleRow(
                    title: tr(endOfDayReminder.type.titleKey),
                    isOn: endOfDayReminder.enabled,
                    showDivider: false,
                    onChanged: (val) => controller.toggleReminder(endOfDayReminder.type, val),
                    trailing: GestureDetector(
                      onTap: () => _pickTime(context, controller, endOfDayReminder),
                      child: ProfileTimeChip(label: _formatTime(context, endOfDayReminder)),
                    ),
                  ),
                ],
              ),
            ),
            if (controller.notificationPermissionDenied.value) ...[
              const SizedBox(height: AppSpacing.l),
              ProfileCard(
                radius: AppRadii.l,
                shadow: AppShadows.cardSubtle,
                padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.m, AppSpacing.screen, AppSpacing.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr(LocaleKeys.tracking_reminders_permission_hint),
                      style: AppTextStyles.body13.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    ProfileOutlineButton(
                      label: tr(LocaleKeys.tracking_reminders_open_settings),
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

  String _formatTime(BuildContext context, TrackingReminderSetting setting) {
    return MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay(hour: setting.hour, minute: setting.minute),
      alwaysUse24HourFormat: MediaQuery.of(context).alwaysUse24HourFormat,
    );
  }

  Future<void> _pickTime(
    BuildContext context,
    TrackingRemindersController controller,
    TrackingReminderSetting reminder,
  ) async {
    final selected = await showTimePickerSheet(
      context: context,
      title: tr(reminder.type.titleKey),
      initialTime: TimeOfDay(hour: reminder.hour, minute: reminder.minute),
    );
    if (selected != null) {
      await controller.changeReminderTime(reminder.type, selected);
    }
  }
}

