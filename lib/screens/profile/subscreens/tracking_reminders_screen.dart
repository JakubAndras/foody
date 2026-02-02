import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/screens/profile/profile_widgets.dart';

class TrackingRemindersScreen extends StatelessWidget {
  const TrackingRemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileGradientScaffold(
      scroll: true,
      padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.lg, AppSpacing.screen, AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileBackButton(onPressed: () => Get.back()),
          const SizedBox(height: AppSpacing.md),
          Text('Tracking Reminders', style: AppTextStyles.h1.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.lg),
          ProfileCard(
            radius: AppRadii.lg,
            shadow: AppShadows.cardSubtle,
            padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.xs, AppSpacing.screen, AppSpacing.xs),
            child: Column(
              children: const [
                _ReminderRow(title: 'Breakfast', time: '8:30 AM', isOn: true),
                _ReminderRow(title: 'Lunch', time: '11:30 AM', isOn: true),
                _ReminderRow(title: 'Snack', time: '4:00 PM', isOn: false),
                _ReminderRow(title: 'Dinner', time: '6:00 PM', isOn: true, showDivider: false),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ProfileCard(
            radius: AppRadii.lg,
            shadow: AppShadows.cardSubtle,
            padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.md, AppSpacing.screen, AppSpacing.md),
            child: Column(
              children: const [
                _ReminderRow(title: 'End of Day', time: '9:00 PM', isOn: false, showDivider: false),
                SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Get one daily reminder and log all your meals at once.',
                    style: AppTextStyles.body13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderRow extends StatelessWidget {
  const _ReminderRow({
    required this.title,
    required this.time,
    required this.isOn,
    this.showDivider = true,
  });

  final String title;
  final String time;
  final bool isOn;
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
              ProfileTimeChip(label: time),
              const SizedBox(width: AppSpacing.sm),
              ProfileToggle(isOn: isOn),
            ],
          ),
        ),
        if (showDivider)
          Divider(height: AppSizes.dividerThin, color: AppColors.surfaceMuted),
      ],
    );
  }
}
