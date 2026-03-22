import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/controller/weight_entry_controller.dart';
import 'package:diplomka/model/user_profile.dart';
import 'package:diplomka/model/weight_entry.dart';
import 'package:diplomka/screens/profile/subscreens/personal_details_diet_screen.dart';
import 'package:diplomka/screens/profile/profile_widgets.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:diplomka/widgets/foody_glass_buttons.dart';
import 'package:diplomka/widgets/glass_popup.dart';

class PersonalDetailsScreen extends StatelessWidget {
  const PersonalDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileGradientScaffold(
      scroll: true,
      padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, AppSpacing.xl),
      child: Obx(() {
        final entries = WeightEntryController.to.entries;
        final double? profileWeight = SessionManager.to.weightKg.value;
        final double? heightCm = SessionManager.to.heightCm.value;
        final double? goalWeight = SessionManager.to.goalWeightKg.value;
        final ProfileSex? sex = SessionManager.to.sex.value;
        final DateTime? dob = SessionManager.to.dateOfBirth.value;
        final ProfileDietType? dietType = SessionManager.to.dietType.value;
        final String? customDietPreferences = SessionManager.to.customDietPreferences.value;

        final WeightEntry? latestEntry = _latestWeight(entries);
        final double? currentWeight = latestEntry?.weight ?? profileWeight;

        final String goalLabel = goalWeight == null ? '—' : '${_formatWeight(goalWeight)} kg';
        final String weightLabel = currentWeight == null ? '—' : '${_formatWeight(currentWeight)} kg';
        final String heightLabel = heightCm == null ? '—' : '${_formatHeight(heightCm)} cm';
        final String dobLabel = dob == null ? '—' : _formatDate(dob);
        final String sexLabel = sex?.label ?? '—';
        final String dietLabel = dietType == null ? '—' : dietType.label;
        final String? dietSubtitle = dietType == ProfileDietType.custom && (customDietPreferences?.trim().isNotEmpty ?? false) ? customDietPreferences!.trim() : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileTopBar(title: tr(LocaleKeys.personal_details_title), onBack: () => Get.back()),
            const SizedBox(height: AppSpacing.l),
            ProfileCard(
              radius: AppRadii.l,
              shadow: AppShadows.cardSubtle,
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
                    onPressed: () => _showNumberSheet(
                      context,
                      title: tr(LocaleKeys.personal_details_goal_weight),
                      unit: 'kg',
                      initialValue: goalWeight,
                      min: 30,
                      max: 250,
                      fractionDigits: 1,
                      onSaved: (value) => SessionManager.to.setGoalWeightKg(value),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            ProfileCard(
              radius: AppRadii.l,
              shadow: AppShadows.cardSubtle,
              padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.xs, AppSpacing.screen, AppSpacing.xs),
              child: Column(
                children: [
                  _DetailRow(
                    label: tr(LocaleKeys.personal_details_current_weight),
                    value: weightLabel,
                    onTap: (_) => _showNumberSheet(
                      context,
                      title: tr(LocaleKeys.personal_details_current_weight),
                      unit: 'kg',
                      initialValue: currentWeight,
                      min: 30,
                      max: 250,
                      fractionDigits: 1,
                      onSaved: (value) async {
                        await SessionManager.to.setWeightKg(value);
                        await WeightEntryController.to.saveEntry(
                          WeightEntry(date: DateTime.now(), weight: value),
                        );
                      },
                    ),
                  ),
                  _DetailRow(
                    label: tr(LocaleKeys.personal_details_height),
                    value: heightLabel,
                    onTap: (_) => _showNumberSheet(
                      context,
                      title: tr(LocaleKeys.personal_details_height),
                      unit: 'cm',
                      initialValue: heightCm,
                      min: 120,
                      max: 230,
                      fractionDigits: 0,
                      onSaved: (value) => SessionManager.to.setHeightCm(value),
                    ),
                  ),
                  _DetailRow(
                    label: tr(LocaleKeys.personal_details_date_of_birth),
                    value: dobLabel,
                    onTap: (_) => _showDobSheet(context, initialDate: dob),
                  ),
                  _DetailRow(
                    label: tr(LocaleKeys.personal_details_gender),
                    value: sexLabel,
                    onTap: (rowContext) => _showSexSheet(context, sex, targetContext: rowContext),
                  ),
                  _DetailRow(
                    label: tr(LocaleKeys.personal_details_diet),
                    value: dietLabel,
                    subtitle: dietSubtitle,
                    showDivider: false,
                    onTap: (_) => _openDietFlow(
                      context,
                      currentDietType: dietType,
                      currentCustomPreferences: customDietPreferences,
                    ),
                  ),
                ],
              ),
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

  Future<void> _showDobSheet(
    BuildContext context, {
    required DateTime? initialDate,
  }) async {
    final now = DateTime.now();
    final initial = initialDate ?? DateTime(now.year - 25, now.month, now.day);
    DateTime selected = initial;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl))),
      clipBehavior: Clip.antiAlias,
      showDragHandle: false,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tr(LocaleKeys.personal_details_dob_label), style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: AppSpacing.m),
                SizedBox(
                  height: AppSizes.pickerHeight,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: initial,
                    maximumDate: now,
                    onDateTimeChanged: (value) => selected = value,
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                Row(
                  children: [
                    Expanded(
                      child: FoodySecondaryButton(label: tr(LocaleKeys.common_cancel), onTap: () => Navigator.of(sheetContext).pop()),
                    ),
                    const SizedBox(width: AppSpacing.s),
                    Expanded(
                      child: FoodyPrimaryButton(
                        label: tr(LocaleKeys.common_save),
                        gradient: LinearGradient(colors: [AppColors.primary, AppColors.primary]),
                        onTap: () async {
                          await SessionManager.to.setDateOfBirth(selected);
                          if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showSexSheet(BuildContext context, ProfileSex? current, {BuildContext? targetContext}) async {
    await showGlassPopup(
      context: context,
      targetContext: targetContext,
      items: ProfileSex.values.map((sex) {
        return GlassPopupItem(
          label: sex.label,
          selected: sex == current,
          onTap: () async {
            Navigator.of(context).pop();
            await SessionManager.to.setSex(sex);
          },
        );
      }).toList(),
    );
  }

  Future<void> _openDietFlow(
    BuildContext context, {
    required ProfileDietType? currentDietType,
    required String? currentCustomPreferences,
  }) async {
    String? selectedDietCode = currentDietType?.code;
    String customPreferencesDraft = currentCustomPreferences ?? '';

    await Get.to<void>(
      () => PersonalDetailsDietScreen(
        onBack: () => Get.back<void>(),
        onNext: () async {
          final ProfileDietType? selectedDiet = profileDietTypeFromCode(selectedDietCode);
          if (selectedDiet == null) return;

          if (selectedDiet != ProfileDietType.custom) {
            await SessionManager.to.setDietType(selectedDiet);
            await SessionManager.to.setCustomDietPreferences(null);
            Get.back<void>();
            return;
          }

          final saved = await _showCustomDietSheet(context, initialPreferences: customPreferencesDraft);
          if (saved == null) return;
          await SessionManager.to.setDietType(ProfileDietType.custom);
          await SessionManager.to.setCustomDietPreferences(saved);
          Get.back<void>();
        },
        initialDiet: selectedDietCode,
        customPreferences: customPreferencesDraft,
        onDietChanged: (diet) => selectedDietCode = diet,
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
      showDragHandle: false,
      builder: (_) => _CustomDietSheet(initialPreferences: initialPreferences),
    );
  }

  Future<void> _showNumberSheet(
    BuildContext context, {
    required String title,
    required String unit,
    required double? initialValue,
    required double min,
    required double max,
    required int fractionDigits,
    required ValueChanged<double> onSaved,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl))),
      clipBehavior: Clip.antiAlias,
      showDragHandle: false,
      builder: (_) => _ProfileNumberSheet(
        title: title,
        unit: unit,
        initialValue: initialValue,
        min: min,
        max: max,
        fractionDigits: fractionDigits,
        onSaved: onSaved,
      ),
    );
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
            decoration: BoxDecoration(
              gradient: AppGradients.primary,
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
            child: Center(
              child: Text(
                label,
                style: AppTextStyles.label11.copyWith(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.subtitle,
    this.showDivider = true,
    this.onTap,
  });

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
                        _TwoLineThreeDotsText(
                          subtitle!,
                          style: AppTextStyles.body14Regular.copyWith(color: AppColors.textSecondary),
                        ),
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
        padding: EdgeInsets.only(left: AppSpacing.l, right: AppSpacing.l, top: AppSpacing.l, bottom: AppSpacing.l + MediaQuery.viewInsetsOf(context).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tr(LocaleKeys.personal_details_custom_diet_title), style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.xs),
            Text(tr(LocaleKeys.personal_details_custom_diet_subtitle), style: AppTextStyles.body14Regular.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.m),
            TextField(
              controller: _controller,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 4,
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
            const SizedBox(height: AppSpacing.m),
            Row(
              children: [
                Expanded(
                  child: FoodySecondaryButton(label: tr(LocaleKeys.common_cancel), onTap: () => Navigator.of(context).pop()),
                ),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _controller,
                    builder: (context, value, _) {
                      final hasText = value.text.trim().isNotEmpty;
                      return FoodyPrimaryButton(
                        label: tr(LocaleKeys.common_save),
                        gradient: LinearGradient(colors: [AppColors.primary, AppColors.primary]),
                        onTap: hasText ? () => Navigator.of(context).pop(_controller.text.trim()) : null,
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileNumberSheet extends StatefulWidget {
  const _ProfileNumberSheet({
    required this.title,
    required this.unit,
    required this.initialValue,
    required this.min,
    required this.max,
    required this.fractionDigits,
    required this.onSaved,
  });

  final String title;
  final String unit;
  final double? initialValue;
  final double min;
  final double max;
  final int fractionDigits;
  final ValueChanged<double> onSaved;

  @override
  State<_ProfileNumberSheet> createState() => _ProfileNumberSheetState();
}

class _ProfileNumberSheetState extends State<_ProfileNumberSheet> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialValue;
    _controller = TextEditingController(
      text: initial == null ? '' : initial.toStringAsFixed(widget.fractionDigits),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double? _parseValue() {
    final raw = _controller.text.trim().replaceAll(',', '.');
    if (raw.isEmpty) return null;
    final value = double.tryParse(raw);
    if (value == null) return null;
    if (value < widget.min || value > widget.max) return null;
    return value;
  }

  Future<void> _handleSave() async {
    final value = _parseValue();
    if (value == null) {
      setState(() => _errorText = tr(LocaleKeys.personal_details_validation_range, namedArgs: {'min': '${widget.min}', 'max': '${widget.max}'}));
      return;
    }
    final normalized = double.parse(value.toStringAsFixed(widget.fractionDigits));
    widget.onSaved(normalized);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(left: AppSpacing.l, right: AppSpacing.l, top: AppSpacing.l, bottom: AppSpacing.l + MediaQuery.viewInsetsOf(context).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.m),
            TextField(
              controller: _controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _handleSave(),
              decoration: InputDecoration(
                hintText: widget.unit,
                hintStyle: AppTextStyles.body16.copyWith(color: AppColors.textTertiary),
                filled: true,
                fillColor: AppColors.surfaceMuted,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.m), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.m),
                suffixText: widget.unit,
                suffixStyle: AppTextStyles.body15.copyWith(color: AppColors.textSecondary),
              ),
              style: AppTextStyles.title17.copyWith(fontWeight: FontWeight.w600),
              onChanged: (_) => setState(() => _errorText = null),
            ),
            if (_errorText != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                _errorText!,
                style: AppTextStyles.body14Regular.copyWith(color: AppColors.errorText),
              ),
            ],
            const SizedBox(height: AppSpacing.m),
            Row(
              children: [
                Expanded(
                  child: FoodySecondaryButton(label: tr(LocaleKeys.common_cancel), onTap: () => Navigator.of(context).pop()),
                ),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: FoodyPrimaryButton(label: tr(LocaleKeys.common_save), gradient: LinearGradient(colors: [AppColors.primary, AppColors.primary]), onTap: _handleSave),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

