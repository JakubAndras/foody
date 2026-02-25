import 'package:diplomka/app_theme.dart';
import 'package:diplomka/controller/tracking_reminders_controller.dart';
import 'package:diplomka/model/tracking_reminder_setting.dart';
import 'package:diplomka/screens/profile/profile_widgets.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
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
      padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.l, AppSpacing.screen, AppSpacing.xl),
      child: Obx(() {
        final remindersByType = {
          for (final reminder in controller.reminders) reminder.type: reminder,
        };

        final mealReminders = mealReminderTypes.map((type) => remindersByType[type] ?? TrackingReminderSetting.defaults(type)).toList();
        final endOfDayReminder = remindersByType[endOfDayType] ?? TrackingReminderSetting.defaults(endOfDayType);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileBackButton(onPressed: () => Get.back()),
            const SizedBox(height: AppSpacing.m),
            Text(easy.tr('tracking_reminders.title'), style: AppTextStyles.h1.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.l),
            ProfileCard(
              radius: AppRadii.lg,
              shadow: AppShadows.cardSubtle,
              padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.xs, AppSpacing.screen, AppSpacing.xs),
              child: Column(
                children: [
                  for (int i = 0; i < mealReminders.length; i++)
                    _ReminderRow(
                      title: easy.tr(mealReminders[i].type.titleKey),
                      time: _formatTime(context, mealReminders[i]),
                      isOn: mealReminders[i].enabled,
                      showDivider: i != mealReminders.length - 1,
                      onToggle: () => controller.toggleReminder(mealReminders[i].type, !mealReminders[i].enabled),
                      onTimeTap: () => _pickTime(context, controller, mealReminders[i]),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            ProfileCard(
              radius: AppRadii.lg,
              shadow: AppShadows.cardSubtle,
              padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.m, AppSpacing.screen, AppSpacing.m),
              child: Column(
                children: [
                  _ReminderRow(
                    title: easy.tr(endOfDayReminder.type.titleKey),
                    time: _formatTime(context, endOfDayReminder),
                    isOn: endOfDayReminder.enabled,
                    showDivider: false,
                    onToggle: () => controller.toggleReminder(endOfDayReminder.type, !endOfDayReminder.enabled),
                    onTimeTap: () => _pickTime(context, controller, endOfDayReminder),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      easy.tr('tracking_reminders.end_of_day_hint'),
                      style: AppTextStyles.body13,
                    ),
                  ),
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
                      easy.tr('tracking_reminders.permission_hint'),
                      style: AppTextStyles.body13.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    ProfileOutlineButton(
                      label: easy.tr('tracking_reminders.open_settings'),
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
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: reminder.hour, minute: reminder.minute),
    );
    if (selected != null) {
      await controller.changeReminderTime(reminder.type, selected);
    }
  }
}

class _ReminderRow extends StatelessWidget {
  const _ReminderRow({
    required this.title,
    required this.time,
    required this.isOn,
    this.onToggle,
    this.onTimeTap,
    this.showDivider = true,
  });

  final String title;
  final String time;
  final bool isOn;
  final VoidCallback? onToggle;
  final VoidCallback? onTimeTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: AppSizes.listRowHeight,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.title17.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              GestureDetector(
                onTap: onTimeTap,
                child: ProfileTimeChip(label: time),
              ),
              const SizedBox(width: AppSpacing.s),
              ProfileToggle(isOn: isOn, onTap: onToggle),
            ],
          ),
        ),
        if (showDivider) Divider(height: AppSizes.dividerThin, color: AppColors.surfaceMuted),
      ],
    );
  }
}
