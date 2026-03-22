import 'dart:io';

import 'package:diplomka/app_theme.dart';
import 'package:diplomka/controller/weight_entry_controller.dart';
import 'package:diplomka/generated/locale_keys.g.dart';
import 'package:diplomka/model/weight_entry.dart';
import 'package:diplomka/screens/logs/weight_log_sheet.dart';
import 'package:diplomka/utils/media_storage.dart';
import 'package:diplomka/widgets/custom_glass_app_bar.dart';
import 'package:diplomka/widgets/mesh_gradient_background.dart';
import 'package:diplomka/widgets/photo_action_popup.dart';
import 'package:diplomka/widgets/variable_blur_scroll_view.dart';
import 'package:diplomka/widgets/weight_progress_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WeightHistoryScreen extends StatelessWidget {
  const WeightHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.meshBase,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Stack(
          children: [
            VariableBlurScrollView(
              topBlurSigma: 52,
              topFadeHeight: 40,
              backgroundColor: Colors.transparent,
              fadeColor: AppColors.meshBase,
              backgroundWidget: const MeshGradientBackground(),
              padding: const EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.huge, AppSpacing.l, AppSpacing.mega + 42),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSizes.topBarHeight),
                  const SizedBox(height: AppSpacing.m),
                  Obx(() {
                    final entries = WeightEntryController.to.entries;
                    return Column(
                      children: [
                        WeightProgressCard(entries: entries),
                        const SizedBox(height: AppSpacing.m),
                        if (entries.isEmpty)
                          const _WeightHistoryEmptyState()
                        else
                          WeightHistoryListView(
                            entries: entries,
                            onEntryTap: (entry) => showWeightLogSheet(context, entry: entry),
                            onPhotoAction: (entry, photoPath) async {
                              debugPrint('[WeightHistory] onPhotoAction: entryId=${entry.id}, photoPath=$photoPath');
                              final updated = entry.copyWith(photoPath: photoPath, clearPhotoPath: photoPath == null);
                              debugPrint('[WeightHistory] updated entry photoPath: ${updated.photoPath}');
                              await WeightEntryController.to.saveEntry(updated);
                              debugPrint('[WeightHistory] saveEntry done, entries count: ${WeightEntryController.to.entries.length}');
                              final saved = WeightEntryController.to.entries.firstWhereOrNull((e) => e.id == entry.id);
                              debugPrint('[WeightHistory] saved entry photoPath from DB: ${saved?.photoPath}');
                            },
                          ),
                        const SizedBox(height: AppSpacing.huge),
                      ],
                    );
                  }),
                ],
              ),
            ),
            Positioned(
              top: 0,
              left: AppSpacing.l,
              right: AppSpacing.l,
              child: SafeArea(
                bottom: false,
                child: CustomGlassAppBar(
                  title: tr(LocaleKeys.profile_weight_history),
                  onBack: () => Get.back(),
                  actions: [
                    CustomGlassIconButton(
                      icon: Icons.add,
                      onPressed: () => showWeightLogSheet(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WeightHistoryListView extends StatelessWidget {
  const WeightHistoryListView({super.key, required this.entries, this.onEntryTap, this.onPhotoAction});

  final List<WeightEntry> entries;
  final ValueChanged<WeightEntry>? onEntryTap;
  final void Function(WeightEntry entry, String? photoPath)? onPhotoAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: entries
          .map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.m),
                child: _WeightHistoryEntryCard(
                  weight: _formatWeight(entry.weight),
                  date: _formatDate(context, entry.date),
                  photoFile: MediaStorage.existingMealPhotoFile(entry.photoPath),
                  onTap: onEntryTap == null ? null : () => onEntryTap!(entry),
                  onPhotoTap: onPhotoAction == null
                      ? null
                      : (cardContext) {
                          showPhotoActionPopup(
                            context: context,
                            targetContext: cardContext,
                            hasPhoto: entry.photoPath != null && entry.photoPath!.isNotEmpty,
                            onResult: (photoPath) => onPhotoAction!(entry, photoPath),
                          );
                        },
                ),
              ))
          .toList(),
    );
  }

  String _formatWeight(double value) {
    final isInt = value % 1 == 0;
    final formatted = value.toStringAsFixed(isInt ? 0 : 1);
    return '$formatted kg';
  }

  String _formatDate(BuildContext context, DateTime date) {
    return DateFormat('MMMM d, yyyy', context.locale.toString()).format(date);
  }
}

class _WeightHistoryEntryCard extends StatelessWidget {
  const _WeightHistoryEntryCard({required this.weight, required this.date, this.photoFile, this.onTap, this.onPhotoTap});

  final String weight;
  final String date;
  final File? photoFile;
  final VoidCallback? onTap;
  final void Function(BuildContext cardContext)? onPhotoTap;

  static const double _cardHeight = 80;
  static const double _thumbnailSize = 80;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.l),
        child: Container(
          height: _cardHeight,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.l),
            border: Border.all(color: AppColors.outline),
            boxShadow: AppShadows.cardSoft,
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              Material(
                color: AppColors.surfaceMuted,
                child: InkWell(
                  onTap: onPhotoTap == null ? null : () => onPhotoTap!(context),
                  child: SizedBox(
                    width: _thumbnailSize,
                    height: _thumbnailSize,
                    child: photoFile != null
                        ? Image.file(photoFile!, fit: BoxFit.cover, width: _thumbnailSize, height: _thumbnailSize)
                        : Icon(Icons.camera_alt_outlined, color: AppColors.textTertiary, size: AppSizes.iconLg),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.l),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(weight, style: AppTextStyles.title17.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(date, style: AppTextStyles.body15.copyWith(color: AppColors.textTertiary)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeightHistoryEmptyState extends StatelessWidget {
  const _WeightHistoryEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.listRowHeight,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.l),
        border: Border.all(color: AppColors.surface),
        boxShadow: AppShadows.cardSubtle,
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
      alignment: Alignment.center,
      child: Text(
        tr(LocaleKeys.weight_log_no_entries),
        style: AppTextStyles.body15.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}
