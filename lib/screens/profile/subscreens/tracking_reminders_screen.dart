import 'package:diplomka/app_theme.dart';
import 'package:diplomka/state/tracking_reminders_notifier.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/tracking_reminder_setting.dart';
import 'package:diplomka/screens/profile/profile_widgets.dart';
import 'package:diplomka/widgets/glass_toggle_row.dart';
import 'package:diplomka/widgets/time_picker_sheet.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TrackingRemindersScreen extends ConsumerWidget {
  const TrackingRemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(trackingRemindersProvider);
    final notifier = ref.read(trackingRemindersProvider.notifier);
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
      child: Builder(
        builder: (context) {
          if (!state.isLoaded) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileTopBar(title: tr(LocaleKeys.tracking_reminders_title), onBack: () => Navigator.of(context).pop()),
              ],
            );
          }

          final remindersByType = {
            for (final reminder in state.reminders) reminder.type: reminder,
          };

          final mealReminders = mealReminderTypes.map((type) => remindersByType[type] ?? TrackingReminderSetting.defaults(type)).toList();
          final endOfDayReminder = remindersByType[endOfDayType] ?? TrackingReminderSetting.defaults(endOfDayType);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileTopBar(title: tr(LocaleKeys.tracking_reminders_title), onBack: () => Navigator.of(context).pop()),
              const SizedBox(height: AppSpacing.m),
              ProfileCard(
                radius: AppRadii.l,
                shadow: AppShadows.screenCard,
                padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.xs, AppSpacing.screen, AppSpacing.xs),
                child: Column(
                  children: [
                    for (int i = 0; i < mealReminders.length; i++)
                      GlassToggleRow(
                        title: tr(mealReminders[i].type.titleKey),
                        isOn: mealReminders[i].enabled,
                        showDivider: i != mealReminders.length - 1,
                        onChanged: (val) => notifier.toggleReminder(mealReminders[i].type, val),
                        trailing: GestureDetector(
                          onTap: () => _pickTime(context, notifier, mealReminders[i]),
                          child: ProfileTimeChip(label: _formatTime(context, mealReminders[i])),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.l),
              ProfileCard(
                radius: AppRadii.l,
                shadow: AppShadows.screenCard,
                padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.xs, AppSpacing.screen, AppSpacing.xs),
                child: Column(
                  children: [
                    GlassToggleRow(
                      title: tr(endOfDayReminder.type.titleKey),
                      isOn: endOfDayReminder.enabled,
                      showDivider: false,
                      onChanged: (val) => notifier.toggleReminder(endOfDayReminder.type, val),
                      trailing: GestureDetector(
                        onTap: () => _pickTime(context, notifier, endOfDayReminder),
                        child: ProfileTimeChip(label: _formatTime(context, endOfDayReminder)),
                      ),
                    ),
                  ],
                ),
              ),
              if (state.notificationPermissionDenied) ...[
                const SizedBox(height: AppSpacing.l),
                ProfileCard(
                  radius: AppRadii.l,
                  shadow: AppShadows.screenCard,
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
                        onPressed: notifier.openSystemNotificationSettings,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
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
    TrackingRemindersNotifier notifier,
    TrackingReminderSetting reminder,
  ) async {
    final selected = await showTimePickerSheet(
      context: context,
      title: tr(reminder.type.titleKey),
      initialTime: TimeOfDay(hour: reminder.hour, minute: reminder.minute),
    );
    if (selected != null) {
      await notifier.changeReminderTime(reminder.type, selected);
    }
  }
}
