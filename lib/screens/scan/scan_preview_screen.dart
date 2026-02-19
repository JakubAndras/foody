import 'package:diplomka/app_theme.dart';
import 'package:diplomka/controller/dashboard_controller.dart';
import 'package:diplomka/screens/main_screen.dart';
import 'package:diplomka/screens/scan/scan_widgets.dart';
import 'package:diplomka/services/selected_date_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScanPreviewScreen extends StatefulWidget {
  const ScanPreviewScreen({
    super.key,
    required this.imagePath,
  });

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
    );

    if (Get.isRegistered<MainScreenController>()) {
      MainScreenController.to.showDashboardTab();
    }
    Get.until((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(AppSpacing.l, 0, AppSpacing.l, AppSpacing.s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildTopBar(),
                  const SizedBox(height: AppSpacing.l),
                  ScanPreviewImage(
                    imagePath: widget.imagePath,
                    hasShadow: false,
                  ),
                  const SizedBox(height: AppSpacing.l),
                  ScanInputField(
                    hint: 'Add notes or description (optional)',
                    controller: _notesController,
                    height: AppSizes.scanTextAreaHeight,
                    maxLines: 3,
                    hasShadow: false,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  ScanPrimaryButton(
                    label: 'Analyze Meal',
                    icon: Icons.auto_awesome,
                    gradient: AppGradients.scanAnalyze,
                    onPressed: _isAnalyzing ? null : _analyze,
                    height: AppSizes.scanAnalyzeButtonHeight,
                    hasShadow: false,
                  ),
                ],
              ),
            ),
            if (_isAnalyzing)
              Positioned.fill(
                child: Container(
                  color: AppColors.overlayDark40,
                  child: const Center(child: CircularProgressIndicator(color: AppColors.onPrimary)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ScanCircleButton(
          icon: Icons.close,
          onPressed: () => Get.back(),
          backgroundColor: AppColors.surface,
          shadow: const <BoxShadow>[],
          border: Border.all(color: AppColors.outline, width: 1.08),
        ),
        Container(
          height: AppSizes.scanTopButtonSize,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(color: AppColors.outline, width: 1.08),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Text('Retake', style: AppTextStyles.body16.copyWith(fontWeight: FontWeight.w500)),
              ),
              const SizedBox(width: AppSpacing.s),
              GestureDetector(
                onTap: () => Get.snackbar('Help', 'Tips for better scans are available on the onboarding screens.'),
                child: Text('Help', style: AppTextStyles.body16.copyWith(fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
      ],
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
