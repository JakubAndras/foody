import 'package:diplomka/app_theme.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/exercise.dart';
import 'package:diplomka/screens/logs/exercise_detail_screen.dart';
import 'package:diplomka/screens/profile/profile_widgets.dart';
import 'package:diplomka/screens/scan/scan_widgets.dart';
import 'package:diplomka/services/ai_feature/ai_pipeline_service.dart';
import 'package:diplomka/widgets/custom_glass_app_bar.dart';
import 'package:diplomka/widgets/foody_glass_buttons.dart';
import 'package:diplomka/widgets/logged_snackbar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class FixExerciseResultScreen extends StatefulWidget {
  final Exercise baseExercise;
  final DateTime? selectedDate;
  final bool openedFromLogScreen;

  const FixExerciseResultScreen({super.key, required this.baseExercise, this.selectedDate, this.openedFromLogScreen = false});

  @override
  State<FixExerciseResultScreen> createState() => _FixExerciseResultScreenState();
}

class _FixExerciseResultScreenState extends State<FixExerciseResultScreen> {
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
                    icon: CupertinoIcons.info,
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
              const Spacer(),
              FoodyPrimaryButton(
                label: _isSubmitting ? tr(LocaleKeys.fix_result_updating) : tr(LocaleKeys.fix_result_update),
                gradient: AppGradients.askAiPrimary,
                onTap: _isSubmitting ? null : _handleUpdate,
              ),
              SizedBox(height: AppSpacing.s),
            ],
          ),
        ),
        if (_showTip)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => setState(() => _showTip = false),
              child: ColoredBox(
                color: AppColors.overlayDark40,
                child: AnimatedPadding(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Center(
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
          ),
      ],
    );
  }

  Future<void> _handleUpdate() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      showSnackBar(context: context, message: tr(LocaleKeys.fix_result_add_details), subtitle: tr(LocaleKeys.fix_result_hint), type: SnackBarType.info);
      return;
    }

    setState(() => _isSubmitting = true);

    final description = '${widget.baseExercise.name}. $text';
    final result = await AiPipelineService.to.analyzeExercise(description: description);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (!result.isSuccess || result.analysis == null) {
      showSnackBar(context: context, message: tr(LocaleKeys.error_exercise_analysis_failed), subtitle: result.message ?? tr(LocaleKeys.common_try_again), type: SnackBarType.error);
      return;
    }

    final answer = result.analysis!.answer;
    final base = widget.baseExercise;
    final updatedExercise = base.copyWith(
      name: answer.name.isNotEmpty ? answer.name : base.name,
      durationMinutes: answer.durationMinutes ?? base.durationMinutes,
      caloriesBurned: answer.caloriesTotal?.toDouble() ?? ((answer.caloriesPerMinute ?? 0) * (answer.durationMinutes ?? 0)).toDouble(),
      confidence: answer.confidence,
    );

    final caloriesBurned = updatedExercise.caloriesBurned;
    final Exercise exerciseToOpen = caloriesBurned > 0 ? updatedExercise : updatedExercise.copyWith(caloriesBurned: base.caloriesBurned);

    Get.off(() => ExerciseDetailScreen(exercise: exerciseToOpen, selectedDate: widget.selectedDate, openedFromLogScreen: widget.openedFromLogScreen));
  }
}
