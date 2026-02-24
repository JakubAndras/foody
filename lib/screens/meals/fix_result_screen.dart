import 'package:diplomka/app_theme.dart';
import 'package:diplomka/model/meal.dart';
import 'package:diplomka/screens/meals/edit_meal_screen.dart';
import 'package:diplomka/screens/meals/meal_components.dart';
import 'package:diplomka/services/ai_feature/ai_pipeline_service.dart';
import 'package:diplomka/utils/media_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FixResultScreen extends StatefulWidget {
  final bool showSyncCards;
  final Meal? baseMeal;
  final DateTime? selectedDate;
  final bool isNewMeal;

  const FixResultScreen({
    super.key,
    this.showSyncCards = false,
    this.baseMeal,
    this.selectedDate,
    this.isNewMeal = false,
  });

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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.s),
              _BackButtonCircle(onTap: () => Navigator.of(context).maybePop()),
              const SizedBox(height: AppSpacing.l),
              Row(
                children: [
                  const Icon(Icons.auto_fix_high, size: AppSizes.iconMd, color: AppColors.textPrimary),
                  const SizedBox(width: AppSpacing.s),
                  Text('Fix result', style: AppTextStyles.h1Alt),
                ],
              ),
              const SizedBox(height: AppSpacing.l),
              _FeedbackInput(
                controller: _controller,
                hintText: 'Describe what needs to be fixed.',
                maxLength: _maxLength,
                onChanged: (_) => setState(() {}),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${_controller.text.length}/$_maxLength',
                  style: AppTextStyles.body15.copyWith(color: AppColors.textTertiary),
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              _ExampleCard(
                text: 'The smoothie is missing the strawberry and almond milk.',
              ),
              if (widget.showSyncCards) ...[
                const SizedBox(height: AppSpacing.l),
                SyncCard(
                  title: 'Calories changed. Sync macros to match?',
                  primaryLabel: 'Sync',
                  secondaryLabel: "Don't sync",
                ),
                const SizedBox(height: AppSpacing.m),
                SyncCard(
                  title: 'Macros changed. Sync calories to match?',
                  primaryLabel: 'Sync',
                  secondaryLabel: "Don't sync",
                ),
                const SizedBox(height: AppSpacing.m),
                SyncCard(
                  title: 'Always sync automatically?',
                  primaryLabel: 'Always sync',
                  secondaryLabel: 'Decide later',
                ),
              ],
              const Spacer(),
              GradientPillButton(
                label: _isSubmitting ? 'Updating...' : 'Update',
                gradient: AppGradients.askAiPrimary,
                onTap: _isSubmitting ? null : _handleUpdate,
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleUpdate() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      Get.snackbar('Add details', 'Describe what needs to be fixed.');
      return;
    }

    setState(() => _isSubmitting = true);
    final photoPath = widget.baseMeal?.photoPath;
    final photoFile = MediaStorage.existingMealPhotoFile(photoPath);
    final imageFiles = photoFile == null ? null : [photoFile];
    final result = await AiPipelineService.to.analyzeMeal(
      imageFiles: imageFiles,
      description: text,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (!result.isSuccess || result.response == null) {
      Get.snackbar('Analysis failed', result.message ?? 'Please try again.');
      return;
    }

    if (result.status == AiAnalysisStatus.lowConfidence) {
      Get.snackbar('Low confidence', result.message ?? 'Please review the result.');
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

    Get.off(() => EditMealScreen(
          meal: updatedMeal,
          isNewMeal: widget.isNewMeal,
          selectedDate: widget.selectedDate,
        ));
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
  final String text;

  const _ExampleCard({required this.text});

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
          style: AppTextStyles.body15.copyWith(color: AppColors.textPrimary),
          children: [
            TextSpan(text: 'Example: ', style: AppTextStyles.body15.copyWith(fontWeight: FontWeight.w700)),
            TextSpan(text: text),
          ],
        ),
      ),
    );
  }
}
