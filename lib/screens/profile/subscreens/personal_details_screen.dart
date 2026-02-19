import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/controller/weight_entry_controller.dart';
import 'package:diplomka/model/user_profile.dart';
import 'package:diplomka/model/weight_entry.dart';
import 'package:diplomka/screens/profile/profile_widgets.dart';
import 'package:diplomka/services/session_manager.dart';

class PersonalDetailsScreen extends StatelessWidget {
  const PersonalDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return ProfileGradientScaffold(
      scroll: true,
      padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.l, AppSpacing.screen, AppSpacing.xl),
      child: Obx(() {
        final entries = WeightEntryController.to.entries;
        final double? profileWeight = SessionManager.to.weightKg.value;
        final double? heightCm = SessionManager.to.heightCm.value;
        final double? goalWeight = SessionManager.to.goalWeightKg.value;
        final ProfileSex? sex = SessionManager.to.sex.value;
        final DateTime? dob = SessionManager.to.dateOfBirth.value;

        final WeightEntry? latestEntry = _latestWeight(entries);
        final double? currentWeight = latestEntry?.weight ?? profileWeight;

        final String goalLabel = goalWeight == null ? '—' : '${_formatWeight(goalWeight)} kg';
        final String weightLabel = currentWeight == null ? '—' : '${_formatWeight(currentWeight)} kg';
        final String heightLabel = heightCm == null ? '—' : '${_formatHeight(heightCm)} cm';
        final String dobLabel = dob == null ? '—' : _formatDate(dob);
        final String sexLabel = sex?.label ?? '—';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileTopBar(title: 'Personal Details', onBack: () => Get.back()),
            const SizedBox(height: AppSpacing.l),
            ProfileCard(
              radius: AppRadii.lg2,
              shadow: AppShadows.cardSubtle,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen, vertical: AppSpacing.m),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Goal Weight', style: AppTextStyles.body15.copyWith(fontWeight: FontWeight.w500)),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(goalLabel, style: AppTextStyles.title17.copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                  _SmallGradientButton(
                    label: goalWeight == null ? 'Set Goal' : 'Change Goal',
                    onPressed: () => _showNumberSheet(
                      context,
                      title: 'Goal Weight',
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
              radius: AppRadii.lg2,
              shadow: AppShadows.cardSubtle,
              padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.xs, AppSpacing.screen, AppSpacing.xs),
              child: Column(
                children: [
                  _DetailRow(
                    label: 'Current weight',
                    value: weightLabel,
                    onTap: () => _showNumberSheet(
                      context,
                      title: 'Current Weight',
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
                    label: 'Height',
                    value: heightLabel,
                    onTap: () => _showNumberSheet(
                      context,
                      title: 'Height',
                      unit: 'cm',
                      initialValue: heightCm,
                      min: 120,
                      max: 230,
                      fractionDigits: 0,
                      onSaved: (value) => SessionManager.to.setHeightCm(value),
                    ),
                  ),
                  _DetailRow(
                    label: 'Date of birth',
                    value: dobLabel,
                    onTap: () => _showDobSheet(context, initialDate: dob, safeArea: media),
                  ),
                  _DetailRow(
                    label: 'Gender',
                    value: sexLabel,
                    showDivider: false,
                    onTap: () => _showSexSheet(context, sex),
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
    required MediaQueryData safeArea,
  }) async {
    final now = DateTime.now();
    final initial = initialDate ?? DateTime(now.year - 25, now.month, now.day);
    DateTime selected = initial;
    final bottomInset = safeArea.viewInsets.bottom;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.screen, AppSpacing.screen, AppSpacing.screen + bottomInset),
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadii.xl),
                boxShadow: AppShadows.modal,
              ),
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SheetHeader(
                    title: 'Date of Birth',
                    onClose: () => Navigator.of(context).pop(),
                  ),
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
                  ProfilePrimaryButton(
                    label: 'Save',
                    onPressed: () async {
                      await SessionManager.to.setDateOfBirth(selected);
                      if (context.mounted) Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showSexSheet(BuildContext context, ProfileSex? current) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              boxShadow: AppShadows.sheet,
            ),
            padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.m, AppSpacing.l, AppSpacing.m),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: ProfileSex.values.map((sex) {
                final isSelected = sex == current;
                return InkWell(
                  onTap: () async {
                    await SessionManager.to.setSex(sex);
                    if (context.mounted) Navigator.of(context).pop();
                  },
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  child: SizedBox(
                    height: AppSizes.actionRowHeight,
                    child: Row(
                      children: [
                        SizedBox(
                          width: AppSizes.iconLg,
                          child: isSelected
                              ? const Icon(Icons.check, color: AppColors.textPrimary, size: AppSizes.iconMd)
                              : const SizedBox(width: AppSizes.iconMd),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            sex.label,
                            style: AppTextStyles.selectMealPickerItem.copyWith(color: AppColors.textHeading),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
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
      backgroundColor: Colors.transparent,
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
    this.showDivider = true,
    this.onTap,
  });

  final String label;
  final String value;
  final bool showDivider;
  final VoidCallback? onTap;

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
                  child: Text(label, style: AppTextStyles.body15.copyWith(fontWeight: FontWeight.w400)),
                ),
                Text(value, style: AppTextStyles.body15.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(width: AppSpacing.s),
                const Icon(Icons.edit_outlined, size: AppSizes.iconSm, color: AppColors.textTertiary),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(height: AppSizes.dividerThin, color: AppColors.surfaceMuted),
      ],
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.title, required this.onClose});

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.w700)),
        SizedBox(
          width: AppSizes.iconButtonSm,
          height: AppSizes.iconButtonSm,
          child: Material(
            color: AppColors.surfaceMuted,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onClose,
              customBorder: const CircleBorder(),
              child: const Icon(Icons.close, size: AppSizes.iconMd, color: AppColors.textSecondary),
            ),
          ),
        ),
      ],
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
      setState(() => _errorText = 'Enter a value between ${widget.min} and ${widget.max}.');
      return;
    }
    final normalized = double.parse(value.toStringAsFixed(widget.fractionDigits));
    widget.onSaved(normalized);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.screen, AppSpacing.screen, AppSpacing.screen + bottomInset),
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.xl),
            boxShadow: AppShadows.modal,
          ),
          padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.l, AppSpacing.l, AppSpacing.l),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SheetHeader(title: widget.title, onClose: () => Navigator.of(context).pop()),
              const SizedBox(height: AppSpacing.l),
              _NumberField(
                controller: _controller,
                unit: widget.unit,
                onChanged: () => setState(() => _errorText = null),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _errorText!,
                  style: AppTextStyles.body14Regular.copyWith(color: AppColors.errorText),
                ),
              ],
              const SizedBox(height: AppSpacing.l),
              ProfilePrimaryButton(
                label: 'Save',
                onPressed: _handleSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({required this.controller, required this.unit, required this.onChanged});

  final TextEditingController controller;
  final String unit;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                hintText: '0',
              ),
              style: AppTextStyles.title17.copyWith(fontWeight: FontWeight.w600),
              onChanged: (_) => onChanged(),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(unit, style: AppTextStyles.body15.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
