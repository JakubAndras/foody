import 'package:diplomka/app_theme.dart';
import 'package:diplomka/services/session_manager.dart';
import 'package:diplomka/widgets/onboarding/onboarding_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OnboardingHeightWeightScreen extends StatefulWidget {
  const OnboardingHeightWeightScreen({
    super.key,
    required this.onNext,
    required this.onBack,
    required this.step,
    required this.totalSteps,
  });

  final VoidCallback onNext;
  final VoidCallback onBack;
  final int step;
  final int totalSteps;

  @override
  State<OnboardingHeightWeightScreen> createState() => _OnboardingHeightWeightScreenState();
}

class _OnboardingHeightWeightScreenState extends State<OnboardingHeightWeightScreen> {
  bool _metric = true;
  late final List<int> _heightValues;
  late final List<int> _weightValues;
  int _heightIndex = 0;
  int _weightIndex = 0;

  @override
  void initState() {
    super.initState();
    _heightValues = List.generate(120, (index) => 140 + index);
    _weightValues = List.generate(140, (index) => 40 + index);
    _heightIndex = (_heightValues.length / 2).floor();
    _weightIndex = (_weightValues.length / 2).floor();

    final double? storedHeight = SessionManager.to.heightCm.value;
    final double? storedWeight = SessionManager.to.weightKg.value;
    if (storedHeight != null) {
      final int index = storedHeight.round() - _heightValues.first;
      _heightIndex = index.clamp(0, _heightValues.length - 1);
    }
    if (storedWeight != null) {
      final int index = storedWeight.round() - _weightValues.first;
      _weightIndex = index.clamp(0, _weightValues.length - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return OnboardingPage(
      progress: widget.step / widget.totalSteps,
      onBack: widget.onBack,
      bottom: OnboardingPrimaryButton(
        label: 'Continue',
        onPressed: () async {
          await SessionManager.to.setHeightCm(_heightValues[_heightIndex].toDouble());
          await SessionManager.to.setWeightKg(_weightValues[_weightIndex].toDouble());
          widget.onNext();
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Height & weight', style: textTheme.headlineLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'This will be used to calibrate your custom plan.',
            style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: _UnitToggle(
              metric: _metric,
              onChanged: (value) => setState(() => _metric = value),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text('Height', style: textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    _PickerColumn(
                      values: _heightValues.map((value) => '$value cm').toList(),
                      initialIndex: _heightIndex,
                      onSelected: (index) => _heightIndex = index,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  children: [
                    Text('Weight', style: textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    _PickerColumn(
                      values: _weightValues.map((value) => '$value kg').toList(),
                      initialIndex: _weightIndex,
                      onSelected: (index) => _weightIndex = index,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UnitToggle extends StatelessWidget {
  const _UnitToggle({required this.metric, required this.onChanged});

  final bool metric;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Imperial',
          style: textTheme.titleSmall?.copyWith(
            color: metric ? AppColors.textTertiary : AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        GestureDetector(
          onTap: () => onChanged(!metric),
          child: Container(
            width: AppSizes.toggleWidth,
            height: AppSizes.toggleHeight,
            padding: const EdgeInsets.all(AppSpacing.xxs),
            decoration: BoxDecoration(
              gradient: AppGradients.primary,
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            child: AnimatedAlign(
              alignment: metric ? Alignment.centerRight : Alignment.centerLeft,
              duration: const Duration(milliseconds: 200),
              child: Container(
                width: AppSizes.toggleHeight - AppSpacing.xs,
                height: AppSizes.toggleHeight - AppSpacing.xs,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          'Metric',
          style: textTheme.titleSmall?.copyWith(
            color: metric ? AppColors.textPrimary : AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

class _PickerColumn extends StatefulWidget {
  const _PickerColumn({
    required this.values,
    required this.initialIndex,
    required this.onSelected,
  });

  final List<String> values;
  final int initialIndex;
  final ValueChanged<int> onSelected;

  @override
  State<_PickerColumn> createState() => _PickerColumnState();
}

class _PickerColumnState extends State<_PickerColumn> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex.clamp(0, widget.values.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle selectedStyle = Theme.of(context).textTheme.titleMedium!.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        );

    final TextStyle unselectedStyle = Theme.of(context).textTheme.bodyLarge!.copyWith(
          color: AppColors.textTertiary,
        );

    return SizedBox(
      height: AppSizes.pickerHeight,
      child: CupertinoPicker(
        itemExtent: AppSizes.pickerItemHeight,
        squeeze: 1.1,
        useMagnifier: true,
        magnification: 1.0,
        selectionOverlay: Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          decoration: BoxDecoration(
            color: AppColors.surfaceSubtle,
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
        ),
        onSelectedItemChanged: (index) {
          setState(() => _selectedIndex = index);
          widget.onSelected(index);
        },
        children: List.generate(widget.values.length, (index) {
          return Center(
            child: Text(
              widget.values[index],
              style: index == _selectedIndex ? selectedStyle : unselectedStyle,
            ),
          );
        }),
      ),
    );
  }
}
