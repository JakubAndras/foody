import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/meal.dart';
import 'package:diplomka/screens/meals/edit_meal_screen.dart';
import 'package:diplomka/screens/meals/meal_components.dart';
import 'package:diplomka/screens/profile/profile_widgets.dart';
import 'package:diplomka/screens/scan/scan_widgets.dart';
import 'package:diplomka/services/ai_feature/ai_pipeline_service.dart';
import 'package:diplomka/utils/media_storage.dart';
import 'package:diplomka/widgets/custom_glass_app_bar.dart';
import 'package:diplomka/widgets/foody_glass_buttons.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
  bool _showTip = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ProfileGradientScaffold(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileTopBar(
                title: tr(LocaleKeys.fix_result_title),
                onBack: () => Navigator.of(context).maybePop(),
                actions: [
                  CustomGlassIconButton(
                    icon: Icons.help_outline,
                    onPressed: () => setState(() => _showTip = true),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.m),
              TextField(
                controller: _controller,
                maxLength: _maxLength,
                maxLines: null,
                minLines: 5,
                textCapitalization: TextCapitalization.sentences,
                style: AppTextStyles.body16,
                decoration: InputDecoration(
                  hintText: tr(LocaleKeys.fix_result_hint),
                  hintStyle: AppTextStyles.body16.copyWith(color: AppColors.textTertiary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.l), borderSide: BorderSide(color: AppColors.borderStrong)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.l), borderSide: BorderSide(color: AppColors.borderStrong)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadii.l), borderSide: BorderSide(color: AppColors.textPrimary, width: 1.5)),
                  contentPadding: const EdgeInsets.all(AppSpacing.l),
                  counterText: '',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.xs),
              Align(
                alignment: Alignment.centerRight,
                child: Text('${_controller.text.length}/$_maxLength', style: AppTextStyles.body13.copyWith(color: AppColors.textTertiary)),
              ),
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
            ],
          ),
        ),
        if (_showTip)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => setState(() => _showTip = false),
              child: ColoredBox(
                color: AppColors.overlayDark40,
                child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                    child: ScanTipOverlay(
                      title: tr(LocaleKeys.fix_result_title),
                      body: tr(LocaleKeys.fix_result_tip_body),
                      onDismiss: () => setState(() => _showTip = false),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
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
