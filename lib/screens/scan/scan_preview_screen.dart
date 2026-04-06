import 'package:diplomka/app_theme.dart';
import 'package:diplomka/widgets/sheet_drag_handle.dart';
import 'package:diplomka/controller/dashboard_controller.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/screens/main_screen.dart';
import 'package:diplomka/screens/scan/scan_widgets.dart';
import 'package:diplomka/services/selected_date_service.dart';
import 'package:diplomka/widgets/custom_glass_app_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class ScanPreviewScreen extends StatefulWidget {
  const ScanPreviewScreen({super.key, required this.imagePath});

  final String? imagePath;

  @override
  State<ScanPreviewScreen> createState() => _ScanPreviewScreenState();
}

class _ScanPreviewScreenState extends State<ScanPreviewScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isAnalyzing = false;

  DateTime get _selectedDate => SelectedDateService.to.selectedDate.value;

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _analyze() {
    if (_isAnalyzing) return;
    setState(() => _isAnalyzing = true);
    final description = _buildDescription();

    DashboardController.to.analyzeMealFromImage(
      selectedDate: _selectedDate,
      imagePath: widget.imagePath,
      description: description,
      preferredMealName: _nameController.text.trim(),
      scrollToTodayMealsOnStart: true,
    );

    if (Get.isRegistered<MainScreenController>()) {
      MainScreenController.to.showDashboardTab();
    }
    Get.until((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return LiquidGlassScope(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: AppColors.background,
        appBar: CustomGlassAppBar(
          leadingIconSize: AppSizes.iconLg,
          horizontalPadding: AppSpacing.m,
          onBack: () => Get.back(),
          actions: [
            CustomGlassIconButtonGroup(
              items: [(icon: CupertinoIcons.arrow_counterclockwise, onPressed: () => Get.back()), (icon: CupertinoIcons.info, onPressed: () => _showPreviewTips(context))],
            ),
          ],
        ),
        body: LiquidGlassBackground(
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(AppSpacing.m, 0, AppSpacing.m, AppSpacing.s),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: AppSpacing.m),
                            ScanPreviewImage(imagePath: widget.imagePath, hasShadow: false),
                            const SizedBox(height: AppSpacing.m),
                            ScanInputField(
                              hint: tr(LocaleKeys.scan_preview_notes_hint),
                              controller: _notesController,
                              height: AppSizes.scanTextAreaHeight,
                              maxLines: 3,
                              hasShadow: false,
                            ),
                          ],
                        ),
                      ),
                      if (_isAnalyzing)
                        Positioned.fill(
                          child: Container(
                            color: AppColors.overlayDark40,
                            child: Center(child: CircularProgressIndicator(color: AppColors.onPrimary)),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.m),
                  child: ScanPrimaryButton(
                    label: tr(LocaleKeys.scan_preview_analyze),
                    icon: CupertinoIcons.sparkles,
                    gradient: AppGradients.askAiPrimary,
                    onPressed: _isAnalyzing ? null : _analyze,
                    height: AppSizes.scanAnalyzeButtonHeight,
                    hasShadow: false,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPreviewTips(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.l)),
        ),
        padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.m, AppSpacing.l, AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SheetDragHandle(color: AppColors.outline),
            const SizedBox(height: AppSpacing.l),
            Text(tr(LocaleKeys.scan_preview_tips_title), style: AppTextStyles.title18.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.m),
            _PreviewTipRow(icon: CupertinoIcons.pencil, text: tr(LocaleKeys.scan_preview_tip_add_description)),
            _PreviewTipRow(icon: CupertinoIcons.camera, text: tr(LocaleKeys.scan_preview_tip_retake_blurry)),
            _PreviewTipRow(icon: CupertinoIcons.eye, text: tr(LocaleKeys.scan_preview_tip_all_visible)),
            _PreviewTipRow(icon: CupertinoIcons.slider_horizontal_3, text: tr(LocaleKeys.scan_preview_tip_review_results)),
          ],
        ),
      ),
    );
  }

  String? _buildDescription() {
    final name = _nameController.text.trim();
    final notes = _notesController.text.trim();
    if (name.isEmpty && notes.isEmpty) return null;
    if (name.isNotEmpty && notes.isNotEmpty) {
      return '$name. $notes';
    }
    return name.isNotEmpty ? name : notes;
  }
}

class _PreviewTipRow extends StatelessWidget {
  const _PreviewTipRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: AppSizes.iconMd, color: AppColors.primary),
          const SizedBox(width: AppSpacing.s),
          Expanded(child: Text(text, style: AppTextStyles.body14Relaxed)),
        ],
      ),
    );
  }
}
