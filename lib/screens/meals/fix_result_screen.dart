import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/meal.dart';
import 'package:diplomka/screens/meals/edit_meal_screen.dart';
import 'package:diplomka/screens/meals/meal_components.dart';
import 'package:diplomka/services/ai_feature/ai_pipeline_service.dart';
import 'package:diplomka/utils/media_storage.dart';
import 'package:diplomka/widgets/custom_glass_app_bar.dart';
import 'package:diplomka/widgets/foody_glass_buttons.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class FixResultScreen extends StatefulWidget {
  final bool showSyncCards;
  final Meal? baseMeal;
  final DateTime? selectedDate;
  final bool isNewMeal;

  const FixResultScreen({super.key, this.showSyncCards = false, this.baseMeal, this.selectedDate, this.isNewMeal = false});

  @override
  State<FixResultScreen> createState() => _FixResultScreenState();
}

class _FixResultScreenState extends State<FixResultScreen> {
  final TextEditingController _controller = TextEditingController();
  static const int _maxLength = 500;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LiquidGlassScope(
      child: Scaffold(
        backgroundColor: AppColors.background,
        extendBodyBehindAppBar: true,
        body: LiquidGlassBackground(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.s),
                  CustomGlassIconButton(icon: Icons.chevron_left, onPressed: () => Navigator.of(context).maybePop()),
                  const SizedBox(height: AppSpacing.l),
                  Row(
                    children: [
                      const Icon(Icons.auto_fix_high, size: AppSizes.iconMd, color: AppColors.textPrimary),
                      const SizedBox(width: AppSpacing.s),
                      Text(tr(LocaleKeys.fix_result_title), style: AppTextStyles.h1.copyWith(fontSize: 32)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.l),
                  _FeedbackInput(controller: _controller, hintText: tr(LocaleKeys.fix_result_hint), maxLength: _maxLength, onChanged: (_) => setState(() {})),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('${_controller.text.length}/$_maxLength', style: AppTextStyles.body15.copyWith(color: AppColors.textTertiary)),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  _ExampleCard(prefix: tr(LocaleKeys.fix_result_example_prefix), text: tr(LocaleKeys.fix_result_example_text)),
                  if (widget.showSyncCards) ...[
                    const SizedBox(height: AppSpacing.l),
                    SyncCard(title: tr(LocaleKeys.meal_sync_macros_prompt), primaryLabel: tr(LocaleKeys.meal_sync), secondaryLabel: tr(LocaleKeys.meal_dont_sync)),
                    const SizedBox(height: AppSpacing.m),
                    SyncCard(title: tr(LocaleKeys.meal_sync_calories_prompt), primaryLabel: tr(LocaleKeys.meal_sync), secondaryLabel: tr(LocaleKeys.meal_dont_sync)),
                    const SizedBox(height: AppSpacing.m),
                    SyncCard(title: tr(LocaleKeys.meal_always_sync), primaryLabel: tr(LocaleKeys.meal_always_sync), secondaryLabel: tr(LocaleKeys.meal_decide_later)),
                  ],
                  const Spacer(),
                  FoodyPrimaryButton(
                    label: _isSubmitting ? tr(LocaleKeys.fix_result_updating) : tr(LocaleKeys.fix_result_update),
                    gradient: AppGradients.askAiPrimary,
                    onTap: _isSubmitting ? null : _handleUpdate,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleUpdate() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      Get.snackbar(tr(LocaleKeys.fix_result_add_details), tr(LocaleKeys.fix_result_hint));
      return;
    }

    setState(() => _isSubmitting = true);
    final photoPath = widget.baseMeal?.photoPath;
    final photoFile = MediaStorage.existingMealPhotoFile(photoPath);
    final imageFiles = photoFile == null ? null : [photoFile];
    final result = await AiPipelineService.to.analyzeMeal(imageFiles: imageFiles, description: text);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (!result.isSuccess || result.response == null) {
      Get.snackbar(tr(LocaleKeys.error_analysis_failed), result.message ?? tr(LocaleKeys.common_try_again));
      return;
    }

    if (result.status == AiAnalysisStatus.lowConfidence) {
      Get.snackbar(tr(LocaleKeys.error_low_confidence), result.message ?? tr(LocaleKeys.error_low_confidence_review));
    }

    final analyzedMeal = Meal.fromAnswer(result.response!.answer);
    final baseMeal = widget.baseMeal;
    final updatedMeal = analyzedMeal.copyWith(
      id: baseMeal?.id,
      dayRecordId: baseMeal?.dayRecordId,
      timestamp: baseMeal?.timestamp ?? DateTime.now(),
      photoPath: baseMeal?.photoPath,
      name: analyzedMeal.name.isEmpty && baseMeal != null ? baseMeal.name : analyzedMeal.name,
    );

    Get.off(() => EditMealScreen(meal: updatedMeal, isNewMeal: widget.isNewMeal, selectedDate: widget.selectedDate));
  }
}

class _FeedbackInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLength;
  final ValueChanged<String>? onChanged;

  const _FeedbackInput({required this.controller, required this.hintText, required this.maxLength, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.feedbackInputHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.l),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.m),
        border: Border.all(color: AppColors.textPrimary, width: 2),
      ),
      child: TextField(
        controller: controller,
        maxLength: maxLength,
        maxLines: null,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.body16.copyWith(color: AppColors.textTertiary),
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
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadii.m)),
      child: RichText(
        text: TextSpan(
          style: AppTextStyles.body15.copyWith(color: AppColors.textPrimary),
          children: [
            TextSpan(
              text: '$prefix ',
              style: AppTextStyles.body15.copyWith(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: text),
          ],
        ),
      ),
    );
  }
}
