import 'package:diplomka/app_theme.dart';
import 'package:diplomka/controller/weight_entry_controller.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/weight_entry.dart';
import 'package:diplomka/screens/meals/meal_sheets.dart';
import 'package:diplomka/screens/profile/profile_widgets.dart';
import 'package:diplomka/widgets/edit_flow/edit_flow_widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

Future<void> showWeightLogSheet(BuildContext context, {WeightEntry? entry}) async {
  await Navigator.of(context, rootNavigator: true).push(MaterialPageRoute<void>(builder: (_) => WeightLogSheet(entry: entry)));
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
  bool _isSaving = false;
  bool _hasTypedWeight = false;

  @override
  void initState() {
    super.initState();
    final latestWeight = WeightEntryController.to.latestEntry?.weight;
    final initialWeight = widget.entry?.weight ?? latestWeight;
    _weightController = TextEditingController(text: initialWeight == null ? '' : _formatWeight(initialWeight));
    final now = DateTime.now();
    _selectedDate = widget.entry?.date ?? DateTime(now.year, now.month, now.day);

    if (widget.entry == null && initialWeight == null) {
      WeightEntryController.to.refreshEntries().then((_) {
        if (!mounted || _hasTypedWeight || _weightController.text.trim().isNotEmpty) return;
        final refreshedLatest = WeightEntryController.to.latestEntry?.weight;
        if (refreshedLatest == null) return;
        _weightController.text = _formatWeight(refreshedLatest);
      });
    }
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
    if (_isSaving) return;

    final weight = _parseWeight();
    if (weight == null) {
      setState(() => _errorText = tr(LocaleKeys.weight_log_invalid_weight));
      return;
    }

    final baseDate = widget.entry?.date ?? DateTime.now();
    final date = _applyDate(baseDate, _selectedDate);
    final entry = WeightEntry(id: widget.entry?.id, date: date, weight: weight);
    setState(() => _isSaving = true);
    try {
      await WeightEntryController.to.saveEntry(entry);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr(LocaleKeys.weight_log_save_failed))));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _handleDelete() async {
    final entry = widget.entry;
    if (entry == null) return;
    final confirm = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: EditConfirmSheet(
          title: tr(LocaleKeys.weight_log_delete_entry),
          message: tr(LocaleKeys.weight_log_delete_message),
          confirmLabel: tr(LocaleKeys.common_delete),
          cancelLabel: tr(LocaleKeys.common_cancel),
          confirmColor: AppColors.error,
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
    FocusScope.of(context).unfocus();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl))),
      clipBehavior: Clip.antiAlias,
      builder: (context) {
        DateTime month = DateTime(_selectedDate.year, _selectedDate.month);
        return SafeArea(
          top: false,
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
    final title = _isEditing ? tr(LocaleKeys.weight_log_title_edit) : tr(LocaleKeys.weight_log_title_log);

    return ProfileGradientScaffold(
      scroll: true,
      padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, AppSpacing.xl),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width - (AppSpacing.screen * 2),
        child: Row(
          children: [
            if (_isEditing) ...[
              Expanded(
                child: _DangerButton(label: tr(LocaleKeys.common_delete), icon: Icons.delete_outline, onPressed: _handleDelete),
              ),
              const SizedBox(width: AppSpacing.s),
            ],
            Expanded(
              child: ProfilePrimaryButton(
                label: _isSaving ? tr(LocaleKeys.common_saving) : tr(LocaleKeys.common_save),
                height: AppSizes.buttonHeight,
                onPressed: _isSaving ? null : _handleSave,
              ),
            ),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileTopBar(title: title, onBack: () => Navigator.of(context).maybePop()),
          const SizedBox(height: AppSpacing.l),
          _LabelledField(
            label: tr(LocaleKeys.weight_log_label_weight),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                    decoration: const InputDecoration(border: InputBorder.none, isCollapsed: true, hintText: '0'),
                    style: AppTextStyles.title17.copyWith(fontWeight: FontWeight.w600),
                    onChanged: (_) => setState(() {
                      _hasTypedWeight = true;
                      _errorText = null;
                    }),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(tr(LocaleKeys.common_kg), style: AppTextStyles.body15.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          _LabelledField(
            label: tr(LocaleKeys.weight_log_label_date),
            onTap: _openDatePicker,
            child: Text(_formatDate(_selectedDate), style: AppTextStyles.title17.copyWith(fontWeight: FontWeight.w600)),
          ),
          if (_errorText != null) ...[const SizedBox(height: AppSpacing.s), Text(_errorText!, style: AppTextStyles.body14.copyWith(color: AppColors.error))],
          const SizedBox(height: AppSpacing.huge),
        ],
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
            height: AppSizes.buttonHeightSm,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: AppColors.surface),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
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
        color: AppColors.errorContainer,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: AppSizes.iconMd, color: AppColors.error),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: AppTextStyles.title17.copyWith(color: AppColors.error, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
