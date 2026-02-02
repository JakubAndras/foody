import 'package:diplomka/app_theme.dart';
import 'package:diplomka/controller/weight_entry_controller.dart';
import 'package:diplomka/model/weight_entry.dart';
import 'package:diplomka/screens/meals/meal_sheets.dart';
import 'package:diplomka/screens/profile/profile_widgets.dart';
import 'package:diplomka/widgets/edit_flow/edit_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

Future<void> showWeightLogSheet(BuildContext context, {WeightEntry? entry}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => WeightLogSheet(entry: entry),
  );
}

class WeightLogSheet extends StatefulWidget {
  const WeightLogSheet({super.key, this.entry});

  final WeightEntry? entry;

  @override
  State<WeightLogSheet> createState() => _WeightLogSheetState();
}

class _WeightLogSheetState extends State<WeightLogSheet> {
  late final TextEditingController _weightController;
  late DateTime _selectedDate;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    final initialWeight = widget.entry?.weight;
    _weightController = TextEditingController(
      text: initialWeight == null ? '' : _formatWeight(initialWeight),
    );
    _selectedDate = widget.entry?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.entry != null;

  String _formatWeight(double value) {
    final bool isInt = value % 1 == 0;
    return value.toStringAsFixed(isInt ? 0 : 1);
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMMM d, yyyy').format(date);
  }

  DateTime _applyDate(DateTime base, DateTime date) {
    return DateTime(date.year, date.month, date.day, base.hour, base.minute);
  }

  double? _parseWeight() {
    final raw = _weightController.text.trim().replaceAll(',', '.');
    if (raw.isEmpty) return null;
    final value = double.tryParse(raw);
    if (value == null || value <= 0) return null;
    return value;
  }

  Future<void> _handleSave() async {
    final weight = _parseWeight();
    if (weight == null) {
      setState(() => _errorText = 'Enter a valid weight.');
      return;
    }

    final baseDate = widget.entry?.date ?? DateTime.now();
    final date = _applyDate(baseDate, _selectedDate);
    final entry = WeightEntry(
      id: widget.entry?.id,
      date: date,
      weight: weight,
    );
    await WeightEntryController.to.saveEntry(entry);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _handleDelete() async {
    final entry = widget.entry;
    if (entry == null) return;
    final confirm = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: EditConfirmSheet(
          title: 'Delete entry?',
          message: 'This weight record will be removed.',
          confirmLabel: 'Delete',
          cancelLabel: 'Cancel',
          confirmColor: AppColors.destructive,
          onCancel: () => Navigator.of(context).pop(false),
          onConfirm: () => Navigator.of(context).pop(true),
        ),
      ),
    );

    if (confirm != true) return;
    await WeightEntryController.to.deleteEntry(entry);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _openDatePicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        DateTime month = DateTime(_selectedDate.year, _selectedDate.month);
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: StatefulBuilder(
            builder: (context, setSheetState) => DatePickerCard(
              month: month,
              selectedDate: _selectedDate,
              onSelected: (date) {
                setState(() {
                  _selectedDate = _applyDate(_selectedDate, date);
                });
                Navigator.of(context).pop();
              },
              onPrevMonth: () => setSheetState(() {
                month = DateTime(month.year, month.month - 1);
              }),
              onNextMonth: () => setSheetState(() {
                month = DateTime(month.year, month.month + 1);
              }),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final title = _isEditing ? 'Edit Entry' : 'Log Weight';

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
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
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
                        onTap: () => Navigator.of(context).pop(),
                        customBorder: const CircleBorder(),
                        child: const Icon(Icons.close, size: AppSizes.iconMd, color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _LabelledField(
                label: 'WEIGHT',
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _weightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                        ],
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isCollapsed: true,
                          hintText: '0',
                        ),
                        style: AppTextStyles.title17.copyWith(fontWeight: FontWeight.w600),
                        onChanged: (_) => setState(() => _errorText = null),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text('kg', style: AppTextStyles.body15.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _LabelledField(
                label: 'DATE',
                onTap: _openDatePicker,
                child: Text(
                  _formatDate(_selectedDate),
                  style: AppTextStyles.title17.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(_errorText!, style: AppTextStyles.body14.copyWith(color: AppColors.error)),
              ],
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  if (_isEditing) ...[
                    Expanded(
                      child: _DangerButton(label: 'Delete', icon: Icons.delete_outline, onPressed: _handleDelete),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Expanded(
                    child: ProfilePrimaryButton(
                      label: 'Save',
                      height: AppSizes.buttonHeightSm,
                      radius: AppRadii.md,
                      onPressed: _handleSave,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LabelledField extends StatelessWidget {
  const _LabelledField({required this.label, required this.child, this.onTap});

  final String label;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelUpper.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: AppSpacing.xs),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: Container(
            height: AppSizes.inputHeightSm,
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: AppColors.surfaceCardBorder),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: child,
          ),
        ),
      ],
    );
  }
}

class _DangerButton extends StatelessWidget {
  const _DangerButton({required this.label, required this.icon, this.onPressed});

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.buttonHeightSm,
      child: Material(
        color: AppColors.dangerSoft,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: AppSizes.iconMd, color: AppColors.danger),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: AppTextStyles.title17.copyWith(color: AppColors.danger, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
