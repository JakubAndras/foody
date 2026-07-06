import 'package:diplomka/app_theme.dart';
import 'package:diplomka/state/motivational_summary_notifier.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/motivational_summary_setting.dart';
import 'package:diplomka/screens/profile/profile_widgets.dart';
import 'package:diplomka/screens/scan/scan_widgets.dart';
import 'package:diplomka/widgets/custom_glass_app_bar.dart';
import 'package:diplomka/widgets/glass_toggle_row.dart';
import 'package:diplomka/widgets/time_picker_sheet.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MotivationalSummaryScreen extends ConsumerStatefulWidget {
  const MotivationalSummaryScreen({super.key});

  @override
  ConsumerState<MotivationalSummaryScreen> createState() => _MotivationalSummaryScreenState();
}

class _MotivationalSummaryScreenState extends ConsumerState<MotivationalSummaryScreen> {
  bool _showTip = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(motivationalSummaryProvider);
    final notifier = ref.read(motivationalSummaryProvider.notifier);

    return Stack(
      children: [
        ProfileGradientScaffold(
          scroll: true,
          padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, AppSpacing.xl),
          child: Builder(
            builder: (context) {
              if (!state.isLoaded) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProfileTopBar(title: tr(LocaleKeys.motivational_summary_title), onBack: () => Navigator.of(context).pop()),
                  ],
                );
              }

              final settingsByType = {
                for (final s in state.summaries) s.type: s,
              };

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileTopBar(
                    title: tr(LocaleKeys.motivational_summary_title),
                    onBack: () => Navigator.of(context).pop(),
                    actions: [
                      CustomGlassIconButton(
                        icon: CupertinoIcons.info,
                        onPressed: () => setState(() => _showTip = true),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.m),
                  ProfileCard(
                    radius: AppRadii.l,
                    shadow: AppShadows.screenCard,
                    padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.xs, AppSpacing.screen, AppSpacing.xs),
                    child: Column(
                      children: [
                        for (int i = 0; i < MotivationalSummaryType.values.length; i++) ...[
                          () {
                            final setting = settingsByType[MotivationalSummaryType.values[i]] ?? MotivationalSummarySetting.defaults(MotivationalSummaryType.values[i]);
                            final timeStr = MaterialLocalizations.of(context).formatTimeOfDay(
                              TimeOfDay(hour: setting.hour, minute: setting.minute),
                              alwaysUse24HourFormat: MediaQuery.of(context).alwaysUse24HourFormat,
                            );
                            return GlassToggleRow(
                              title: tr(setting.type.titleKey),
                              isOn: setting.enabled,
                              showDivider: i != MotivationalSummaryType.values.length - 1,
                              onChanged: (val) => notifier.toggleSummary(setting.type, val),
                              trailing: GestureDetector(
                                onTap: () => _pickTime(context, notifier, setting),
                                child: ProfileTimeChip(label: timeStr),
                              ),
                            );
                          }(),
                        ],
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
                            tr(LocaleKeys.motivational_summary_permission_hint),
                            style: AppTextStyles.body13.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: AppSpacing.m),
                          ProfileOutlineButton(
                            label: tr(LocaleKeys.motivational_summary_open_settings),
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
        ),
        if (_showTip)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => setState(() => _showTip = false),
              child: ColoredBox(
                color: AppColors.overlayDark40,
                child: AnimatedPadding(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                      child: ScanTipOverlay(
                        title: tr(LocaleKeys.motivational_summary_title),
                        body: tr(LocaleKeys.motivational_summary_description),
                        onDismiss: () => setState(() => _showTip = false),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _pickTime(
    BuildContext context,
    MotivationalSummaryNotifier notifier,
    MotivationalSummarySetting setting,
  ) async {
    final selected = await showTimePickerSheet(
      context: context,
      title: tr(setting.type.titleKey),
      initialTime: TimeOfDay(hour: setting.hour, minute: setting.minute),
    );
    if (selected != null) {
      await notifier.changeSummaryTime(setting.type, selected);
    }
  }
}
