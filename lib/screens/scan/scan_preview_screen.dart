import 'dart:io';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/model/ai_response.dart';
import 'package:diplomka/model/meal.dart';
import 'package:diplomka/screens/meals/edit_meal_screen.dart';
import 'package:diplomka/screens/meals/fix_result_screen.dart';
import 'package:diplomka/screens/scan/scan_widgets.dart';
import 'package:diplomka/services/ai_feature/ai_pipeline_service.dart';
import 'package:diplomka/utils/media_storage.dart';
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
  String? _persistedPhotoPath;

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    setState(() => _isAnalyzing = true);
    final description = _buildDescription();
    final String? resolvedPhotoPath = await _resolvePhotoPath();
    final imageFiles = resolvedPhotoPath == null ? null : [File(resolvedPhotoPath)];
    final result = await AiPipelineService.to.analyzeMeal(
      imageFiles: imageFiles,
      description: description,
    );
    if (!mounted) return;
    setState(() => _isAnalyzing = false);

    if (result.status == AiAnalysisStatus.failure || result.response == null) {
      await _showAnalysisFailure();
      return;
    }

    if (result.status == AiAnalysisStatus.lowConfidence) {
      Get.snackbar('Low confidence', result.message ?? 'Please review the result.');
    }

    final meal = _mealFromResponse(result.response!, description).copyWith(
      photoPath: resolvedPhotoPath,
    );
    Get.to(() => EditMealScreen(
          meal: meal,
          isNewMeal: true,
          selectedDate: DateTime.now(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xxxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildTopBar(),
                  const SizedBox(height: AppSpacing.lg),
                  ScanPreviewImage(imagePath: widget.imagePath),
                  const SizedBox(height: AppSpacing.lg),
                  ScanInputField(
                    hint: 'Meal name (optional)',
                    controller: _nameController,
                    height: AppSizes.scanInputHeight,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ScanInputField(
                    hint: 'Add notes or description (optional)',
                    controller: _notesController,
                    height: AppSizes.scanTextAreaHeight,
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  ScanPrimaryButton(
                    label: 'Analyze Meal',
                    icon: Icons.auto_awesome,
                    gradient: AppGradients.scanAnalyze,
                    onPressed: _isAnalyzing ? null : _analyze,
                    height: AppSizes.scanAnalyzeButtonHeight,
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
        ),
        Container(
          height: AppSizes.scanTopButtonSize,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(color: AppColors.outline, width: 1.08),
            boxShadow: AppShadows.cameraControl,
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Text('Retake', style: AppTextStyles.body16.copyWith(fontWeight: FontWeight.w500)),
              ),
              const SizedBox(width: AppSpacing.sm),
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

  Meal _mealFromResponse(AiResponse response, String? description) {
    final meal = Meal.fromAnswer(response.answer);
    if (description == null || description.trim().isEmpty) {
      return meal;
    }
    if (_nameController.text.trim().isNotEmpty) {
      return meal.copyWith(name: _nameController.text.trim());
    }
    return meal;
  }

  Future<void> _showAnalysisFailure() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Analysis failed'),
        content: const Text('We could not analyze this meal. You can retry or log it manually.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final photoPath = await _resolvePhotoPath();
              final meal = Meal(
                name: _nameController.text.trim(),
                ingredients: const [],
                timestamp: DateTime.now(),
                photoPath: photoPath,
              );
              Get.to(() => EditMealScreen(
                    meal: meal,
                    isNewMeal: true,
                    selectedDate: DateTime.now(),
                  ));
            },
            child: const Text('Manual entry'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final photoPath = await _resolvePhotoPath();
              final meal = Meal(
                name: _nameController.text.trim(),
                ingredients: const [],
                timestamp: DateTime.now(),
                photoPath: photoPath,
              );
              Get.to(() => FixResultScreen(
                    baseMeal: meal,
                    selectedDate: DateTime.now(),
                    isNewMeal: true,
                  ));
            },
            child: const Text('Try text fix'),
          ),
        ],
      ),
    );
  }

  Future<String?> _resolvePhotoPath() async {
    if (_persistedPhotoPath != null) return _persistedPhotoPath;
    final rawPath = widget.imagePath;
    if (rawPath == null || rawPath.isEmpty) return null;
    final persisted = await MediaStorage.persistMealPhoto(rawPath);
    if (persisted != null) {
      _persistedPhotoPath = persisted;
      return persisted;
    }
    if (await File(rawPath).exists()) {
      _persistedPhotoPath = rawPath;
      return rawPath;
    }
    return null;
  }
}
