import 'dart:io' show Platform;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/state/weight_entry_notifier.dart';
import 'package:diplomka/model/user_profile.dart';
import 'package:diplomka/model/weight_entry.dart';
import 'package:diplomka/screens/logs/weight_log_sheet.dart';
import 'package:diplomka/screens/profile/subscreens/personal_details_diet_screen.dart';
import 'package:diplomka/screens/profile/profile_widgets.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:diplomka/widgets/info_dialog.dart';
import 'package:diplomka/widgets/picker_column.dart';
import 'package:diplomka/widgets/sheet_drag_handle.dart';
import 'package:diplomka/widgets/sheet_top_bar.dart';

class PersonalDetailsScreen extends ConsumerWidget {
  const PersonalDetailsScreen({super.key});

  String _workoutsLabel(String? code) {
    return switch (code) {
      '0-1' => '0–1',
      '2-3' => '2–3',
      '4-5' => '4–5',
      '6+' => '6+',
      _ => '—',
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProfileGradientScaffold(
      scroll: true,
      padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, AppSpacing.xl),
      child: Consumer(
        builder: (context, ref, _) {
        final entries = ref.watch(weightEntriesProvider).value ?? const <WeightEntry>[];
        final session = ref.watch(sessionProvider);
        final double? profileWeight = session.weightKg;
        final double? heightCm = session.heightCm;
        final double? goalWeight = session.goalWeightKg;
        final ProfileSex? sex = session.sex;
        final DateTime? dob = session.dateOfBirth;
        final ProfileDietType? dietType = session.dietType;
        final String? customDietPreferences = session.customDietPreferences;
        final String? workoutsPerWeek = session.workoutsPerWeek;

        final WeightEntry? latestEntry = _latestWeight(entries);
        final double? currentWeight = latestEntry?.weight ?? profileWeight;

        final String goalLabel = goalWeight == null ? '—' : '${_formatWeight(goalWeight)} kg';
        final String weightLabel = currentWeight == null ? '—' : '${_formatWeight(currentWeight)} kg';
        final String heightLabel = heightCm == null ? '—' : '${_formatHeight(heightCm)} cm';
        final String dobLabel = dob == null ? '—' : _formatDate(dob);
        final String sexLabel = sex?.label ?? '—';
        final String dietLabel = dietType == null ? '—' : dietType.label;
        final String? dietSubtitle = dietType == ProfileDietType.custom && (customDietPreferences?.trim().isNotEmpty ?? false) ? customDietPreferences!.trim() : null;
        final String workoutsLabel = '${_workoutsLabel(workoutsPerWeek)} ${tr(LocaleKeys.personal_details_activity_workouts_week)}';

        final double? bmrValue = session.bmr;
        final String bmrLabel = bmrValue != null ? '${bmrValue.round()} kcal' : '—';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileTopBar(title: tr(LocaleKeys.personal_details_title), onBack: () => Navigator.of(context).pop()),
            const SizedBox(height: AppSpacing.m),
            ProfileCard(
              radius: AppRadii.l,
              shadow: AppShadows.screenCard,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen, vertical: AppSpacing.m),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tr(LocaleKeys.personal_details_goal_weight), style: AppTextStyles.body15.copyWith(fontWeight: FontWeight.w500)),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(goalLabel, style: AppTextStyles.title17.copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                  _SmallGradientButton(
                    label: goalWeight == null ? tr(LocaleKeys.personal_details_set_goal) : tr(LocaleKeys.personal_details_change_goal),
                    onPressed: () => showWeightLogSheet(
                      context,
                      title: tr(LocaleKeys.personal_details_goal_weight),
                      initialWeight: goalWeight,
                      showDate: false,
                      onSave: (weight) => ref.read(sessionProvider.notifier).setGoalWeightKg(weight),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            ProfileCard(
              radius: AppRadii.l,
              shadow: AppShadows.screenCard,
              padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.xs, AppSpacing.screen, AppSpacing.xs),
              child: Column(
                children: [
                  _DetailRow(
                    label: tr(LocaleKeys.personal_details_current_weight),
                    value: weightLabel,
                    onTap: (_) => showWeightLogSheet(
                      context,
                      title: tr(LocaleKeys.personal_details_current_weight),
                      initialWeight: currentWeight,
                      showDate: false,
                      onSave: (weight) async {
                        await ref.read(sessionProvider.notifier).setWeightKg(weight);
                        await ref.read(weightEntriesProvider.notifier).saveEntry(WeightEntry(date: DateTime.now(), weight: weight));
                      },
                    ),
                  ),
                  _DetailRow(
                    label: tr(LocaleKeys.personal_details_height),
                    value: heightLabel,
                    onTap: (_) => _showHeightSheet(context, ref, initialHeightCm: heightCm),
                  ),
                  _DetailRow(
                    label: tr(LocaleKeys.personal_details_date_of_birth),
                    value: dobLabel,
                    onTap: (_) => _showDobSheet(context, ref, initialDate: dob),
                  ),
                  _DetailRow(label: tr(LocaleKeys.personal_details_gender), value: sexLabel, onTap: (_) => _showSexSheet(context, ref, sex)),
                  _InfoDetailRow(
                    label: tr(LocaleKeys.personal_details_activity_level),
                    value: workoutsLabel,
                    onTap: () => _showWorkoutsSheet(context, ref, workoutsPerWeek),
                    onInfoTap: () => _showActivityInfoDialog(context),
                  ),
                  _DetailRow(
                    label: tr(LocaleKeys.personal_details_diet),
                    value: dietLabel,
                    subtitle: dietSubtitle,
                    showDivider: false,
                    onTap: (_) => _openDietFlow(context, ref, currentDietType: dietType, currentCustomPreferences: customDietPreferences),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            ProfileCard(
              radius: AppRadii.l,
              shadow: AppShadows.screenCard,
              padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.xs, AppSpacing.screen, AppSpacing.xs),
              child: _BmrRow(label: tr(LocaleKeys.personal_details_bmr), value: bmrLabel, onInfoTap: () => _showBmrInfoDialog(context)),
            ),
          ],
        );
      }),
    );
  }

  WeightEntry? _latestWeight(List<WeightEntry> entries) {
    if (entries.isEmpty) return null;
    final list = entries.toList()..sort((a, b) => b.date.compareTo(a.date));
    return list.first;
  }

  String _formatWeight(double value) {
    final isInt = value % 1 == 0;
    return value.toStringAsFixed(isInt ? 0 : 1);
  }

  String _formatHeight(double value) {
    final isInt = value % 1 == 0;
    return value.toStringAsFixed(isInt ? 0 : 1);
  }

  String _formatDate(DateTime date) {
    return '${date.day}. ${date.month}. ${date.year}';
  }

  Future<void> _showDobSheet(BuildContext context, WidgetRef ref, {required DateTime? initialDate}) async {
    final now = DateTime.now();
    final initial = initialDate ?? DateTime(now.year - 25, now.month, now.day);
    DateTime selected = initial;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: AppColors.overlayDark40,
      builder: (sheetContext) {
        return Padding(
          padding: Platform.isAndroid ? const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xxxl + AppSpacing.xs) : const EdgeInsets.all(AppSpacing.xs),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl), bottom: Radius.circular(AppRadii.xxl + 10)),
            ),
            child: SafeArea(
              top: false,
              bottom: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: AppSpacing.xxs),
                  const SheetDragHandle(),
                  const SizedBox(height: AppSpacing.xs),
                  SheetTopBar(
                    title: tr(LocaleKeys.personal_details_dob_label),
                    onClose: () => Navigator.of(sheetContext).pop(),
                    onConfirm: () async {
                      await ref.read(sessionProvider.notifier).setDateOfBirth(selected);
                      if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                    },
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  SizedBox(
                    height: AppSizes.pickerHeight,
                    child: CupertinoDatePicker(mode: CupertinoDatePickerMode.date, initialDateTime: initial, maximumDate: now, onDateTimeChanged: (value) => selected = value),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showHeightSheet(BuildContext context, WidgetRef ref, {required double? initialHeightCm}) async {
    final initial = initialHeightCm?.round() ?? 175;
    int selectedCm = initial.clamp(140, 259);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: AppColors.overlayDark40,
      builder: (sheetContext) {
        return Padding(
          padding: Platform.isAndroid ? const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xxxl + AppSpacing.xs) : const EdgeInsets.all(AppSpacing.xs),
          child: _HeightPickerSheet(
            initialCm: selectedCm,
            onSave: (cm) async {
              await ref.read(sessionProvider.notifier).setHeightCm(cm.toDouble());
              if (sheetContext.mounted) Navigator.of(sheetContext).pop();
            },
            onClose: () => Navigator.of(sheetContext).pop(),
          ),
        );
      },
    );
  }

  Future<void> _showSexSheet(BuildContext context, WidgetRef ref, ProfileSex? current) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: AppColors.overlayDark40,
      builder: (sheetContext) {
        return Padding(
          padding: Platform.isAndroid ? const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xxxl + AppSpacing.xs) : const EdgeInsets.all(AppSpacing.xs),
          child: _GenderPickerSheet(
            initialSex: current,
            onSave: (sex) async {
              await ref.read(sessionProvider.notifier).setSex(sex);
              if (sheetContext.mounted) Navigator.of(sheetContext).pop();
            },
            onClose: () => Navigator.of(sheetContext).pop(),
          ),
        );
      },
    );
  }

  Future<void> _openDietFlow(BuildContext context, WidgetRef ref, {required ProfileDietType? currentDietType, required String? currentCustomPreferences}) async {
    String? selectedDietCode = currentDietType?.code;
    String customPreferencesDraft = currentCustomPreferences ?? '';

    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => PersonalDetailsDietScreen(
          onBack: () => Navigator.of(context).pop(),
          onNext: () async {
            final ProfileDietType? selectedDiet = profileDietTypeFromCode(selectedDietCode);
            if (selectedDiet == null) return;

            if (selectedDiet != ProfileDietType.custom) {
              await ref.read(sessionProvider.notifier).setDietType(selectedDiet);
              if (context.mounted) Navigator.of(context).pop();
              return;
            }

            final saved = await _showCustomDietSheet(context, initialPreferences: customPreferencesDraft);
            if (saved == null) return;
            await ref.read(sessionProvider.notifier).setDietType(ProfileDietType.custom);
            await ref.read(sessionProvider.notifier).setCustomDietPreferences(saved);
            if (context.mounted) Navigator.of(context).pop();
          },
          initialDiet: selectedDietCode,
          customPreferences: customPreferencesDraft,
          onDietChanged: (diet) => selectedDietCode = diet,
        ),
      ),
    );
  }

  Future<String?> _showCustomDietSheet(BuildContext context, {required String initialPreferences}) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl))),
      clipBehavior: Clip.antiAlias,
      builder: (_) => _CustomDietSheet(initialPreferences: initialPreferences),
    );
  }

  Future<void> _showWorkoutsSheet(BuildContext context, WidgetRef ref, String? current) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: AppColors.overlayDark40,
      builder: (sheetContext) {
        return Padding(
          padding: Platform.isAndroid ? const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xxxl + AppSpacing.xs) : const EdgeInsets.all(AppSpacing.xs),
          child: _WorkoutsPickerSheet(
            initialWorkouts: current,
            onSave: (value) async {
              await ref.read(sessionProvider.notifier).setWorkoutsPerWeek(value);
              if (sheetContext.mounted) Navigator.of(sheetContext).pop();
            },
            onClose: () => Navigator.of(sheetContext).pop(),
          ),
        );
      },
    );
  }

  void _showBmrInfoDialog(BuildContext context) {
    showInfoDialog(context, title: tr(LocaleKeys.personal_details_bmr_info_title), body: tr(LocaleKeys.personal_details_bmr_info_body));
  }

  void _showActivityInfoDialog(BuildContext context) {
    showInfoDialog(context, title: tr(LocaleKeys.personal_details_activity_info_title), body: tr(LocaleKeys.personal_details_activity_info_body));
  }
}

class _SmallGradientButton extends StatelessWidget {
  const _SmallGradientButton({required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.buttonHeightXs,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          child: Ink(
            decoration: BoxDecoration(gradient: AppGradients.primary, borderRadius: BorderRadius.circular(AppRadii.pill)),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
            child: Center(
              child: Text(
                label,
                style: AppTextStyles.label11.copyWith(color: AppColors.onPrimary, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value, this.subtitle, this.showDivider = true, this.onTap});

  final String label;
  final String value;
  final String? subtitle;
  final bool showDivider;
  final void Function(BuildContext)? onTap;

  @override
  Widget build(BuildContext context) {
    final bool hasSubtitle = subtitle != null;

    return Column(
      children: [
        InkWell(
          onTap: onTap != null ? () => onTap!(context) : null,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: hasSubtitle ? AppSpacing.m : AppSpacing.s),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: AppTextStyles.body15.copyWith(fontWeight: FontWeight.w500)),
                      if (subtitle != null) ...[
                        const SizedBox(height: AppSpacing.xxs),
                        _TwoLineThreeDotsText(subtitle!, style: AppTextStyles.body14Regular.copyWith(color: AppColors.textSecondary)),
                      ],
                    ],
                  ),
                ),
                Text(value, style: AppTextStyles.body15.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
        if (showDivider) Divider(height: AppSizes.dividerThin, color: AppColors.surfaceMuted),
      ],
    );
  }
}

class _TwoLineThreeDotsText extends StatelessWidget {
  const _TwoLineThreeDotsText(this.text, {required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textDirection = Directionality.of(context);
        final maxWidth = constraints.maxWidth;
        if (maxWidth.isInfinite || maxWidth <= 0) {
          return Text(text, maxLines: 2, style: style);
        }

        final painter = TextPainter(
          text: TextSpan(text: text, style: style),
          textDirection: textDirection,
          maxLines: 2,
        )..layout(maxWidth: maxWidth);

        if (!painter.didExceedMaxLines) {
          return Text(text, maxLines: 2, style: style);
        }

        int low = 0;
        int high = text.length;

        while (low < high) {
          final mid = (low + high + 1) ~/ 2;
          final candidate = '${text.substring(0, mid).trimRight()}...';

          painter.text = TextSpan(text: candidate, style: style);
          painter.layout(maxWidth: maxWidth);

          if (painter.didExceedMaxLines) {
            high = mid - 1;
          } else {
            low = mid;
          }
        }

        final trimmed = text.substring(0, low).trimRight();
        final result = trimmed.isEmpty ? '...' : '$trimmed...';
        return Text(result, maxLines: 2, style: style);
      },
    );
  }
}

class _CustomDietSheet extends StatefulWidget {
  const _CustomDietSheet({required this.initialPreferences});

  final String initialPreferences;

  @override
  State<_CustomDietSheet> createState() => _CustomDietSheetState();
}

class _CustomDietSheetState extends State<_CustomDietSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialPreferences);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.xxs),
            const SheetDragHandle(),
            const SizedBox(height: AppSpacing.xs),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _controller,
              builder: (context, value, _) {
                final hasText = value.text.trim().isNotEmpty;
                return SheetTopBar(
                  title: tr(LocaleKeys.personal_details_custom_diet_title),
                  onClose: () => Navigator.of(context).pop(),
                  onConfirm: hasText ? () => Navigator.of(context).pop(_controller.text.trim()) : null,
                );
              },
            ),
            const SizedBox(height: AppSpacing.s),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
              child: Text(tr(LocaleKeys.personal_details_custom_diet_subtitle), style: AppTextStyles.body14Regular.copyWith(color: AppColors.textSecondary)),
            ),
            const SizedBox(height: AppSpacing.m),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
              child: TextField(
                controller: _controller,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 4,
                maxLength: 300,
                style: AppTextStyles.body16,
                decoration: InputDecoration(
                  hintText: tr(LocaleKeys.onboarding_custom_diet_hint),
                  hintStyle: AppTextStyles.body16.copyWith(color: AppColors.textTertiary),
                  filled: true,
                  fillColor: AppColors.surfaceMuted,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.m), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.all(AppSpacing.m),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.l),
          ],
        ),
      ),
    );
  }
}

class _HeightPickerSheet extends StatefulWidget {
  const _HeightPickerSheet({required this.initialCm, required this.onSave, required this.onClose});

  final int initialCm;
  final ValueChanged<int> onSave;
  final VoidCallback onClose;

  @override
  State<_HeightPickerSheet> createState() => _HeightPickerSheetState();
}

class _HeightPickerSheetState extends State<_HeightPickerSheet> {
  static const int _minCm = 140;
  static const int _maxCm = 259;
  late final List<String> _values;
  late int _selectedCm;

  @override
  void initState() {
    super.initState();
    _selectedCm = widget.initialCm.clamp(_minCm, _maxCm);
    _values = List.generate(_maxCm - _minCm + 1, (i) => '${_minCm + i} cm');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl), bottom: Radius.circular(AppRadii.xxl + 10)),
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.xxs),
            const SheetDragHandle(),
            const SizedBox(height: AppSpacing.xs),
            SheetTopBar(title: tr(LocaleKeys.personal_details_height), onClose: widget.onClose, onConfirm: () => widget.onSave(_selectedCm)),
            const SizedBox(height: AppSpacing.xs),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: PickerColumn(
                values: _values,
                selectedIndex: _selectedCm - _minCm,
                height: AppSizes.pickerHeight,
                onSelected: (index) => setState(() => _selectedCm = _minCm + index),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

class _GenderPickerSheet extends StatefulWidget {
  const _GenderPickerSheet({required this.initialSex, required this.onSave, required this.onClose});

  final ProfileSex? initialSex;
  final ValueChanged<ProfileSex> onSave;
  final VoidCallback onClose;

  @override
  State<_GenderPickerSheet> createState() => _GenderPickerSheetState();
}

class _GenderPickerSheetState extends State<_GenderPickerSheet> {
  late final List<String> _labels;
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _labels = ProfileSex.values.map((s) => s.label).toList();
    _selectedIndex = widget.initialSex != null ? ProfileSex.values.indexOf(widget.initialSex!) : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl), bottom: Radius.circular(AppRadii.xxl + 10)),
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.xxs),
            const SheetDragHandle(),
            const SizedBox(height: AppSpacing.xs),
            SheetTopBar(title: tr(LocaleKeys.personal_details_gender), onClose: widget.onClose, onConfirm: () => widget.onSave(ProfileSex.values[_selectedIndex])),
            const SizedBox(height: AppSpacing.m),
            PickerColumn(values: _labels, selectedIndex: _selectedIndex, height: 140, onSelected: (index) => setState(() => _selectedIndex = index)),
            const SizedBox(height: AppSpacing.l),
          ],
        ),
      ),
    );
  }
}

class _InfoDetailRow extends StatelessWidget {
  const _InfoDetailRow({required this.label, required this.value, required this.onTap, required this.onInfoTap});

  final String label;
  final String value;
  final VoidCallback onTap;
  final VoidCallback onInfoTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(label, style: AppTextStyles.body15.copyWith(fontWeight: FontWeight.w500)),
                      const SizedBox(width: AppSpacing.xs),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onInfoTap,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs, vertical: AppSpacing.xxs),
                          child: Icon(CupertinoIcons.info_circle, size: AppSizes.iconSm, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(value, style: AppTextStyles.body15.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
        Divider(height: AppSizes.dividerThin, color: AppColors.surfaceMuted),
      ],
    );
  }
}

class _BmrRow extends StatelessWidget {
  const _BmrRow({required this.label, required this.value, required this.onInfoTap});

  final String label;
  final String value;
  final VoidCallback onInfoTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Text(label, style: AppTextStyles.body15.copyWith(fontWeight: FontWeight.w500)),
                const SizedBox(width: AppSpacing.xs),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onInfoTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs, vertical: AppSpacing.xxs),
                    child: Icon(CupertinoIcons.info_circle, size: AppSizes.iconSm, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          Text(value, style: AppTextStyles.body15.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _WorkoutsPickerSheet extends StatefulWidget {
  const _WorkoutsPickerSheet({required this.initialWorkouts, required this.onSave, required this.onClose});

  final String? initialWorkouts;
  final ValueChanged<String> onSave;
  final VoidCallback onClose;

  @override
  State<_WorkoutsPickerSheet> createState() => _WorkoutsPickerSheetState();
}

class _WorkoutsPickerSheetState extends State<_WorkoutsPickerSheet> {
  static const List<String> _codes = ['0-1', '2-3', '4-5', '6+'];
  late String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialWorkouts;
  }

  String _titleForCode(String code) {
    return switch (code) {
      '0-1' => tr(LocaleKeys.onboarding_workouts_0_1),
      '2-3' => tr(LocaleKeys.onboarding_workouts_2_3),
      '4-5' => tr(LocaleKeys.onboarding_workouts_4_5),
      '6+' => tr(LocaleKeys.onboarding_workouts_6_plus),
      _ => code,
    };
  }

  String _subtitleForCode(String code) {
    return switch (code) {
      '0-1' => tr(LocaleKeys.onboarding_workouts_0_1_desc),
      '2-3' => tr(LocaleKeys.onboarding_workouts_2_3_desc),
      '4-5' => tr(LocaleKeys.onboarding_workouts_4_5_desc),
      '6+' => tr(LocaleKeys.onboarding_workouts_6_plus_desc),
      _ => '',
    };
  }

  IconData _iconForCode(String code) {
    return switch (code) {
      '0-1' => CupertinoIcons.moon_zzz,
      '2-3' => CupertinoIcons.person,
      '4-5' => CupertinoIcons.bolt,
      '6+' => CupertinoIcons.flame,
      _ => CupertinoIcons.person,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl), bottom: Radius.circular(AppRadii.xxl + 10)),
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.xxs),
            const SheetDragHandle(),
            const SizedBox(height: AppSpacing.xs),
            SheetTopBar(title: tr(LocaleKeys.personal_details_activity_level), onClose: widget.onClose, onConfirm: _selected != null ? () => widget.onSave(_selected!) : null),
            const SizedBox(height: AppSpacing.m),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
              child: Column(
                children: _codes.map((code) {
                  final bool isSelected = _selected == code;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.s),
                    child: GestureDetector(
                      onTap: () => setState(() => _selected = code),
                      child: Container(
                        height: AppSizes.workoutCardHeight,
                        decoration: BoxDecoration(color: isSelected ? AppColors.primary : AppColors.surfaceMuted, borderRadius: BorderRadius.circular(AppRadii.m)),
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                        child: Row(
                          children: [
                            Container(
                              width: AppSizes.iconXl,
                              height: AppSizes.iconXl,
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.onPrimary.withValues(alpha: 0.2) : AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(_iconForCode(code), color: isSelected ? AppColors.onPrimary : AppColors.textPrimary, size: AppSizes.iconLg),
                            ),
                            const SizedBox(width: AppSpacing.m),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _titleForCode(code),
                                    style: AppTextStyles.title17.copyWith(fontWeight: FontWeight.w600, color: isSelected ? AppColors.onPrimary : AppColors.textPrimary),
                                  ),
                                  const SizedBox(height: AppSpacing.xxs),
                                  Text(
                                    _subtitleForCode(code),
                                    style: AppTextStyles.body14Regular.copyWith(color: isSelected ? AppColors.onPrimary.withValues(alpha: 0.7) : AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.l),
          ],
        ),
      ),
    );
  }
}

