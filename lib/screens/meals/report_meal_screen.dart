import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/screens/meals/meal_components.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ReportMealScreen extends StatefulWidget {
  const ReportMealScreen({super.key});

  @override
  State<ReportMealScreen> createState() => _ReportMealScreenState();
}

class _ReportMealScreenState extends State<ReportMealScreen> {
  final TextEditingController _controller = TextEditingController();
  static const int _maxLength = 500;
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screen, AppSpacing.s, AppSpacing.screen, AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BackButtonCircle(onTap: () => Navigator.of(context).maybePop()),
              const SizedBox(height: AppSpacing.l),
              Row(
                children: [
                  const Icon(Icons.report_outlined, size: AppSizes.iconMd, color: AppColors.textPrimary),
                  const SizedBox(width: AppSpacing.s),
                  Text(tr(LocaleKeys.report_meal_title), style: AppTextStyles.h1Alt),
                ],
              ),
              const SizedBox(height: AppSpacing.l),
              _FeedbackInput(
                controller: _controller,
                hintText: tr(LocaleKeys.report_meal_hint),
                maxLength: _maxLength,
                onChanged: (_) => setState(() => _errorText = null),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${_controller.text.length}/$_maxLength',
                  style: AppTextStyles.body16Regular.copyWith(
                    color: AppColors.textTertiary,
                    letterSpacing: -0.2344,
                  ),
                ),
              ),
              if (_errorText != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Text(
                    _errorText!,
                    style: AppTextStyles.body14Regular.copyWith(color: AppColors.errorText),
                  ),
                ),
              const SizedBox(height: AppSpacing.m),
              _ExampleCard(
                prefix: tr(LocaleKeys.report_meal_example_prefix),
                text: tr(LocaleKeys.report_meal_example_text),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.edge,
            AppSpacing.s,
            AppSpacing.edge,
            AppSpacing.l + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: GradientPillButton(
            label: _isSubmitting ? tr(LocaleKeys.report_meal_reporting) : tr(LocaleKeys.report_meal_submit),
            gradient: AppGradients.primary,
            onTap: _isSubmitting ? null : _handleReport,
          ),
        ),
      ),
    );
  }

  Future<void> _handleReport() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _errorText = tr(LocaleKeys.report_meal_empty_error));
      return;
    }

    setState(() => _isSubmitting = true);
    await Future<void>.delayed(AppTheme.transitionDuration);
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    Navigator.of(context).maybePop();
  }
}

class _BackButtonCircle extends StatelessWidget {
  final VoidCallback onTap;

  const _BackButtonCircle({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: Ink(
        width: AppSizes.backButtonSize,
        height: AppSizes.backButtonSize,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(color: AppColors.outline),
        ),
        child: const Icon(Icons.chevron_left, size: AppSizes.iconMd, color: AppColors.textPrimary),
      ),
    );
  }
}

class _FeedbackInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLength;
  final ValueChanged<String>? onChanged;

  const _FeedbackInput({
    required this.controller,
    required this.hintText,
    required this.maxLength,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.feedbackInputHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.l),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.textPrimary, width: 2),
      ),
      child: TextField(
        controller: controller,
        maxLength: maxLength,
        maxLines: null,
        style: AppTextStyles.body16Regular.copyWith(letterSpacing: -0.4316),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.inputPlaceholder16,
          border: InputBorder.none,
          counterText: '',
        ),
        onChanged: onChanged,
      ),
    );
  }
}

class _ExampleCard extends StatelessWidget {
  final String prefix;
  final String text;

  const _ExampleCard({required this.prefix, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: RichText(
        text: TextSpan(
          style: AppTextStyles.body16Regular.copyWith(color: AppColors.textPrimary),
          children: [
            TextSpan(text: '$prefix ', style: AppTextStyles.body16.copyWith(fontWeight: FontWeight.w700)),
            TextSpan(text: text),
          ],
        ),
      ),
    );
  }
}
